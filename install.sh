#!/bin/bash

#
# Check the bash shell script is being run by root
#
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#
# Install Nginx
#
yum install epel-release -y

yum install nginx -y

yes | cp -rf ./nginx/nginx.conf /etc/nginx/
cp ./nginx/default.conf /etc/nginx/conf.d/

systemctl start nginx

systemctl enable nginx

systemctl restart nginx

#
# Install mariadb
#

yum -y install mariadb-server mariadb

systemctl start mariadb

yum -y install expect

NEW_MYSQL_PASSWORD="3N9Rs8MEoqd0Ybo"
CURRENT_MYSQL_PASSWORD=""

SECURE_MYSQL=$(expect -c "
set timeout 3
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$CURRENT_MYSQL_PASSWORD\r\"
expect \"root password?\"
send \"y\r\"
expect \"New password:\"
send \"$NEW_MYSQL_PASSWORD\r\"
expect \"Re-enter new password:\"
send \"$NEW_MYSQL_PASSWORD\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

#
# Execution mysql_secure_installation
#
echo "${SECURE_MYSQL}"

yum -y remove expect

systemctl enable mariadb

systemctl restart mariadb

#
# Install php7.0
#
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm

yum -y install yum-utils

yum-config-manager --enable remi-php70   [Install PHP 7.0]

yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip \
	php-fileinfo php-fpm php-json php-simplexml php-bcmath php-mbstring php-xml php-imagick

yes | cp -rf ./php/php.ini /etc/
yes | cp -rf ./php/www.conf /etc/php-fpm.d/

systemctl start php-fpm

systemctl enable php-fpm

cp /usr/share/nginx/html/* /var/www/html/
