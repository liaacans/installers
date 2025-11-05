#!/bin/bash

echo "🗑️ Menghapus proteksi Anti Tautan Server List..."

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/ServersController.php"
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
LAYOUT_PATH="/var/www/pterodactyl/resources/views/layouts/admin.blade.php"

# Restore Controller
if compgen -G "${REMOTE_PATH}.bak_*" > /dev/null; then
  LATEST_BACKUP=$(ls -t "${REMOTE_PATH}.bak_"* 2>/dev/null | head -n1)
  if [ -n "$LATEST_BACKUP" ] && [ -f "$LATEST_BACKUP" ]; then
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ Controller berhasil dikembalikan dari backup: $(basename $LATEST_BACKUP)"
  else
    echo "⚠️ Tidak ada backup controller yang valid ditemukan"
  fi
else
  echo "⚠️ Tidak ada backup controller yang ditemukan"
fi

# Restore View
if compgen -G "${VIEW_PATH}.bak_*" > /dev/null; then
  LATEST_VIEW_BACKUP=$(ls -t "${VIEW_PATH}.bak_"* 2>/dev/null | head -n1)
  if [ -n "$LATEST_VIEW_BACKUP" ] && [ -f "$LATEST_VIEW_BACKUP" ]; then
    mv "$LATEST_VIEW_BACKUP" "$VIEW_PATH"
    echo "✅ View berhasil dikembalikan dari backup: $(basename $LATEST_VIEW_BACKUP)"
  else
    echo "⚠️ Tidak ada backup view yang valid ditemukan"
  fi
else
  echo "⚠️ Tidak ada backup view yang ditemukan"
fi

# Restore Layout
if compgen -G "${LAYOUT_PATH}.bak_*" > /dev/null; then
  LATEST_LAYOUT_BACKUP=$(ls -t "${LAYOUT_PATH}.bak_"* 2>/dev/null | head -n1)
  if [ -n "$LATEST_LAYOUT_BACKUP" ] && [ -f "$LATEST_LAYOUT_BACKUP" ]; then
    mv "$LATEST_LAYOUT_BACKUP" "$LAYOUT_PATH"
    echo "✅ Layout berhasil dikembalikan dari backup: $(basename $LATEST_LAYOUT_BACKUP)"
  else
    echo "⚠️ Tidak ada backup layout yang valid ditemukan"
  fi
else
  echo "⚠️ Tidak ada backup layout yang ditemukan"
fi

# Clear cache
echo "🔄 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear
php artisan cache:clear
php artisan config:clear

echo ""
echo "🎉 Uninstall proteksi berhasil!"
echo "🔗 Semua fitur telah dikembalikan ke keadaan semula"
echo "📋 Tombol 'Create New', footer, dan tautan telah dikembalikan"
