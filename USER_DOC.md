# User Documentation - Inception

## Services Provided

- **WordPress**: Website at https://login.42.fr
- **NGINX**: Web server with HTTPS
- **MariaDB**: Database (internal only)

## Starting and Stopping

```bash
# Start
make

# Stop
make down
```

## Accessing the Website

1. Open: https://login.42.fr
2. Accept the self-signed certificate warning

### Administration Panel

URL: https://login.42.fr/wp-admin

## Credentials

Stored in `secrets/` directory:
- `secrets/credentials.txt` - WordPress passwords
- `secrets/db_password.txt` - Database password

## Checking Services

```bash
# Check containers are running
docker ps

# Check logs
docker logs nginx
docker logs wordpress
docker logs mariadb

# Check volumes
docker volume ls

# Check network
docker network ls

# Check HTTPS is working
curl -kIs https://login.42.fr | head -5

# Check WordPress users
docker exec wordpress wp user list --allow-root

# Check database
docker exec wordpress wp db check --allow-root
```

All 3 containers should show status "Up".
