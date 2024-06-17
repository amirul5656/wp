#!/bin/bash

# Check if the script is being run by the root user
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Update and upgrade Ubuntu
apt-get update; apt-get upgrade -y; apt-get install -y fail2ban ufw;

# Install NGINX
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
# Add hardening commands here

#Install PHP7.4 and common PHP packages
echo "Install PHP 7.4"
sudo apt install -y software-properties-common ca-certificates lsb-release apt-transport-https 
LC_ALL=C.UTF-8 sudo add-apt-repository ppa:ondrej/php -y
sudo apt install -y php7.4 php7.4-fpm php7.4-mysql php-common php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline php7.4-mbstring php7.4-xml php7.4-gd php7.4-curl


sudo systemctl enable php7.4-fpm
sudo systemctl start php7.4-fpm

#Update PHP CLI configuration
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.4/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.4/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/cli/php.ini

#Configure sessions directory permissions
chmod 733 /var/lib/php/sessions
chmod +t /var/lib/php/sessions


#Tweak PHP-FPM settings
sed -i "s/error_reporting = .*/error_reporting = E_ALL \& ~E_NOTICE \& ~E_STRICT \& ~E_DEPRECATED/" /etc/php/7.4/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = Off/" /etc/php/7.4/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 256M/" /etc/php/7.4/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 256M/" /etc/php/7.4/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/fpm/php.ini

#Tune PHP-FPM pool settings

sed -i "s/;listen\.mode =.*/listen.mode = 0666/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/;request_terminate_timeout =.*/request_terminate_timeout = 60/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/pm\.max_children =.*/pm.max_children = 70/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/pm\.start_servers =.*/pm.start_servers = 20/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/pm\.min_spare_servers =.*/pm.min_spare_servers = 20/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/pm\.max_spare_servers =.*/pm.max_spare_servers = 35/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/;pm\.max_requests =.*/pm.max_requests = 500/" /etc/php/7.4/fpm/pool.d/www.conf

#Install MariaDB (MySQL) and set a strong root password

#Creating Database#
sudo apt-get install mariadb-server -y

cd /etc/nginx/sites-available/
wget https://raw.githubusercontent.com/amirul5656/wp/main/hendra56.my.id
cd~
cd /var/www/html/
mkdir hendra56.my.id
cd~
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
rm latest.tar.gz
cd wordpress
mv * /var/www/html/hendra56.my.id

sudo ln -s /etc/nginx/sites-available/hendra56.my.id /etc/nginx/sites-enabled/hendra56.my.id
sudo unlink /etc/nginx/sites-enabled/default
sudo systemctl reload nginx
