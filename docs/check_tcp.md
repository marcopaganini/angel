# Check_tcp Plugin

## Description

This plugin will try to open a given tcp port on a given host. The program will
generate a "green" condition if the connection is successful or a "red"
condition otherwise.

## Parameters

All we needs here is the remote host and remote port to open. The parameter line format is:

```
remote_host!remote_port
```

You can use a numeric value for the port or a valid service name (check
`/etc/services` to make sure the service is declared).

Example

```
spektr.local!smtp
```

Check host "spektr.local", port smtp (25). Note that the program will
automatically convert the service name to the correct service number.

## Bugs and other unpleasant things

A few things definitely need more work in this plugin. In particular, the
script sends nothing to the port. Ideally, there would be a "send/expect"
option.
