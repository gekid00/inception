#!/bin/sh

# Initialiser MariaDB si pas déjà fait
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Créer le fichier SQL d'initialisation
    cat > /tmp/init.sql << EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # Démarrer MariaDB avec le script d'init
    exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 --port=3306 --skip-networking=0 --init-file=/tmp/init.sql
fi

# Relancer MariaDB en mode normal
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 --port=3306 --skip-networking=0
