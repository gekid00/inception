#!/bin/sh

# Initialiser MariaDB si pas déjà fait
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Démarrer MariaDB en arrière-plan pour la configuration
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
pid="$!"

# Attendre que MariaDB soit prêt
i=30
while [ $i -gt 0 ]; do
    if mysqladmin ping >/dev/null 2>&1; then
        break
    fi
    i=$((i-1))
    sleep 1
done

if [ $i -eq 0 ]; then
    echo "MariaDB failed to start"
    exit 1
fi

# Configuration de la base de données
mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
mysql -e "FLUSH PRIVILEGES;"

# Arrêter MariaDB temporaire
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# Relancer MariaDB avec le CMD
exec "$@"
