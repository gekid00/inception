# User Documentation - Inception

This guide explains how to use the Inception infrastructure as an end user or administrator.

## What Services Are Provided

The Inception stack provides the following services:

1. **WordPress Website** - A fully functional content management system
   - Accessible via HTTPS (port 443)
   - Multiple user accounts (admin and author)
   - Blog/website functionality

2. **NGINX Web Server** - Secure web server
   - TLS/SSL encryption (TLSv1.2/1.3)
   - Reverse proxy to WordPress
   - HTTPS-only access

3. **MariaDB Database** - Database backend
   - Stores WordPress content
   - User and post data
   - Not directly accessible from outside

## Starting and Stopping the Project

### Starting the Infrastructure

From the project root directory:

```bash
make
```

This command will:
- Create necessary data directories
- Build Docker images
- Start all containers
- Initialize the database (first run only)
- Install WordPress (first run only)

**First startup takes 2-5 minutes** as it downloads WordPress and initializes the database.

### Stopping the Infrastructure

To stop all services:

```bash
make down
```

This preserves your data in `/home/your_login/data`.

### Restarting

To restart after stopping:

```bash
make
```

Your data and changes are preserved.

## Accessing the Website

### Prerequisites

1. **Add domain to /etc/hosts**:
   ```bash
   sudo nano /etc/hosts
   ```

   Add this line (replace `login` with your actual login):
   ```
   127.0.0.1 login.42.fr
   ```

2. **Ensure port 443 is available**:
   ```bash
   sudo lsof -i :443
   ```
   If something is using it, stop that service first.

### Accessing the Public Site

1. Open your web browser
2. Navigate to: `https://login.42.fr` (replace `login` with your login)
3. **Accept the self-signed certificate warning**:
   - Chrome/Edge: Click "Advanced" → "Proceed to login.42.fr"
   - Firefox: Click "Advanced" → "Accept the Risk and Continue"
   - Safari: Click "Show Details" → "visit this website"

You should see the WordPress homepage.

### Accessing the Administration Panel

1. Navigate to: `https://login.42.fr/wp-admin`
2. Enter administrator credentials (see "Locating Credentials" below)
3. You can now:
   - Create/edit posts and pages
   - Manage users
   - Install themes and plugins
   - Configure WordPress settings

## Locating and Managing Credentials

### Where Credentials Are Stored

All credentials are located in the `secrets/` directory at the project root:

```
inception/
└── secrets/
    ├── credentials.txt       # All credentials listed here
    ├── db_password.txt       # Database user password
    └── db_root_password.txt  # Database root password
```

### Reading Credentials

```bash
cat secrets/credentials.txt
```

This file contains:
- WordPress admin username and password
- WordPress author username and password
- MariaDB credentials

### Changing Credentials

**IMPORTANT**: Changing credentials after first setup requires recreating the infrastructure.

1. Stop and clean everything:
   ```bash
   make fclean
   ```

2. Edit credential files:
   ```bash
   nano secrets/db_password.txt
   nano secrets/db_root_password.txt
   nano secrets/credentials.txt  # Update for reference
   ```

3. Rebuild:
   ```bash
   make
   ```

## Checking That Services Are Running

### Quick Status Check

```bash
docker ps
```

You should see 3 containers running:
- `nginx`
- `wordpress`
- `mariadb`

**All should show status "Up"**.

### Detailed Service Check

#### 1. Check NGINX

```bash
curl -k https://login.42.fr
```

Should return HTML content (WordPress homepage).

```bash
docker logs nginx
```

Should show nginx access logs without errors.

#### 2. Check WordPress

```bash
docker logs wordpress
```

Should show:
- "Waiting for MariaDB..."
- "MariaDB is ready!"
- PHP-FPM startup messages

#### 3. Check MariaDB

```bash
docker logs mariadb
```

Should show MariaDB startup without errors.

Test database connectivity:
```bash
docker exec -it mariadb mysql -u wpuser -p$(cat secrets/db_password.txt) -e "SHOW DATABASES;"
```

Should display the `wordpress` database.

### Checking Data Persistence

Your data is stored in:
```bash
ls -la /home/your_login/data/
```

You should see:
- `mariadb/` - Database files
- `wordpress/` - WordPress files

**If these directories are empty, containers are not running correctly.**

### Testing After Reboot

1. Reboot your machine:
   ```bash
   sudo reboot
   ```

2. After reboot, restart services:
   ```bash
   cd /path/to/inception
   make
   ```

3. Verify your changes are still there:
   - Open `https://login.42.fr`
   - Check that any posts/pages you created are still present

## Troubleshooting

### Port 443 Already in Use

```bash
sudo lsof -i :443
# Kill the process or:
sudo systemctl stop nginx  # If system nginx is running
```

### Cannot Access Website

1. Check /etc/hosts has the entry
2. Check containers are running: `docker ps`
3. Check firewall isn't blocking port 443
4. Try restarting: `make down && make`

### "Connection Not Secure" / Certificate Warning

This is **normal** - we use self-signed certificates. Click "Advanced" and proceed.

### Lost Data After Cleanup

If you ran `make fclean`, data is **permanently deleted**. Use `make down` or `make clean` to preserve data.

### Containers Keep Restarting

Check logs:
```bash
docker logs mariadb
docker logs wordpress
docker logs nginx
```

Look for error messages and check that secrets files exist.

## Summary of Commands

| Command | Description |
|---------|-------------|
| `make` | Start the infrastructure |
| `make down` | Stop containers (preserve data) |
| `make clean` | Stop and remove volumes |
| `make fclean` | Complete cleanup (deletes data) |
| `docker ps` | Check running containers |
| `docker logs <container>` | View container logs |
| `docker exec -it <container> bash` | Enter container shell |

## Getting Help

For technical issues, refer to:
- [DEV_DOC.md](DEV_DOC.md) - Developer documentation
- [README.md](README.md) - Project overview
- Container logs: `docker logs <container_name>`
