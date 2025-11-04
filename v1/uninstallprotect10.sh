#!/bin/bash

BACKUP_PATTERNS=(
  "/root/backup_protect10_*"
)

ORIGINAL_PATHS=(
  "/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ViewController.php"
  "/var/www/pterodactyl/app/Http/Controllers/Admin/ServerController.php"
  "/var/www/pterodactyl/resources/views/admin/servers/view.blade.php"
  "/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
)

echo "🗑️  Menghapus proteksi Anti Akses Server View & Node List..."

# Find the latest backup directory
LATEST_BACKUP=$(find /root -maxdepth 1 -type d -name "backup_protect10_*" | sort -r | head -n1)

if [ -z "$LATEST_BACKUP" ]; then
  echo "❌ Tidak ada backup ditemukan untuk proteksi ini."
  echo "⚠️  File mungkin masih dalam keadaan terproteksi."
  exit 1
fi

echo "📦 Memulihkan dari backup: $LATEST_BACKUP"

# Restore files from backup
for ORIGINAL_PATH in "${ORIGINAL_PATHS[@]}"; do
  BACKUP_PATH="${LATEST_BACKUP}${ORIGINAL_PATH}"
  
  if [ -f "$BACKUP_PATH" ]; then
    mkdir -p "$(dirname "$ORIGINAL_PATH")"
    cp "$BACKUP_PATH" "$ORIGINAL_PATH"
    chmod 644 "$ORIGINAL_PATH"
    echo "✅ Berhasil memulihkan: $ORIGINAL_PATH"
  else
    echo "⚠️  Backup tidak ditemukan untuk: $ORIGINAL_PATH"
    
    # Remove protected files if backup doesn't exist
    if [ -f "$ORIGINAL_PATH" ]; then
      rm -f "$ORIGINAL_PATH"
      echo "🗑️  File proteksi dihapus: $ORIGINAL_PATH"
    fi
  fi
done

# Clear view cache
if [ -d "/var/www/pterodactyl" ]; then
  cd /var/www/pterodactyl
  php artisan view:clear 2>/dev/null || echo "⚠️  Gagal clear view cache, tetapi tidak masalah."
fi

echo "♻️  Proteksi berhasil dihapus!"
echo "📂 Backup masih disimpan di: $LATEST_BACKUP (jika ingin dihapus manual)"
echo "🔓 Akses Server View & Node List telah dikembalikan ke normal"
