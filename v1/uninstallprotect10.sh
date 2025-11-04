#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerViewController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

echo "🔄 Memulai proses uninstall proteksi Server View..."

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "📦 Menemukan backup file: $LATEST_BACKUP"
    
    # Restore backup
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    chmod 644 "$REMOTE_PATH"
    
    echo "✅ Proteksi berhasil diuninstall!"
    echo "📂 File asli telah dikembalikan dari backup."
    echo "🔓 Akses Server View sekarang terbuka untuk semua user."
else
    echo "⚠️  Tidak ditemukan backup file untuk direstore."
    echo "🗑️  Menghapus file proteksi..."
    
    if [ -f "$REMOTE_PATH" ]; then
        rm -f "$REMOTE_PATH"
        echo "✅ File proteksi berhasil dihapus."
        echo "🔓 Akses Server View sekarang terbuka untuk semua user."
    else
        echo "❌ File proteksi tidak ditemukan di $REMOTE_PATH"
        echo "💡 Mungkin proteksi belum terinstall atau sudah diuninstall."
    fi
fi

echo "🎯 Jangan lupa clear cache Pterodactyl:"
echo "   php artisan cache:clear"
echo "   php artisan view:clear"
