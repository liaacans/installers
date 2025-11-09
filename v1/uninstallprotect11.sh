#!/bin/bash

echo "🔄 MEMULAI PROSES UNINSTALL PROTEKSI ADMIN NODES..."

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeSettingsController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ Tidak ditemukan backup file untuk NodeSettingsController"
    echo "📋 Mencari backup files yang ada:"
    ls -la $BACKUP_PATTERN 2>/dev/null || echo "Tidak ada backup files ditemukan."
else
    echo "📦 Menemukan backup file: $LATEST_BACKUP"
    echo "🔄 Mengembalikan file original..."
    
    # Backup file saat ini dulu sebelum restore
    CURRENT_BACKUP="${REMOTE_PATH}.current_bak_$(date -u +"%Y-%m-%d-%H-%M-%S")"
    if [ -f "$REMOTE_PATH" ]; then
        cp "$REMOTE_PATH" "$CURRENT_BACKUP"
        echo "📁 Backup file saat ini dibuat: $CURRENT_BACKUP"
    fi
    
    # Restore file original
    cp "$LATEST_BACKUP" "$REMOTE_PATH"
    chmod 644 "$REMOTE_PATH"
    echo "✅ NodeSettingsController berhasil dikembalikan"
fi

echo ""
echo "🎉 UNINSTALL BASIC SELESAI!"
echo "🔓 Akses normal ke node settings telah dikembalikan"
