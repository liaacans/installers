#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/admin/servers/view/1"
BACKUP_PATH="${REMOTE_PATH}.bak_*"

echo "🗑️ Menghapus proteksi Admin Only untuk Server List..."

# Cari backup terbaru
LATEST_BACKUP=$(ls -td $BACKUP_PATH 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "📦 Memulihkan dari backup: $LATEST_BACKUP"
    
    # Hapus folder saat ini
    rm -rf "$REMOTE_PATH"
    
    # Restore dari backup
    cp -r "$LATEST_BACKUP" "$REMOTE_PATH"
    
    # Set permissions
    chmod -R 755 "$REMOTE_PATH"
    find "$REMOTE_PATH" -type f -name "*.blade.php" -exec chmod 644 {} \;
    
    echo "✅ Proteksi berhasil dihapus dan file asli dipulihkan!"
    echo "📂 Folder dipulihkan dari: $LATEST_BACKUP"
else
    echo "❌ Backup tidak ditemukan. Menghapus file proteksi..."
    
    if [ -d "$REMOTE_PATH" ]; then
        rm -rf "$REMOTE_PATH"
        echo "✅ Folder proteksi berhasil dihapus!"
    else
        echo "⚠️ Folder proteksi tidak ditemukan di $REMOTE_PATH"
    fi
fi

echo "♻️ Silakan clear cache Pterodactyl jika diperlukan"
