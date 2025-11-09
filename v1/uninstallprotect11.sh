#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeViewController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

echo "🗑️ Menghapus proteksi Admin Nodes Security Panel..."

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "📦 Restore backup dari: $LATEST_BACKUP"
    cp "$LATEST_BACKUP" "$REMOTE_PATH"
    chmod 644 "$REMOTE_PATH"
    echo "✅ File controller berhasil di-restore!"
else
    echo "⚠️ Tidak ditemukan backup file, perlu restore manual"
    echo "📍 File asli perlu di-restore dari backup Pterodactyl"
fi

# Hapus CSS security
SECURITY_CSS_PATH="/var/www/pterodactyl/public/themes/pterodactyl/css/security-panel.css"
if [ -f "$SECURITY_CSS_PATH" ]; then
    rm -f "$SECURITY_CSS_PATH"
    echo "✅ Security CSS dihapus!"
fi

# Hapus reference CSS dari layout
LAYOUT_PATH="/var/www/pterodactyl/resources/views/layouts/admin.blade.php"
if [ -f "$LAYOUT_PATH" ]; then
    sed -i '/security-panel.css/d' "$LAYOUT_PATH"
    echo "✅ Security CSS reference dihapus dari layout!"
fi

# Hapus view protected
PROTECTED_VIEW="/var/www/pterodactyl/resources/views/admin/nodes/view/index_protected.blade.php"
if [ -f "$PROTECTED_VIEW" ]; then
    rm -f "$PROTECTED_VIEW"
    echo "✅ Protected view dihapus!"
fi

# Clear cache
echo "🔄 Clearing cache..."
php /var/www/pterodactyl/artisan view:clear
php /var/www/pterodactyl/artisan cache:clear

echo ""
echo "♻️ Uninstall proteksi nodes selesai!"
echo "🔓 Semua fitur nodes sekarang dapat diakses normal oleh semua admin"
echo "⚠️ Jika masih ada masalah, restore Pterodactyl dari backup original"
