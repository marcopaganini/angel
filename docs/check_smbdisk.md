# Check_smbdisk Plugin

## Description

This plugin checks for disk conditions on NT or Samba shares. It uses the `du`
command of the `smbclient` utility to get the total and remaining blocks on the
share, converting that to a percentage.

Before using this plugin, you must have the Samba suite installed and working,
and you must define the following variables in `angel.conf`:

```
$main::Smbclient
```

Full pathname to smbclient utility supplied with Samba.

```
$main::Smb_user
```
Username to login to NT server.

```
$main::Smb_pass
```

Password to login to NT server.

## Parameters

This plugin accepts one NetBIOS name and multiple share names, each with its
own yellow and red thresholds.

The parameter line should be formatted as:

```
netbiosname!sharename spacespec!sharename spacespec
```

Where:

* **hostname**

   NetBIOS name of the NT or Samba server.

* **sharename**

   Share name. All share names must be listed explicitly to be checked, unlike
   the `Check_disk` module, which checks all filesystems on a Unix system.

* **spacespec**

   This defines how the plugin should interpret the various space conditions on
   the specified mountpoint. Its format is "pct_yellow pct_red". A share with
   more than `pct_yellow`% of used space will be reported as "yellow". A share
   with more than `pct_red`% will be flagged as "red". Only the first share at
   yellow or red is reported, the user is advised to list them in decreasing
   order of importance.

## Examples

```
fileserver!vol1 80 90!mail 60 75
```

This would check the shares `\\fileserver\vol1` and `\\fileserver\mail`.

## Author

Fraser McCrossan (fraserm@ichanneltech.com)
(based on the `Check_disk` module by Marco Paganini paganini@paganini.net)

