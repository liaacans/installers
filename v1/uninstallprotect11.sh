#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php"
BACKUP_PATTERN="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php.bak_*"
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"

echo "🔓 Menghapus proteksi Advanced Security Panel..."

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "📦 Memulihkan backup dari: $LATEST_BACKUP"
    cp "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ File controller berhasil dipulihkan"
else
    echo "⚠️ Tidak ditemukan backup file"
fi

# Hapus file security views yang kita buat
SECURITY_FILES=(
    "security_overlay.blade.php"
    "settings.blade.php" 
    "configuration.blade.php"
    "allocation.blade.php"
    "index.blade.php"
)

for file in "${SECURITY_FILES[@]}"; do
    if [ -f "$VIEW_PATH/$file" ]; then
        echo "⚠️ File modifikasi ditemukan: $VIEW_PATH/$file"
        echo "ℹ️ Silakan restore manual file original untuk: $file"
    fi
done

echo "♻️  Melakukan refresh cache..."
cd /var/www/pterodactyl
php artisan cache:clear
php artisan view:clear

echo "🎉 Proteksi Advanced Security Panel berhasil dihapus!"
echo "📂 Semua admin sekarang dapat mengakses semua tab nodes"
