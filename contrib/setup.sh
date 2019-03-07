#!/bin/sh
clear
restartgrace=graceful
reloadit=reload
echo $""
echo $"Angel Setup By: Matt A. Callihan"
echo $""
echo $"Please Back Up Your Angel Configuration Files."
echo $""
echo $"Use Ctrl+c To Abort Or Press Any Key To Continue."
echo $"
read angelpause
clear
echo $"Please Wait ..."
echo $""
echo $"Enter The Full System Path To Your httpd.conf file."
echo $""
echo $"Default = /etc/httpd/conf/httpd.conf"
read httpdconfigure
if [ "$httpdconfigure" = "" ]; then
httpdconfigure=/etc/httpd/conf/httpd.conf
fi
mkdir /usr/local/angel/
mv * /usr/local/angel/
printf "\n \n #############Angel Settings############# \n Alias /angel /usr/local/angel/html \n <Directory /usr/local/angel/html> \n Order allow,deny \n Allow from all \n </Directory> \n ########################################" >> "$httpdconfigure"
echo $""
echo $"$httpdconfigure Udated"
echo $""
echo $"Enter The Full Path To Your httpd Command."
echo $""
echo $"Default = /etc/rc.d/init.d/httpd"
read restartwww
if [ "$restartwww" = "" ]; then
restartwww=/etc/rc.d/init.d/httpd
$restartwww $restartgrace
fi
echo $""
echo $"Enter The Full System Path To Your crontab file."
echo $""
echo $"Default = /etc/crontab"
read crontabconfigure
if [ "$crontabconfigure" = "" ]; then
crontabconfigure=/etc/crontab
fi
printf "\n \n #################################Angel Settings############################### \n -0,20,40 * * * *	root	perl /usr/local/angel/bin/angel \n ##############################################################################" >> "$crontabconfigure"
echo $""
echo $"$crontabconfigure Updated"
echo $""
echo $"Enter The Command To Reload Crond."
echo $""
echo $"Default = /etc/rc.d/init.d/crond reload"
read restartcron
if [ "$restartcron" = "" ]; then
restartcron=/etc/rc.d/init.d/crond
$restartcron $reloadit
fi
echo $""
echo $"Step One Completed Angel Installed And Running."
echo $""
echo $"Installing Necessary Perl Modules."
echo $""
echo $"Please Wait ..."
echo $""
perl -MCPAN -e 'install Proc::Simple'
echo $""
echo $"Installation Completed."
echo $""