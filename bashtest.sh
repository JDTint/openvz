#!/bin/bash

cd /vz/template/cache;

read -p "Container number: " cont
read -p "IP Address:" ip
read -p "DNS Server: " dns
read -p "Username: " user
echo "Password :"
read -s pass

vzctl create $cont --ostemplate centos-7-x86_64-minimal
vzctl set $cont --ipadd $ip --save
vzctl set $cont --nameserver $dns --save
vzctl set $cont --userpasswd $user:$pass --save

vzctl start $cont
sleep 1

vzctl exec $cont 'yum -y install httpd && \
service httpd start && \
echo "<font size="55">Test page '$cont'</font>" >> /var/www/html/index.html'

