#!/bin/sh

# Génération des certificats SSL auto-signés
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=FR/ST=France/L=Paris/O=42/OU=42/CN=${DOMAIN_NAME}"
fi

# Lancer Nginx
exec "$@"
