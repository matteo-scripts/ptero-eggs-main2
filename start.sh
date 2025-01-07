#!/bin/ash

# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Function to print messages with colors
log_success() {
    echo -e "${GREEN}[SUCCESS] $1${RESET}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $1${RESET}"
}

log_error() {
    echo -e "${RED}[ERROR] $1${RESET}"
}

# Check if DOMAIN is set via environment variable
if [ -z "$DOMAIN" ]; then
    log_error "No domain provided. Please set the DOMAIN environment variable."
    exit 1
else
    log_success "DOMAIN is set to: $DOMAIN"
fi

# Replace DOMAIN in Nginx configuration
if [ -f "/home/container/nginx/conf.d/default.conf" ]; then
    echo "Replacing DOMAIN in Nginx configuration..."
    sed -i "s|\\\${DOMAIN}|${DOMAIN}|g" /home/container/nginx/conf.d/default.conf
    log_success "Replaced DOMAIN in /home/container/nginx/conf.d/default.conf"
else
    log_error "Nginx configuration file not found at /home/container/nginx/conf.d/default.conf"
    exit 1
fi

# Clean up temp directory
echo "⏳ Cleaning up temporary files..."
if rm -rf /home/container/tmp/*; then
    log_success "Temporary files removed successfully."
else
    log_error "Failed to remove temporary files."
    exit 1
fi

# Start PHP-FPM
echo "⏳ Starting PHP-FPM..."
if /usr/sbin/php-fpm8 --fpm-config /home/container/php-fpm/php-fpm.conf --daemonize; then
    log_success "PHP-FPM started successfully."
else
    log_error "Failed to start PHP-FPM."
    exit 1
fi

# Start Nginx
echo "⏳ Starting Nginx..."
if /usr/sbin/nginx -c /home/container/nginx/nginx.conf -p /home/container/; then
    log_success "Nginx started successfully."
else
    log_error "Failed to start Nginx."
    exit 1
fi

# Final message
log_success "Web server is running. All services started successfully."

# Keep the container running (optional)
tail -f /dev/null
