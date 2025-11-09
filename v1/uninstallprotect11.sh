#!/bin/bash

echo "🗑️  Menghapus proteksi Anti Akses Admin Node View..."

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "🔄 Mengembalikan backup file controller..."
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ Backup berhasil dikembalikan: $(basename $LATEST_BACKUP)"
else
    echo "⚠️  Tidak ada backup controller ditemukan"
fi

# Hapus view file yang diproteksi
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view/index.blade.php"
if [ -f "$VIEW_PATH" ]; then
    rm "$VIEW_PATH"
    echo "✅ View file proteksi dihapus"
fi

# Hapus routes protected
ROUTES_PATH="/var/www/pterodactyl/routes/protected_nodes.php"
if [ -f "$ROUTES_PATH" ]; then
    rm "$ROUTES_PATH"
    echo "✅ Routes proteksi dihapus"
fi

# Clear cache
echo "🧹 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear 2>/dev/null && echo "✅ View cache cleared" || echo "⚠️ Gagal clear view cache"
php artisan route:clear 2>/dev/null && echo "✅ Route cache cleared" || echo "⚠️ Gagal clear route cache"
php artisan cache:clear 2>/dev/null && echo "✅ Application cache cleared" || echo "⚠️ Gagal clear app cache"

echo ""
echo "🎉 Uninstall proteksi berhasil diselesaikan!"
echo "🔓 Semua admin sekarang bisa mengakses nodes view normal"
echo "💡 Jika ada masalah, restart queue worker: php artisan queue:restart"
