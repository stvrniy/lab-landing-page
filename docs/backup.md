# Backup Procedures

Backup guide for static landing page.

## Backup Strategy

For static website, backups are simple but important for version history.

### Backup Types

| Type | Description | Use Case |
|------|-------------|----------|
| Full | Complete copy of all files | Initial backup, major updates |
| Incremental | Only changed files | Regular scheduled backups |
| Git-based | Commit history | Version control (built-in) |

## What to Backup

```
Backup Target
├── Source Code
│   ├── index.html
│   ├── en/index.html
│   ├── css/
│   ├── js/
│   └── images/
├── Configuration
│   ├── nginx.conf
│   ├── apache.conf
│   └── Dockerfile
└── Git Repository
    └── .git/ (full history)
```

## Backup Locations

| Component | Default Location | Backup Path |
|-----------|-----------------|-------------|
| Source | /var/www/lab-landing-page | /var/backups/lab-landing-page/ |
| Config | /etc/nginx/sites-available/ | /var/backups/config/ |
| Git | project/.git/ | GitHub remote |

## Manual Backup

### Create Backup Script

```bash
#!/bin/bash
# backup.sh - Backup landing page

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/lab-landing-page"
PROJECT_DIR="/var/www/lab-landing-page"

# Create backup directory
mkdir -p $BACKUP_DIR

# Create archive
tar -czf $BACKUP_DIR/lab-landing-page_$TIMESTAMP.tar.gz $PROJECT_DIR

# Create git backup
git bundle create $BACKUP_DIR/lab-landing-page_$TIMESTAMP.bundle --all

echo "Backup created: lab-landing-page_$TIMESTAMP.tar.gz"
```

### Run Manual Backup

```bash
# Make script executable
chmod +x backup.sh

# Run backup
./backup.sh
```

## Scheduled Backups

### Cron Schedule

```bash
# Edit crontab
crontab -e

# Add backup job (daily at 2 AM)
0 2 * * * /path/to/backup.sh

# Weekly backup (Sunday at 3 AM)
0 3 * * 0 /path/to/backup.sh
```

### Git-Based Version Control (Built-in)

Since we use Git, commit history is automatically backed up:

```bash
# Check git status
git status

# View commit history
git log --oneline

# Create backup bundle
git bundle create backup.bundle --all
```

## Backup Retention

| Backup Type | Frequency | Keep For |
|-------------|-----------|----------|
| Daily | 7 days |
| Weekly | 4 weeks |
| Monthly | 12 months |

### Cleanup Script

```bash
#!/bin/bash
# cleanup_old_backups.sh

BACKUP_DIR="/var/backups/lab-landing-page"
DAYS_TO_KEEP=7

# Delete old daily backups
find $BACKUP_DIR -name "*.tar.gz" -mtime +$DAYS_TO_KEEP -delete

# Keep only last 4 weekly backups
ls -t $BACKUP_DIR/*.tar.gz | tail -n +5 | xargs -r rm

echo "Old backups cleaned up"
```

## GitHub Remote Backup (Recommended)

GitHub automatically backs up your repository:

```bash
# Verify remote is set
git remote -v

# View all branches
git branch -a

# View all tags
git tag -l

# Clone to backup location
git clone --mirror https://github.com/stvrniy/lab-landing-page.git
```

## Verification

### Check Backup Integrity

```bash
# Verify tar archive
tar -tzf lab-landing-page_20240115_020000.tar.gz | head

# Test extraction
mkdir -p /tmp/test_backup
tar -xzf lab-landing-page_20240115_020000.tar.gz -C /tmp/test_backup
rm -rf /tmp/test_backup

# Verify git bundle
git bundle verify backup.bundle
```

### Automated Verification

```bash
#!/bin/bash
# verify_backup.sh

BACKUP_FILE="/var/backups/lab-landing-page/latest.tar.gz"

if [ -f "$BACKUP_FILE" ]; then
    echo "Backup exists: $BACKUP_FILE"
    tar -tzf $BACKUP_FILE > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✓ Backup is valid"
    else
        echo "✗ Backup is corrupted!"
    fi
else
    echo "✗ Backup not found!"
fi
```

## Restore Procedures

### Full Restore

```bash
# Stop web server
sudo systemctl stop nginx

# Remove current version
sudo rm -rf /var/www/lab-landing-page

# Restore from backup
sudo tar -xzf /var/backups/lab-landing-page_20240115_020000.tar.gz -C /var/www/

# Fix permissions
sudo chown -R www-data:www-data /var/www/lab-landing-page

# Start web server
sudo systemctl start nginx
```

### Selective Restore

```bash
# Extract specific file
tar -xzf lab-landing-page_20240115_020000.tar.gz -C /tmp/ \
    --strip-components=1 var/www/lab-landing-page/index.html

# Copy specific file
sudo cp /tmp/index.html /var/www/lab-landing-page/
```

### Restore from Git

```bash
# Clone fresh copy
git clone https://github.com/stvrniy/lab-landing-page.git /tmp/restore
sudo cp -r /tmp/restore/* /var/www/lab-landing-page/
```

## Restore from GitHub

```bash
# Clone to new location
git clone https://github.com/stvrniy/lab-landing-page.git /tmp/restored-site

# Deploy restored files
sudo cp -r /tmp/restored-site/* /var/www/lab-landing-page/
sudo chown -R www-data:www-data /var/www/lab-landing-page
```

## Testing Restore

```bash
# Start local server
cd /tmp/restored-site
python -m http.server 8080 &

# Test in browser
curl -I http://localhost:8080

# Stop test server
pkill -f "python -m http.server"
```

## Backup Checklist

- [ ] Source files backed up
- [ ] Config files backed up
- [ ] Git repository synced
- [ ] Backup integrity verified
- [ ] Restore tested
- [ ] Documentation updated

## Emergency Recovery

If everything is lost:

1. Clone from GitHub:
   ```bash
   git clone https://github.com/stvrniy/lab-landing-page.git
   ```

2. Deploy to server:
   ```bash
   sudo cp -r lab-landing-page/* /var/www/lab-landing-page/
   ```
