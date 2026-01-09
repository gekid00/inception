FROM alpine:3.19

RUN apk update && apk add --no-cache \
    php82-fpm \
    php82-mysqli \
    php82-phar \
    php82-curl \
    php82-gd \
    php82-mbstring \
    php82-xml \
    php82-zip \
    php82-iconv \
    php82-json \
    php82-session \
    php82-openssl \
    php82-tokenizer \
    mariadb-client \
    wget \
    curl

COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh && \
    mkdir -p /var/www/html && \
    chown -R nobody:nobody /var/www/html

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm82", "-F"]
