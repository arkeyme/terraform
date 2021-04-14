#! /bin/bash
sudo apt-get update
sudo apt install net-tools
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
sudo wget wget https://wordpress.org/latest.tar.gz -O /var/www/latest.tar.gz
sudo tar vxzf /var/www/latest.tar.gz --directory /var/www/
sudo apt-get -y install php libapache2-mod-php php-mysql mysql-client
sudo mv /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php


# Script to create Database:
# mysql -u admin -p -h wpdb.cluster-cdp3jna0fq5u.eu-west-1.rds.amazonaws.com
# CREATE DATABASE wp;
# CREATE USER 'wpuser' IDENTIFIED BY 'pa$$w0rd';
# GRANT ALL PRIVILEGES ON wp.* TO 'wpuser';
# FLUSH PRIVILEGES;

sudo sed -i 's/database_name_here/wp/g' /var/www/wordpress/wp-config.php
sudo sed -i 's/username_here/wpuser/g' /var/www/wordpress/wp-config.php
sudo sed -i 's/password_here/pa$$w0rd/g' /var/www/wordpress/wp-config.php

## Replace Database address here:
sudo sed -i 's/localhost/wpdb.cluster-cdp3jna0fq5u.eu-west-1.rds.amazonaws.com/g' /var/www/wordpress/wp-config.php

echo "<VirtualHost *:80>" | sudo tee /etc/apache2/sites-enabled/000-default.conf
echo "ServerAdmin ansustiwaz@gmail.com" | sudo tee -a /etc/apache2/sites-enabled/000-default.conf
echo "DocumentRoot /var/www/wordpress" | sudo tee -a /etc/apache2/sites-enabled/000-default.conf
echo "<Directory /var/www/wordpress>" | sudo tee -a /etc/apache2/sites-enabled/000-default.conf
echo "     Options Indexes FollowSymLinks" | sudo tee -a /etc/apache2/sites-enabled/000-default.conf
echo "     AllowOverride All" | sudo tee -a /etc/apache2/sites-enabled/000-default.conf
echo "     Require all granted" | sudo tee -a /etc/apache2/sites-enabled/000-default.conf
echo "</Directory>" | sudo tee -a /etc/apache2/sites-enabled/000-default.conf
echo "ErrorLog ${APACHE_LOG_DIR}/domain.com_error.log" | sudo tee -a /etc/apache2/sites-enabled/000-default.conf
echo "CustomLog ${APACHE_LOG_DIR}/domain.com_access.log combined" | sudo tee -a /etc/apache2/sites-enabled/000-default.conf
echo "</VirtualHost>" | sudo tee -a /etc/apache2/sites-enabled/000-default.conf

sudo systemctl restart apache2