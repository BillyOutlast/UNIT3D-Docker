FROM archlinux:latest

LABEL description="UNIT3D Docker image"
LABEL version="latest"
LABEL name="unit3d docker"

# Install base dependencies
RUN pacman -Sy --noconfirm archlinux-keyring \
    && pacman-key --init \
    && pacman-key --populate archlinux \
    && pacman -Syu --noconfirm --needed \
    git \
    base-devel \
    mariadb \
    valkey \
    nginx \
    python3 \
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

# Install bun globally using npm
RUN npm install -g bun || npm update -g bun

# Enable required PHP extensions
RUN sed -i '/^;zend_extension=opcache/s/^;//' /etc/php/php.ini \
    && sed -i '/^;extension=iconv/s/^;//' /etc/php/php.ini \
    && sed -i '/^;extension=bcmath/s/^;//' /etc/php/php.ini \
    && sed -i '/^;extension=intl/s/^;//' /etc/php/php.ini \
    && sed -i '/^;extension=mysqli/s/^;//' /etc/php/php.ini \
    && sed -i '/^;extension=pdo_mysql/s/^;//' /etc/php/php.ini \
    && sed -i '/^;extension=intl/s/^;//' /etc/php/php.ini \
    && sed -i '/^;extension=redis/s/^;//' /etc/php/conf.d/redis.ini \
    && sed -i '/^;extension=igbinary/s/^;//' /etc/php/conf.d/igbinary.ini


# Expose necessary ports
EXPOSE 80 443 3306 6379



