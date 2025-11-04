#!/bin/bash

# File paths
MAIN_SERVICE_PATH="/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php"
VIEW_PATH="/var/www/pterodactyl/resources/scripts/components/server/ServerConsoleContainer.tsx"

# Backup patterns
MAIN_BACKUP_PATTERN="${MAIN_SERVICE_PATH}.bak_*"
VIEW_BACKUP_PATTERN="${VIEW_PATH}.bak_*"

echo "🗑️  Menghapus proteksi Anti Modifikasi Server v10..."

# Restore main service file
LATEST_MAIN_BACKUP=$(ls -t $MAIN_BACKUP_PATTERN 2>/dev/null | head -1)
if [ -n "$LATEST_MAIN_BACKUP" ]; then
  cp "$LATEST_MAIN_BACKUP" "$MAIN_SERVICE_PATH"
  chmod 644 "$MAIN_SERVICE_PATH"
  echo "✅ File utama berhasil dikembalikan dari: $LATEST_MAIN_BACKUP"
else
  echo "⚠️  Tidak ditemukan backup file utama. File akan dihapus."
  if [ -f "$MAIN_SERVICE_PATH" ]; then
    rm "$MAIN_SERVICE_PATH"
    echo "✅ File utama berhasil dihapus."
  fi
fi

# Restore view file
LATEST_VIEW_BACKUP=$(ls -t $VIEW_BACKUP_PATTERN 2>/dev/null | head -1)
if [ -n "$LATEST_VIEW_BACKUP" ]; then
  cp "$LATEST_VIEW_BACKUP" "$VIEW_PATH"
  echo "✅ File view berhasil dikembalikan dari: $LATEST_VIEW_BACKUP"
else
  echo "⚠️  Tidak ditemukan backup file view. Rebuild panel diperlukan."
  if [ -f "$VIEW_PATH" ]; then
    echo "📝 File view masih ada, rebuild panel diperlukan untuk mengembalikan tampilan normal."
  fi
fi

# Clear compiled views
echo "🔄 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear
php artisan cache:clear

echo "🎉 Uninstall proteksi v10 selesai!"
echo "📝 Jika tampilan tidak normal, jalankan: cd /var/www/pterodactyl && npm run build"
