#!/bin/bash

echo "🛠️  Menghapus proteksi Anti Tautan Server View..."

VIEW_DIR="/var/www/pterodactyl/resources/views/admin/servers/view"

if [ ! -d "$VIEW_DIR" ]; then
    echo "❌ Directory view tidak ditemukan: $VIEW_DIR"
    exit 1
fi

echo "🔄 Memulihkan semua file view dari backup..."

# Restore semua file dari backup
find "$VIEW_DIR" -name "*.blade.php.bak_*" | while read backup_file; do
    original_file="${backup_file%.bak_*}"
    echo "✅ Memulihkan: $(basename "$original_file")"
    mv "$backup_file" "$original_file"
done

# Hapus file protected yang tidak ada backupnya
find "$VIEW_DIR" -name "*.blade.php" | while read view_file; do
    if grep -q "SERVER PROTECTION ACTIVE" "$view_file" 2>/dev/null || 
       grep -q "ginaabaikhati" "$view_file" 2>/dev/null; then
        echo "🗑️  Menghapus protected view: $(basename "$view_file")"
        rm -f "$view_file"
    fi
done

# Hapus file default catch-all
if [ -f "$VIEW_DIR/default.blade.php" ]; then
    rm -f "$VIEW_DIR/default.blade.php"
    echo "🗑️  Menghapus default catch-all view"
fi

# Clear cache
echo "🔄 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear
php artisan cache:clear

echo ""
echo "🎉 UNINSTALL BERHASIL!"
echo "✅ Semua proteksi view server telah dihapus"
echo "✅ Tautan view server sekarang dapat diakses normal"
echo "✅ Server management kembali berfungsi"
echo "🔓 Sistem kembali normal"

echo ""
echo "📝 Backup file disimpan dengan ekstensi .bak_*"
echo "   File asli telah dipulihkan dari backup"
