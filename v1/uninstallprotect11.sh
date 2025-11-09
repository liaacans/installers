#!/bin/bash

echo "🎯 MEMULAI UNINSTALL COMPLETE SEMUA PROTEKSI NODES"
echo "=================================================="

# Function untuk log
log() {
    echo "📝 $1"
}

# Function untuk check success
check_success() {
    if [ $? -eq 0 ]; then
        echo "✅ $1"
    else
        echo "❌ $1"
    fi
}

# 1. Uninstall Basic Controller Protection
log "1. Uninstalling Basic Controller Protection..."
REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeSettingsController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    CURRENT_BACKUP="${REMOTE_PATH}.complete_uninstall_bak_$(date -u +"%Y-%m-%d-%H-%M-%S")"
    [ -f "$REMOTE_PATH" ] && cp "$REMOTE_PATH" "$CURRENT_BACKUP"
    cp "$LATEST_BACKUP" "$REMOTE_PATH"
    chmod 644 "$REMOTE_PATH"
    check_success "Basic controller protection diuninstall"
else
    echo "⚠️  Tidak ada backup basic controller ditemukan"
fi

# 2. Uninstall Full Controller Protection
log "2. Uninstalling Full Controller Protection..."
CONTROLLERS=(
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeAllocationController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeServiceController.php"
)

for CONTROLLER_PATH in "${CONTROLLERS[@]}"; do
    BACKUP_PATTERN="${CONTROLLER_PATH}.bak_*"
    LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)
    
    if [ -n "$LATEST_BACKUP" ]; then
        CURRENT_BACKUP="${CONTROLLER_PATH}.complete_uninstall_bak_$(date -u +"%Y-%m-%d-%H-%M-%S")"
        [ -f "$CONTROLLER_PATH" ] && cp "$CONTROLLER_PATH" "$CURRENT_BACKUP"
        cp "$LATEST_BACKUP" "$CONTROLLER_PATH"
        chmod 644 "$CONTROLLER_PATH"
        echo "   ✅ $(basename $CONTROLLER_PATH) dikembalikan"
    fi
done
check_success "Full controller protection diuninstall"

# 3. Uninstall Middleware Protection
log "3. Uninstalling Middleware Protection..."
MIDDLEWARE_PATH="/var/www/pterodactyl/app/Http/Middleware/StrictNodeAccess.php"
KERNEL_PATH="/var/www/pterodactyl/app/Http/Kernel.php"
ROUTES_PATH="/var/www/pterodactyl/routes/admin.php"

# Hapus middleware file
if [ -f "$MIDDLEWARE_PATH" ]; then
    MIDDLEWARE_BACKUP="${MIDDLEWARE_PATH}.complete_uninstall_bak_$(date -u +"%Y-%m-%d-%H-%M-%S")"
    cp "$MIDDLEWARE_PATH" "$MIDDLEWARE_BACKUP"
    rm "$MIDDLEWARE_PATH"
    echo "   ✅ Middleware file dihapus"
fi

# Hapus dari Kernel
if [ -f "$KERNEL_PATH" ] && grep -q "strict.node" "$KERNEL_PATH"; then
    KERNEL_BACKUP="${KERNEL_PATH}.complete_uninstall_bak_$(date -u +"%Y-%m-%d-%H-%M-%S")"
    cp "$KERNEL_PATH" "$KERNEL_BACKUP"
    sed -i "/'strict.node' =>.*StrictNodeAccess::class,/d" "$KERNEL_PATH"
    echo "   ✅ Middleware dihapus dari Kernel"
fi

# Hapus dari routes
if [ -f "$ROUTES_PATH" ] && grep -q "strict.node" "$ROUTES_PATH"; then
    ROUTES_BACKUP="${ROUTES_PATH}.complete_uninstall_bak_$(date -u +"%Y-%m-%d-%H-%M-%S")"
    cp "$ROUTES_PATH" "$ROUTES_BACKUP"
    sed -i "/Route::group(['middleware' => 'strict.node'], function () {/d" "$ROUTES_PATH"
    sed -i "/}); \/\/ End strict node middleware/d" "$ROUTES_PATH"
    echo "   ✅ Middleware dihapus dari routes"
fi

check_success "Middleware protection diuninstall"

# 4. Final cleanup
log "4. Melakukan final cleanup..."
sudo php /var/www/pterodactyl/artisan cache:clear
sudo php /var/www/pterodactyl/artisan route:clear
sudo php /var/www/pterodactyl/artisan view:clear
sudo php /var/www/pterodactyl/artisan config:clear

check_success "Cache cleared"

echo ""
echo "=================================================="
echo "🎉 UNINSTALL COMPLETE SELESAI!"
echo "🔓 SEMUA proteksi telah dihapus"
echo "📊 Semua file telah dikembalikan ke state original"
echo "💫 Backup files disimpan dengan prefix: complete_uninstall_bak"
echo ""
echo "📌 Semua admin sekarang bisa mengakses node settings normal"
echo "=================================================="
