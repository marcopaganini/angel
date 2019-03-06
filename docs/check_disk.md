# Check Disk Plugin

## Description

This plugin checks for disk conditions on other hosts. It uses the rsh command
to grab the output of 'df' on the remote unix system. Its behavior can be
controlled by parameters (See Parameters below).

## Parameters

This plugin accepts many options allowing a reasonable degree of control over
its operation. The user may set new values for the yellow and red thresholds,
or even ignore entirely a filesystem (mounted CDROMs are good candidates for
this).

The parameter line should be in the format:

```
hostname!ostype!fs spacespec!fs spacespec...
```

Where:

* **hostname**: The host name. The system must be able to locate this box by
  this name, or it  won't work.

* **ostype**: The operating system type. Currently supported types are
  linux,sco32,sco50 and hpux10.

* **fs**: The desired mount point. Angel will check this mountpoint and report
  any "out of order" space conditions on it. These conditions are calculated
  based on the "spacespec" parameter below.  You may also use the
  meta-filesystem "default". This will change the default values for all
  filesystems. You may change the default and override these values for
  specific filesystems.

* **spacespec**: This defines how the plugin should interpret the various space
  conditions on the specified mountpoint. Its format is `pct_yellow pct_red`.
  Every filesystem with more than `pct_yellow%` of used space will be reported
  as "yellow". Filesystems with more than `pct_red%` will be flagged as "red".

  It may be a good idea to use "999 999" for cdrom filesystems. Since there
  won't ever be a 999% filesystem, it will always report as "green".

## Examples

```
default 80 90!/cdrom 999 999!/home 60 70
```

Ignore the /cdrom filesystem (999% will never be reached), warn yellow if the
filesystem occupancy reaches 80% and red if it reaches 90%. There's an
exception for the /home filesystem, in this case (yellow >= 60%, red >= 70%)

```
/u1 50 90!/u2 70 80!/u3 75 85
```

Different defaults will be used for the /u1, /u2 and /u3 filesystems. Every
other filesystem will use the hardwired defaults (see the plugin source code
for more details).

## Bugs and other unpleasant things

Some things definitely need more work in this plugin:

* Many unix flavors do not use "rsh" as the "remote shell" command. HPUX, for
  instance, uses remsh whereas SCO Unix uses the "rcmd" command. Ideally, the
  plugin would check its host OS and adjust accordingly.

* There's no support for SSH, being this a very old program. It's trivial to add.

* The parameter format just plain sucks. It's hard to read between all those
  exclamation signs.
