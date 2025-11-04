#!/bin/bash

PANEL_PATH="/var/www/pterodactyl"
SECURITY_CONFIG="${PANEL_PATH}/storage/security_protection_v10.json"
BACKUP_DIR="${PANEL_PATH}/storage/security_backups"

echo "🗑️  Memulai uninstall Security Panel v10..."

# Cek apakah protection terinstall
if [ ! -f "$SECURITY_CONFIG" ]; then
    echo "❌ Security Panel v10 tidak terdeteksi terinstall."
    exit 1
fi

# Baca backup files dari config
BACKUP_FILES=$(grep -o '"backup_files": \[[^]]*\]' "$SECURITY_CONFIG" | sed 's/"backup_files": \[\([^]]*\)\]/\1/' | tr -d '[]" ')

echo "🔄 Mengembalikan file original..."

# Restore semua file backup
for backup_info in $BACKUP_FILES; do
    IFS='|' read -r original_file backup_file <<< "$backup_info"
    
    if [ -f "$backup_file" ]; then
        cp "$backup_file" "$original_file"
        echo "✅ Restored: $original_file"
    else
        echo "⚠️  Backup not found: $backup_file"
    fi
done

# Hapus config file
rm -f "$SECURITY_CONFIG"
echo "✅ Config file dihapus: $SECURITY_CONFIG"

# Clear cache jika diperlukan
if [ -d "${PANEL_PATH}/bootstrap/cache" ]; then
    rm -f ${PANEL_PATH}/bootstrap/cache/*.php
    echo "✅ Cache cleared"
fi

echo "🎉 Uninstall Security Panel v10 selesai!"
echo "📝 Semua file telah dikembalikan ke state semula"
