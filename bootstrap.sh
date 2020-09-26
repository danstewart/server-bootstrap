#!/usr/bin/env bash

# Must be root
if [[ "$EUID" != 0 ]]; then
	echo 'ERROR: Run as root'
	exit
fi


# Users
echo "== Creating Users and Groups =="
declare -A users=( ["dstewart"]=1 )

groupadd code

for user in ${!users[@]}; do
	useradd "$user"
	
	usermod -a -G code "$user"
	if [[ ${users[$user]} == 1 ]]; then
  		usermod -aG wheel "$user"
	fi
	
	# Copy authorized keys
	mkdir -p /home/$user/.ssh
	cp /root/.ssh/authorized_keys /home/$user/.ssh/
	chown ${user}:${user} -R /home/$user/.ssh
	chmod 700 /home/$user/.ssh
	chmod 600 /home/$user/.ssh/authorized_keys
	
	echo "Please set a password for $user: "
	passwd "$user"
done


# SSH Config
echo "== Configuring ssh =="
printf "Port 22\nPermitRootLogin no\nAllowUsers dstewart\n" >> /etc/ssh/sshd_config
systemctl restart sshd


# Standard dependencies
echo "== Updating and installing dependencies =="
dnf update -y
dnf install -y git vim cronie httpie mariadb mariadb-server mariadb-devel nginx certbot certbot-nginx podman


# nginx
echo "== Configuring nginx =="
mkdir -p /data/www/
curl https://raw.githubusercontent.com/danstewart/server-bootstrap/master/config/nginx.conf -o /etc/nginx/nginx.conf
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled
systemctl enable nginx
systemctl start nginx
chown -R nginx:nginx /data/www
usermod -a -G code nginx


# set up code dir
echo "== Creating /code =="
mkdir -p /code
chgrp -R code /code
chown g+s /code


# SELinux
echo "== Configuring SELinux =="
chcon -Rt httpd_sys_content_t /code
chcon -Rt httpd_sys_content_t /data/www


# mariadb
echo "== Configuring mariadb =="
systemctl enable mariadb.service
systemctl start mariadb.service
/usr/bin/mysql_secure_installation


# Cron
echo "== Adding cron tasks =="
sudo systemctl enable crond
sudo systemctl start crond
cronline="0 0 1,15 * * python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew -q"
(crontab -l 2>/dev/null; echo "$cronline") | uniq - | crontab -


# Done
dt=$(date +%Y-%m-%d)
echo $dt > /bootstrapped
echo "== Done =="
