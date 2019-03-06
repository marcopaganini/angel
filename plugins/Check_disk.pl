#-----------------------------------------------------------------------------
#	Check_disk
#
#	Plug-in to report the disk conditions of a given host
#
#	Parameters:
#
#		hostname!ostype!fs spacespec!fs spacespec...
#
#		'hostname'
#			The host name
#
#		'ostype'
#			The operating system type. Currently supported types
#			are linux,sco32,sco50 and hpux10.
#
#		'fs'
#			Is the filesystem (use 'default' for all Filesystems)
#
#		'spacespec'
#			is in the form "pct_yellow pct_red". Every file system
#			with >=pct_yellow of used bytes will be flagged as 
#			yellow. If the used space >=pct_red, the result will
#			be a red condition.
#
#	Example parameters:
#
#		default 80 90!/cdrom 999 999!/home 60 70
#
#		Ignore the /cdrom filesystem (999% will never be reached),
#		warn yellow if the filesystem occupancy reaches 80% and
#		red if it reaches 90%. There's an exception for the /home
#		filesystem, in this case (yellow >= 60%, red >= 70%)
#
#	Version Log:
#		0.7 - Added support for Solaris and SunOs [Philippe Charnier]
#			- Added support for AIX [Norbert Gruener]
#			- Angel will now display all error conditions correctly
#			- Now uses the $main::Remote_cmd instead of rsh hardcoded
#
#       Updated May 11 1998 by Norbert E. Gruener: added ostype irix
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

sub Check_disk
{

	##
	##	Global values
	##

	my($Default_pct_yellow) = 90;	## Yellow condition at this percent...
	my($Default_pct_red)    = 95;	## Red condition at this...
	my($Default_tries)      = 5;  	## How many iterations...
	my($Default_timeout)    = 5;  	## Iteration timeout

	my ($hostname,$ostype,$param,$yellow,$red);
	my ($rcmdline,$mountpoint,%filesys,@dfoutput);
	my ($dfmount,$dfused,$tmp,$fsyellow,$fsred,$ret);
	my ($message,$red_alert,$yellow_alert);

	## Parse the commands...
	## and mount the 'filesys' hash

	$message = "OK";

	foreach $param (split('!',$_[0]))
	{
		## The first one is the hostname
		if (!defined($hostname))
		{
			$hostname = $param;
			next;
		}
		
		## The second one is the Operating system type
		if (!defined($ostype))
		{
			$ostype = lc($param);
			next;
		}

		($mountpoint,$yellow,$red) = split(' ',$param);

		## Ignore if invalid
		next if (!defined($mountpoint) || !defined($yellow) || !defined($red));

		$filesys{$mountpoint} = [$yellow,$red];
	}

	##
	##	We now execute the remote command using the 'ostype'
	##	parameter to call the correct command on the remote host
	##

	if    ($ostype eq "linux")  	{ $rcmdline = "df -v"; }
	elsif ($ostype eq "sco32")  	{ $rcmdline = "df -vi"; }
	elsif ($ostype eq "sco50")  	{ $rcmdline = "df -vi"; }
	elsif ($ostype eq "solaris")  	{ $rcmdline = "df -F ufs -k"; }
	elsif ($ostype eq "sunos")  	{ $rcmdline = "df -t 4.2"; }
	elsif ($ostype eq "aix") 	{ $rcmdline = "df"; }
        elsif ($ostype eq "irix")       { $rcmdline = "df"; }
	elsif ($ostype eq "hpux10") 	{ $rcmdline = "df -v | grep \"\\%\""; }
	else
	{
		return(-1,"Check_disk: Unknown ostype $ostype");
	}

	($ret,@dfoutput) = timeexec($Default_tries,$Default_timeout,"$main::Remote_cmd $hostname \"$rcmdline\"");

	if ($ret != 0)
	{
		return(-1,"Probable command timeout");
	}

	## Some heuristics here... If the output has only one
	## line, (or less) there's something wrong since df
	## always outputs at least one header line and one
	## mount point information line

	if ($#dfoutput < 1)
	{
		return(-1,"Check_disk: Empty output from df");
	}
		
	shift (@dfoutput);	## Remove the header line from 'df'

	foreach $param (@dfoutput)
	{
		chomp($param);

		## Parse the output of df -vi (or the equivalent command)

		if ($ostype eq "sco32" || $ostype eq "sco50")
		{
			($dfmount,$tmp,$tmp,$tmp,$tmp,$dfused,$tmp,$tmp,$tmp) = split(" ",$param);
		}
		elsif ($ostype eq "linux")
		{
			($tmp,$tmp,$tmp,$tmp,$dfused,$dfmount) = split(" ",$param);
		}
		elsif ($ostype eq "solaris" || $ostype eq "sunos")
		{
			($dfmount,$tmp,$tmp,$tmp,$dfused,$tmp) = split(" ",$param);
		}
		elsif ($ostype eq "aix")
		{
			($tmp,$tmp,$tmp,$dfused,$tmp,$tmp,$dfmount) = split(" ",$param);
		}
                elsif ($ostype eq "irix")
                {
                        ($tmp,$tmp,$tmp,$tmp,$tmp,$dfused,$dfmount) = split(" ",$param);
                }
		elsif ($ostype eq "hpux10")
		{
			($dfmount,$tmp,$tmp,$tmp,$dfused,$tmp,$tmp,$tmp) = split(" ",$param);
		}

		## If we have a specific entry in the filesys array, use it
		## If not, we test for a 'default' entry.
		## If none is found, we'll use our default hardcoded values.

		if (exists($filesys{$dfmount}))
		{
			$fsyellow = $filesys{$dfmount}[0];
			$fsred    = $filesys{$dfmount}[1];
		}
		elsif (exists($filesys{'default'}))
		{
			$fsyellow = $filesys{'default'}[0];
			$fsred    = $filesys{'default'}[1];
		}
		else
		{
			$fsyellow = $Default_pct_yellow;
			$fsred    = $Default_pct_red;
		}

		## Check the limits

		$dfused =~ tr/%//d;
		
		if ($dfused >= $fsred)
		{
			$message = "Mount point $dfmount is $dfused\% full\n";
			$red_alert = 1;
		}
		elsif ($dfused >= $fsyellow)
		{
			$message = "Mount point $dfmount is $dfused\% full\n";
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

	## If we're here, no errors were found

	return(0, $message);
}

1;
