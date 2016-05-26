FROM 1and1internet/ubuntu-16-apache-2.4-php-5.6:unstable

WORKDIR /var/www/html

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev php5.6-gd php5.6-mysql curl && rm -rf /var/lib/apt/lists/* 

RUN a2enmod rewrite expires

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=60'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
  } > /etc/php/5.6/apache2/conf.d/10-opcache.ini

# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/latest.tar.gz \
  && tar -xzf wordpress.tar.gz -C /usr/src/ \
  && rm wordpress.tar.gz \
  && chown -R www-data:www-data /usr/src/wordpress

# Wordpress DB_Host defaults to 3306. Define as host:port if not on 3306
ENV WORDPRESS_DB_HOST=mysql \
    WORDPRESS_DB_USER=wordpress \
    WORDPRESS_DB_NAME=wordpress \
    WORDPRESS_DB_PASSWORD=EnvVarHere 

COPY supervisord-pre /hooks/supervisord-pre
