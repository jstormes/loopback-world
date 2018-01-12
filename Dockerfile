# This is a convenience container for local workstation development
FROM php:7.1-apache
MAINTAINER You

# Install Linux tools
RUN apt-get update \
 && apt-get install -y net-tools curl wget git zip unzip mysql-client joe

# Install PHP libraries
RUN docker-php-ext-install pdo pdo_mysql

# Install PHP Composer tools
RUN wget https://getcomposer.org/installer \
 && php installer \
 && mv composer.phar /usr/local/bin/composer \
 && composer global require phpunit/phpunit \
   phpunit/dbunit \
   phing/phing \
   sebastian/phpcpd \
   phploc/phploc \
   phpmd/phpmd \
   squizlabs/php_codesniffer

# Install PHP XDebug, default should work in most situation.
# See also XDEBUG_CONFIG in docker-compose.yml.
RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini

# Install custom .bashrc for PATH, SSH keys and MySQL defaults
ADD bash_scripts/bashrc.sh /root/.bashrc

# Set Timezone
#RUN echo "date.timezone = \"GMT\"" > /usr/local/etc/php/conf.d/timezone.ini \
#   && echo "GMT" > /etc/timezone \
#   && rm -f /etc/localtime \
#   && ln -s /usr/share/zoneinfo/US/Pacific /etc/localtime

# Enable Apache ReWrite and SSL
RUN a2enmod rewrite \
    && a2enmod ssl vhost_alias

# Apache config, might be better linked into container.
RUN rm -fr /etc/apache2/sites-enabled/*
ADD apache_assets/001-loopback-world-ssl.conf /etc/apache2/sites-enabled/
ADD apache_assets/001-loopback-world.conf /etc/apache2/sites-enabled/

# Copy "*.loopback.world" cert into container.  Might be better to link it.
ADD apache_assets/site.key /etc/ssl/certs/
ADD apache_assets/site.crt /etc/ssl/certs/

# Add our script files so they can be found
ENV PATH /root/bin:$PATH

# Add MariaDb
RUN { \
		echo "mariadb-server" mysql-server/root_password password 'naked'; \
		echo "mariadb-server" mysql-server/root_password_again password 'naked'; \
	} | debconf-set-selections \
	&& apt-get install -y mariadb-server

# Add CRON
RUN apt-get install -y cron

WORKDIR /var/www
EXPOSE 443 80

# Add Tini
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]


ADD bash_scripts/init_prod.sh /etc/init.sh
RUN chmod a+x /etc/init.sh

# Run your program under Tini
#CMD ["init.sh", "-and", "-its", "arguments"]
CMD ["bash", "/etc/init.sh"]
