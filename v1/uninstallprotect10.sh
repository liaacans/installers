#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerViewController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

echo "🔄 Memulai proses uninstall proteksi..."

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -z "$LATEST_BACKUP" ]; then
  echo "❌ Tidak ditemukan backup file untuk dikembalikan."
  echo "💡 Pastikan file backup dengan pattern ${REMOTE_PATH}.bak_* ada."
  exit 1
fi

echo "📦 Menemukan backup file: $LATEST_BACKUP"

# Restore backup
mv "$LATEST_BACKUP" "$REMOTE_PATH"
chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi berhasil diuninstall!"
echo "📂 File asli telah dikembalikan: $REMOTE_PATH"
echo "🗂️ Backup yang digunakan: $LATEST_BACKUP"
echo "🔓 Akses Server List/View sekarang terbuka untuk semua admin"
