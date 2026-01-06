*This project has been created as part of the 42 curriculum by login.*

# Inception

## Description

Inception is a system administration project that focuses on containerization using Docker. The goal is to create a small infrastructure composed of different services (NGINX, WordPress, MariaDB) using docker-compose, following best practices for security, isolation, and persistence.

This project demonstrates:
- Docker containerization and orchestration
- Service isolation with Docker networks
- Data persistence with Docker volumes
- Secure credential management with environment variables
- NGINX configuration with TLS/SSL
- WordPress deployment with php-fpm
- MariaDB database management

## Instructions

### Prerequisites

- Docker and docker-compose installed
- Make utility
- sudo privileges (for directory creation)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/gekid00/inception.git
cd inception
```

2. Create and configure the `.env` file:
```bash
cp srcs/.env.example srcs/.env
nano srcs/.env
# Change the first line:
USER=your_login
```

3. Build and start the infrastructure:
```bash
make
```

This will automatically:
- Add your domain to `/etc/hosts` (requires sudo password)
- Create data directories in `/home/your_login/data/`
- Build Docker images
- Start all containers

4. Access the website:
- Open your browser: `https://your_login.42.fr`
- Accept the self-signed certificate warning

### Usage

- `make` or `make all` - Build and start all containers
- `make down` - Stop all containers
- `make clean` - Stop containers and remove volumes
- `make fclean` - Full cleanup (containers, images, volumes, data)
- `make re` - Rebuild everything from scratch

### Credentials

All credentials are stored in the `srcs/.env` file. Default credentials:
- **WordPress Admin**: wproot / SecureAdminPass123!
- **WordPress Author**: author_user / UserPass123!
- **Database**: wpuser / wppass123

**Important**: Change these passwords in the `.env` file before deploying to production.

## Project Description

### Use of Docker

This project uses **Docker** to containerize three main services:
1. **NGINX**: Web server with TLS/SSL support
2. **WordPress**: CMS with php-fpm
3. **MariaDB**: Database server

Each service runs in an isolated container built from **Debian Bookworm** base images, ensuring:
- Process isolation
- Resource management
- Reproducible environments
- Easy deployment

### Sources Included

- **Dockerfiles**: Custom-built images for each service (no ready-made images from DockerHub)
- **Configuration files**: NGINX config, setup scripts
- **Docker Compose**: Orchestration file defining services, networks, and volumes
- **Environment Variables**: Configuration stored in `.env` file

### Main Design Choices

1. **Debian Bookworm**: Chosen for stability and security updates
2. **Environment Variables**: Used for configuration in `.env` file (not hardcoded in Dockerfiles)
3. **Named Volumes**: For persistent data storage with bind mounts to `/home/login/data`
4. **Bridge Network**: Custom network for service communication
5. **TLSv1.2/1.3**: Modern encryption protocols for NGINX
6. **php-fpm**: Separate PHP processing from web server for better performance

### Comparisons

#### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker |
|--------|------------------|--------|
| **Isolation** | Full OS isolation | Process-level isolation |
| **Size** | GBs (full OS) | MBs (shared kernel) |
| **Boot time** | Minutes | Seconds |
| **Resource usage** | High (separate kernel) | Low (shared kernel) |
| **Portability** | Limited | High |
| **Use case** | Complete OS needed | Microservices, apps |

**Choice**: Docker is ideal for this project because we need lightweight, portable, and fast-starting services.

#### Secrets vs Environment Variables

| Aspect | Secrets | Environment Variables |
|--------|---------|----------------------|
| **Security** | Encrypted at rest | Plain text in .env |
| **Visibility** | Limited access | File-based access |
| **Storage** | Secure tmpfs mount | .env file (gitignored) |
| **Rotation** | Easier to rotate | Edit .env and restart |
| **Best for** | Production secrets | Development/single-host |

**Choice**: Environment variables in `.env` file are used for this project. The `.env` file is excluded from git, providing adequate security for a development/educational environment. For production, Docker Swarm secrets would be preferred.

#### Docker Network vs Host Network

| Aspect | Docker Network | Host Network |
|--------|----------------|--------------|
| **Isolation** | Network isolation | No isolation |
| **Port conflicts** | Avoided | Possible |
| **Performance** | Slight overhead | Native |
| **Security** | Better | Lower |
| **Service discovery** | DNS-based | Localhost |

**Choice**: Custom bridge network provides isolation, security, and DNS-based service discovery (e.g., `wordpress` can connect to `mariadb` by name).

#### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|----------------|-------------|
| **Management** | Docker-managed | User-managed |
| **Portability** | High | Path-dependent |
| **Performance** | Optimized | Host filesystem |
| **Permissions** | Docker handles | Manual handling |
| **Backup** | Docker CLI | Standard tools |

**Choice**: Named volumes with bind mounts combine the best of both worlds:
- Docker manages volumes (portability)
- Data stored in known location (`/home/login/data`) for easy access and backup

## Resources

### Documentation
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress WP-CLI](https://wp-cli.org/)
- [MariaDB Documentation](https://mariadb.com/kb/en/)

### Tutorials
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [NGINX SSL Configuration](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [Docker Secrets Management](https://docs.docker.com/engine/swarm/secrets/)

### AI Usage

AI (Claude) was used in this project for:
- **Documentation structure**: Organizing README according to 42 requirements
- **Best practices research**: Finding optimal Docker configurations
- **Troubleshooting**: Debugging docker-compose and Dockerfile issues
- **Security reviews**: Ensuring proper secrets management

AI was NOT used for:
- Direct code generation (all configurations written and understood by student)
- Copy-pasting without understanding
- Bypassing learning objectives

All code was reviewed, tested, and understood before integration.
