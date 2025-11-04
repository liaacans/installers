#!/bin/bash

echo "🗑️  Menghapus proteksi Panel Admin Servers..."

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/ServersController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "📦 Memulihkan backup dari: $LATEST_BACKUP"
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    chmod 644 "$REMOTE_PATH"
    echo "✅ File berhasil dipulihkan dari backup"
else
    echo "⚠️  Tidak ditemukan backup file, menghapus file modifikasi..."
    if [ -f "$REMOTE_PATH" ]; then
        rm "$REMOTE_PATH"
        echo "✅ File modifikasi dihapus"
    else
        echo "ℹ️  File tidak ditemukan, mungkin sudah dihapus"
    fi
fi

# Hapus CSS custom
CSS_PATH="/var/www/pterodactyl/public/themes/pterodactyl/css/custom-protect.css"
if [ -f "$CSS_PATH" ]; then
    rm "$CSS_PATH"
    echo "🎨 CSS custom dihapus"
fi

echo "♻️  Restarting queue dan workers..."
sudo php /var/www/pterodactyl/artisan queue:restart
sudo systemctl restart pteroq

echo "🎉 Uninstall proteksi berhasil!"
echo "📋 Semua fitur admin Servers telah dikembalikan ke normal"
