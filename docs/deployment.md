# Deployment Instructions

Production deployment guide for static landing page.

## Hardware Requirements

| Parameter | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | Any x86_64 | Any modern processor |
| RAM | 512 MB | 1 GB |
| Disk | 100 MB | 500 MB SSD |
| Network | 10 Mbps | 100 Mbps |

> **Note:** For static website, minimal resources are sufficient.

## Required Software

### Option 1: GitHub Pages (Recommended)

No software required - hosted by GitHub.

### Option 2: Nginx

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nginx

# CentOS/RHEL
sudo yum install nginx

# macOS
brew install nginx
```

### Option 3: Apache

```bash
# Ubuntu/Debian
sudo apt install apache2

# CentOS/RHEL
sudo yum install httpd
```

## Network Configuration

### Firewall

```bash
# UFW (Ubuntu)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# firewalld (CentOS)
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

### DNS

Point your domain to server IP address:
- A record: @ → server IP
- CNAME: www → @ (optional)

## Server Configuration

### Option 1: Deploy to Nginx

```bash
# Stop nginx if running
sudo systemctl stop nginx

# Create deployment directory
sudo mkdir -p /var/www/lab-landing-page
sudo chown -R $USER:$USER /var/www/lab-landing-page

# Copy files
cp -r /path/to/project/* /var/www/lab-landing-page/

# Create nginx config
sudo nano /etc/nginx/sites-available/lab-landing-page
```

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    root /var/www/lab-landing-page;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/lab-landing-page /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

### Option 2: Deploy to Apache

```bash
# Create deployment directory
sudo mkdir -p /var/www/lab-landing-page
sudo chown -R $USER:$USER /var/www/lab-landing-page

# Copy files
cp -r /path/to/project/* /var/www/lab-landing-page/

# Create config
sudo nano /etc/apache2/sites-available/lab-landing-page.conf
```

```apache
<VirtualHost *:80>
    ServerName your-domain.com
    DocumentRoot /var/www/lab-landing-page
    
    <Directory /var/www/lab-landing-page>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
    
    # Security headers
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    
    # Gzip
    AddOutputFilterByType DEFLATE text/html text/plain text/css application/javascript
</VirtualHost>
```

```bash
# Enable site
sudo a2ensite lab-landing-page
sudo a2enmod headers rewrite
sudo systemctl restart apache2
```

### Option 3: Deploy with Docker

```bash
# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY . /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# Build and run
docker build -t lab-landing-page .
docker run -d -p 80:80 --name landing-page lab-landing-page
```

## SSL/HTTPS (Let's Encrypt)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal
sudo systemctl enable certbot.timer
```

## Verification

Check if site is working:

```bash
# Check nginx/apache status
sudo systemctl status nginx
sudo systemctl status apache2

# Check port
netstat -tulpn | grep :80

# Test locally
curl -I http://localhost

# Test from external
curl -I https://your-domain.com
```

## Expected Output

```
HTTP/1.1 200 OK
Server: nginx/1.18.0
Content-Type: text/html
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| 403 Forbidden | Check file permissions: `chmod -R 755 /var/www/lab-landing-page` |
| 404 Not Found | Verify root path in nginx config |
| SSL error | Check certificate paths |
| Site not loading | Check firewall rules |

## Rollback

```bash
# Backup current
sudo cp -r /var/www/lab-landing-page /var/www/lab-landing-page.backup

# Restore from backup
sudo rm -rf /var/www/lab-landing-page
sudo mv /var/www/lab-landing-page.backup /var/www/lab-landing-page
sudo systemctl restart nginx
```
