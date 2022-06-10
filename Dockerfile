FROM debian:buster
MAINTAINER Alexandre Penasso 

ENV DEBIAN_FRONTEND noninteractive
ENV ACCEPT_EULA Y
ENV TERM xterm


RUN apt-get update && \
  apt-get -yqq install apt-transport-https  ca-certificates \
  vim unzip libpng-dev libzip-dev unzip vim joe \
  wget curl git ssh gnupg2 

RUN \
  wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
  echo "deb https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/php.list && \
apt-get -qq update && apt-get -qqy upgrade

RUN  apt-get -qq update && apt-get install -y \
   libapache2-mod-php7.4 php7.4-cgi \
   php7.4-cli        php7.4-gd      php7.4-common    php7.4-intl    php7.4-json   \
   php7.4-mbstring     php7.4-mysql    php7.4-opcache      php7.4-readline       php7.4-xml    php7.4-xsl php7.4-mysqli \
   php7.4-zip  php7.4-redis  php7.4-sqlite3 php7.4-curl php7.4-mcrypt \
   php7.4-dev php7.4-ldap apache2 pdftk 

# Install prerequisites for the sqlsrv and pdo_sqlsrv PHP extensions.
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - 
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update \
    && apt-get install -y msodbcsql17 mssql-tools unixodbc-dev 

RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv
RUN echo "extension=sqlsrv.so" | tee /etc/php/7.4/mods-available/sqlsrv.ini
RUN echo "extension=pdo_sqlsrv.so" | tee /etc/php/7.4/mods-available/pdo_sqlsrv.ini
RUN phpenmod sqlsrv pdo_sqlsrv ldap

RUN apt-get -yqq install msmtp \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite
RUN a2enmod speling
RUN a2enmod rewrite

RUN for i in `grep 'AllowOverride None' /etc/apache2/* -rl`; do perl -pi -e "s/AllowOverride None/AllowOverride All/g" $i ; done


#COPY msmtprc /etc/msmtprc
#COPY php.ini /etc/php/7.4/cli/php.ini
#COPY php.ini /etc/php/7.4/apache2/php.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


RUN mkdir -p /var/www && a2enmod vhost_alias ssl  rewrite headers 

#aby apache log sel na stdout dockeru
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log


EXPOSE 80 443

CMD  /usr/sbin/apache2ctl -D FOREGROUND

