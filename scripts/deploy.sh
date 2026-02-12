#!/bin/bash
# deploy.sh - Automated deployment script for production

set -e

echo "=========================================="
echo "  Landing Page Deployment Script"
echo "=========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_DIR="/var/www/lab-landing-page"
BACKUP_DIR="/var/backups/lab-landing-page"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run as root"
        exit 1
    fi
}

# Create backup
backup() {
    log_info "Creating backup..."
    mkdir -p $BACKUP_DIR
    if [ -d "$DEPLOY_DIR" ]; then
        cp -r "$DEPLOY_DIR" "$BACKUP_DIR/lab-landing-page_$TIMESTAMP"
        log_info "Backup created: lab-landing-page_$TIMESTAMP"
    fi
}

# Deploy to nginx
deploy_nginx() {
    log_info "Deploying to Nginx..."
    mkdir -p $DEPLOY_DIR
    rsync -av --delete --exclude='.git' --exclude='.github' \
        "$PROJECT_DIR/" "$DEPLOY_DIR/"
    chown -R www-data:www-data $DEPLOY_DIR
    chmod -R 755 $DEPLOY_DIR
    systemctl reload nginx
    log_info "Deployed to $DEPLOY_DIR"
}

# Deploy to Docker
deploy_docker() {
    log_info "Building Docker image..."
    docker build -t lab-landing-page:$TIMESTAMP "$PROJECT_DIR/"
    docker stop landing-page 2>/dev/null || true
    docker run -d -p 80:80 --name landing-page lab-landing-page:$TIMESTAMP
    log_info "Deployed via Docker"
}

# Test deployment
test_deploy() {
    log_info "Testing deployment..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
    if [ "$HTTP_CODE" = "200" ]; then
        log_info "Deployment successful! (HTTP $HTTP_CODE)"
    else
        log_error "Deployment failed! (HTTP $HTTP_CODE)"
        exit 1
    fi
}

# Show usage
usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  nginx     Deploy to Nginx"
    echo "  docker    Deploy via Docker"
    echo "  backup    Create backup only"
    echo "  test      Test current deployment"
    echo "  all       Backup, deploy, and test"
    exit 1
}

# Main
case "${1:-all}" in
    nginx)
        check_root
        backup
        deploy_nginx
        test_deploy
        ;;
    docker)
        deploy_docker
        test_deploy
        ;;
    backup)
        check_root
        backup
        ;;
    test)
        test_deploy
        ;;
    all)
        check_root
        backup
        deploy_nginx
        test_deploy
        ;;
    *)
        usage
        ;;
esac

echo ""
log_info "Done!"
