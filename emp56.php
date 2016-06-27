#!/bin/sh

######
######	Installation Example) emp56 user password
######    After this script, you must edit nginx for extra configuration
######

# Locale. It prevent error message on shell.
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_COLLATE=C
export LC_CTYPE=en_US.UTF-8



# Default User Setting.
# /home/thruthesky/www will be the default server root.
# user_password is the default password of database root.
read -p "emp username: " user
read -s -p "emp password: " user_password

# TEST
# Uninstalling Enginx, PHP, MariaDB and install it again.
# Comment out this on productio mode. ( or just leave it. It won't take any harm )
userdel -r $user
rm -rf phpMyAdmin*
systemctl stop php-fpm
systemctl stop mysql
yum remove -y MariaDB-server MariaDB-client
rm -rf /var/lib/mysql
rm -f /etc/my.cnf

nginx -s stop
rm -f /etc/nginx/default.d/php.conf


# INSTALLATION BEGINS
#
yum update -y
yum install -y expect
yum install -y unzip



# Create user account
useradd $user
expect <<- EOE
spawn passwd $user
expect "password: "
send "$user_password\r"
expect "password: "
send "$user_password\r"
expect eof
EOE

# Create phpinfo.php file
#
chmod 755 /home/$user
mkdir /home/$user/www
echo "<?php" > /home/$user/www/phpinfo.php
echo "phpinfo();" >> /home/$user/www/phpinfo.php


# Install phpMyAdmin on /home/$user/www/phpMyAdmin
#
wget https://files.phpmyadmin.net/phpMyAdmin/4.6.3/phpMyAdmin-4.6.3-all-languages.zip
unzip -q phpMyAdmin-4.6.3-all-languages.zip
mv phpMyAdmin-4.6.3-all-languages /home/$user/www/phpMyAdmin
rm -f phpMyAdmin-4.6.3-all-languages.zip
chown -R $user.$user /home/$user


#yum remove -y httpd httpd-tools


# Install webtatic
#
rpm -Uvh https://mirror.webtatic.com/yum/el7/epel-release.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

yum install -y nginx



# Install MariaDB & Start & Password Update
#
echo "[mariadb]" > /etc/yum.repos.d/MariaDB.repo
echo "name=MariaDB" >> /etc/yum.repos.d/MariaDB.repo
echo "baseurl = http://yum.mariadb.org/10.1/centos6-amd64" >> /etc/yum.repos.d/MariaDB.repo
echo "gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB" >> /etc/yum.repos.d/MariaDB.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/MariaDB.repo

yum clean all
yum remove -y mariadb-libs
yum install -y MariaDB-server MariaDB-client


systemctl start mysql

expect <<- EOS
spawn mysql_secure_installation
expect ": "
send "\n"
expect "] "
send "y\n"

expect ": "
send "$user_password\n"
expect ": "
send "$user_password\n"

expect "] "
send "y\n"
expect "] "
send "y\n"
expect "] "
send "y\n"
expect "\ "
send "y\n"
expect "MariaDB!"
expect eof
EOS




# Install PHP5.6w & Run
#
yum install -y php56w php56w-devel php56w-gd php56w-mbstring php56w-pdo php56w-xml php56w-mysqlnd php56w-fpm
systemctl start php-fpm



# Configure Nginx for PHP
# Run Nginx
#
(cat <<- _EOF_
location ~ \.php$ {
	root		/home/thruthesky/www;
	fastcgi_pass	127.0.0.1:9000;
	fastcgi_index	index.php;
	fastcgi_param	SCRIPT_FILENAME   \$document_root\$fastcgi_script_name;
	include		fastcgi_params;
}
_EOF_
) > /etc/nginx/default.d/php.conf

nginx

