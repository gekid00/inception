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
# Check containers
docker ps

# Check logs
docker logs nginx
docker logs wordpress
docker logs mariadb
```

All 3 containers should show status "Up".
