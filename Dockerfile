FROM archlinux:latest

# Install base dependencies
RUN pacman -Sy --noconfirm archlinux-keyring \
    && pacman-key --init \
    && pacman-key --populate archlinux \
    && pacman -Syu --noconfirm --needed \
    git \
    base-devel \
    mariadb \
    redis \
    nginx \
    php \
    php-fpm \
    php-gd \
    php-intl \
    php-pgsql \
    php-sqlite \
    php-redis \
    php-imagick \
    composer \
    nodejs \
    npm \
    yarn \
    unzip \
    && yes | pacman -Scc

# Set up MariaDB
RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

# Clone UNIT3D repository
WORKDIR /var/www
RUN git clone https://github.com/HDInnovations/UNIT3D.git unit3d

# Copy env file into UNIT3D directory
COPY env /var/www/unit3d/.env

WORKDIR /var/www/unit3d
# Enable required PHP extensions
RUN sed -i '/^;zend_extension=opcache/s/^;//' /etc/php/php.ini \
    && sed -i '/^;extension=iconv/s/^;//' /etc/php/php.ini \
    && sed -i '/^;extension=bcmath/s/^;//' /etc/php/php.ini \
    && sed -i '/^;extension=intl/s/^;//' /etc/php/php.ini

# Install PHP dependencies
RUN composer install --no-interaction --prefer-dist

# Install JS dependencies
RUN yarn install

# Expose necessary ports
EXPOSE 80 443 3306 6379