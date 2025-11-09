#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php"
BACKUP_PATTERN="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php.bak_*"

echo "🔓 Menghapus proteksi Advanced Security Panel..."

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "📦 Memulihkan backup dari: $LATEST_BACKUP"
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ File controller berhasil dipulihkan"
else
    echo "⚠️ Tidak ditemukan backup file, menghapus file modifikasi..."
    if [ -f "$REMOTE_PATH" ]; then
        rm "$REMOTE_PATH"
        echo "✅ File modifikasi dihapus"
    else
        echo "ℹ️ File tidak ditemukan: $REMOTE_PATH"
    fi
fi

# Hapus file security views (opsional)
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view/security_alert.blade.php"
if [ -f "$VIEW_PATH" ]; then
    rm "$VIEW_PATH"
    echo "✅ Security view file dihapus: $VIEW_PATH"
fi

# Restore original index view (opsional - perlu disesuaikan dengan backup asli)
# Jika ingin restore lengkap, perlu backup original view terlebih dahulu

echo "♻️  Melakukan refresh cache..."
cd /var/www/pterodactyl
php artisan cache:clear
php artisan view:clear

echo "🎉 Proteksi Advanced Security Panel berhasil dihapus!"
echo "📂 Node settings, configuration, dan allocation sekarang dapat diakses oleh semua admin"
