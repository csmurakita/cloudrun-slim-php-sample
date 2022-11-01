FROM php:8.1-fpm

# php extensions
RUN apt-get update \
    && apt-get install -y zlib1g-dev libzip-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install zip

# composer
COPY --from=composer:2.4 /usr/bin/composer /usr/bin/composer

# php-fpm
COPY www.conf /usr/local/etc/php-fpm.d/www.conf
RUN rm /usr/local/etc/php-fpm.d/zz-docker.conf

# nginx
COPY --from=nginx:1.23 /usr/sbin/nginx /usr/sbin/nginx
COPY --from=nginx:1.23 /etc/nginx/ /etc/nginx/
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir /var/cache/nginx \
    && chown www-data /var/cache/nginx \
    && mkdir /var/log/nginx \
    && ln -s /dev/stdout /var/log/nginx/access.log \
    && ln -s /dev/stderr /var/log/nginx/error.log

RUN mkdir /app && chown www-data /app
WORKDIR /app
COPY --chown=www-data . ./

USER www-data
RUN composer install

USER root
RUN chmod +x /app/entrypoint.sh
CMD ["/app/entrypoint.sh"]
