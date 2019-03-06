# Check_load Plugin

## Description

This plugin checks for system load conditions on other hosts. It uses the rsh
command to grab the output of 'uptime' on the remote unix system. Its behavior
can be controlled by parameters (See Parameters below).

## Parameters

The program calls "uptime" on the remote hosts and grabs the "last 1 minute"
counter from the command's output. It then uses the user specified (or
hardwired, if no parameters are passed) thresholds to decide if it should emit
a "yellow" or a "red" condition.

The parameter line should be in the format:

```
hostname!yellow_threshold!red_threshold
```

Conditions under `yellow_threshold` will always be flagged as "green". System loads between `yellow_threshold` and `red_threshold` will be yellow. Anything above `red_threshold` will generate a "red" condition.

Examples:

```
kraken.monsters.com!2!3
```

Warns yellow if the load of kraken.monsters.com exceeds 2. Warns red if the load exceeds 3.

## Bugs and other unpleasant things

* Only the "last 1 minute" counter is considered. It would be handy if the
  plugin could check the other counters and issue warnings based on "load
  trends".

* There's no support for SSH, being this an old program, but it should be
  trivial to add.
