# Developer Documentation - Inception

## Setting Up from Scratch

### Prerequisites

- Docker and docker-compose
- Make
- sudo privileges

### Configuration

1. Edit `srcs/.env` with your login
2. Create secrets in `secrets/` directory:
   - `db_password.txt`
   - `db_root_password.txt`
   - `credentials.txt`

## Building and Launching

```bash
# Build and start
make

# Stop
make down

# Clean volumes
make clean

# Full cleanup
make fclean

# Rebuild
make re
```

## Managing Containers and Volumes

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View logs
docker logs <container>
docker logs -f <container>  # Follow logs in real-time

# Enter a container shell
docker exec -it <container> sh

# List volumes
docker volume ls

# Inspect a volume
docker volume inspect <volume>
```

## Network

```bash
# List networks
docker network ls

# Inspect the inception network
docker network inspect srcs_inception
```

## Useful Verification Commands

```bash
# Check TLS configuration
echo | openssl s_client -connect login.42.fr:443 2>/dev/null | grep Protocol

# Check HTTPS response
curl -kIs https://login.42.fr | head -5

# Check WordPress users
docker exec wordpress wp user list --allow-root

# Check database health
docker exec wordpress wp db check --allow-root

# Check PID 1 in each container
docker exec <container> cat /proc/1/cmdline | tr '\0' ' '

# Check restart policy
docker inspect <container> --format='{{.HostConfig.RestartPolicy.Name}}'

# Check Alpine version in a container
docker exec <container> cat /etc/os-release | grep PRETTY_NAME
```

## Data Storage and Persistence

Data is stored in `/home/login/data/`:
- `mariadb/` - Database files
- `wordpress/` - WordPress files

Volumes are named volumes managed by Docker, visible with `docker volume ls`.

To verify persistence: stop and restart containers, data should still be present.
