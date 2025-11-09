#!/bin/bash

echo "🗑️ Menghapus proteksi Admin Nodes Security Panel..."

BACKUP_DIR="/var/www/pterodactyl/backups"

# Remove middleware file
MIDDLEWARE_PATH="/var/www/pterodactyl/app/Http/Middleware/CheckNodeAccess.php"
if [ -f "$MIDDLEWARE_PATH" ]; then
    rm -f "$MIDDLEWARE_PATH"
    echo "✅ Middleware file removed: $MIDDLEWARE_PATH"
fi

# Remove middleware from Kernel
KERNEL_PATH="/var/www/pterodactyl/app/Http/Kernel.php"
if [ -f "$KERNEL_PATH" ]; then
    # Backup current kernel first
    TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
    cp "$KERNEL_PATH" "$BACKUP_DIR/Kernel.current_$TIMESTAMP.php"
    
    # Remove middleware registration
    sed -i "/'node.access' =>.*CheckNodeAccess::class,/d" "$KERNEL_PATH"
    echo "✅ Middleware removed from Kernel"
fi

# Remove middleware from routes
ROUTES_PATH="/var/www/pterodactyl/routes/admin.php"
if [ -f "$ROUTES_PATH" ]; then
    # Remove middleware from nodes group
    sed -i "/->middleware(\['node.access'\]);/d" "$ROUTES_PATH"
    echo "✅ Middleware removed from routes"
fi

# Restore original files from backup if available
echo "🔄 Restoring original files from backup..."
for backup_file in "$BACKUP_DIR"/*.bak_*; do
    if [ -f "$backup_file" ]; then
        filename=$(basename "$backup_file")
        original_name=$(echo "$filename" | sed 's/\.bak_[0-9]*//')
        
        case "$original_name" in
            "Kernel.php")
                cp "$backup_file" "/var/www/pterodactyl/app/Http/Kernel.php"
                echo "✅ Restored Kernel.php"
                ;;
            "admin_routes.php")
                cp "$backup_file" "/var/www/pterodactyl/routes/admin.php"
                echo "✅ Restored admin routes"
                ;;
            "AppServiceProvider.php")
                cp "$backup_file" "/var/www/pterodactyl/app/Providers/AppServiceProvider.php"
                echo "✅ Restored AppServiceProvider"
                ;;
        esac
    fi
done

# Remove blade directive from AppServiceProvider
APP_PROVIDER_PATH="/var/www/pterodactyl/app/Providers/AppServiceProvider.php"
if [ -f "$APP_PROVIDER_PATH" ]; then
    sed -i "/Blade::if('canAccessNodes'/d" "$APP_PROVIDER_PATH"
    sed -i "/return.*Auth::user()->id === 1;/d" "$APP_PROVIDER_PATH"
    echo "✅ Blade directive removed"
fi

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

echo ""
echo "♻️ Uninstall proteksi nodes selesai!"
echo "🔓 Semua fitur nodes sekarang dapat diakses normal oleh semua admin"
echo "📁 Backup files tersimpan di: $BACKUP_DIR"
echo "⚠️ Jika ada masalah, restore manual dari backup files"
