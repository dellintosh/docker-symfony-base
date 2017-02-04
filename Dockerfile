FROM dellintosh/alpine:3.5
MAINTAINER Justus Luthy <justus@luthyenterprises.com>

# Set Environment Variables
ENV default_timezone "America/Chicago"

RUN apk add --no-cache \
    nginx \
    tzdata \
    autoconf \
    g++ \
    make \
    tzdata \
    php7-apcu \
    php7-bcmath \
    php7-bz2 \
    php7-ctype \
    php7-curl \
    php7-dev \
    php7-dom \
    php7-fpm \
    php7-gd \
    php7-gettext \
    php7-gmp \
    php7-iconv \
    php7-intl \
    php7-json \
    php7-mbstring \
    php7-mcrypt \
    php7-mysqli \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-pdo_mysql \
    php7-phar \
    php7-posix \
    php7-session \
    php7-xml \
    php7-zip \
    && cp /usr/share/zoneinfo/${default_timezone} /etc/localtime \
    && echo "${default_timezone}" > /etc/timezone \
    && ln -s /usr/bin/php7 /usr/bin/php \
    && apk del tzdata

# ensure www-data user exists
RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1
# 82 is the standard uid/gid for "www-data" in Alpine
# http://git.alpinelinux.org/cgit/aports/tree/main/apache2/apache2.pre-install?h=v3.3.2
# http://git.alpinelinux.org/cgit/aports/tree/main/lighttpd/lighttpd.pre-install?h=v3.3.2
# http://git.alpinelinux.org/cgit/aports/tree/main/nginx-initscripts/nginx-initscripts.pre-install?h=v3.3.2

ADD nginx/nginx.conf /etc/nginx/
ADD nginx/symfony.conf /etc/nginx/sites-available/
ADD php/www.conf /etc/php7/php-fpm.d/

ADD services /etc/services.d
ADD fix-attrs /etc/fix-attrs.d
ADD cont-init /etc/cont-init.d

RUN mkdir -p /etc/nginx/sites-enabled \
    && ln -s /etc/nginx/sites-available/symfony.conf /etc/nginx/sites-enabled/symfony \
    && rm /etc/nginx/conf.d/default.conf \
    && echo "upstream php-upstream { server localhost:9000; }" > /etc/nginx/conf.d/upstream.conf

# WORKAROUND Due to https://bugs.alpinelinux.org/issues/5378
RUN sed -i "s/ -n / /" $(which pecl)

RUN yes | pecl install apcu_bc-beta \
    && sh -c "echo extension=apc.so > /etc/php7/conf.d/z_apc.ini"

# Install Composer
RUN apk-install curl ca-certificates \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && apk del curl ca-certificates \
    && composer --version

RUN echo 'alias ll="ls -la"' >> ~/.bashrc
RUN echo 'alias sf="php app/console"' >> ~/.bashrc
RUN echo 'alias sf3="php bin/console"' >> ~/.bashrc

WORKDIR /var/www/symfony

EXPOSE 80

ENTRYPOINT ["/init"]
