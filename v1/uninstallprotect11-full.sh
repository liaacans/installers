#!/bin/bash

echo "🔄 MEMULAI PROSES UNINSTALL FULL PROTEKSI ADMIN NODES..."

# List semua controller yang diproteksi
CONTROLLERS=(
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeSettingsController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeAllocationController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeServiceController.php"
)

RESTORED_COUNT=0
FAILED_COUNT=0

for CONTROLLER_PATH in "${CONTROLLERS[@]}"; do
    BACKUP_PATTERN="${CONTROLLER_PATH}.bak_*"
    LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)
    
    if [ -n "$LATEST_BACKUP" ]; then
        echo "📦 Mengembalikan: $(basename $CONTROLLER_PATH)"
        
        # Backup file saat ini
        CURRENT_BACKUP="${CONTROLLER_PATH}.uninstall_bak_$(date -u +"%Y-%m-%d-%H-%M-%S")"
        if [ -f "$CONTROLLER_PATH" ]; then
            cp "$CONTROLLER_PATH" "$CURRENT_BACKUP"
        fi
        
        # Restore original
        cp "$LATEST_BACKUP" "$CONTROLLER_PATH"
        chmod 644 "$CONTROLLER_PATH"
        
        echo "✅ Berhasil dikembalikan dari: $(basename $LATEST_BACKUP)"
        ((RESTORED_COUNT++))
    else
        echo "⚠️  Tidak ada backup untuk: $(basename $CONTROLLER_PATH)"
        ((FAILED_COUNT++))
    fi
done

# Clear cache
echo "🔄 Membersihkan cache aplikasi..."
sudo php /var/www/pterodactyl/artisan cache:clear
sudo php /var/www/pterodactyl/artisan view:clear

echo ""
echo "📊 HASIL UNINSTALL:"
echo "✅ Berhasil dikembalikan: $RESTORED_COUNT file"
echo "⚠️  Gagal dikembalikan: $FAILED_COUNT file"
echo "🎉 UNINSTALL FULL SELESAI!"
echo "🔓 Semua akses ke node settings telah dikembalikan ke normal"
