#!/bin/bash

echo "🗑️  Menghapus proteksi Anti Tautan Server..."

# File paths
INDEX_FILE="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
VIEW_FILE="/var/www/pterodactyl/resources/views/admin/servers/view/26.blade.php"
BACKUP_DIR="/var/www/pterodactyl/backups"

# Create backup directory if not exists
mkdir -p "$BACKUP_DIR"

# Restore index file from backup
INDEX_BACKUP=$(ls -t "${INDEX_FILE}.bak_"* 2>/dev/null | head -n1)
if [ -n "$INDEX_BACKUP" ]; then
    echo "🔄 Memulihkan file index dari backup: $INDEX_BACKUP"
    cp "$INDEX_BACKUP" "$INDEX_FILE"
    chmod 644 "$INDEX_FILE"
    echo "✅ File index berhasil dipulihkan"
else
    echo "⚠️  Backup file index tidak ditemukan, menghapus file modifikasi..."
    if [ -f "$INDEX_FILE" ]; then
        # Backup current modified file before deleting
        CURRENT_BACKUP="${BACKUP_DIR}/index_modified_$(date -u +"%Y-%m-%d-%H-%M-%S").blade.php"
        cp "$INDEX_FILE" "$CURRENT_BACKUP"
        rm -f "$INDEX_FILE"
        echo "📦 Backup file modifikasi disimpan di: $CURRENT_BACKUP"
    fi
fi

# Restore view file from backup
VIEW_BACKUP=$(ls -t "${VIEW_FILE}.bak_"* 2>/dev/null | head -n1)
if [ -n "$VIEW_BACKUP" ]; then
    echo "🔄 Memulihkan file view dari backup: $VIEW_BACKUP"
    cp "$VIEW_BACKUP" "$VIEW_FILE"
    chmod 644 "$VIEW_FILE"
    echo "✅ File view berhasil dipulihkan"
else
    echo "⚠️  Backup file view tidak ditemukan, menghapus file modifikasi..."
    if [ -f "$VIEW_FILE" ]; then
        # Backup current modified file before deleting
        CURRENT_BACKUP="${BACKUP_DIR}/view26_modified_$(date -u +"%Y-%m-%d-%H-%M-%S").blade.php"
        cp "$VIEW_FILE" "$CURRENT_BACKUP"
        rm -f "$VIEW_FILE"
        echo "📦 Backup file modifikasi disimpan di: $CURRENT_BACKUP"
    fi
fi

# Clear cache
echo "🔄 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear
php artisan cache:clear

echo ""
echo "🎉 Uninstall proteksi berhasil!"
echo "✅ Semua file telah dikembalikan ke keadaan semula"
echo "🔓 Fitur manage server sekarang dapat diakses kembali oleh semua user"
echo "📂 Backup file modifikasi disimpan di: $BACKUP_DIR"
