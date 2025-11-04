#!/bin/bash

echo "🗑️ Memulai proses uninstall semua proteksi..."

# File-file yang akan di-restore
FILES=(
    "/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerViewController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerTableController.php"
)

for file in "${FILES[@]}"; do
    echo "🔍 Memeriksa $file"
    
    # Cari backup file terbaru
    LATEST_BACKUP=$(ls -t ${file}.bak_* 2>/dev/null | head -n1)
    
    if [ -n "$LATEST_BACKUP" ]; then
        echo "📦 Restoring $file dari $LATEST_BACKUP"
        cp "$LATEST_BACKUP" "$file"
        chmod 644 "$file"
        echo "✅ $file berhasil di-restore"
    else
        echo "⚠️  Tidak ditemukan backup untuk $file"
    fi
done

echo ""
echo "🎉 Uninstall selesai!"
echo "📋 File yang di-restore:"
echo "   - DetailsModificationService.php"
echo "   - ServerViewController.php" 
echo "   - ServerTableController.php"
echo ""
echo "🔁 Restart queue untuk memastikan perubahan berlaku:"
echo "   sudo php /var/www/pterodactyl/artisan queue:restart"
