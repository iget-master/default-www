FROM ubuntu:20.04

# Define default answers for debconf and set
# debian frontend to noninteractive mode.
COPY scripts/*.sh /scripts/
RUN chmod +x /scripts/*
RUN /scripts/defaults.sh
RUN export DEBIAN_FRONTEND=noninteractive

ADD https://deb.nodesource.com/setup_10.x /scripts/nodejs.sh
RUN chmod +x /scripts/nodejs.sh && sync && /scripts/nodejs.sh
RUN rm -f /scripts/nodejs.sh

ENV TZ=America/Fortaleza
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install packages
RUN apt-get clean && apt-get -y update && apt-get install -y locales software-properties-common && \
    locale-gen en_US.UTF-8 && \
    LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt -y update && apt install -y \
    git \
    nginx \
    gnupg \
    php8.0 \
    php8.0-gd \
    php8.0-curl \
    php8.0-fpm \
    php8.0-mbstring \
    php8.0-mysql \
    php8.0-tidy \
    php8.0-zip \
    php8.0-xml \
    php8.0-redis \
    php8.0-soap \
    mysql-client-8.0 \
    nodejs \
    supervisor \
    wget \
    && rm -rf /var/lib/apt/lists/* && echo 'Packages installed and lists cleaned'

# Install composer. Not using apt to do it because it uses an very old build.
RUN /scripts/install-composer.sh

# Add configuration files
COPY conf/php/* /etc/php/8.0/fpm/conf.d
COPY conf/nginx/conf.d/* /etc/nginx/conf.d
COPY conf/nginx/sites/* /etc/nginx/sites-enabled
COPY conf/nginx/sites/* /etc/nginx/sites-available
COPY conf/supervisor/* /etc/supervisor/conf.d/
COPY conf/supervisord.conf /etc/supervisor/supervisord.conf

# Disable default site on nginx
RUN rm -rf /etc/nginx/sites-enabled/default

# Disable daemon mode on php-fpm
RUN sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php/8.0/fpm/php-fpm.conf

# Create run directories for mysql and php-fpm
RUN mkdir /var/run/php

# Expose HTTP port
EXPOSE 80

WORKDIR /var/www

CMD ["/scripts/run.sh"]

