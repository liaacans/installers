#!/bin/bash

echo "🗑️ Menghapus proteksi Admin Server View..."

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerViewController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

# Cari backup terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "🔄 Mengembalikan file dari backup: $LATEST_BACKUP"
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ File asli berhasil dikembalikan"
else
    echo "⚠️ Tidak ada backup ditemukan, menghapus file modifikasi..."
    if [ -f "$REMOTE_PATH" ]; then
        rm "$REMOTE_PATH"
        echo "✅ File modifikasi dihapus"
    else
        echo "ℹ️ File tidak ditemukan, mungkin sudah dihapus"
    fi
fi

# Restore Nodes Controller
NODES_LIST_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php"
NODES_BACKUP_PATTERN="${NODES_LIST_PATH}.bak_*"

LATEST_NODES_BACKUP=$(ls -t $NODES_BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_NODES_BACKUP" ]; then
    echo "🔄 Mengembalikan nodes controller dari backup: $LATEST_NODES_BACKUP"
    mv "$LATEST_NODES_BACKUP" "$NODES_LIST_PATH"
    echo "✅ Nodes controller berhasil dikembalikan"
else
    echo "⚠️ Tidak ada backup nodes controller ditemukan"
    echo "ℹ️ Silakan restore nodes controller secara manual jika diperlukan"
fi

echo "♻️ Jalankan perintah berikut untuk clear cache:"
echo "   cd /var/www/pterodactyl && php artisan cache:clear && php artisan view:clear"
echo ""
echo "✅ Uninstall proteksi selesai!"
