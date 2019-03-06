#------------------------------------------------------------------------------
#	Check_tcp
#
#	This plugin will check for tcp connections.
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
#	Revision log:
#
#	0.6 - 18/Mar/1998 - (Marco paganini)
#		Complete rewrite using IO::Socket. Got rid of
#		the annoying timeout problem using the regular
#		Socket module.
#------------------------------------------------------------------------------

require 5.002;
use strict;
use IO::Socket;
use Proc::Simple;

sub Check_tcp
{
	## Global

	my ($Default_timeout) = 20;		## 20 seconds to abort connection
	my ($remote,$service) = split("!", $_[0]);
	my ($sock);

	###

	$sock = IO::Socket::INET->new(PeerAddr => $remote,
								  PeerPort => $service,
								  Proto    => 'tcp',
								  Timeout  => $Default_timeout);

	if (!defined($sock))
	{
		return (2,"Connection refused or timeout [$service/tcp]");
	}
	else
	{
		return (0,"OK");
	}
}
1;
