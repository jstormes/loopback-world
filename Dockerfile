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

FROM jstormes/lamp
MAINTAINER James Stormes <jstormes@stormes.net>

# Install Linux tools, PHP Composer, PHP tools, XDebug, and Apache's vhost alias.
# Remove all Aapche enabled sites.
RUN apt-get update \
 && apt-get install -y net-tools curl wget git zip unzip zlib1g-dev libpng-dev mariadb-client joe gnupg2 libldap2-dev inetutils-ping gettext ssl-cert \
 && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
 && docker-php-ext-install gd zip ldap gettext \
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
 && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y nodejs build-essential \
    && npm -g install grunt-cli nano yarn \
    && echo '{ "allow_root": true }' > /root/.bowerrc \
 && yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini \
 && yes '' | pecl install -f redis \
 && rm -rf /tmp/pear \
 && docker-php-ext-enable redis \
 && a2enmod vhost_alias http2 headers \
 && rm -fr /etc/apache2/sites-enabled/* \
 && rm installer \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && echo "* *   * * *   root    cd /var/www && run-parts --report /var/www/cron/minutely >> /var/log/cron.log 2>&1" >> /etc/crontab \
 && echo "17 *  * * *   root    cd /var/www && run-parts --report /var/www/cron/hourly >> /var/log/cron.log 2>&1" >> /etc/crontab \
 && echo "25 6  * * *   root    cd /var/www && run-parts --report /var/www/cron/daily >> /var/log/cron.log 2>&1" >> /etc/crontab \
 && echo "47 6  * * 7   root    cd /var/www && run-parts --report /var/www/cron/weekly >> /var/log/cron.log 2>&1" >> /etc/crontab \
 && echo "52 6  1 * *   root    cd /var/www && run-parts --report /var/www/cron/monthly >> /var/log/cron.log 2>&1" >> /etc/crontab \
 && echo "0 */4 * * *   root    cd /var/www && run-parts --report /var/www/cron/fourhour >> /var/log/cron.log 2>&1" >> /etc/crontab \
 && echo " "  >> /etc/crontab \
 && sed -i '/bind-address/c\bind-address\t\t= 0.0.0.0' /etc/mysql/my.cnf \
 && /bin/bash -c "/usr/bin/mysqld_safe &" \
 && sleep 5 \
 && mysql -u root -pnaked -e "CREATE USER 'root'@'%' IDENTIFIED BY 'naked';" \
 && mysql -u root -pnaked -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' REQUIRE NONE WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;" \
 && mysql -u root -pnaked -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'naked' WITH GRANT OPTION;" \
 && chmod -R a+rw /var/log/apache2 \
 && sed -Ei "s/bind-address.*/bind-address=0.0.0.0/g" /etc/mysql/mariadb.conf.d/50-server.cnf


# Apache config
ADD apache_assets/100-loopback-world-ssl.conf /etc/apache2/sites-enabled/
ADD apache_assets/100-loopback-world.conf /etc/apache2/sites-enabled/

# Copy "*.loopback.world" cert into container.
ADD apache_assets/site.key /etc/ssl/certs/
ADD apache_assets/site.crt /etc/ssl/certs/
ADD apache_assets/gsalphasha2g2r1.crt /etc/ssl/certs/

ADD assets/ldap/ssl.ldif /etc/ldap/
ADD assets/ssl/certs/loopback.world.cert.pem /etc/ssl/certs/
ADD assets/ssl/certs/loopback.world.fullchain.pem /etc/ssl/certs/
ADD assets/ssl/private/loopback.world.privkey.pem /etc/ssl/private/
RUN chown :ssl-cert /etc/ssl/private/loopback.world.privkey.pem \
 && chmod 640 /etc/ssl/private/loopback.world.privkey.pem \
 && usermod -aG ssl-cert openldap \
 && echo "BASE    dc=loopback,dc=world" >>  /etc/ldap/ldap.conf \
 && echo "URI     ldap://loopback.world" >>  /etc/ldap/ldap.conf \
 && echo "TLSCACertificateFile /etc/ssl/certs/loopback.world.fullchain.pem" >> /etc/ldap/ldap.conf \
 && echo "TLSCertificateFile /etc/ssl/certs/loopback.world.cert.pem" >> /etc/ldap/ldap.conf \
 && echo "TLSCertificateKeyFile /etc/ssl/private/loopback.world.privkey.pem" >> /etc/ldap/ldap.conf
RUN /bin/bash -c "service slapd start" \
 && sleep 10 \
 && ldapmodify -H ldapi:// -Y EXTERNAL -f /etc/ldap/ssl.ldif

EXPOSE 443 80 3306

# Install custom .bashrc
ADD bash_scripts/bashrc.sh /root/.bashrc
# Add our script files so they can be found
ENV PATH /root/bin:~/.composer/vendor/bin:$PATH

ADD bash_scripts/copy_sshkey.sh /root/.copy_sshkey.sh
ENV BASH_ENV /root/.copy_sshkey.sh

# Varables to make LAMP development easer.
ENV XDEBUG_CONFIG remote_host=host.docker.internal remote_port=9000 remote_autostart=1
ENV MYSQL_PWD naked
ENV MYSQL_USER root
ENV MYSQL_HOST localhost




