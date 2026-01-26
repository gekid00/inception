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
# List containers
docker ps

# View logs
docker logs <container>

# Enter container
docker exec -it <container> sh

# List volumes
docker volume ls

# Inspect volume
docker volume inspect <volume>
```

## Data Storage and Persistence

Data is stored in `/home/login/data/`:
- `mariadb/` - Database files
- `wordpress/` - WordPress files

Volumes are named volumes managed by Docker, visible with `docker volume ls`.
