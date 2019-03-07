#-----------------------------------------------------------------------------
#	Check_ping
#
#	Plug-in to report the ICMP roundtrip time to a given host
#
#	Parameters:
#
#		hostname:Check_ping:hostaddress!PORT:LABEL:ttl_yellow!ttl_red!loss_yellow!loss_red
#
#		'hostname'
#			The host name
#
#		'PORT'
#			The port to connect to usually ICMP
#
#		'LABEL'
#			The label to use in the table usually PING
#
#		'ttl_yellow' and 'ttl_red'
#			The yellow and red thresholds for the roundtrip time,
#			respectively.
#
#		'loss_yellow' and 'loss_red'
#			The yellow and red thresholds for the percent of
#			packet loss.
#
#	Example parameters:
#
#		LABEL:100!200!5!15
#
#		Roundtrips above 100 (usually ms, depending on your
#		ping command output) will be flagged as yellow. Above
#		200ms will result in a red condition. Yellow for loss
#		rates above or equal to 5%, red above or equal to 15%.
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
#
#	0.7.3
#	Modified October 25 2002 by Matt A. Callihan
#	Fixed Check_Ping.pl to work with iputils-ss020124 and beyond.
#
#
#------------------------------------------------------------------------------

require 5.002;
use strict;

sub Check_ping
{
	##
	##	Global values
	##

	my($Default_tries)       = 10;	## 10 tries
	my($Default_timeout)     = 10;	## of 10 seconds each...
	
	my($Default_ttl_yellow)  = 100;	## Yellow condition at this percent...
	my($Default_ttl_red)     = 200;	## Red condition at this...
	my($Default_loss_yellow) = 5;	## Yellow if loss >= 5%
	my($Default_loss_red)    = 15;	## Red if loss >= 15%

	## Most OS/es use -c, as god wanted us to. Except, of course,
	## for HP, which uses -n.

	my($Default_ping_cmd)    = "ping -c 3 \%s";

	my ($hostname);
	my ($rcmdline,@output,$avg,$loss,$param);
	my ($ttl_yellow,$ttl_red,$loss_yellow,$loss_red,$tmp,$ret);

	## Parse the commands...
	## and mount the 'filesys' hash

	foreach $param (split('!',$_[0]))
	{
		## The first one is the hostname
		if (!defined($hostname))
		{
			$hostname = $param;
			next;
		}
		
		## TTL yellow
		if (!defined($ttl_yellow))
		{
			$ttl_yellow = lc($param);
			next;
		}

		## TTL red
		if (!defined($ttl_red))
		{
			$ttl_red = lc($param);
			next;
		}

		## Loss % yellow
		if (!defined($loss_yellow))
		{
			$loss_yellow = lc($param);
			next;
		}

		## Loss % red
		if (!defined($loss_red))
		{
			$loss_red = lc($param);
			next;
		}
	}

	## Basic sanity check -- Set values to default if not
	## defined (it may mean an error in the parameter line)

	if (!defined($ttl_yellow) || !defined($ttl_red))
	{
		$ttl_yellow = $Default_ttl_yellow;
		$ttl_red    = $Default_ttl_red;
	}

	if (!defined($loss_yellow) || !defined($loss_red))
	{
		$loss_yellow = $Default_loss_yellow;
		$loss_red    = $Default_loss_red;
	}

	## Format cmdline
	
	$rcmdline = sprintf($Default_ping_cmd, $hostname);
	
	($ret,@output) = timeexec($Default_tries,$Default_timeout,$rcmdline);
	if ($ret != 0)
	{
		return(-1,"Probable command timeout");
	}

	## We now start looking for the "% loss" output and
	## N/N/N values

	foreach $param (@output)
	{
		chomp($param);

		if (!defined($loss))
		{
		        # Deal with both ping format outputs
		        # 3 packets transmitted, 3 received, 0% loss, time 2023ms
		        # 3 packets transmitted, 3 packets received, 0% packet loss
			($loss) = ($param =~ m/received, (\d+)\% (?:packet )?loss/i);
		}

		if (!defined($avg))
		{
			($avg)  = ($param =~ m#[0-9\.]+?/([0-9\.]+?)/[0-9\.]+#i);
		}
	}
	## Sanity check 
        if (!defined($loss) || !defined($avg))
	{
		return(-1,"Cannot determine loss or average ttl time");
	}

	## Check the limits

	if ($loss >= $loss_red)
	{
		return(2,"Loss rate = $loss\% (red mark reached)");
	}
	elsif ($loss >= $loss_yellow)
	{
		return(1,"Loss rate = $loss\% (yellow mark reached)");
	}
	elsif ($avg >= $ttl_red)
	{
		return(2,"Roundtrip average = $avg (red mark reached)");
	}
	elsif ($avg >= $ttl_yellow)
	{
		return(1,"Roundtrip average = $avg (yellow mark reached)");
	}
	else
	{
		return(0,"OK");
	}
}

1;
