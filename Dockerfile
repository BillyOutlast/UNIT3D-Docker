FROM fedora:latest  

LABEL description="UNIT3D Docker image"
LABEL version="latest"
LABEL name="unit3d docker"

# Install Remi repository and enable PHP 8.4 module
RUN dnf install -y dnf-plugins-core \
    && dnf install -y https://rpms.remirepo.net/fedora/remi-release-$(rpm -E %fedora).rpm \
    && dnf module reset php -y \
    && dnf module enable php:remi-8.4 -y \
    && dnf install -y php

# Install base dependencies
RUN dnf -y update \
    && dnf -y install \
    git \
    mariadb-server \
    redis \
    nginx \
    python3 \
    php \
    php-fpm \
    php-gd \
    php-intl \
    php-pgsql \
    php-sqlite3 \
    php-bcmath \
    php-mysqlnd \
    php-zip \
    nodejs \
    npm \
    unzip \
    && dnf clean all


# Install composer manually
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Install yarnpkg using npm
RUN npm install -g yarn

# Install php-pecl-redis and php-imagick using pecl
RUN dnf -y install php-pear php-devel gcc make ImageMagick-devel \
    && pecl channel-update pecl.php.net \
    && pecl install redis imagick \
    && echo "extension=redis.so" > /etc/php.d/40-redis.ini \
    && echo "extension=imagick.so" > /etc/php.d/40-imagick.ini

# Install and enable dnf-automatic for automatic updates
RUN dnf -y install dnf-automatic \
    && systemctl enable dnf-automatic.timer



# Configure dnf-automatic to run updates at midnight UTC
RUN sed -i 's/^OnCalendar=.*/OnCalendar=*-*-* 00:00:00 UTC/' /usr/lib/systemd/system/dnf-automatic.timer


# Set up MariaDB
RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

RUN sed -i '/^;extension=iconv/s/^;//' /etc/php.ini \
    && sed -i '/^;extension=bcmath/s/^;//' /etc/php.ini \
    && sed -i '/^;extension=intl/s/^;//' /etc/php.ini \
    && sed -i '/^;extension=mysqli/s/^;//' /etc/php.ini \
    && sed -i '/^;extension=intl/s/^;//' /etc/php.ini \
    && sed -i '/^;extension=zip/s/^;//' /etc/php.ini \
    && sed -i '/^;extension=pdo_mysql/s/^;//' /etc/php.ini \
    && sed -i '/^;extension=intl/s/^;//' /etc/php.ini 


# Install bun globally using npm
RUN npm install -g bun || npm update -g bun 



# Disable remote login for MariaDB (MySQL)
RUN echo "[mysqld]\nskip-networking\nskip-bind-address" >> /etc/my.cnf.d/disable-remote.cnf

# Disable user logon for mysql user
RUN usermod -s /sbin/nologin mysql

# Create restricted user for running PHP application
RUN useradd -r -s /sbin/nologin unit3d \
    && mkdir -p /var/www/html \
    && chown unit3d:unit3d /var/www/html


# Expose necessary ports
EXPOSE 80 443 3306 6379



