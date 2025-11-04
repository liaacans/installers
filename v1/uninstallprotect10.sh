#!/bin/bash

echo "🗑️  Menghapus Proteksi Level 10..."

# List file yang diproteksi
PROTECTED_FILES=(
    "/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ViewController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerTableController.php"
)

# List backup files
BACKUP_FILES=()
for file in "${PROTECTED_FILES[@]}"; do
    if [ -f "${file}.bak_"* ]; then
        BACKUP_FILES+=($(ls -t "${file}.bak_"* 2>/dev/null | head -1))
    fi
done

if [ ${#BACKUP_FILES[@]} -eq 0 ]; then
    echo "❌ Tidak ada backup file ditemukan untuk restore."
    echo "📋 File yang dicari:"
    for file in "${PROTECTED_FILES[@]}"; do
        echo "   - ${file}.bak_*"
    done
    exit 1
fi

echo "📦 Backup files yang ditemukan:"
for backup in "${BACKUP_FILES[@]}"; do
    echo "   - $backup"
done

echo ""
read -p "⚠️  Apakah Anda yakin ingin menghapus proteksi dan restore backup? (y/N): " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "❌ Operasi dibatalkan."
    exit 0
fi

# Restore backup files
for backup_file in "${BACKUP_FILES[@]}"; do
    original_file="${backup_file%.bak_*}"
    
    if [ -f "$backup_file" ]; then
        mv "$backup_file" "$original_file"
        echo "✅ Restored: $original_file"
    fi
done

echo ""
echo "♻️  Menjalankan optimasi Pterodactyl..."
cd /var/www/pterodactyl
php artisan optimize:clear
php artisan view:clear
php artisan cache:clear

echo ""
echo "✅ Proteksi Level 10 berhasil dihapus!"
echo "🔄 Semua file telah dikembalikan ke versi original."
echo "🎯 Sistem kembali ke mode akses normal."
