FROM alpine:3.19

RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client

COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["mysqld"]
