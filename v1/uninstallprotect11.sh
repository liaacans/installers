#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

echo "🗑️  Menghapus proteksi Anti Akses Admin Node View..."

LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ Backup dikembalikan: $(basename $LATEST_BACKUP)"
else
    [ -f "$REMOTE_PATH" ] && rm "$REMOTE_PATH"
    echo "✅ File proteksi dihapus"
fi

# Hapus view files
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
rm -f "$VIEW_PATH/settings.blade.php" "$VIEW_PATH/configuration.blade.php" "$VIEW_PATH/allocation.blade.php" "$VIEW_PATH/servers.blade.php"

echo "🧹 Membersihkan cache..."
cd /var/www/pterodactyl && php artisan view:clear >/dev/null 2>&1

echo "🎉 Uninstall proteksi berhasil!"
echo "🔓 Semua admin sekarang bisa akses normal"
