#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeSettingsController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

echo "🔄 Memulai proses uninstall proteksi Admin Node Settings..."

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ Tidak ditemukan backup file untuk dikembalikan."
    echo "📋 Backup files yang ada:"
    ls -la $BACKUP_PATTERN 2>/dev/null || echo "Tidak ada backup files ditemukan."
    exit 1
fi

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

# Clear cache
echo "🔄 Membersihkan cache aplikasi..."
sudo php /var/www/pterodactyl/artisan cache:clear
sudo php /var/www/pterodactyl/artisan view:clear

echo "✅ Uninstall berhasil!"
echo "📂 File original telah dikembalikan dari: $LATEST_BACKUP"
echo "📁 Backup file modifikasi disimpan di: $CURRENT_BACKUP"
echo "🔓 Proteksi telah dihapus, akses normal kembali aktif."

# Opsional: Tawarkan untuk menghapus backup files
echo ""
echo "💡 Tips: Anda bisa menghapus backup files manual dengan perintah:"
echo "rm /var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeSettingsController.php.bak_*"
