#!/bin/bash

echo "🗑️ Menghapus proteksi Security Panel Admin Nodes View..."

# File utama
REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesViewController.php"
BACKUP_PATTERN="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesViewController.php.bak_*"

# File tambahan
ADDITIONAL_PATTERNS=(
    "/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php.bak_*"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php.bak_*"
)

# View templates
VIEW_PATTERNS=(
    "/var/www/pterodactyl/resources/views/admin/nodes/index.blade.php.bak_*"
    "/var/www/pterodactyl/resources/views/admin/nodes/view.blade.php.bak_*"
    "/var/www/pterodactyl/resources/views/admin/nodes/settings.blade.php.bak_*"
    "/var/www/pterodactyl/resources/views/admin/nodes/configuration.blade.php.bak_*"
)

# Restore file utama
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ Backup utama dikembalikan: $LATEST_BACKUP"
else
    echo "⚠️ Tidak ada backup utama ditemukan"
fi

# Restore file tambahan
for PATTERN in "${ADDITIONAL_PATTERNS[@]}"; do
    for BACKUP_FILE in $PATTERN; do
        if [ -f "$BACKUP_FILE" ]; then
            ORIGINAL_FILE="${BACKUP_FILE%.bak_*}"
            mv "$BACKUP_FILE" "$ORIGINAL_FILE"
            echo "✅ Backup additional dikembalikan: $BACKUP_FILE"
        fi
    done
done

# Restore view templates
for PATTERN in "${VIEW_PATTERNS[@]}"; do
    for BACKUP_FILE in $PATTERN; do
        if [ -f "$BACKUP_FILE" ]; then
            ORIGINAL_FILE="${BACKUP_FILE%.bak_*}"
            mv "$BACKUP_FILE" "$ORIGINAL_FILE"
            echo "✅ Backup view dikembalikan: $BACKUP_FILE"
        fi
    done
done

# Hapus security code dari view templates yang tidak ada backup
VIEW_PATHS=(
    "/var/www/pterodactyl/resources/views/admin/nodes/index.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/view.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/settings.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/configuration.blade.php"
)

for VIEW_PATH in "${VIEW_PATHS[@]}"; do
    if [ -f "$VIEW_PATH" ]; then
        # Hapus security code
        sed -i '/@if(auth()->check() && auth()->user()->id !== 1)/,/@endif/d' "$VIEW_PATH"
        sed -i '/SECURITY RESTRICTION/d' "$VIEW_PATH"
        sed -i '/Akses ditolak, protect by @naaofficiall/d' "$VIEW_PATH"
        sed -i '/Hanya Administrator Utama/d' "$VIEW_PATH"
        echo "✅ Security code dihapus dari: $VIEW_PATH"
    fi
done

# Clear cache
cd /var/www/pterodactyl
php artisan cache:clear
php artisan view:clear
php artisan config:clear

echo "✅ Proteksi Security Panel berhasil dihapus sepenuhnya!"
echo "🔓 Semua admin sekarang bisa mengakses semua nodes"
echo "🔄 Cache telah dibersihkan"
echo "📋 Semua file backup telah dikembalikan ke original"
