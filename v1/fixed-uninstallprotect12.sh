#!/bin/bash

echo "🗑️ Memulai proses uninstall semua proteksi..."

# File-file yang akan di-restore dengan path yang benar
FILES=(
    "/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerViewController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerTableController.php"
)

RESTART_NEEDED=false

for file in "${FILES[@]}"; do
    echo ""
    echo "🔍 Memeriksa $file"
    
    # Cek jika file ada
    if [ ! -f "$file" ]; then
        echo "⚠️  File tidak ditemukan: $file"
        continue
    fi
    
    # Cari backup file terbaru (pattern yang benar)
    LATEST_BACKUP=$(find "$(dirname "$file")" -name "$(basename "$file").bak_*" -type f | sort -r | head -n1)
    
    if [ -n "$LATEST_BACKUP" ] && [ -f "$LATEST_BACKUP" ]; then
        echo "📦 Restoring dari $LATEST_BACKUP"
        cp "$LATEST_BACKUP" "$file"
        chmod 644 "$file"
        echo "✅ $file berhasil di-restore"
        RESTART_NEEDED=true
    else
        echo "❌ Tidak ditemukan backup untuk $file"
        echo "💡 Backup pattern: $(basename "$file").bak_2025-11-04-11-10-30"
    fi
done

echo ""
if [ "$RESTART_NEEDED" = true ]; then
    echo "🎉 Uninstall selesai!"
    echo "🔁 Restart queue untuk memastikan perubahan berlaku:"
    echo "   sudo php /var/www/pterodactyl/artisan queue:restart"
else
    echo "ℹ️  Tidak ada perubahan yang dilakukan."
fi
