#!/bin/bash

echo "🗑️ Menghapus proteksi Admin Nodes Security Panel..."

BACKUP_DIR="/var/www/pterodactyl/backups"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

# Remove middleware file
MIDDLEWARE_PATH="/var/www/pterodactyl/app/Http/Middleware/CheckNodeAccess.php"
if [ -f "$MIDDLEWARE_PATH" ]; then
    rm -f "$MIDDLEWARE_PATH"
    echo "✅ Middleware file removed: $MIDDLEWARE_PATH"
fi

# Remove view composer file
COMPOSER_PATH="/var/www/pterodactyl/app/Http/View/Composers/NodeComposer.php"
if [ -f "$COMPOSER_PATH" ]; then
    rm -f "$COMPOSER_PATH"
    echo "✅ View composer removed: $COMPOSER_PATH"
fi

# Remove middleware from Kernel
KERNEL_PATH="/var/www/pterodactyl/app/Http/Kernel.php"
if [ -f "$KERNEL_PATH" ]; then
    # Backup current kernel first
    cp "$KERNEL_PATH" "$BACKUP_DIR/Kernel.current_$TIMESTAMP.php"
    
    # Remove middleware registration using awk (more reliable)
    awk '!/'\''node.access'\'' =>.*CheckNodeAccess::class,/' "$KERNEL_PATH" > "/tmp/kernel_fixed.php"
    mv "/tmp/kernel_fixed.php" "$KERNEL_PATH"
    
    echo "✅ Middleware removed from Kernel"
fi

# Remove view composer registration
COMPOSER_PROVIDER_PATH="/var/www/pterodactyl/app/Providers/ViewServiceProvider.php"
if [ -f "$COMPOSER_PROVIDER_PATH" ]; then
    # Remove composer registration
    awk '!/view()->composer.*NodeComposer::class/' "$COMPOSER_PROVIDER_PATH" > "/tmp/composer_fixed.php"
    mv "/tmp/composer_fixed.php" "$COMPOSER_PROVIDER_PATH"
    echo "✅ View composer registration removed"
fi

# Restore original routes from backup
ROUTES_PATH="/var/www/pterodactyl/routes/admin.php"
if [ -f "$BACKUP_DIR/admin_routes.php.bak_$TIMESTAMP" ]; then
    cp "$BACKUP_DIR/admin_routes.php.bak_$TIMESTAMP" "$ROUTES_PATH"
    echo "✅ Routes restored from backup"
else
    # Remove middleware from routes manually
    if [ -f "$ROUTES_PATH" ]; then
        sed -i "/->middleware(\['node.access'\]);/d" "$ROUTES_PATH"
        echo "✅ Middleware removed from routes"
    fi
fi

# Restore other files from backup
echo "🔄 Restoring original files from backup..."
for backup_file in "$BACKUP_DIR"/*.bak_*; do
    if [ -f "$backup_file" ]; then
        filename=$(basename "$backup_file")
        original_name=$(echo "$filename" | sed 's/\.bak_[0-9]*//')
        
        case "$original_name" in
            "Kernel.php")
                cp "$backup_file" "/var/www/pterodactyl/app/Http/Kernel.php"
                echo "✅ Restored Kernel.php from backup"
                ;;
            "admin_routes.php")
                cp "$backup_file" "/var/www/pterodactyl/routes/admin.php"
                echo "✅ Restored admin routes from backup"
                ;;
            "ViewServiceProvider.php")
                cp "$backup_file" "/var/www/pterodactyl/app/Providers/ViewServiceProvider.php"
                echo "✅ Restored ViewServiceProvider from backup"
                ;;
        esac
    fi
done

# Remove security CSS
SECURITY_CSS_PATH="/var/www/pterodactyl/public/themes/pterodactyl/css/security-panel.css"
if [ -f "$SECURITY_CSS_PATH" ]; then
    rm -f "$SECURITY_CSS_PATH"
    echo "✅ Security CSS removed"
fi

# Remove CSS from layout
LAYOUT_PATH="/var/www/pterodactyl/resources/views/layouts/admin.blade.php"
if [ -f "$LAYOUT_PATH" ]; then
    sed -i '/security-panel.css/d' "$LAYOUT_PATH"
    echo "✅ CSS reference removed from layout"
fi

# Clear all caches
echo "🔄 Clearing all caches..."
php /var/www/pterodactyl/artisan view:clear
php /var/www/pterodactyl/artisan cache:clear
php /var/www/pterodactyl/artisan config:clear
php /var/www/pterodactyl/artisan route:clear

# Test PHP syntax
echo "🔍 Testing PHP syntax..."
php -l "$KERNEL_PATH"
if [ -f "$COMPOSER_PROVIDER_PATH" ]; then
    php -l "$COMPOSER_PROVIDER_PATH"
fi
php -l "$ROUTES_PATH"

echo ""
echo "♻️ Uninstall proteksi nodes selesai!"
echo "🔓 Semua fitur nodes sekarang dapat diakses normal oleh semua admin"
echo "📁 Backup files tersimpan di: $BACKUP_DIR"
echo "✅ Semua file sudah di-test syntax PHP-nya"
