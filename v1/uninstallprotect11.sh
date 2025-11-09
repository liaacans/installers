#!/bin/bash

echo "🔄 Memulai proses uninstall proteksi Node Controller..."

# Files yang dibuat
FILES=(
    "/var/www/pterodactyl/app/Http/Middleware/CheckNodeAccess.php"
    "/var/www/pterodactyl/resources/views/errors/403.blade.php"
)

# Backup files yang akan di-restore
BACKUP_FILES=(
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeViewController.php.bak_*"
    "/var/www/pterodactyl/routes/admin.php.bak_*"
    "/var/www/pterodactyl/app/Http/Kernel.php.bak_*"
)

# 1. Hapus file yang kita buat
for FILE in "${FILES[@]}"; do
    if [ -f "$FILE" ]; then
        rm "$FILE"
        echo "🗑️  Menghapus: $FILE"
    fi
done

# 2. Restore backup files
for BACKUP_PATTERN in "${BACKUP_FILES[@]}"; do
    LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)
    if [ -n "$LATEST_BACKUP" ]; then
        ORIGINAL_FILE=$(echo "$LATEST_BACKUP" | sed 's/\.bak_[^ ]*//')
        mv "$LATEST_BACKUP" "$ORIGINAL_FILE"
        echo "📦 Restore: $ORIGINAL_FILE"
    fi
done

# 3. Remove middleware dari Kernel (jika masih ada)
KERNEL_PATH="/var/www/pterodactyl/app/Http/Kernel.php"
if [ -f "$KERNEL_PATH" ]; then
    sed -i "/'node.access' =>.*CheckNodeAccess::class,/d" "$KERNEL_PATH"
    echo "🔧 Middleware dihapus dari Kernel"
fi

# 4. Remove middleware dari routes
ROUTES_PATH="/var/www/pterodactyl/routes/admin.php"
if [ -f "$ROUTES_PATH" ]; then
    sed -i "s/,'middleware' => \['node.access'\]//g" "$ROUTES_PATH"
    sed -i "s/'middleware' => \['node.access'\],//g" "$ROUTES_PATH"
    echo "🔄 Middleware dihapus dari Routes"
fi

# 5. Clear cache
echo "🧹 Clearing cache..."
cd /var/www/pterodactyl
php artisan view:clear --quiet
php artisan cache:clear --quiet
php artisan route:clear --quiet

# 6. Hapus backup files lainnya
echo "🧹 Membersihkan backup files tersisa..."
find /var/www/pterodactyl -name "*.bak_*" -type f -delete 2>/dev/null

echo ""
echo "🎉 Uninstall proteksi berhasil!"
echo "🔓 Akses Node Controller sekarang terbuka untuk semua admin"
echo "✅ Semua file telah di-restore ke keadaan semula"
echo "🌐 Pterodactyl berjalan normal tanpa proteksi"
