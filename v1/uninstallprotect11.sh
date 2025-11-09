#!/bin/bash

echo "🗑️  Menghapus proteksi Anti Akses Admin Node View..."

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "🔄 Mengembalikan backup file..."
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ Backup berhasil dikembalikan: $(basename $LATEST_BACKUP)"
else
    echo "⚠️  Tidak ada backup file ditemukan, menghapus file proteksi..."
    if [ -f "$REMOTE_PATH" ]; then
        rm "$REMOTE_PATH"
        echo "✅ File proteksi dihapus"
    else
        echo "ℹ️  File proteksi tidak ditemukan"
    fi
fi

# Hapus view files yang diproteksi
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
VIEW_FILES=("settings.blade.php" "configuration.blade.php" "allocation.blade.php" "servers.blade.php")

for view_file in "${VIEW_FILES[@]}"; do
    if [ -f "$VIEW_PATH/$view_file" ]; then
        rm "$VIEW_PATH/$view_file"
        echo "✅ View file dihapus: $view_file"
    fi
done

# Clear view cache
echo "🧹 Membersihkan cache views..."
cd /var/www/pterodactyl
php artisan view:clear 2>/dev/null || echo "⚠️ Gagal clear view cache"
php artisan cache:clear 2>/dev/null || echo "⚠️ Gagal clear cache"

echo "🎉 Uninstall proteksi berhasil diselesaikan!"
echo "🔓 Semua admin sekarang bisa mengakses halaman nodes view normal"
echo "💡 Jangan lupa restart worker queue jika diperlukan"
