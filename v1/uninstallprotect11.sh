#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php"
BACKUP_PATTERN="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php.bak_*"
LIMITED_VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view-limited.blade.php"

echo "🔄 Memulai proses uninstall proteksi Node Controller..."

# Cek apakah ada backup file
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "📦 Menemukan backup file: $LATEST_BACKUP"
    
    # Restore backup
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ File asli berhasil di-restore dari backup"
    
    # Hapus view limited jika ada
    if [ -f "$LIMITED_VIEW_PATH" ]; then
        rm "$LIMITED_VIEW_PATH"
        echo "✅ View limited berhasil dihapus"
    fi
    
    # Clear cache
    php /var/www/pterodactyl/artisan view:clear
    php /var/www/pterodactyl/artisan cache:clear
    
    echo "🎉 Uninstall proteksi berhasil!"
    echo "🔓 Akses Node Controller sekarang terbuka untuk semua admin"
else
    echo "❌ Tidak ditemukan backup file untuk di-restore"
    echo "ℹ️ File saat ini mungkin sudah dalam keadaan normal atau backup tidak tersedia"
    
    # Hapus view limited jika ada
    if [ -f "$LIMITED_VIEW_PATH" ]; then
        rm "$LIMITED_VIEW_PATH"
        echo "✅ View limited berhasil dihapus"
    fi
    
    # Clear cache
    php /var/www/pterodactyl/artisan view:clear
    php /var/www/pterodactyl/artisan cache:clear
fi

# Hapus backup files lainnya jika ada
OTHER_BACKUPS=$(ls $BACKUP_PATTERN 2>/dev/null | wc -l)
if [ $OTHER_BACKUPS -gt 0 ]; then
    echo "🧹 Membersihkan backup files lainnya..."
    rm -f $BACKUP_PATTERN
    echo "✅ Backup files lainnya berhasil dibersihkan"
fi

echo "🎯 Proses uninstall selesai!"
