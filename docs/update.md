# Update Procedures

Guide for updating the static landing page in production.

## Pre-Update Checklist

- [ ] Review changes in repository
- [ ] Test changes locally
- [ ] Backup current version
- [ ] Check compatibility
- [ ] Schedule maintenance window (if needed)

## Backup

```bash
# Create timestamped backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
cp -r /var/www/lab-landing-page /var/www/lab-landing-page_backup_$TIMESTAMP

# Or using tar
tar -czf /var/backups/lab-landing-page_$TIMESTAMP.tar.gz /var/www/lab-landing-page
```

## Compatibility Check

For static website, compatibility is minimal:

```bash
# Check HTML validity (optional)
npx html-validate index.html

# Check for broken links (optional)
npx broken-link-checker http://localhost:8000
```

## Downtime Planning

Static website updates typically require **0-30 seconds** downtime.

| Method | Downtime |
|--------|----------|
| GitHub Pages | 0 seconds (atomic) |
| Nginx (copy) | ~5 seconds |
| Docker | ~10 seconds |

## Update Process

### Option 1: GitHub Pages (Automatic)

```bash
# Push changes to main branch
git add .
git commit -m "feat: Update content"
git push origin main

# GitHub Actions automatically deploys
# Site updated in ~1-2 minutes
```

### Option 2: Nginx

```bash
# 1. Pull latest changes
cd /path/to/project
git pull origin main

# 2. Stop nginx briefly
sudo systemctl stop nginx

# 3. Copy files
sudo rsync -av --delete /path/to/project/ /var/www/lab-landing-page/

# 4. Start nginx
sudo systemctl start nginx

# Total downtime: ~5-10 seconds
```

### Option 3: Docker

```bash
# 1. Pull latest code
cd /path/to/project
git pull origin main

# 2. Rebuild and restart container
docker build -t lab-landing-page:latest .
docker stop landing-page
docker run -d -p 80:80 --name landing-page lab-landing-page:latest

# Total downtime: ~10-20 seconds
```

## Configuration Update

If configuration files change:

```bash
# Backup old config
sudo cp /etc/nginx/sites-available/lab-landing-page /etc/nginx/sites-available/lab-landing-page.backup

# Apply new config
sudo nano /etc/nginx/sites-available/lab-landing-page

# Test config
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

## Post-Update Verification

```bash
# Check site responds
curl -I https://your-domain.com

# Check all pages load
curl -I https://your-domain.com/en/

# Check assets load
curl -I https://your-domain.com/css/styles.css
curl -I https://your-domain.com/js/main.js

# Verify no 404 errors in browser console
```

## Rollback Procedure

### Quick Rollback (GitHub Pages)

```bash
# Revert to previous commit
git revert HEAD
git push origin main

# Or reset to specific commit
git log --oneline -n 10
git reset --hard <commit-hash>
git push --force origin main
```

### Rollback (Nginx)

```bash
# Stop nginx
sudo systemctl stop nginx

# Restore from backup
sudo rm -rf /var/www/lab-landing-page
sudo mv /var/www/lab-landing-page_backup_$TIMESTAMP /var/www/lab-landing-page

# Start nginx
sudo systemctl start nginx
```

### Rollback (Docker)

```bash
# Stop current container
docker stop landing-page

# Remove current image
docker rmi lab-landing-page:latest

# Rebuild from backup
cd /path/to/backup
docker build -t lab-landing-page:latest .

# Run
docker run -d -p 80:80 --name landing-page lab-landing-page:latest
```

## Version Control Best Practices

```bash
# Create version tag before update
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin v1.1.0

# After update
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0
```

## Update Checklist

- [ ] Review changes
- [ ] Test locally
- [ ] Create backup
- [ ] Apply update
- [ ] Verify site loads
- [ ] Check browser console for errors
- [ ] Test on mobile device
- [ ] Document changes
