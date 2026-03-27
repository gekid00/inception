# Inception

A 42 school project that sets up a multi-container Docker infrastructure running
NGINX, WordPress, and MariaDB. Each service runs in its own container, built from
Alpine Linux, and orchestrated with docker-compose.

## Technologies

- **Docker / Docker Compose** -- containerization and orchestration
- **NGINX** -- reverse proxy with TLSv1.2/TLSv1.3 (self-signed certificate)
- **WordPress 6.4** -- CMS with PHP 8.2-FPM
- **MariaDB** -- relational database
- **Alpine Linux 3.22** -- minimal base image for all containers

## Architecture

```
Client (HTTPS :443) --> NGINX --> WordPress (php-fpm :9000) --> MariaDB (:3306)
```

- A **bridge network** isolates inter-container communication.
- **Docker secrets** store database and WordPress passwords securely.
- **Named volumes** with bind mounts persist data under `/home/$USER/data/`.

## Build and Run

Prerequisites: Docker, Docker Compose, sudo access.

Create a `.env` file in `srcs/` and a `secrets/` directory with the required
credential files (see `docker-compose.yml` for expected secret paths).

```bash
# Build images and start all containers
make

# Stop containers
make down

# Stop and remove volumes
make clean

# Full cleanup (volumes + persistent data on host)
make fclean

# Rebuild from scratch
make re
```

## Usage

Once running, open your browser and navigate to:

```
https://<login>.42.fr
```

The Makefile automatically adds the domain to `/etc/hosts`. An admin account and
an author account are created during the first WordPress setup (credentials are
read from Docker secrets).

## Key Concepts

| Concept | Implementation |
|---------|---------------|
| Container isolation | One process per container, bridge network |
| TLS termination | Self-signed cert generated at NGINX startup |
| Secret management | Docker secrets mounted at `/run/secrets/` |
| Data persistence | Named volumes bound to `/home/$USER/data/` |
| Health checks | WordPress waits for MariaDB before installing |
