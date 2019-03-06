#------------------------------------------------------------------------------
#	Check_load
#
#	ANGEL Plug-in to report the load conditions of a given host
#
#	Parameters:
#
#		hostname!load_yellow!load_red
#
#		'hostname'
#			The host name
#
#		'load_yellow'
#			Loads above load_yellow (but below load_red) will be
#			flagged as 'yellow'
#
#		'load_red'
#			Loads above load_red will always be flagged as 'red'.
#
#	BUGS:
#		The program uses the information gathered from the last
#		1 minute (uptime)
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
#	Version Log:
#		0.7 - Now uses the $main::Remote_cmd instead of rsh hardcoded
#
#       Updated May 11 1998 by Norbert E. Gruener: cleaned up local variables
#------------------------------------------------------------------------------

require 5.002;
use strict;

sub Check_load
{
	##
	##	Global values
	##

	my($Default_yellow)  = 2;	## Yellow condition...
	my($Default_red)     = 3;	## Red condition at this...
	my($Default_tries)   = 6;	## Number of tries
	my($Default_timeout) = 5;	## Timeout (in seconds)

	my ($hostname,$yellow,$red);
	my ($upoutput);
	my ($min1,$min5,$min10);
	my ($ret);

        ## Parse the plugin parameters...

	($hostname,$yellow,$red) = split('!',$_[0]);

	## Set yellow and red to default values if they're not present

	$yellow = $Default_yellow if (!defined($yellow));
	$red    = $Default_red    if (!defined($red));

	##
	##	We now execute the remote command 'uptime'
	##

	($ret,$upoutput) = timeexec($Default_tries,$Default_timeout,"$main::Remote_cmd $hostname \"uptime\"");

	## Check the return code.

	if ($ret != 0)
	{
		return(-1, "Check_load: Probable command timeout");
	}

	if (!($upoutput =~ m/average:[ ]*([0-9\.]+),[ ]*([0-9\.]+),[ ]*([0-9\.]+)/))
	{
		return(-1, "Check_load: Cannot parse uptime output");
	}

	($min1,$min5,$min10) = ($1,$2,$3);

	if ($min1 >= $red)
	{
		return(2,"Load $min1 exceeds $red");
	}
	elsif ($min1 >= $yellow)
	{
		return(1,"Load $min1 exceeds $yellow");
	}

	## If we're here, no errors were found

	return (0,"OK");
}
1;
