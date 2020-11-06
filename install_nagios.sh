#!/bin/bash

if [ ! -d "nagios" ]; then
  mkdir nagios
fi

cd nagios

if [ ! -f "/usr/bin/wget" ]; then
yum -y install wget
fi

if [ ! -f nagios-4.4.6.tar.gz ]; then 
wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.4.6.tar.gz &
fi

if [ ! -f nagios-plugins-2.3.3.tar.gz ]; then 
wget http://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz &
fi 

/usr/bin/id nagios 

if [ $? ]; then
useradd nagios
fi

/usr/bin/getent group nagcmd

if [ $? ]; then
groupadd nagcmd
fi

exit
usermod -a -G nagcmd nagios

usermod -a -G nagios,nagcmd apache


yum install -y httpd php gcc glibc glibc-common gd gd-devel make net-snmp unzip 

tar xvfz nagios-4.4.6.tar.gz &

tar xvfz nagios-plugins-2.3.3.tar.gz &

cd nagios-4.4.6

./configure --with-command-group=nagcmd

make all

make install

make install-init

make install-config

make install-commandmode

make install-webconf

cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/

chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers

/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

/etc/init.d/nagios start

/etc/init.d/httpd start

if [ ! -f "" ]; then
  echo "nagiosadmin:hAYh0VdO4gOwQ" > /usr/local/nagios/etc/htpasswd.users
fi

cd ../nagios-plugins-2.3.3

./configure --with-nagios-user=nagios --with-nagios-group=nagios

make

make install 

chkconfig --add nagios

chkconfig --level 35 nagios on

chkconfig --add httpd

chkconfig --level 35 httpd on

/etc/init.d/nagios restart

/etc/init.d/httpd restart

