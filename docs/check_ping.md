# Check_ping Plugin

## Description

This plugin checks for roundtrip times and packet loss conditions using your OS
ping command. You can set alarms based on roundtrip times and percent of
packets lost during the test.

## Parameters

The parameter line should be in the format:

```
hostname!ttl_yellow!ttl_red!loss_yellow!loss_red
```

Where:

**ttl_yellow**<br>
**ttl_red**<br>

   These parameters control the yellow and red thresholds based on the
   roundtrip times. TTLs above `ttl_yellow` (but below `ttl_red`) result in an
   yellow alert.  TTLs above `ttl_red` will always result in a red condition.

**loss_yellow**<br>
**loss_red**<br>

   Warn yellow if the loss of packets is >= `loss_yellow`%. Warn red if the loss
   of packets if >= `loss_red`%.

Example

```
haha.hehe.com!100!200!5!15
```

Warns yellow if the roundtrip time to haha.hehe.com exceeds 100ms (I'm assuming
here your PING command uses milisseconds, as most do). Warns red if it exceeds
200ms. Also, We'll get an yellow alert if more than 4% of our packets gets lots
during the connection, and a red alert if more than 14% gets lost.
