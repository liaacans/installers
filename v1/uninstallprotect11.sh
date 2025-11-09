#!/bin/bash

echo "🗑️ Menghapus proteksi Admin Nodes Security Panel..."

# Remove custom middleware
MIDDLEWARE_PATH="/var/www/pterodactyl/app/Http/Middleware/CheckNodeAccess.php"
if [ -f "$MIDDLEWARE_PATH" ]; then
    rm -f "$MIDDLEWARE_PATH"
    echo "✅ Custom middleware removed!"
fi

# Remove middleware from kernel
KERNEL_PATH="/var/www/pterodactyl/app/Http/Kernel.php"
if [ -f "$KERNEL_PATH" ]; then
    sed -i '/CheckNodeAccess/d' "$KERNEL_PATH"
    echo "✅ Middleware removed from Kernel!"
fi

# Remove CSS security
SECURITY_CSS_PATH="/var/www/pterodactyl/public/themes/pterodactyl/css/security-panel.css"
if [ -f "$SECURITY_CSS_PATH" ]; then
    rm -f "$SECURITY_CSS_PATH"
    echo "✅ Security CSS dihapus!"
fi

# Remove CSS reference from layout
LAYOUT_PATH="/var/www/pterodactyl/resources/views/layouts/admin.blade.php"
if [ -f "$LAYOUT_PATH" ]; then
    sed -i '/security-panel.css/d' "$LAYOUT_PATH"
    echo "✅ Security CSS reference dihapus dari layout!"
fi

# Restore original nodes view
NODES_VIEW_DIR="/var/www/pterodactyl/resources/views/admin/nodes/view"
if [ -f "$NODES_VIEW_DIR/index.blade.php.bak" ]; then
    mv "$NODES_VIEW_DIR/index.blade.php.bak" "$NODES_VIEW_DIR/index.blade.php"
    echo "✅ Original nodes view restored!"
else
    echo "⚠️ Backup view tidak ditemukan, nodes view mungkin masih modified"
fi

# Clear all caches
echo "🔄 Clearing all caches..."
php /var/www/pterodactyl/artisan route:clear
php /var/www/pterodactyl/artisan config:clear
php /var/www/pterodactyl/artisan view:clear
php /var/www/pterodactyl/artisan cache:clear

echo ""
echo "♻️ Uninstall proteksi nodes selesai!"
echo "🔓 Semua fitur nodes sekarang dapat diakses normal oleh semua admin"
echo "✅ Pterodactyl akan berjalan normal seperti semula"
