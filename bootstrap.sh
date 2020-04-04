#!/usr/bin/env bash

# Must be root
if [ "$EUID" -ne 0 ]; then
	echo 'ERROR: Run as root'
	exit
fi

# Standard dependencies
dnf install -y git httpie mariadb mariadb-server mariadb-devel nginx certbot certbot-nginx

# nginx
mkdir -p /data/www/
cp config/nginx.conf /etc/nginx/
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled
systemctl enable nginx
systemctl start nginx

# mariadb
systemctl enable mariadb.service
systemctl start mariadb.service
/usr/bin/mysql_secure_installation

# SELinux
setsebool -P httpd_can_network_connect on
chcon -Rt httpd_sys_content_t /data/www

# certbot cron
cronline="0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew -q"
(crontab -l; echo "$cronline") | uniq - | crontab -

# Done
dt=$(date +%Y=%m-%d)
echo $dt > /bootstrapped
