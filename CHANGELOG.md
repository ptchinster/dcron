# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] (git)

### Added

- `extra/crond.service` for systemd. Thanks to Miklos Vajna.

### Fixed

- Documentation and error message updates.

### Changed

- Numeric loglevels specified by `crond -l <level>` weren't being validated.
  Now we no longer accept numeric loglevels; they must be specified
  symbolically. Thanks to Rogutės Sparnuotos.
- Continued portability improvements. Makefile now uses `-lbsd-compat`.
  Factored allocation and string calls to `utils.c`.
- Many internal changes and annotations to pass splint review.

## [4.6] - 2024-05-09

### Added

- PID file when run in daemon mode.

### Fixed

- Several bugs, both performance and output issues

### Changed

- Took over ownership of project, since last version was over a decade ago. Changed associated URLs.
- Hardened CFLAGS and changed linking process. No idea when last eyes were on this with security in mind.
- Documentation updates


## [4.5] - 2011-05-01

Thanks for testing and feedback: Feifei Jia, Spider.007, Ray Kohler,
Igor Zakharoff, Edward Hades, and Joe Lightning.

### Fixed

- Some cron jobs were running multiple times. Now we make sure not to
  ArmJobs that are already running; and not to resynchronize while jobs are
  running; and to poll the DST setting. (Fixes Arch FS#18681; thanks to Vincent
  Cappe and Paul Gideon Dann for identifying the second issue; and Tilman
  Sauerbeck for identifying the third.)
- @monthly was wrongly being parsed the same as @yearly (fixes Arch
  FS#19123). Thanks to Peter Johnson, Paul Gideon Dann, and Tilman Sauerbeck.
- Running `/etc/rc.d/crond start` after startup could leak unwanted
  environment into cronjobs; now we force crond to start in empty env
  (fixes Arch FS#22085). Thanks to Mantas.
- Set LOGNAME environment variable in cronjobs. Requested by Michael
  Trunner; fixes Arch FS#18338.
- extra/crond.logrotate now correctly gets pid from /var/run/crond.pid
  (fixes Arch FS#18039). Thanks to Kay Abendroth, revel, and Chlump Chatkupt.
- `extra/crontab.vim` works around an issue where vim's writebackup would
  interfere with crontab's security model (addresses Arch FS#18352).
  Thanks to Armadillo and Simon Williams.
- Makefile uses `$LDFLAGS` (fixes Arch FS#23784).
  Thanks to Kristoffer Tidemann and Mike Frysinger.

### Changed

- `extra/crond.rc`: now uses `$CROND_ARGS` from `/etc/conf.d/crond`; sample included
  as `extra/crond.conf`. Suggested by Eric Bélanger.
- `extra/prune-cronstamps` now only deletes files, and is formatted as a
  @weekly crontab. Thanks to Alec Moskvin <alecm@gmx.com>.
- defs.h sets default locations for CRONTABS and CRONSTAMPS beneath /var/spool/cron/,
  as in earlier versions of dcron.
- Documentation updates.


## [4.4] - 2010-01-17

Thanks to Juergen Daubert for more testing and suggestions.

### Added

- `extra/prune-cronstamps`
- `extra/` documentation

### Fixed

- Finished mailjobs were being left as zombie processes.
- When using crond with logging-to-file, user jobs could only log some
  events if they had write access to the log. Fixed this by having crond
  keep a file descriptor open to the log; also added a SIGHUP handler
  to make crond re-open the logfile. The sample logrotate script now
  sends that signal.

### Changed
- More sensible command-line parsing by crontab.
- general improvement of README and manpages.
- Portability improvements, and defs.h now has fuller comments about
  requirements.
- Makefile improvements: `make` now caches variables for `make install`;
    don't stomp CFLAGS environment variable, and added BINDIR,SBINDIR,MANDIR.


## [4.3] - 2010-01-11

Thanks to Juergen Daubert for testing and suggestions.

### Added

- Makefile: `CRONTAB_GROUP` for `make install`
### Changed

- Internal refactoring to make buffer overflow checks
  clearer and portability issues more explicit.
- Made file argument to `-L` mandatory; optional args to
  `getopt` needs GNU extensions.
- Makefile: renamed TIMESTAMPS -> CRONSTAMPS.


## [4.2] - 2010-01-11

### Changed

- Makefile tweaks.
- Moved more constants to #defines.

## [4.1] - 2010-01-10

### Fixed

- Parsing some numeric fields in crontabs.
	(Terminus of range wasn't being modded.)
- Fixed Makefile permissions on `crond` and `crontab` binaries.
- Updated Makefile to make it easier to customize timestamps at configure
  time. Also, if LC_TIME is defined when crond runs, we use that instead of
  compiled-in default (for logging to files, to customize syslog output use
  syslog-ng's 'template' command).


## [4.0] - 2010-01-06

### Added

- Applied "Daniel's patch" from dcron 3.x tarballs to enable logging to
  syslog or files. Added further logging improvements.
- Options: `-m user@host` & `-M mailer`.
- Various crontab syntax extensions, including "2nd Monday of every month",
  @reboot, @daily, and finer-grained frequency specifiers.
- Jobs can wait until AFTER other jobs have finished.
- Enhanced parsing of cron.update file, to make it possible for scripts to
  interact with a running crond in limited ways.

### Changed

- Jim Pryor took over development; folded in changes from his fork "yacron"
- Various internal changes
- Updated Makefile, manpage buildchain, and docs

## [3.2]

### Fixed

- A minor bug: remove the newline terminating a line only if there
  is a newline to remove.

## [3.1]

By VMiklos and Matt Dillon.

### Added

- Support for `root-run` crontab files in `/etc/cron.d`

### Changed
- Rewrote a good chunk of the crontab file management code.

## [3.0]

### Fixed

- `/tmp` race and misc cleanups from Emiel Kollof <emiel@gamepoint.net>

## [2.9]

### Changed

- Modernize the code; remove `strcpy()` and `sprintf()` in favor of `snprintf()`.
  (Supplied by Christine Jamison <technobabe@mail.nwmagic.net>)

## [2.8]

### Fixed

- A bug found by Christian HOFFMANN:  newline removal was broken
  for lines that began with whitespace, causing crontab lines
  to be chopped off.

## [2.7]

- Committed changes suggested by Ragnar Hojland Espinosa <ragnar@redestb.es>

### Fixed

- A few printfs,

### Removed

- `strdup()` function
  ( strdup() is now standard in all major clib's )

## [2.4-2.6]
    ( changes lost )

## [2.3]

### Fixed

- dillon: bug in `job.c` -- if `ChangeUser()` fails, would return
  from child fork rather then exit!  Oops.

## [2.2]:w

- dillon: Initial release

