#!/bin/bash

echo "🔄 Memulai proses uninstall proteksi Node Controller..."

# Files yang perlu di-restore
declare -A FILES=(
    ["NodeController"]="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php"
    ["NodeViewController"]="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeViewController.php"
    ["NodeSettingsController"]="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeSettingsController.php"
    ["NodeAllocationController"]="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeAllocationController.php"
)

# Files tambahan yang dibuat
EXTRA_FILES=(
    "/var/www/pterodactyl/app/Http/Middleware/CheckNodeAccess.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/limited.blade.php"
)

# Restore backup files
for FILE_NAME in "${!FILES[@]}"; do
    FILE_PATH="${FILES[$FILE_NAME]}"
    BACKUP_PATTERN="${FILE_PATH}.bak_*"
    LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)
    
    if [ -n "$LATEST_BACKUP" ]; then
        echo "📦 Restoring $FILE_NAME dari: $LATEST_BACKUP"
        mv "$LATEST_BACKUP" "$FILE_PATH"
    else
        echo "⚠️  Tidak ada backup untuk $FILE_NAME"
    fi
done

# Hapus file tambahan
for EXTRA_FILE in "${EXTRA_FILES[@]}"; do
    if [ -f "$EXTRA_FILE" ]; then
        rm "$EXTRA_FILE"
        echo "🗑️  Menghapus: $EXTRA_FILE"
    fi
done

# Remove middleware dari Kernel
KERNEL_PATH="/var/www/pterodactyl/app/Http/Kernel.php"
KERNEL_BACKUP="${KERNEL_PATH}.bak_*"
LATEST_KERNEL_BACKUP=$(ls -t $KERNEL_BACKUP 2>/dev/null | head -n1)

if [ -n "$LATEST_KERNEL_BACKUP" ]; then
    mv "$LATEST_KERNEL_BACKUP" "$KERNEL_PATH"
    echo "🔧 Kernel berhasil di-restore dari backup"
else
    # Hapus manual jika tidak ada backup
    sed -i "/'node.access' =>.*CheckNodeAccess::class,/d" "$KERNEL_PATH" 2>/dev/null
    echo "🔧 Middleware dihapus dari Kernel"
fi

# Restore routes
ROUTES_PATH="/var/www/pterodactyl/routes/admin.php"
ROUTES_BACKUP_PATTERN="${ROUTES_PATH}.bak_*"
LATEST_ROUTES_BACKUP=$(ls -t $ROUTES_BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_ROUTES_BACKUP" ]; then
    mv "$LATEST_ROUTES_BACKUP" "$ROUTES_PATH"
    echo "🔄 Routes berhasil di-restore"
else
    # Hapus manual middleware dari routes
    sed -i "/'middleware' => 'node.access'/d" "$ROUTES_PATH" 2>/dev/null
    sed -i "/Route::group(\[.*node\.access.*\], function () {/d" "$ROUTES_PATH" 2>/dev/null
    echo "🔄 Middleware dihapus dari Routes"
fi

# Clear semua cache
php /var/www/pterodactyl/artisan view:clear
php /var/www/pterodactyl/artisan cache:clear
php /var/www/pterodactyl/artisan route:clear

# Hapus backup files lainnya
echo "🧹 Membersihkan backup files tersisa..."
find /var/www/pterodactyl -name "*.bak_*" -type f -delete 2>/dev/null

echo ""
echo "🎉 Uninstall proteksi berhasil!"
echo "🔓 Akses Node Controller sekarang terbuka untuk semua admin"
echo "✅ Semua file telah di-restore ke keadaan semula"
