#!/bin/bash

echo "🗑️  Menghapus proteksi Anti Akses Admin Node View..."

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "🔄 Mengembalikan backup controller..."
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ Controller backup berhasil dikembalikan: $(basename $LATEST_BACKUP)"
else
    echo "⚠️  Tidak ada backup controller ditemukan"
    if [ -f "$REMOTE_PATH" ]; then
        echo "🗑️  Menghapus file controller proteksi..."
        rm "$REMOTE_PATH"
    fi
fi

# Hapus view files yang diproteksi
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
VIEW_FILES=("index.blade.php" "settings.blade.php" "configuration.blade.php" "allocation.blade.php" "servers.blade.php")

echo "🗑️  Menghapus view files proteksi..."
for view_file in "${VIEW_FILES[@]}"; do
    if [ -f "$VIEW_PATH/$view_file" ]; then
        rm "$VIEW_PATH/$view_file"
        echo "✅ View file dihapus: $view_file"
    else
        echo "ℹ️  View file tidak ditemukan: $view_file"
    fi
done

# Clear cache
echo "🧹 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear 2>/dev/null && echo "✅ View cache cleared" || echo "⚠️ Gagal clear view cache"
php artisan cache:clear 2>/dev/null && echo "✅ Application cache cleared" || echo "⚠️ Gagal clear cache"
php artisan config:clear 2>/dev/null && echo "✅ Config cache cleared" || echo "⚠️ Gagal clear config cache"

echo ""
echo "🎉 Uninstall proteksi berhasil diselesaikan!"
echo "🔓 Semua admin sekarang bisa mengakses halaman nodes view normal"
echo "💡 System telah dikembalikan ke state original Pterodactyl"
echo ""
echo "📋 Status:"
echo "   ✅ Controller original dikembalikan"
echo "   ✅ View files proteksi dihapus" 
echo "   ✅ Cache dibersihkan"
echo "   ✅ Akses normal untuk semua admin"
