#!/bin/bash

################################################################################
# Script: install-apache-php.sh
# Description: Automate installation of Apache and PHP on a Linux VM
# Supported OS: Ubuntu, Debian, and derivatives
# Usage: sudo bash install-apache-php.sh
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print messages
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

################################################################################
# Step 1: Check if running as root
################################################################################
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root. Use 'sudo bash install-apache-php.sh'"
   exit 1
fi

print_status "Script started. Running as root."

################################################################################
# Step 2: Update package list
################################################################################
print_status "Updating package list..."
apt update || {
    print_error "Failed to update package list"
    exit 1
}

################################################################################
# Step 3: Install Apache2
################################################################################
print_status "Installing Apache2 web server..."
apt install -y apache2 || {
    print_error "Failed to install Apache2"
    exit 1
}

print_status "Apache2 installed successfully"

################################################################################
# Step 4: Install PHP
################################################################################
print_status "Installing PHP and common PHP modules..."
apt install -y php php-cli php-common php-mysql php-json php-mbstring || {
    print_error "Failed to install PHP"
    exit 1
}

print_status "PHP installed successfully"

################################################################################
# Step 5: Enable Apache modules for PHP
################################################################################
print_status "Enabling Apache PHP module..."
a2enmod php* 2>/dev/null || print_warning "Some PHP modules may not be available"

################################################################################
# Step 6: Enable and start Apache
################################################################################
print_status "Enabling Apache to start on boot..."
systemctl enable apache2 || {
    print_error "Failed to enable Apache2"
    exit 1
}

print_status "Starting Apache2 service..."
systemctl start apache2 || {
    print_error "Failed to start Apache2"
    exit 1
}

################################################################################
# Step 7: Validation - Check if Apache is running
################################################################################
print_status "Validating installation..."

if systemctl is-active --quiet apache2; then
    print_status "✓ Apache2 is running"
else
    print_error "✗ Apache2 is not running"
    exit 1
fi

################################################################################
# Step 8: Validation - Check if PHP is installed
################################################################################
if php -v > /dev/null 2>&1; then
    PHP_VERSION=$(php -v | head -n 1)
    print_status "✓ PHP is installed: $PHP_VERSION"
else
    print_error "✗ PHP is not installed or not in PATH"
    exit 1
fi

################################################################################
# Step 9: Display installation summary
################################################################################
echo ""
echo "==============================================="
echo -e "${GREEN}Installation completed successfully!${NC}"
echo "==============================================="
echo ""
echo "Apache2 Status:"
systemctl status apache2 --no-pager | head -n 3
echo ""
echo "PHP Version:"
php -v
echo ""
echo "Web server root directory: /var/www/html"
echo "Apache configuration: /etc/apache2/apache2.conf"
echo "PHP configuration: /etc/php/*/apache2/php.ini"
echo ""
echo "To verify Apache and PHP are working together:"
echo "  1. Create a test file: sudo bash -c 'echo \"<?php phpinfo(); ?>\" > /var/www/html/info.php'"
echo "  2. Open browser: http://localhost/info.php"
echo ""
echo "==============================================="

exit 0
