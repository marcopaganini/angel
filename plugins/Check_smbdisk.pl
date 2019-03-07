#-----------------------------------------------------------------------------
#	Check_disk
#
#	Plug-in to report the disk conditions of an NT share using
#	the 'smbclient' program supplied with Samba
#
#	Parameters:
#
#		netbiosname!share spacespec!share spacespec...
#
#		'netbiosname'
#			The NETBios name of the NT (or Samba) server
#
#		'share'
#			Share name; the plugin will connect to
#			\\netbiosname\share and execute a "du" command
#			in smbclient
#
#		'spacespec'
#			is in the form "pct_yellow pct_red". Every share
#			with >=pct_yellow of used bytes will be flagged as
#			yellow. If the used space >=pct_red, the result will
#			be a red condition.
#
#	Example parameters:
#
#		fileserver!vol1 80 90!mail 60 75
#
#	Version Log:
#		0.1 - Initial version, based on the Check_disk plugin
#		      [Fraser McCrossan]
#
#	LEGAL STUFF:
#
#	The Angel Network Monitor
#	Copyright (C) 1998 Marco Paganini (paganini@paganini.net)
#
#	This program is free software; you can redistribute it and/or
#	modify it under the terms of the GNU General Public License
#	as published by the Free Software Foundation; either version 2
#	of the License, or (at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program; if not, write to the Free Software
#	Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
#	The Angel Network Monitor Copyright (C) 1998 Marco Paganini
#	This program comes with ABSOLUTELY NO WARRANTY;
#	This is free software, and you are welcome
#	to redistribute it under certain conditions; refer to the COPYING
#	file for details.
#------------------------------------------------------------------------------

require 5.002;
use strict;

sub Check_smbdisk
{

    open(SMB, ">smblog");
    print SMB "Start\n";
    ##
    ##	Global values
    ##

    my($Default_pct_yellow) = 90;	## Yellow condition at this percent...
    my($Default_pct_red)    = 95;	## Red condition at this...
    my($Default_tries)      = 5;  	## How many iterations...
    my($Default_timeout)    = 5;  	## Iteration timeout

    my ($netbiosname,$param,$yellow,$red);
    my ($smbcommand,$share,%filesys,@smboutput);
    my ($smbpct,$fsyellow,$fsred,$ret);
    my ($message,$red_alert,$yellow_alert);

    ## Parse the commands...
    ## and mount the 'filesys' hash

    $message = "OK";

    foreach $param (split('!',$_[0]))
    {
	## The first one is the netbiosname
	if (!defined($netbiosname))
	{
	    $netbiosname = $param;
	    next;
	}

	($share,$yellow,$red) = split(' ',$param);

	## Ignore if invalid
	next if (!defined($share) || !defined($yellow) || !defined($red));

	##
	##	We now connect to the share and run "du"
	##

	$smbcommand = "$main::Smbclient '\\\\$netbiosname\\$share' $main::Smb_pass -U $main::Smb_user -c du";
	print SMB $smbcommand;

	($ret,@smboutput) = timeexec($Default_tries,$Default_timeout,"$smbcommand");

	if ($ret != 0)
	{
	    return(-1,"Probable command timeout");
	}

	## Some heuristics here... If the output has less than
	## 3 lines, there's something wrong

	if ($#smboutput < 3)
	{
	    return(-1,"Check_smbdisk: Empty output from du");
	}

      PARAM: foreach $param (@smboutput)
      {
	  chomp($param);

	  ## Parse the output of du

	  if ($param =~/^\s*([0-9]+) blocks of size ([0-9]+)[^0-9]+([0-9]+) blocks available/) {
	      $smbpct = ($3 / $1) * 100;
	      print SMB "$smbpct\n";

	      ## If we have a specific entry in the filesys array, use it
	      ## If not, we test for a 'default' entry.
	      ## If none is found, we'll use our default hardcoded values.

	      ## Check the limits

	      if ($smbpct >= $red)
	      {
		  $message = sprintf "Drive containing share $share is %.1f%% full\n", $smbpct;
		  $red_alert = 1;
	      }
	      elsif ($smbpct >= $yellow)
	      {
		  $message = sprintf "Drive containing share $share is %.1f%% full\n", $smbpct;
		  $yellow_alert = 1;
	      }
	  }

	  if (defined($red_alert))
	  {
	      chop $message;
	      return(2, $message);
	  }
	  elsif (defined($yellow_alert))
	  {
	      chop $message;
	      return(1, $message);
	  }

      }
    }
    ## If we're here, no errors were found

    return(0, $message);
}

1;
