DCRON - DILLON'S LIGHTWEIGHT CRON DAEMON
========================================

This lightweight cron daemon aims to be simple and secure, with just enough
features to stay useful. It was written from scratch by Matt Dillon in 1994.
It's now developed and maintained by James Pryor.

In the author's opinion, having to combine a cron daemon with another daemon
like anacron makes for too much complexity. So the goal is a simple cron daemon
that can also take over the central functions of anacron.

Unlike other fatter cron daemons, though, this cron doesn't even try to manage
environment variables or act as a shell. All jobs are run with `/bin/sh` for
conformity and portability. We don't try to use the user's preferred shell:
that breaks down for special users and even makes some of us normal users
unhappy (for example, /bin/csh does not use a true O_APPEND mode and has
difficulty redirecting stdout and stderr both to different places!). You can,
of course, run shell scripts in whatever language you like by making them
executable with #!/bin/csh or whatever as the first line. If you don't like
the extra processes, just `exec` them.

If you need to set special environment variables, pass them as arguments to a
script.

The programs were written with an eye towards security, hopefully we haven't
forgotton anything. The programs were also written with an eye towards nice,
clean, algorithmically sound code. It's small, and the only fancy code is that
which deals with child processes. We do not try to optimize with vfork() since
it causes headaches and is rather pointless considering we're execing a shell
most of the time, and we pay close attention to leaving descriptors open in the
`crond` and close attention to preventing `crond` from running away.


DOWNLOADING
-----------

The project is hosted at [GitHub](https://github.com/ptchinster/dcron)
and the latest version can be downloaded from the
[tags page](https://github.com/ptchinster/dcron/tags).

COMPILING
---------

You must use a compiler that understands prototypes, such as GCC.

(1) The following compile-time defaults are configurable via
command-line assignments on the `make` line (they're shown here with
their default values):

	PREFIX=/usr/local         # where files will ultimately be installed
	SBINDIR = $(PREFIX)/sbin  # where crond will be installed
	BINDIR = $(PREFIX)/bin    # where crontab will be installed
	MANDIR = $(PREFIX)/share/man  # where manpages will be installed
	CRONTABS = /var/spool/cron/crontabs     # default dir for per-user crontabs
	CRONSTAMPS = /var/spool/cron/cronstamps # default dir
	SCRONTABS = /etc/cron.d   # default dir for system crontabs

	CRONTAB_GROUP = wheel     # who's allowed to edit their own crontabs?
	LOG_IDENT = crond         # syslog uses facility LOG_CRON and this identity
	TIMESTAMP_FMT = %b %e %H:%M:%S  # used if LC_TIME unset and logging to file

A few additional compile-time settings are defined in `defs.h`. If you find yourself
wanting to edit `defs.h` directly, try editing the `DEFS` line in the `Makefile` instead.

(2) Run make with your desired settings. For example:

	make PREFIX=/usr CRONTAB_GROUP=users

(3) If you're using the git version, you might also want to `make man`,
to be sure the manpages are updated. This requires 
[pandoc](http://johnmacfarlane.net/pandoc/).


INSTALLING
----------

(4) `make install` installs the files underneath PREFIX (by default, /usr/local).
If you're packaging, you can supply a DESTDIR argument here:

	make DESTDIR=/path/to/your/package/root install

Permissions will be as follows:

	-rwx------  0 root   root    32232 Jan  6 18:58 /usr/local/sbin/crond
	-rwsr-x---  0 root   wheel   15288 Jan  6 18:58 /usr/local/bin/crontab

Only users belonging to crontab's group (here "wheel") will be able to use it.
You may want to create a special "cron" group and assign crontab to it:

	groupadd cron
	chgrp cron /usr/local/bin/crontab
	chmod 4750 /usr/local/bin/crontab

(If the group already exists, you can specify it by supplying `CRONTAB_GROUP`
to the `make` or `make install` commands.)

Then add users to group `cron` when you want them to be able to install
or edit their own crontabs. The superuser is able to install crontabs for users
who don't have the privileges to edit their own.

You should schedule `crond` to run automatically from system startup, using
`/etc/rc.local` or a similar mechanism. `crond` automatically detaches. By default
it logs all events <= loglevel NOTICE to syslog.

The crontab files and timestamps are usually located in
`/var/spool/cron/cron{tabs,stamps}/` directories respectively.
These directories normally have permissions `755`.

Here is the superuser's crontab, created using `sudo crontab -e`:

	-rw-------  0 root   root      513 Jan  6 18:58 /var/spool/cron/crontabs/root

TESTING
-------

Use the crontab program to create a personal crontab with the following
two lines:

	* * * * *  date >> /tmp/test
	* * * * *  date

Check the log output of `crond` to ensure the cron entries are being
run once a minute, check `/tmp/test` to ensure the date is being
appended to it once a minute, and check your mail to ensure that `crond`
is mailing you the date from the other entry once a minute.

After you are through testing cron, delete the entries with `crontab -e`
or `crontab -d`.

EXTRAS
------

The following are included in the `extra/` folder. None of them are installed
by `make install`:

- `crond.rc`: This is an example rc script to start and stop `crond`.
   It could be placed in `/etc/rc.d` or `/etc/init.d` in suitable systems.
- `crond.conf`: This contains user-modifiable settings for `crond.rc`.
  The sample `crond.rc` expects to source this file from `/etc/conf.d/crond`.
- `run-cron`: This simple shell script is a bare-bones alternative to Debian's `run-parts`.
- `crond.service`: This is an example sysvinit service to start and stop `crond`.
  It could be placed in `/lib/systemd/system` in suitable systems.
- `root.crontab`: This is an example crontab to install for the root user, or to install
  in `/etc/cron.d`. It runs any executable scripts located in the directories
  `/etc/cron.{hourly,daily,weekly,monthly}`  at the appropriate times.
  This example uses the `run-cron` script mentioned above, and relies on you to
  create the /etc/cron.* directories.
- `prune-cronstamps`: `crond` never removes any files from your cronstamps directory.
  If usernames are abandoned, or cron job names are abandoned, unused files will accumulate
  there. This simple cronjob will prune any cronstamp files older than three months.
  It will run weekly if placed in `/etc/cron.d`.
- `crond.logrotate`: This is an example to place in `/etc/logrotate.d`. This config file assumes you
  run `crond` using `-L /var/log/crond.log`. If you run `crond` using `syslog` instead (the default),
  you may prefer to configure the rotation of all your syslog-generated logs
  in a single config file.
- `crontab.vim`: This makes vim handle backup files in way that doesn't interfere
  with crontab's security model.


BUG REPORTS, SUBMISSIONS
------------------------

For bug reports and code changes please use GitHub's integrated
[issues](https://github.com/dubiousjim/dcron/issues)
and [pull requests](https://github.com/dubiousjim/dcron/pull).

We aim to keep this program simple, secure, and bug-free, in preference to
adding features. Those advanced features we have added recently (such as
`@noauto`, `FREQ=` and `AFTER=` tags, advanced `cron.update` parsing) fit naturally
into the existing codebase.

Our goal is also to make this program compilable in as near to a C89-strict a
manner as possible. Less-portable features we're aware of are described in the
comments to `defs.h`. We'll reduce these dependencies as feasible.
Do let us know if any of them are an obstacle to using `crond` on your platform.

Changes to `defs.h`, whether to override defaults or to accommodate your platform,
should be made by a combination of a `-D` option in the `Makefile`
and an `#ifdef` for that option in `defs.h`.
Don't rely on pre-definitions made by the C compiler.

Prototypes for system functions should come from external include
files and NOT from `defs.h` or any source file. If no prototype exists for a
particular function, contact your vendor to get an update for your includes.

Note that the source code, especially in regard to changing the
effective user, is Linux specific (SysVish). We welcome any changes
in regard to making the mechanism work with other platforms.


CREDITS
-------

We use `concat`, a lightweight replacement for `asprintf`, in order to be more
portable. This was written by Solar Designer and is in the public domain.

LICENSE
-------

This project licensed under GNU General Public License 2 or any later version.
For the full license text please see the [COPYING file](./COPYING) or the
[GNU Project's website](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html).
