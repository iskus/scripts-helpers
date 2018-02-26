#!/bin/bash
RED='\033[0;31m'         #  ${RED}
GREEN='\033[0;32m'      #  ${GREEN}
NORMAL=$(tput sgr0)
BOLD=$(tput bold)

set -e

# read -p "Insert project name [main/web/transport]: " PROJECT_NAME
# if [ "$PROJECT_NAME" != "main" ] && [ "$PROJECT_NAME" != "web" ] && [ "$PROJECT_NAME" != "transport" ]; then
#   echo -en "${RED}ERROR! Incorrect project name: ${BOLD} ${PROJECT_NAME}! $NORMAL \n"
#   exit 1
# fi
#PROJECT_NAME="web"
projectName() {
    if [ $1 == '' ] 
        then
        read -p "Insert project name: " PROJECT_NAME
        projectName $PROJECT_NAME
        PROJECT_NAME=$STR
    fi
}
# read -p "Insert username: [$SUDO_USER]" USER_NAME
# if [ $USER_NAME == '' ] 
#     then
    USER_NAME=$SUDO_USER
# fi
# echo $USER_NAME
# echo $LOGNAME
# echo $SUDO_USER
# exit

read -p "Insert project name: " PROJECT_NAME
if [ $PROJECT_NAME == '' ] 
    then
    read -p "Insert project name: " PROJECT_NAME
fi
read -p "Insert environment name [Loc/dev/test/prod]: " ENV
if [ "$ENV" != "dev" ] && [ "$ENV" != "test" ] && [ "$ENV" != "prod" ]; then
  #echo "must set ENV to either 'dev', 'test' or 'prod'"
  #exit 1
  ENV="loc"
fi

CWD="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NGINX_CONFIG_DIR="/etc/nginx"
echo "environment: $ENV"

#config file section
#echo "-----> copying $ENV config file"
#cp /var/www/$PROJECT_NAME/app/config/config.default.ini /var/www/$PROJECT_NAME/app/config/$PROJECT_NAME.$ENV.config.ini
#echo
#echo "-----> done with config"

#composer section
# if [ -f "composer.json" ]
# then
#     if [ ! -f "/usr/local/bin/composer" ] || [ ! -f "composer.phar" ]
#     then
#         echo "-----> Composer not found; installing..."
#         sudo curl -sS https://getcomposer.org/installer | php
#         sudo mv composer.phar /usr/local/bin/composer
#     fi
#     echo "-----> Installing Composer dependencies"
#     cd $CWD
#     composer install
# fi


#nginx section
read -p "Enter the nginx root path for this project. [/home/$USER_NAME/www/$PROJECT_NAME]:" PROMPT
case $PROMPT in
    "")
        NGINX_ROOT="/home/$USER_NAME/www/$PROJECT_NAME"
        ;;
    *)
        NGINX_ROOT=$PROMPT
        ;;
esac
read -p "Enter the nginx server name for this project. [$PROJECT_NAME.$ENV]:" PROMPT
case $PROMPT in
    "")
        NGINX_HOSTNAME="$PROJECT_NAME.$ENV"
        ;;
    *)
        NGINX_HOSTNAME=$PROMPT
        ;;
esac
echo "-----> using $NGINX_HOSTNAME"

read -p "Enter the nginx port for this project. [80]:" PROMPT
case $PROMPT in
    "")
        NGINX_PORT="80"
        ;;
    [0-9])
        NGINX_PORT=$PROMPT
        ;;
    *)
        echo 'invalid port; using default'
        NGINX_PORT="80"
        ;;
esac
echo "-----> using port $NGINX_PORT"

echo "-----> Moving server root into $NGINX_ROOT"
mkdir -p $NGINX_ROOT/public
mkdir -p $NGINX_ROOT/logs
chmod -R 0777 $NGINX_ROOT
echo "<?php
            echo 'НЕМА ЗА ШО!<br/>';
            phpinfo();" > $NGINX_ROOT/public/index.php

#cp -r $CWD/app $CWD/cache $CWD/public $CWD/vendor $NGINX_ROOT

echo "-----> Installing server config"
echo "
server {
    listen   $NGINX_PORT;
    server_name $NGINX_HOSTNAME;

    root $NGINX_ROOT/public;
    index index.php index.html index.htm;

    access_log $NGINX_ROOT/logs/access.log;
    error_log $NGINX_ROOT/logs/error.log;

    charset utf-8;
    client_max_body_size 100M;
    fastcgi_read_timeout 1800;

    location / {
        try_files \$uri \$uri/ /index.php?_url=\$uri&\$args;
    }

    location ~ [^/]\.php(/|\$) {
        try_files \$uri =404;
        fastcgi_pass  unix:/var/run/php/php7.2-fpm.sock;
        fastcgi_index /index.php;

        include fastcgi_params;
        fastcgi_split_path_info ^(.+?\.php)(/.*)\$;
        if (!-f \$document_root\$fastcgi_script_name) {
            return 404;
        }

        fastcgi_param PATH_INFO       \$fastcgi_path_info;
        # fastcgi_param PATH_TRANSLATED \$document_root\$fastcgi_path_info;
        # and set php.ini cgi.fix_pathinfo=0

        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)\$ {
        expires       max;
        log_not_found off;
        access_log    off;
    }
}
" > $NGINX_CONFIG_DIR/sites-available/$PROJECT_NAME

ln -s -f $NGINX_CONFIG_DIR/sites-available/$PROJECT_NAME $NGINX_CONFIG_DIR/sites-enabled/$PROJECT_NAME
chown -R www-data:www-data $NGINX_ROOT

echo "127.0.0.1     $NGINX_HOSTNAME" >> /etc/hosts

echo "-----> Restarting nginx "

service nginx restart
service php7.2-fpm start

echo "We're done"

echo "http://$NGINX_HOSTNAME Открывай, должен работать по идее!"
