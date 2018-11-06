FROM alpine:3.8

# ensure www-data user exists
RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1
# 82 is the standard uid/gid for "www-data" in Alpine
# http://git.alpinelinux.org/cgit/aports/tree/main/apache2/apache2.pre-install?h=v3.3.2
# http://git.alpinelinux.org/cgit/aports/tree/main/lighttpd/lighttpd.pre-install?h=v3.3.2
# http://git.alpinelinux.org/cgit/aports/tree/main/nginx-initscripts/nginx-initscripts.pre-install?h=v3.3.2

# Add Bash since Alpine is bundled just with SH
RUN apk add --no-cache bash \
    nginx \
    nodejs \
    php7 \
    php7-gd \
    php7-curl \
    php7-fpm \
    php7-mbstring \
    php7-pdo_mysql \
    php7-tidy \
    php7-zip \
    php7-xml \
    php7-xdebug \
    php7-soap \
    mysql-client \
    composer \
    supervisor

# Define default answers for debconf and set
# debian frontend to noninteractive mode.
COPY scripts/*.sh /scripts/
RUN chmod +x /scripts/*

## Add configuration files
COPY conf/php/* /etc/php7/conf.d
COPY conf/php-fpm.d/* /etc/php7/php-fpm.d/www.conf
COPY conf/nginx/conf.d/* /etc/nginx/conf.d
COPY conf/nginx/sites/* /etc/nginx/conf.d

COPY conf/supervisord.conf /etc/supervisord.conf
COPY conf/supervisor/* /etc/supervisor.d/

RUN sed -i 's/user nginx;/user www-data;/g' /etc/nginx/nginx.conf
RUN sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php7/php-fpm.conf
RUN sed -i 's/;pid = run\/php-fpm7.pid/pid = run\/php\/php-fpm7.pid/g' /etc/php7/php-fpm.conf
RUN sed -i 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php\/php-fpm7.sock/g' /etc/php7/php-fpm.d/www.conf
RUN sed -i 's/user = nobody/user = www-data/g' /etc/php7/php-fpm.d/www.conf
RUN echo "<?php phpinfo();" > /var/www/index.php

# Create run directories for php-fpm
RUN mkdir /run/nginx/ /run/php /var/log/supervisor
#
## Expose HTTP port
#EXPOSE 80

WORKDIR /var/www

CMD ["/scripts/run.sh"]

