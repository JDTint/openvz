#!/bin/bash

cd /vz/template/cache;

read -p "Container number: " cont
read -p "Hostname: " host
read -p "IP Address:" ip
read -p "DNS Server: " dns
read -p "Username: " user
echo "Password :"
read -s pass

vzctl create $cont --ostemplate centos-7-x86_64-minimal
vzctl set $cont --ipadd $ip --save
vzctl set $cont --nameserver $dns --save
vzctl set $cont --userpasswd $user:$pass --save
vzctl set $cont --hostname $host --save


vzctl start $cont
sleep 1

vzctl exec $cont 'yum -y install httpd && \
	yum -y install mod_security && \
	echo "<font size="55"> Test page '$cont'.</font>" >> /var/www/html/index.html' 


vzctl exec $cont 'cat << EOF >> /etc/httpd/modsecurity.d/activated_rules/rules_01.conf
# default action when matching rules
SecDefaultAction "phase:2,deny,log,status:406"

# "etc/passwd" is included in request URI
SecRule REQUEST_URI "etc/passwd" "id:'500001'"

# "test" is included in URI
SecRule REQUEST_URI "[Tt][Ee][Ss][Tt]" "id:'500002'"
EOF'

vzctl exec $cont 'sed -i "$ d" /etc/httpd/modsecurity.d/activated_rules/rules_01.conf && service httpd start'

vzctl exec $cont 'yum -y install screen && \ 
yum -y install perl && \
	yum -y install wget && \
	cd /home && \ 
wget -N http://httpupdate.cpanel.net/latest && \
	sh latest'

