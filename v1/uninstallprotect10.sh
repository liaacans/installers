#!/bin/bash

echo "🗑️ Menghapus proteksi Anti Tautan Server List..."

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/ServersController.php"
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"

# Restore Controller
if [ -f "${REMOTE_PATH}.bak_"* ]; then
  LATEST_BACKUP=$(ls -t "${REMOTE_PATH}.bak_"* 2>/dev/null | head -n1)
  if [ -n "$LATEST_BACKUP" ]; then
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ Controller berhasil dikembalikan dari backup: $LATEST_BACKUP"
  else
    echo "⚠️ Tidak ada backup controller yang ditemukan"
  fi
else
  echo "⚠️ Tidak ada backup controller yang ditemukan"
fi

# Restore View
if [ -f "${VIEW_PATH}.bak_"* ]; then
  LATEST_VIEW_BACKUP=$(ls -t "${VIEW_PATH}.bak_"* 2>/dev/null | head -n1)
  if [ -n "$LATEST_VIEW_BACKUP" ]; then
    mv "$LATEST_VIEW_BACKUP" "$VIEW_PATH"
    echo "✅ View berhasil dikembalikan dari backup: $LATEST_VIEW_BACKUP"
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
php artisan route:clear

echo ""
echo "🎉 Uninstall proteksi berhasil!"
echo "🔗 Tautan server list telah dikembalikan ke keadaan semula"
