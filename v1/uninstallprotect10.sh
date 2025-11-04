#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

echo "🔄 Memulai proses uninstall proteksi..."

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ Tidak ditemukan backup file untuk dikembalikan"
    echo "📋 Backup files yang tersedia:"
    ls -la $BACKUP_PATTERN 2>/dev/null || echo "Tidak ada backup files"
    exit 1
fi

echo "📦 Menemukan backup file: $LATEST_BACKUP"
echo "🔄 Mengembalikan file original..."

# Restore backup
mv "$LATEST_BACKUP" "$REMOTE_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Proteksi berhasil diuninstall!"
    echo "📂 File original telah dikembalikan: $REMOTE_PATH"
    echo "🗑️ Backup file yang digunakan: $LATEST_BACKUP"
    
    # Tampilkan backup files yang masih tersisa
    REMAINING_BACKUPS=$(ls $BACKUP_PATTERN 2>/dev/null | wc -l)
    if [ $REMAINING_BACKUPS -gt 0 ]; then
        echo "📋 Backup files tersisa: $REMAINING_BACKUPS"
        echo "💡 Hapus manual jika tidak diperlukan:"
        ls -la $BACKUP_PATTERN 2>/dev/null
    fi
else
    echo "❌ Gagal mengembalikan backup file"
    exit 1
fi
