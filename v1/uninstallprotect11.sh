#!/bin/bash

FILE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerTableController.php"

echo "🗑️ Uninstall Proteksi Hide Node dari Server List..."

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t ${FILE_PATH}.bak_* 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "📦 Restoring file dari $LATEST_BACKUP"
    cp "$LATEST_BACKUP" "$FILE_PATH"
    chmod 644 "$FILE_PATH"
    echo "✅ Proteksi Hide Node dari Server List berhasil diuninstall"
    echo "🔁 Restart queue: sudo php /var/www/pterodactyl/artisan queue:restart"
else
    echo "❌ Tidak ditemukan backup file untuk proteksi ini"
    echo "💡 File backup harus berformat: ${FILE_PATH}.bak_2025-11-04-11-10-30"
fi
