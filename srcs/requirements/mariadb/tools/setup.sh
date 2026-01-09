#!/bin/sh

# Initialiser MariaDB si pas déjà fait
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Démarrer MariaDB temporairement pour configuration initiale
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --skip-grant-tables &
    pid="$!"

    # Attendre que MariaDB soit prêt
    i=30
    while [ $i -gt 0 ]; do
        if mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; then
            break
        fi
        i=$((i-1))
        sleep 1
    done

    if [ $i -eq 0 ]; then
        echo "MariaDB failed to start"
        exit 1
    fi

    # Configuration initiale de la base de données
    mysql --socket=/run/mysqld/mysqld.sock -u root -e "FLUSH PRIVILEGES;"
    mysql --socket=/run/mysqld/mysqld.sock -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql --socket=/run/mysqld/mysqld.sock -u root -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql --socket=/run/mysqld/mysqld.sock -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
    mysql --socket=/run/mysqld/mysqld.sock -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql --socket=/run/mysqld/mysqld.sock -u root -e "FLUSH PRIVILEGES;"

    # Arrêter MariaDB temporaire
    kill "$pid"
    wait "$pid"
fi

# Relancer MariaDB en mode normal avec le CMD
exec "$@" --user=mysql --datadir=/var/lib/mysql
