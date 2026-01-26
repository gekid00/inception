*This project has been created as part of the 42 curriculum by rbourkai.*

# Inception

## Description

A Docker infrastructure with NGINX, WordPress, and MariaDB containers, using docker-compose for orchestration.

## Instructions

```bash
# Build and start
make

# Stop
make down

# Full cleanup
make fclean
```

Access: https://rbourkai.42.fr

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Documentation](https://mariadb.com/kb/en/)

### AI Usage

AI was used for documentation structure and troubleshooting. All code was reviewed and understood before integration.

## Project Description

### Use of Docker

Three services containerized with Alpine Linux 3.19:
- **NGINX**: Web server with TLS
- **WordPress**: CMS with php-fpm
- **MariaDB**: Database

### Comparisons

#### Virtual Machines vs Docker

| Aspect | VM | Docker |
|--------|-----|--------|
| Isolation | Full OS | Process-level |
| Size | GBs | MBs |
| Boot time | Minutes | Seconds |

#### Secrets vs Environment Variables

| Aspect | Secrets | Env Variables |
|--------|---------|---------------|
| Security | Encrypted | Plain text |
| Storage | /run/secrets/ | .env file |

**Choice**: Secrets for passwords, env variables for config.

#### Docker Network vs Host Network

| Aspect | Docker Network | Host Network |
|--------|----------------|--------------|
| Isolation | Yes | No |
| Security | Better | Lower |

**Choice**: Bridge network for isolation.

#### Docker Volumes vs Bind Mounts

| Aspect | Volumes | Bind Mounts |
|--------|---------|-------------|
| Managed by | Docker | User |
| Visible in docker volume ls | Yes | No |

**Choice**: Named volumes with local driver, data in /home/login/data.
