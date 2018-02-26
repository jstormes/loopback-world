# This is a convenience container for local workstation development
#
# This is a Docker Anti-Pattern.  I am putting all the services into
# one container and I am doing it knowing that this is NOT the way
# you should do it.   That is just how I roll...
#
# Breaking the law, breaking the law ...
#
# This is intended for development but also allows less experienced
# system operators to deploy to system like QNAP NAS server as one
# container, without having to understand how to connect and
# maintain separate services.
#

FROM jstormes/lamp:stable
MAINTAINER James Stormes <jstormes@stormes.net>

# Install Linux tools, PHP Composer, PHP tools, XDebug, and Apache's vhost alias.
# Remove all Aapche enabled sites.
RUN apt-get update \
 && apt-get install -y net-tools curl wget git zip unzip mariadb-client joe \
 && wget https://getcomposer.org/installer \
 && php installer \
 && mv composer.phar /usr/local/bin/composer \
 && composer global require phpunit/phpunit \
   phpunit/dbunit \
   phing/phing \
   sebastian/phpcpd \
   phploc/phploc \
   phpmd/phpmd \
   squizlabs/php_codesniffer \
 && yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini \
 && a2enmod vhost_alias \
 && rm -fr /etc/apache2/sites-enabled/* \
 && rm installer \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Apache config
ADD apache_assets/100-loopback-world-ssl.conf /etc/apache2/sites-enabled/
ADD apache_assets/100-loopback-world.conf /etc/apache2/sites-enabled/

# Copy "*.loopback.world" cert into container.  Might be better to link it.
ADD apache_assets/site.key /etc/ssl/certs/
ADD apache_assets/site.crt /etc/ssl/certs/
ADD apache_assets/gsalphasha2g2r1.crt /etc/ssl/certs/

# Install custom .bashrc
ADD bash_scripts/bashrc.sh /root/.bashrc
# Add our script files so they can be found
ENV PATH /root/bin:$PATH





