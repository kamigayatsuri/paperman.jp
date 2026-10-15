##############################################################
# Dockerfile
#
# 1. Ubuntuの御パッケージ内で常に最新を取得する
# 2. DocumentRootは取り回しのため、シンボリックリンクを使用

# Copyright © 2023 Kamigayatsuri
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”),
# to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# 我は汝に興味なく、汝も我に興味なし。我と汝の心懐を交わすに能わず。沈黙こそが価値。忘れ去らん。
##############################################################
FROM ubuntu:26.04

# avoidance for against blocking installing by git
ENV DEBIAN_FRONTEND=noninteractive

##############################################################
# setting up locale
##############################################################
ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8

##############################################################
# ENVs
##############################################################
ENV APACHE_DOCUMENT_ROOT "/var/www/src"
ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS ${APACHE_CONFDIR}/envvars

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR "/var/log/apache2"

# to chk command with `php -i | grep 'php.ini'`
#ENV PHP_INI_DIR /usr/local/etc/php
ENV PHP_VERSION=8.5
ENV PHP_INI_DIR=/etc/php/${PHP_VERSION}
ENV NVM_DIR=/usr/local/nvm

##############################################################
# set up Apache document root

# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
##############################################################

RUN mkdir -p "${APACHE_DOCUMENT_ROOT}" \
    && chown "${APACHE_RUN_USER}:${APACHE_RUN_GROUP}" "${APACHE_DOCUMENT_ROOT}" \
    && chmod 755 "${APACHE_DOCUMENT_ROOT}"

##############################################################
# apt update and apt-get install
# if there is build-essential, then "gcc" is not required
##############################################################
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    libcurl4-openssl-dev \
    ca-certificates \
    git \
    make \
    vim \
    gnupg2 \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-dev \
    libpng-dev \
    libpq-dev \
    libapache2-mod-php${PHP_VERSION} \
    locales \
    openssl \
    ssl-cert \
    unzip \
    zlib1g-dev \
    sudo

# install php ${PHP_VERSION}
RUN apt install --no-install-recommends -y \
 php${PHP_VERSION} \
 php${PHP_VERSION}-mysql \
 php${PHP_VERSION}-mbstring \
 php${PHP_VERSION}-xml \
 php${PHP_VERSION}-zip \
 php${PHP_VERSION}-curl \
 php${PHP_VERSION}-intl \
 php${PHP_VERSION}-apcu \
 php${PHP_VERSION}-xdebug \
 php${PHP_VERSION}-gd \
 php${PHP_VERSION}-redis
#php${PHP_VERSION}-fileinfo \ #php-common
#php${PHP_VERSION}-phar \ #php-common
#php${PHP_VERSION}-ctype \ #php-common

# PHPのバージョンを変更
RUN update-alternatives --set php /usr/bin/php${PHP_VERSION}

# nvm(nodejs) & npm インストール
RUN mkdir -p "$NVM_DIR" \
    && curl -fsSLo /tmp/nvm-install.sh https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh \
    && bash /tmp/nvm-install.sh \
    && rm /tmp/nvm-install.sh

RUN bash -c '. "$NVM_DIR/nvm.sh" \
    && nvm install --lts \
    && nvm alias default "lts/*" \
    && npm install -g npm@latest \
    && NODE_BIN_DIR="$(dirname "$(nvm which default)")" \
    && ln -sf "$NODE_BIN_DIR/node" /usr/local/bin/node \
    && ln -sf "$NODE_BIN_DIR/npm" /usr/local/bin/npm \
    && ln -sf "$NODE_BIN_DIR/npx" /usr/local/bin/npx \
    && chmod -R a+rX "$NVM_DIR"'

# install apache2
RUN apt-get install --no-install-recommends -y apache2 \
    && echo 'ServerName localhost' > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername

RUN echo "ja_JP.UTF-8 UTF-8" >/etc/locale.gen
RUN locale-gen
RUN echo "export LANG=ja_JP.UTF-8" >> ~/.bashrc

##############################################################
# configure php
##############################################################
# logs should go to stdout / stderr
RUN ln -sfT /dev/stderr "${APACHE_LOG_DIR}/error.log"
RUN ln -sfT /dev/stdout "${APACHE_LOG_DIR}/access.log"
RUN ln -sfT /dev/stdout "${APACHE_LOG_DIR}/other_vhosts_access.log"

RUN chown -R --no-dereference "${APACHE_RUN_USER}:${APACHE_RUN_GROUP}" "${APACHE_LOG_DIR}"

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event && a2enmod mpm_prefork;

# PHP files should be handled by PHP, and should be preferred over any other file type
RUN printf '%s\n' \
    '<FilesMatch \.php$>' \
    '    SetHandler application/x-httpd-php' \
    '</FilesMatch>' \
    '' \
    'DirectoryIndex disabled' \
    'DirectoryIndex index.php index.html' \
    '' \
    '<Directory /var/www/html>' \
    '    Options -Indexes' \
    '    AllowOverride All' \
    '</Directory>' \
    > "${APACHE_CONFDIR}/conf-available/docker-php.conf"

##############################################################
# Enable Apache modules
#  the docker-php.conf configuration
#  the default SSL virtual host
#  Check Apache configuration syntax
##############################################################
RUN a2enmod rewrite headers ssl php${PHP_VERSION} \
    && a2enconf docker-php \
    && ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf \
    && apachectl -t
# set up ssl
RUN mkdir -p /etc/apache2/ssl \
    && openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout /etc/apache2/ssl/localhost.key \
        -out /etc/apache2/ssl/localhost.crt \
        -subj "/CN=localhost" \
        -addext "subjectAltName=DNS:localhost" \
    && chmod 600 /etc/apache2/ssl/localhost.key \
    && rm -rf /var/lib/apt/lists/*

##############################################################
# clean up
##############################################################
RUN apt-get -y clean && rm -rf /var/lib/apt/lists/*

##############################################################
# setting up www document root
##############################################################
# delete the "index.html" that installing Apache drops in here
RUN ["rm", "-rvf", "/var/www/html"]
COPY . ${APACHE_DOCUMENT_ROOT}
RUN ["ln", "-s", "/var/www/src/public", "/var/www/html"]

# ready entrypoint srript
COPY ./script/entrypoint.sh /tmp
RUN ["chmod", "+x", "/tmp/entrypoint.sh"]
ENTRYPOINT ["/tmp/entrypoint.sh"]

EXPOSE 80
EXPOSE 443

CMD ["apachectl", "-D", "FOREGROUND"]
