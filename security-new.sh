#!/bin/bash

# security.sh - Security Panel Pterodactyl by @ginaabaikhati
# Script ini hanya boleh dijalankan di server Pterodactyl yang sah

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variabel global
PANEL_DIR="/var/www/pterodactyl"
BACKUP_DIR="/root/pterodactyl_backup"
ERROR_MESSAGE="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Fungsi untuk mengecek apakah ini server Pterodactyl yang valid
check_pterodactyl_environment() {
    echo -e "${BLUE}[INFO]${NC} Mengecek environment Pterodactyl..."
    
    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "${RED}[ERROR]${NC} Directory Pterodactyl tidak ditemukan di $PANEL_DIR"
        echo -e "${RED}[ERROR]${NC} Script ini hanya bisa dijalankan di server Pterodactyl yang valid!"
        exit 1
    fi
    
    if [ ! -f "$PANEL_DIR/app/Http/Controllers/Admin" ]; then
        echo -e "${RED}[ERROR]${NC} Struktur directory tidak sesuai dengan Pterodactyl Panel!"
        echo -e "${RED}[ERROR]${NC} Script ini hanya bisa dijalankan di server Pterodactyl yang valid!"
        exit 1
    fi
    
    # Cek apakah user adalah root
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[ERROR]${NC} Script harus dijalankan sebagai root!"
        exit 1
    fi
    
    echo -e "${GREEN}[SUCCESS]${NC} Environment Pterodactyl terdeteksi!"
}

# Fungsi untuk membuat backup
create_backup() {
    echo -e "${BLUE}[INFO]${NC} Membuat backup file yang akan dimodifikasi..."
    
    mkdir -p $BACKUP_DIR
    
    # Backup file yang akan dimodifikasi
    cp $PANEL_DIR/app/Http/Controllers/Admin/*Controller.php $BACKUP_DIR/ 2>/dev/null || true
    cp $PANEL_DIR/app/Http/Middleware/AdminAuthenticate.php $BACKUP_DIR/ 2>/dev/null || true
    cp $PANEL_DIR/routes/admin.php $BACKUP_DIR/ 2>/dev/null || true
    
    echo -e "${GREEN}[SUCCESS]${NC} Backup berhasil dibuat di $BACKUP_DIR"
}

# Fungsi untuk install security
install_security() {
    echo -e "${BLUE}[INFO]${NC} Memulai instalasi security panel..."
    
    check_pterodactyl_environment
    create_backup
    
    # 1. Modifikasi Admin Controller untuk menambahkan security check
    echo -e "${BLUE}[INFO]${NC} Memodifikasi Admin Controllers..."
    
    # File controller yang akan dimodifikasi
    CONTROLLERS=(
        "SettingsController.php"
        "NodeController.php" 
        "LocationController.php"
        "NestController.php"
        "UserController.php"
        "ServerController.php"
    )
    
    for controller in "${CONTROLLERS[@]}"; do
        if [ -f "$PANEL_DIR/app/Http/Controllers/Admin/$controller" ]; then
            # Backup file asli
            cp "$PANEL_DIR/app/Http/Controllers/Admin/$controller" "$BACKUP_DIR/${controller}.original"
            
            # Tambahkan security check di setiap method yang berbahaya
            sed -i '/public function [a-zA-Z]*/{
:loop
N
/\n    {/!b loop
a\
        \\/\\/ Security Check by @ginaabaikhati\
        if (\\\\auth()->user()->id !== 1) {\
            return redirect()->route('"'"'admin.index'"'"')->with('"'"'error'"'"', '"'"''"$ERROR_MESSAGE"''"'"');\
        }
}' "$PANEL_DIR/app/Http/Controllers/Admin/$controller"
            
            echo -e "${GREEN}[SUCCESS]${NC} Modifikasi $controller selesai"
        else
            echo -e "${YELLOW}[WARNING]${NC} File $controller tidak ditemukan, skip..."
        fi
    done
    
    # 2. Modifikasi routes admin.php untuk tambahan security middleware
    echo -e "${BLUE}[INFO]${NC} Memodifikasi admin routes..."
    
    if [ -f "$PANEL_DIR/routes/admin.php" ]; then
        cp "$PANEL_DIR/routes/admin.php" "$BACKUP_DIR/admin.php.original"
        
        # Tambahkan security middleware untuk routes yang berbahaya
        sed -i 's/Route::delete/Route::middleware('"'"'admin.security'"'"')->delete/g' "$PANEL_DIR/routes/admin.php"
        sed -i 's/Route::post/Route::middleware('"'"'admin.security'"'"')->post/g' "$PANEL_DIR/routes/admin.php" 
        sed -i 's/Route::put/Route::middleware('"'"'admin.security'"'"')->put/g' "$PANEL_DIR/routes/admin.php"
        sed -i 's/Route::patch/Route::middleware('"'"'admin.security'"'"')->patch/g' "$PANEL_DIR/routes/admin.php"
        
        echo -e "${GREEN}[SUCCESS]${NC} Modifikasi admin routes selesai"
    fi
    
    # 3. Buat custom middleware untuk security check
    echo -e "${BLUE}[INFO]${NC} Membuat custom middleware..."
    
    cat > "$PANEL_DIR/app/Http/Middleware/AdminSecurity.php" << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminSecurity
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        // Hanya user dengan ID 1 yang bisa akses fungsi berbahaya
        if (auth()->user()->id !== 1) {
            return redirect()->route('admin.index')->with('error', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return $next($request);
    }
}
EOF

    echo -e "${GREEN}[SUCCESS]${NC} Custom middleware dibuat"
    
    # 4. Register middleware di Kernel.php
    echo -e "${BLUE}[INFO]${NC} Mendaftarkan middleware..."
    
    if [ -f "$PANEL_DIR/app/Http/Kernel.php" ]; then
        cp "$PANEL_DIR/app/Http/Kernel.php" "$BACKUP_DIR/Kernel.php.original"
        
        # Tambahkan middleware ke $routeMiddleware
        sed -i "/protected \$routeMiddleware = \[/a\
        'admin.security' => \\\\App\\\\Http\\\\Middleware\\\\AdminSecurity::class," "$PANEL_DIR/app/Http/Kernel.php"
        
        echo -e "${GREEN}[SUCCESS]${NC} Middleware terdaftar"
    fi
    
    # 5. Clear cache dan optimize
    echo -e "${BLUE}[INFO]${NC} Membersihkan cache..."
    
    cd $PANEL_DIR
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    
    echo -e "${GREEN}[SUCCESS]${NC} Instalasi security panel selesai!"
    echo -e "${YELLOW}[NOTE]${NC} Hanya user dengan ID 1 yang bisa mengubah settings, nodes, locations, nests, dan menghapus/modifikasi user/server lain"
}

# Fungsi untuk mengubah teks error
change_error_text() {
    echo -e "${BLUE}[INFO]${NC} Mengubah teks error security..."
    
    read -p "Masukkan teks error baru: " new_error_text
    
    if [ -z "$new_error_text" ]; then
        echo -e "${RED}[ERROR]${NC} Teks error tidak boleh kosong!"
        return 1
    fi
    
    # Update variabel global
    ERROR_MESSAGE="$new_error_text"
    
    # Update semua file controller dengan teks error baru
    CONTROLLERS=(
        "SettingsController.php"
        "NodeController.php" 
        "LocationController.php"
        "NestController.php"
        "UserController.php"
        "ServerController.php"
    )
    
    for controller in "${CONTROLLERS[@]}"; do
        if [ -f "$PANEL_DIR/app/Http/Controllers/Admin/$controller" ]; then
            # Escape special characters untuk sed
            escaped_text=$(printf '%s\n' "$ERROR_MESSAGE" | sed 's/[[\.*^$/]/\\&/g')
            
            # Update teks error
            sed -i "s/return redirect()->route('admin.index')->with('error', '.*');/return redirect()->route('admin.index')->with('error', '$escaped_text');/g" "$PANEL_DIR/app/Http/Controllers/Admin/$controller"
        fi
    done
    
    # Update middleware juga
    if [ -f "$PANEL_DIR/app/Http/Middleware/AdminSecurity.php" ]; then
        escaped_text=$(printf '%s\n' "$ERROR_MESSAGE" | sed 's/[[\.*^$/]/\\&/g')
        sed -i "s/->with('error', '.*');/->with('error', '$escaped_text');/g" "$PANEL_DIR/app/Http/Middleware/AdminSecurity.php"
    fi
    
    # Clear cache
    cd $PANEL_DIR
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    
    echo -e "${GREEN}[SUCCESS]${NC} Teks error berhasil diubah menjadi: $ERROR_MESSAGE"
}

# Fungsi untuk uninstall security
uninstall_security() {
    echo -e "${BLUE}[INFO]${NC} Memulai uninstall security panel..."
    
    check_pterodactyl_environment
    
    # 1. Restore file controller dari backup
    echo -e "${BLUE}[INFO]${NC} Merestore controller files..."
    
    CONTROLLERS=(
        "SettingsController.php"
        "NodeController.php" 
        "LocationController.php"
        "NestController.php"
        "UserController.php"
        "ServerController.php"
    )
    
    for controller in "${CONTROLLERS[@]}"; do
        if [ -f "$BACKUP_DIR/${controller}.original" ]; then
            cp "$BACKUP_DIR/${controller}.original" "$PANEL_DIR/app/Http/Controllers/Admin/$controller"
            echo -e "${GREEN}[SUCCESS]${NC} Restore $controller selesai"
        fi
    done
    
    # 2. Restore admin routes
    if [ -f "$BACKUP_DIR/admin.php.original" ]; then
        cp "$BACKUP_DIR/admin.php.original" "$PANEL_DIR/routes/admin.php"
        echo -e "${GREEN}[SUCCESS]${NC} Restore admin routes selesai"
    fi
    
    # 3. Restore Kernel.php
    if [ -f "$BACKUP_DIR/Kernel.php.original" ]; then
        cp "$BACKUP_DIR/Kernel.php.original" "$PANEL_DIR/app/Http/Kernel.php"
        echo -e "${GREEN}[SUCCESS]${NC} Restore Kernel.php selesai"
    fi
    
    # 4. Hapus custom middleware
    if [ -f "$PANEL_DIR/app/Http/Middleware/AdminSecurity.php" ]; then
        rm "$PANEL_DIR/app/Http/Middleware/AdminSecurity.php"
        echo -e "${GREEN}[SUCCESS]${NC} Middleware dihapus"
    fi
    
    # 5. Clear cache
    echo -e "${BLUE}[INFO]${NC} Membersihkan cache..."
    
    cd $PANEL_DIR
    php artisan config:clear
    php artisan route:clear
    php artisan view:clear
    php artisan cache:clear
    
    echo -e "${GREEN}[SUCCESS]${NC} Uninstall security panel selesai!"
    echo -e "${YELLOW}[NOTE]${NC} Panel Pterodactyl telah dikembalikan ke keadaan semula"
}

# Fungsi utama
main() {
    clear
    echo -e "${GREEN}"
    echo "================================================"
    echo "    Security Panel Pterodactyl"
    echo "    By @ginaabaikhati"
    echo "================================================"
    echo -e "${NC}"
    
    while true; do
        echo
        echo -e "${BLUE}Pilihan Menu:${NC}"
        echo "1. Install Security Panel"
        echo "2. Ubah Teks Error" 
        echo "3. Uninstall Security Panel"
        echo "4. Exit"
        echo
        read -p "Pilih menu [1-4]: " choice
        
        case $choice in
            1)
                install_security
                ;;
            2)
                change_error_text
                ;;
            3)
                uninstall_security
                ;;
            4)
                echo -e "${GREEN}[INFO]${NC} Keluar dari script..."
                exit 0
                ;;
            *)
                echo -e "${RED}[ERROR]${NC} Pilihan tidak valid!"
                ;;
        esac
        
        echo
        read -p "Tekan Enter untuk melanjutkan..."
        clear
        echo -e "${GREEN}"
        echo "================================================"
        echo "    Security Panel Pterodactyl"
        echo "    By @ginaabaikhati"
        echo "================================================"
        echo -e "${NC}"
    done
}

# Protection: Cek environment sebelum menjalankan
check_pterodactyl_environment

# Jalankan fungsi utama
main "$@"
