#!/bin/sh

# Configuration de php-fpm pour écouter sur le port 9000
sed -i 's|listen = 127.0.0.1:9000|listen = 9000|g' /etc/php82/php-fpm.d/www.conf
sed -i 's|;listen.owner = nobody|listen.owner = nobody|g' /etc/php82/php-fpm.d/www.conf
sed -i 's|;listen.group = nobody|listen.group = nobody|g' /etc/php82/php-fpm.d/www.conf

# Attendre que MariaDB soit prêt
echo "Waiting for MariaDB..."
while ! mysqladmin ping -h mariadb -u${MYSQL_USER} -p${MYSQL_PASSWORD} --silent &> /dev/null ; do
    sleep 1
done
echo "MariaDB is ready!"

# Télécharger WP-CLI
if [ ! -f /usr/local/bin/wp ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Télécharger WordPress si pas déjà fait
if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --allow-root

    # Créer wp-config.php
    wp config create \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb \
        --allow-root

    # Installer WordPress
    wp core install \
        --url=${DOMAIN_NAME} \
        --title="Inception WordPress" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root

    # Créer un utilisateur supplémentaire
    wp user create \
        ${WP_USER} \
        ${WP_USER_EMAIL} \
        --role=author \
        --user_pass=${WP_USER_PASSWORD} \
        --allow-root
fi

# Lancer php-fpm
exec "$@"
