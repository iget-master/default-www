FROM ubuntu:18.04

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
    apache2 \
    gnupg \
    php7.2 \
    php7.2-gd \
    php7.2-curl \
    php7.2-fpm \
    php7.2-mbstring \
    php7.2-mysql \
    php7.2-tidy \
    php7.2-zip \
    php7.2-xml \
    php7.2-redis \
    php-soap \
    mysql-client-5.7 \
    libapache2-mod-php \
    nodejs \
    supervisor \
    wget \
    && rm -rf /var/lib/apt/lists/* && echo 'Packages installed and lists cleaned'

# Install composer. Not using apt to do it because it uses an very old build.
RUN /scripts/install-composer.sh

# Add configuration files
COPY conf/php/* /etc/php/7.2/fpm/conf.d
COPY conf/supervisor/* /etc/supervisor/conf.d/
COPY conf/apache/sites-enabled /etc/apache2/sites-enabled
COPY conf/supervisord.conf /etc/supervisor/supervisord.conf

# Enable mod rewrite on apache2
RUN a2enmod rewrite

# Disable daemon mode on php-fpm
RUN sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php/7.2/fpm/php-fpm.conf
RUN sed -i 's/;DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www/g' /etc/apache2/sites-enabled/000-default.conf

# Create run directories for mysql and php-fpm
RUN mkdir /var/run/php

# Expose HTTP port
EXPOSE 80

WORKDIR /var/www

CMD ["/scripts/run.sh"]

