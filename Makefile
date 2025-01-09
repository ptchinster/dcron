# Makefile for Dillon's crond and crontab
VERSION = 4.5

# these variables can be configured by e.g. `make SCRONTABS=/different/path`
PREFIX = /usr/local
CRONTAB_GROUP = wheel
SCRONTABS = /etc/cron.d
CRONTABS = /var/spool/cron/crontabs
CRONSTAMPS = /var/spool/cron/cronstamps
# used for syslog
LOG_IDENT = crond
# used for logging to file (syslog manages its own timestamps)
# if LC_TIME is set, it will override any compiled-in timestamp format
TIMESTAMP_FMT = %b %e %H:%M:%S
SBINDIR = $(PREFIX)/sbin
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man

-include config


SHELL = /bin/sh
INSTALL = install -o root
INSTALL_PROGRAM = $(INSTALL) -D
INSTALL_DATA = $(INSTALL) -D -m0644 -g root
INSTALL_DIR = $(INSTALL) -d -m0755 -g root
CFLAGS ?= -O2
CFLAGS += -Wall -Wextra -Wstrict-prototypes -Wno-missing-field-initializers -Wfloat-equal -fstack-protector-all -Wformat-security -Wformat=2 -fPIE 
CFLAGS += -Wl,-z,nodump -Wl,-z,noexecstack -Wl,-z,noexecheap -Wl,-z,relro -Wl,-z,now -Wl,-z,nodlopen -Wl,-z,-pie
CFLAGS += -Wno-format-nonliteral -Wno-sign-compare
SRCS = src/main.c src/subs.c src/database.c src/job.c src/concat.c src/chuser.c
OBJS = build/main.o build/subs.o build/database.o build/job.o build/concat.o build/chuser.o
TABSRCS = src/crontab.c src/chuser.c
TABOBJS = build/crontab.o build/chuser.o
PROTOS = build/protos.h
LIBS =
LDFLAGS =
DEFS =  -DVERSION='"$(VERSION)"' \
		-DSCRONTABS='"$(SCRONTABS)"' -DCRONTABS='"$(CRONTABS)"' \
		-DCRONSTAMPS='"$(CRONSTAMPS)"' -DLOG_IDENT='"$(LOG_IDENT)"' \
		-DTIMESTAMP_FMT='"$(TIMESTAMP_FMT)"'

# save variables needed for `make install` in config
all: protos.h crond crontab ;
	rm -f config
	echo "PREFIX = $(PREFIX)" >> config
	echo "SBINDIR = $(SBINDIR)" >> config
	echo "BINDIR = $(BINDIR)" >> config
	echo "MANDIR = $(MANDIR)" >> config
	echo "CRONTAB_GROUP = $(CRONTAB_GROUP)" >> config
	echo "SCRONTABS = $(SCRONTABS)" >> config
	echo "CRONTABS = $(CRONTABS)" >> config
	echo "CRONSTAMPS = $(CRONSTAMPS)" >> config

protos.h: $(SRCS) $(TABSRCS)
	mkdir -p build/ out/ # for later
	fgrep -h Prototype $(SRCS) $(TABSRCS) > $(PROTOS)

crond: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ $(LIBS) -o out/crond

crontab: $(TABOBJS)
	$(CC) $(CLFAGS) $(LDFLAGS) $^ -o out/crontab

build/%.o: src/%.c src/defs.h $(PROTOS)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $(DEFS) $< -o $@

install:
	$(INSTALL_PROGRAM) -m0700 -g root crond $(DESTDIR)$(SBINDIR)/crond
	$(INSTALL_PROGRAM) -m4750 -g $(CRONTAB_GROUP) crontab $(DESTDIR)$(BINDIR)/crontab
	$(INSTALL_DATA) out/man/crontab.1 $(DESTDIR)$(MANDIR)/man1/crontab.1
	$(INSTALL_DATA) out/man/crond.8 $(DESTDIR)$(MANDIR)/man8/crond.8
	$(INSTALL_DIR) $(DESTDIR)$(SCRONTABS)
	$(INSTALL_DIR) $(DESTDIR)$(CRONTABS)
	$(INSTALL_DIR) $(DESTDIR)$(CRONSTAMPS)

clean: force
	rm -rf out/ build/ config

force: ;

man: force
	mkdir -p out/man/
	-pandoc -t man -f markdown -s man/crontab.md -o out/man/crontab.1
	-pandoc -t man -f markdown -s man/crond.md -o out/man/crond.8

# for maintainer's use only
TARNAME = /home/abs/_dcron/dcron-$(VERSION).tar.gz
dist: clean man
	bsdtar -cz --exclude repo/.git -f $(TARNAME).new -s'=^repo=dcron-$(VERSION)=' -C .. repo
	mv -f $(TARNAME).new $(TARNAME)
