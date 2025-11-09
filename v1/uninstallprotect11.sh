#!/bin/bash

echo "🔄 MEMULAI PROSES UNINSTALL PROTEKSI ADMIN NODES - FIXED VERSION..."

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeSettingsController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ Tidak ditemukan backup file untuk NodeSettingsController"
    echo "📋 Mencari backup files yang ada:"
    ls -la $BACKUP_PATTERN 2>/dev/null || echo "Tidak ada backup files ditemukan."
else
    echo "📦 Menemukan backup file: $LATEST_BACKUP"
    echo "🔄 Mengembalikan file original..."
    
    # Backup file saat ini dulu sebelum restore
    CURRENT_BACKUP="${REMOTE_PATH}.current_bak_$(date -u +"%Y-%m-%d-%H-%M-%S")"
    if [ -f "$REMOTE_PATH" ]; then
        cp "$REMOTE_PATH" "$CURRENT_BACKUP"
        echo "📁 Backup file saat ini dibuat: $CURRENT_BACKUP"
    fi
    
    # Restore file original
    cp "$LATEST_BACKUP" "$REMOTE_PATH"
    chmod 644 "$REMOTE_PATH"
    echo "✅ NodeSettingsController berhasil dikembalikan"
fi

# PERBAIKAN KHUSUS UNTUK ROUTES ADMIN.PHP
echo ""
echo "🔧 MEMPERBAIKI FILE ROUTES ADMIN.PHP..."
ROUTES_PATH="/var/www/pterodactyl/routes/admin.php"
ROUTES_BACKUP_PATTERN="${ROUTES_PATH}.bak_*"

# Cari backup routes terbaru
LATEST_ROUTES_BACKUP=$(ls -t $ROUTES_BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_ROUTES_BACKUP" ]; then
    echo "📦 Menemukan backup routes: $LATEST_ROUTES_BACKUP"
    
    # Backup routes saat ini
    CURRENT_ROUTES_BACKUP="${ROUTES_PATH}.current_bak_$(date -u +"%Y-%m-%d-%H-%M-%S")"
    if [ -f "$ROUTES_PATH" ]; then
        cp "$ROUTES_PATH" "$CURRENT_ROUTES_BACKUP"
        echo "📁 Backup routes saat ini dibuat: $CURRENT_ROUTES_BACKUP"
    fi
    
    # Restore routes original
    cp "$LATEST_ROUTES_BACKUP" "$ROUTES_PATH"
    chmod 644 "$ROUTES_PATH"
    echo "✅ Routes admin.php berhasil dikembalikan"
else
    echo "⚠️  Tidak ada backup routes ditemukan, mencoba perbaikan manual..."
    
    # Perbaikan manual untuk bracket yang tidak tertutup
    if [ -f "$ROUTES_PATH" ]; then
        # Backup dulu
        MANUAL_BACKUP="${ROUTES_PATH}.manual_fix_bak_$(date -u +"%Y-%m-%d-%H-%M-%S")"
        cp "$ROUTES_PATH" "$MANUAL_BACKUP"
        
        # Perbaiki bracket yang tidak tertutup
        sed -i '/Route::group(\[.*middleware.*\x27strict.node\x27.*\], function () {/d' "$ROUTES_PATH"
        sed -i '/}); \/\/ End strict node middleware/d' "$ROUTES_PATH"
        
        # Pastikan bracket tertutup dengan benar
        echo "🔧 Melakukan perbaikan struktur bracket..."
        
        # Hitung bracket terbuka dan tertutup
        OPEN_BRACKETS=$(grep -o "{" "$ROUTES_PATH" | wc -l)
        CLOSE_BRACKETS=$(grep -o "}" "$ROUTES_PATH" | wc -l)
        
        echo "   Bracket terbuka: $OPEN_BRACKETS, Bracket tertutup: $CLOSE_BRACKETS"
        
        if [ $OPEN_BRACKETS -ne $CLOSE_BRACKETS ]; then
            echo "⚠️  Terdeteksi bracket tidak seimbang, melakukan perbaikan..."
            # Tambahkan bracket penutup jika diperlukan
            BRACKET_DIFF=$((OPEN_BRACKETS - CLOSE_BRACKETS))
            if [ $BRACKET_DIFF -gt 0 ]; then
                for ((i=1; i<=BRACKET_DIFF; i++)); do
                    echo "}" >> "$ROUTES_PATH"
                    echo "   ✅ Menambahkan bracket penutup ke-$i"
                done
            fi
        fi
        
        echo "✅ Perbaikan manual routes selesai"
    fi
fi

# HAPUS MIDDLEWARE FILE JIKA ADA
echo ""
echo "🗑️  MENGHAPUS MIDDLEWARE JIKA ADA..."
MIDDLEWARE_PATH="/var/www/pterodactyl/app/Http/Middleware/StrictNodeAccess.php"
if [ -f "$MIDDLEWARE_PATH" ]; then
    MIDDLEWARE_BACKUP="${MIDDLEWARE_PATH}.uninstall_bak_$(date -u +"%Y-%m-%d-%H-%M-%S")"
    cp "$MIDDLEWARE_PATH" "$MIDDLEWARE_BACKUP"
    rm "$MIDDLEWARE_PATH"
    echo "✅ Middleware file dihapus (backup: $(basename $MIDDLEWARE_BACKUP))"
else
    echo "✅ Middleware file tidak ditemukan (sudah dihapus)"
fi

# HAPUS REGISTRASI MIDDLEWARE DARI KERNEL
echo ""
echo "🔧 MENGHAPUS REGISTRASI MIDDLEWARE DARI KERNEL..."
KERNEL_PATH="/var/www/pterodactyl/app/Http/Kernel.php"
if [ -f "$KERNEL_PATH" ]; then
    if grep -q "strict.node" "$KERNEL_PATH"; then
        KERNEL_BACKUP="${KERNEL_PATH}.uninstall_bak_$(date -u +"%Y-%m-%d-%H-%M-%S")"
        cp "$KERNEL_PATH" "$KERNEL_BACKUP"
        
        # Hapus baris registrasi middleware
        sed -i "/'strict.node' =>.*StrictNodeAccess::class,/d" "$KERNEL_PATH"
        echo "✅ Registrasi middleware dihapus dari Kernel"
    else
        echo "✅ Registrasi middleware tidak ditemukan di Kernel"
    fi
else
    echo "⚠️  Kernel file tidak ditemukan"
fi

# CLEAR CACHE
echo ""
echo "🔄 MEMBERSIHKAN CACHE..."
sudo php /var/www/pterodactyl/artisan cache:clear
sudo php /var/www/pterodactyl/artisan route:clear
sudo php /var/www/pterodactyl/artisan view:clear
sudo php /var/www/pterodactyl/artisan config:clear

echo ""
echo "🎉 UNINSTALL FIXED SELESAI!"
echo "🔓 Semua proteksi telah dihapus"
echo "🔧 File routes admin.php telah diperbaiki"
echo "💫 Sistem kembali ke state normal"
