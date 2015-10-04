#!/bin/bash
RED='\033[0;31m'         #  ${RED}
GREEN='\033[0;32m'      #  ${GREEN}
NORMAL=$(tput sgr0)
BOLD=$(tput bold)

PHP_EXT_PATH="/etc/php5/mods-available"
PHP_FPM_PATH="/etc/php5/fpm/conf.d"
PHP_CLI_PATH="/etc/php5/cli/conf.d"

MONGO_INI="${PHP_EXT_PATH}/mongo.ini"
PHALCON_INI="${PHP_EXT_PATH}/phalcon.ini"


echo -en "${BOLD}Start base installation... \n\n"
echo -en "${BOLD}Update system... $NORMAL \n"
apt-get update
echo -en "Updated $BOLD $GREEN Done! $NORMAL \n\n"

echo -en "${BOLD}Upgrade system... $NORMAL \n"
apt-get upgrade
echo -en "Upgraded $BOLD $GREEN Done! $NORMAL \n\n"


echo -en "${BOLD}Start nginx installation... $NORMAL \n"
apt-get install nginx -y
echo -en "Nginx installation $BOLD $GREEN Done! $NORMAL \n\n"


echo -en "${BOLD}Start PHP-FPM installation... $NORMAL \n"
apt-get -y install php5-fpm php5-dev php5-cli php5-json php5-curl php5-gearman php5-mcrypt php-pear php-apc php5-mysql
echo -en "PHP-FPM installation $BOLD $GREEN Done! $NORMAL \n\n"

echo -en "${BOLD}Start mongodb installation... $NORMAL \n"
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
apt-get update
apt-get install -y mongodb-org
pecl install mongo


echo "extension=mongo.so">$MONGO_INI
ln -s -f $MONGO_INI "${PHP_FPM_PATH}/mongo.ini"
ln -s -f $MONGO_INI "${PHP_CLI_PATH}/mongo.ini"

echo -en "MongoDB installation $BOLD $GREEN Done! $NORMAL \n\n"

echo "MySQL installation --------------------------------------->>>>>>"
apt-get install mysql-server
mysql_install_db
mysql_secure_installation


echo "-----> Installing Phalcon"
apt-get install libpcre3-dev -y

git clone --depth=1 git://github.com/phalcon/cphalcon.git
pushd cphalcon/build
./install
popd
rm -rf cphalcon

echo "extension=phalcon.so">$PHALCON_INI
ln -s -f $PHALCON_INI "${PHP_FPM_PATH}/phalcon.ini"
ln -s -f $PHALCON_INI "${PHP_CLI_PATH}/phalcon.ini"

echo -en "Phalcon installation $BOLD $GREEN Done! $NORMAL \n\n"

echo "-----> Installing phalcon dev tools"
mkdir /var/www/manager
cd /var/www/manager
sudo git clone https://github.com/phalcon/phalcon-devtools.git
cd /var/www/manager/phalcon-devtools
sudo sh /var/www/manager/phalcon-devtools/phalcon.sh    
sudo ln -s ~/phalcon-devtools/phalcon.php /usr/bin/phalcon

echo "-----> Starting Nginx"
service nginx restart
echo "-----> Starting PHP-FPM"
service php5-fpm restart
echo "Done."

echo "-----> Composer installing..."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

read -p "Do you want install Gearman Server? [y/n]:" PROMPT
if [ "$PROMPT" == "y" ] || [ "$PROMPT" == "Y" ]; then
	apt-get install gearman-job-server -y
  	echo -en "Gearman Server installation $BOLD $GREEN Done! $NORMAL \n\n"
fi

read -p "Do you want install RabbitMQ Server? [y/n]:" PROMPT
if [ "$PROMPT" == "y" ] || [ "$PROMPT" == "Y" ]; then
	deb http://www.rabbitmq.com/debian/ testing main
	wget https://www.rabbitmq.com/rabbitmq-signing-key-public.asc
	apt-key add rabbitmq-signing-key-public.asc
	apt-get update
	apt-get install rabbitmq-server -y
  	echo -en "RabbitMQ Server installation $BOLD $GREEN Done! $NORMAL \n\n"
fi

cd /var
mkdir www
cd www

read -p "Do you want install Supervisor? [y/n]:" PROMPT
if [ "$PROMPT" == "y" ] || [ "$PROMPT" == "Y" ]; then
	apt-get install supervisor
  	echo -en "Supervisor installation $BOLD $GREEN Done! $NORMAL \n\n"
fi
