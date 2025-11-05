#!/bin/bash

echo "🗑️ Menghapus proteksi Anti Tautan Server List..."

REMOTE_PATH="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"

# Restore View dari backup
if [ -f "${REMOTE_PATH}.bak_"* ]; then
  LATEST_BACKUP=$(ls -t "${REMOTE_PATH}.bak_"* 2>/dev/null | head -n1)
  if [ -n "$LATEST_BACKUP" ]; then
    cp "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ View berhasil dikembalikan dari backup: $LATEST_BACKUP"
  else
    echo "⚠️ Tidak ada backup view yang ditemukan"
  fi
else
  echo "⚠️ Tidak ada backup view yang ditemukan"
fi

# Clear cache
echo "🔄 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear
php artisan cache:clear

echo ""
echo "🎉 Uninstall proteksi berhasil!"
echo "🔗 Tombol Manage Server telah dikembalikan ke keadaan semula"
