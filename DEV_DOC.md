# Developer Documentation - Inception

This guide explains how to set up, develop, and maintain the Inception infrastructure.

## Setting Up the Environment from Scratch

### Prerequisites

Before starting, ensure you have:

1. **Docker Engine** (version 20.10+)
   ```bash
   docker --version
   ```

2. **Docker Compose** (version 1.29+ or docker-compose plugin)
   ```bash
   docker-compose --version
   # or
   docker compose version
   ```

3. **Make utility**
   ```bash
   make --version
   ```

4. **sudo privileges** (for creating directories in /home)

### Installation Steps

#### 1. Clone the Repository

```bash
git clone <repository-url>
cd inception
```

#### 2. Configure Environment Variables

Edit the `.env` file in `srcs/.env`:

```bash
nano srcs/.env
```

**Required variables**:
```env
# Domain (replace 'login' with your 42 login)
DOMAIN_NAME=login.42.fr

# MySQL/MariaDB
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser

# WordPress
WP_ADMIN_USER=wproot
WP_ADMIN_EMAIL=wproot@login.42.fr
WP_USER=author_user
WP_USER_EMAIL=author@login.42.fr
```

**Note**: Passwords are stored in `secrets/` directory, not in `.env`.

#### 3. Configure Secrets

The `secrets/` directory contains sensitive credentials:

```bash
ls secrets/
# db_password.txt
# db_root_password.txt
# credentials.txt
```

**Edit if needed**:
```bash
nano secrets/db_password.txt        # MariaDB user password
nano secrets/db_root_password.txt   # MariaDB root password
```

#### 4. Configure /etc/hosts

Add your domain to `/etc/hosts`:

```bash
sudo nano /etc/hosts
```

Add line:
```
127.0.0.1 login.42.fr
```

Replace `login` with your actual login.

#### 5. Create Data Directories

The Makefile will create these automatically, but you can create them manually:

```bash
mkdir -p /home/$USER/data/mariadb
mkdir -p /home/$USER/data/wordpress
```

## Building and Launching

### Using the Makefile

The Makefile provides convenient commands:

#### Build and Start

```bash
make
# or
make all
```

This will:
1. Create data directories
2. Build Docker images
3. Start containers in detached mode

#### Stop Containers

```bash
make down
```

Stops all containers but preserves data.

#### Clean Volumes

```bash
make clean
```

Stops containers and removes Docker volumes (data preserved in `/home/$USER/data`).

#### Full Cleanup

```bash
make fclean
```

Removes containers, images, volumes, and data directories.

#### Rebuild

```bash
make re
```

Equivalent to `make fclean && make`.

### Manual Docker Compose Commands

If you prefer not to use Make:

```bash
cd srcs

# Create data directories first
mkdir -p /home/$USER/data/{mariadb,wordpress}

# Build images
docker-compose build

# Start containers
docker-compose up -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down

# Remove volumes
docker-compose down -v
```

## Managing Containers and Volumes

### Container Management

#### List Running Containers

```bash
docker ps
```

Expected output:
```
CONTAINER ID   IMAGE                 STATUS      PORTS
xxxxxxxxxxxx   nginx:inception       Up X mins   0.0.0.0:443->443/tcp
xxxxxxxxxxxx   wordpress:inception   Up X mins
xxxxxxxxxxxx   mariadb:inception     Up X mins
```

#### View Container Logs

```bash
# All containers
docker-compose -f srcs/docker-compose.yml logs

# Specific container
docker logs nginx
docker logs wordpress
docker logs mariadb

# Follow logs in real-time
docker logs -f wordpress
```

#### Enter a Container

```bash
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
```

#### Restart a Container

```bash
docker restart nginx
docker restart wordpress
docker restart mariadb
```

#### Stop a Specific Container

```bash
docker stop nginx
docker start nginx
```

### Volume Management

#### List Volumes

```bash
docker volume ls
```

You should see:
- `srcs_mariadb_data`
- `srcs_wordpress_data`

#### Inspect Volume

```bash
docker volume inspect srcs_mariadb_data
```

Shows mount point and configuration.

#### Check Data on Host

```bash
ls -la /home/$USER/data/mariadb
ls -la /home/$USER/data/wordpress
```

#### Backup Data

```bash
# Backup MariaDB
sudo tar -czf mariadb-backup-$(date +%Y%m%d).tar.gz /home/$USER/data/mariadb

# Backup WordPress
sudo tar -czf wordpress-backup-$(date +%Y%m%d).tar.gz /home/$USER/data/wordpress
```

#### Restore Data

```bash
# Stop containers
make down

# Restore
sudo tar -xzf mariadb-backup-YYYYMMDD.tar.gz -C /

# Start containers
make
```

## Project Data Storage and Persistence

### Data Location

All persistent data is stored in:

```
/home/$USER/data/
├── mariadb/          # MariaDB database files
│   ├── mysql/
│   ├── wordpress/    # WordPress database
│   └── ...
└── wordpress/        # WordPress files
    ├── wp-content/
    ├── wp-config.php
    └── ...
```

### How Persistence Works

#### Docker Volumes

Defined in `srcs/docker-compose.yml`:

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/${USER}/data/mariadb

  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/${USER}/data/wordpress
```

This creates **named volumes** with **bind mounts**:
- Docker manages volumes (portability)
- Data stored in known location (easy access)

#### Persistence Guarantees

- **Container removal**: Data persists
- **Image rebuild**: Data persists
- **System reboot**: Data persists
- **`make clean`**: Data persists
- **`make fclean`**: Data is **deleted**

### Testing Persistence

```bash
# 1. Start infrastructure
make

# 2. Make changes (create a WordPress post)
# 3. Stop containers
make down

# 4. Remove containers and volumes
docker-compose -f srcs/docker-compose.yml down -v

# 5. Restart
make

# 6. Check website - changes should still be there
```

## Useful Development Commands

### Debugging

#### Check Network Connectivity

```bash
# Enter WordPress container
docker exec -it wordpress bash

# Test MariaDB connection
mysqladmin ping -h mariadb -u wpuser -p

# Test from nginx to wordpress
docker exec -it nginx bash
curl wordpress:9000
```

#### Check Docker Network

```bash
docker network ls
docker network inspect srcs_inception
```

Shows all connected containers.

#### Monitor Resource Usage

```bash
docker stats
```

Real-time CPU, memory, network usage.

### Database Management

#### Access MariaDB CLI

```bash
docker exec -it mariadb mysql -u root -p$(cat secrets/db_root_password.txt)
```

Or as wpuser:
```bash
docker exec -it mariadb mysql -u wpuser -p$(cat secrets/db_password.txt) wordpress
```

#### Useful MySQL Commands

```sql
-- Show databases
SHOW DATABASES;

-- Use WordPress database
USE wordpress;

-- Show tables
SHOW TABLES;

-- Show users
SELECT user, host FROM mysql.user;

-- Check WordPress posts
SELECT * FROM wp_posts WHERE post_type='post';

-- Exit
EXIT;
```

#### Export Database

```bash
docker exec mariadb mysqldump -u root -p$(cat secrets/db_root_password.txt) wordpress > wordpress-backup.sql
```

#### Import Database

```bash
cat wordpress-backup.sql | docker exec -i mariadb mysql -u root -p$(cat secrets/db_root_password.txt) wordpress
```

### WordPress Management

#### WP-CLI Commands

```bash
# Enter WordPress container
docker exec -it wordpress bash

# List users
wp user list --allow-root

# Create user
wp user create newuser email@example.com --role=editor --allow-root

# Update WordPress
wp core update --allow-root

# Install plugin
wp plugin install plugin-name --activate --allow-root

# Clear cache
wp cache flush --allow-root
```

### NGINX Management

#### Test Configuration

```bash
docker exec nginx nginx -t
```

#### Reload Configuration

After editing `srcs/requirements/nginx/conf/nginx.conf`:

```bash
# Rebuild
make re

# Or just restart nginx
docker restart nginx
```

#### View SSL Certificate

```bash
docker exec nginx openssl x509 -in /etc/nginx/ssl/nginx.crt -text -noout
```

## Architecture Overview

```
                    ┌─────────────┐
                    │   Browser   │
                    └──────┬──────┘
                           │ HTTPS (443)
                    ┌──────▼──────┐
                    │    NGINX    │ (debian:bookworm)
                    │  TLSv1.2/3  │
                    └──────┬──────┘
                           │ FastCGI (9000)
                    ┌──────▼──────────┐
                    │   WordPress     │ (debian:bookworm)
                    │   + php-fpm     │
                    └──────┬──────────┘
                           │ MySQL (3306)
                    ┌──────▼──────┐
                    │   MariaDB   │ (debian:bookworm)
                    └─────────────┘

Docker Network: inception (bridge)

Volumes:
├── mariadb_data    → /home/$USER/data/mariadb
└── wordpress_data  → /home/$USER/data/wordpress
```

## Service-Specific Details

### NGINX Service

**Dockerfile**: `srcs/requirements/nginx/Dockerfile`
- Base: debian:bookworm
- Installs: nginx, openssl
- Exposes: port 443
- Entry: `/usr/local/bin/setup.sh`

**Setup Script**: `srcs/requirements/nginx/tools/setup.sh`
- Generates self-signed SSL certificate
- Launches nginx in foreground

**Config**: `srcs/requirements/nginx/conf/nginx.conf`
- Listens on port 443 with SSL
- TLSv1.2 and TLSv1.3 only
- Proxies PHP to WordPress via FastCGI

### WordPress Service

**Dockerfile**: `srcs/requirements/wordpress/Dockerfile`
- Base: debian:bookworm
- Installs: php-fpm, php extensions, wp-cli
- Exposes: port 9000 (php-fpm)
- Entry: `/usr/local/bin/setup.sh`

**Setup Script**: `srcs/requirements/wordpress/tools/setup.sh`
- Configures php-fpm to listen on port 9000
- Waits for MariaDB
- Downloads WordPress via WP-CLI
- Creates wp-config.php with secrets
- Creates 2 users (admin + author)

### MariaDB Service

**Dockerfile**: `srcs/requirements/mariadb/Dockerfile`
- Base: debian:bookworm
- Installs: mariadb-server
- Exposes: port 3306
- Entry: `/usr/local/bin/setup.sh`

**Setup Script**: `srcs/requirements/mariadb/tools/setup.sh`
- Reads passwords from Docker secrets
- Initializes database
- Creates WordPress database and users
- Secures root account

## Troubleshooting Guide

### Build Failures

#### Error: "Cannot pull debian:bookworm"

Check internet connection:
```bash
ping debian.org
docker pull debian:bookworm
```

#### Error: "COPY failed"

Ensure files exist:
```bash
ls srcs/requirements/nginx/conf/
ls srcs/requirements/nginx/tools/
```

### Runtime Failures

#### MariaDB Won't Start

Check logs:
```bash
docker logs mariadb
```

Common issues:
- Corrupt data: `make fclean && make`
- Permissions: `sudo chown -R $USER /home/$USER/data`

#### WordPress Can't Connect to Database

Check:
1. MariaDB is running: `docker ps`
2. Secrets are readable: `cat secrets/db_password.txt`
3. Network exists: `docker network ls | grep inception`

#### NGINX 502 Bad Gateway

WordPress container not responding:
```bash
docker logs wordpress
docker exec nginx curl wordpress:9000
```

### Performance Issues

```bash
# Check resource usage
docker stats

# Check disk space
df -h /home/$USER/data
```

## Best Practices

1. **Never commit secrets**: Ensure `secrets/` is in `.gitignore`
2. **Always test after changes**: `make re` to rebuild
3. **Check logs regularly**: `docker logs -f <container>`
4. **Backup before major changes**: `tar -czf backup.tar.gz /home/$USER/data`
5. **Use `make down`** instead of `make fclean` to preserve data

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [NGINX Config Reference](https://nginx.org/en/docs/)
- [WP-CLI Handbook](https://make.wordpress.org/cli/handbook/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
