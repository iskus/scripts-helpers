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

read -p "Insert username: " USER_NAME
read -p "Insert project name: " PROJECT_NAME

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
mkdir -p $NGINX_ROOT/logs
#cp -r $CWD/app $CWD/cache $CWD/public $CWD/vendor $NGINX_ROOT

echo "-----> Installing server config"
sudo echo "server {
        listen $NGINX_PORT;
        index index.php index.html;
        server_name $NGINX_HOSTNAME;
        root $NGINX_ROOT/public;


        access_log $NGINX_ROOT/logs/access.log;
        error_log $NGINX_ROOT/logs/error.log;
        client_max_body_size 64m;

        charset utf-8;

        index index.php index.html index.htm;

        try_files \$uri \$uri/ @rewrite;

        location @rewrite {
            rewrite ^/(.*)$ /index.php?q=/\$1;
        }

        location ~ \.php$ {
                fastcgi_pass unix:/run/php/php7.0-fpm.sock
                fastcgi_index index.php;
                include fastcgi_params;
                fastcgi_param   SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        }


        location ~ /\.ht {
                deny  all;
        }
}
" > $NGINX_CONFIG_DIR/sites-available/$PROJECT_NAME

sudo ln -s -f $NGINX_CONFIG_DIR/sites-available/$PROJECT_NAME $NGINX_CONFIG_DIR/sites-enabled/$PROJECT_NAME
sudo chown -R www-data:www-data $NGINX_ROOT

echo "127.0.0.1     $NGINX_HOSTNAME" >> /etc/hosts

echo "-----> Restarting nginx "

sudo service nginx restart

echo "We're done"
