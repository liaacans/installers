#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default error message
ERROR_MESSAGE="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Function to display header
display_header() {
    clear
    echo -e "${BLUE}"
    echo "=========================================="
    echo "    Pterodactyl Security Panel Installer"
    echo "=========================================="
    echo -e "${NC}"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}Error: Jangan jalankan script ini sebagai root!${NC}"
        exit 1
    fi
}

# Function to check Pterodactyl installation
check_pterodactyl() {
    if [ ! -f "/var/www/pterodactyl/app/Http/Controllers/Controller.php" ]; then
        echo -e "${RED}Error: Pterodactyl tidak ditemukan!${NC}"
        echo "Pastikan Pterodactyl terinstall di /var/www/pterodactyl"
        exit 1
    fi
}

# Function to backup files
backup_files() {
    echo -e "${YELLOW}Membuat backup file...${NC}"
    sudo cp -r /var/www/pterodactyl /var/www/pterodactyl_backup_$(date +%Y%m%d_%H%M%S)
    echo -e "${GREEN}Backup berhasil dibuat!${NC}"
}

# Function to install security
install_security() {
    display_header
    echo -e "${YELLOW}Memulai instalasi security panel...${NC}"
    
    check_root
    check_pterodactyl
    backup_files
    
    # Create security middleware
    echo -e "${YELLOW}Membuat security middleware...${NC}"
    
    sudo cat > /var/www/pterodactyl/app/Http/Middleware/SecurityMiddleware.php << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SecurityMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        $routeName = $request->route()->getName();
        $path = $request->path();
        
        // ID 1 memiliki akses penuh
        if ($user && $user->id === 1) {
            return $next($request);
        }

        // Lock settings admin dan application api
        $lockedRoutes = [
            'admin.settings', 'admin.api', 'admin.nodes', 'admin.locations',
            'admin.nests', 'admin.users', 'admin.servers'
        ];

        $lockedPaths = [
            'admin/settings', 'admin/api', 'admin/nodes', 'admin/locations',
            'admin/nests', 'admin/users', 'admin/servers'
        ];

        foreach ($lockedRoutes as $route) {
            if (strpos($routeName, $route) !== false) {
                abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
            }
        }

        foreach ($lockedPaths as $lockedPath) {
            if (strpos($path, $lockedPath) !== false) {
                abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
            }
        }

        // Lock specific actions untuk user lain
        if ($user && $user->id !== 1) {
            // Lock delete/ubah/edit untuk nests, locations, nodes
            if ($request->isMethod('POST') || $request->isMethod('PUT') || $request->isMethod('DELETE')) {
                $restrictedPaths = ['nests', 'locations', 'nodes', 'users'];
                foreach ($restrictedPaths as $restricted) {
                    if (strpos($path, $restricted) !== false) {
                        abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
                    }
                }
            }

            // Lock view server lain
            if (strpos($path, 'server') !== false && !$this->isUserServer($user, $request)) {
                abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
            }
        }

        return $next($request);
    }

    private function isUserServer($user, $request): bool
    {
        // Implementasi logika untuk mengecek apakah server milik user
        // Ini adalah implementasi sederhana, sesuaikan dengan kebutuhan
        $serverId = $request->route('server');
        if (!$serverId) return false;

        // Logika pengecekan ownership server
        // Di sini Anda perlu menyesuaikan dengan model yang sesuai
        return true;
    }
}
EOF

    # Update Kernel.php untuk menambahkan middleware
    echo -e "${YELLOW}Memperbarui Kernel.php...${NC}"
    
    # Backup Kernel.php terlebih dahulu
    sudo cp /var/www/pterodactyl/app/Http/Kernel.php /var/www/pterodactyl/app/Http/Kernel.php.backup
    
    # Tambahkan middleware ke Kernel.php
    sudo sed -i "/protected \$middlewareGroups = \[/a\        'security' => \\\\Pterodactyl\\\\Http\\\\Middleware\\\\SecurityMiddleware::class," /var/www/pterodactyl/app/Http/Kernel.php
    
    # Update routes untuk menerapkan middleware
    echo -e "${YELLOW}Memperbarui routes...${NC}"
    
    # Backup routes
    sudo cp /var/www/pterodactyl/routes/web.php /var/www/pterodactyl/routes/web.php.backup
    
    # Tambahkan middleware ke routes yang diperlukan
    sudo sed -i "1i<?php" /var/www/pterodactyl/routes/web.php
    sudo sed -i "/Route::group(\['prefix' => 'admin', 'namespace' => 'Admin', 'middleware' => \[/s/];/', 'security']];/" /var/www/pterodactyl/routes/web.php
    
    # Update LocaleController.php untuk fix error
    echo -e "${YELLOW}Memperbaiki LocaleController.php...${NC}"
    
    sudo cat > /var/www/pterodactyl/app/Http/Controllers/LocaleController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class LocaleController extends Controller
{
    public function __invoke(Request $request, string $locale)
    {
        $user = $request->user();
        
        // Security check untuk user selain ID 1
        if ($user && $user->id !== 1) {
            $allowedPaths = ['dashboard', 'account', 'server'];
            $currentPath = $request->path();
            
            $isAllowed = false;
            foreach ($allowedPaths as $path) {
                if (strpos($currentPath, $path) !== false) {
                    $isAllowed = true;
                    break;
                }
            }
            
            if (!$isAllowed && strpos($currentPath, 'admin') !== false) {
                abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
            }
        }
        
        if (!in_array($locale, config('app.locales', ['en', 'de', 'fr', 'pt', 'ru', 'th', 'pl', 'ko', 'ja', 'zh']))) {
            return response()->json(['error' => 'Invalid locale.'], 400);
        }

        $request->session()->put('locale', $locale);

        return response()->json(['success' => true]);
    }
}
EOF

    # Update AdminController untuk security tambahan
    echo -e "${YELLOW}Menambahkan security ke AdminController...${NC}"
    
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/AdminController.php" ]; then
        sudo cp /var/www/pterodactyl/app/Http/Controllers/Admin/AdminController.php /var/www/pterodactyl/app/Http/Controllers/Admin/AdminController.php.backup
        
        sudo sed -i '/public function __construct()/a\        $this->middleware(function ($request, $next) {\n            if (auth()->check() && auth()->user()->id !== 1) {\n                abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");\n            }\n            return $next($request);\n        });' /var/www/pterodactyl/app/Http/Controllers/Admin/AdminController.php
    fi

    # Update file Controller.php jika tidak ada
    if [ ! -f "/var/www/pterodactyl/app/Http/Controllers/Controller.php" ]; then
        sudo cat > /var/www/pterodactyl/app/Http/Controllers/Controller.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers;

use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Routing\Controller as BaseController;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class Controller extends BaseController
{
    use AuthorizesRequests, DispatchesJobs, ValidatesRequests;
}
EOF
    fi

    # Jalankan optimasi Laravel
    echo -e "${YELLOW}Menjalankan optimasi Laravel...${NC}"
    sudo php /var/www/pterodactyl/artisan config:cache
    sudo php /var/www/pterodactyl/artisan route:cache
    sudo php /var/www/pterodactyl/artisan view:cache

    # Set permissions
    sudo chown -R www-data:www-data /var/www/pterodactyl/
    sudo chmod -R 755 /var/www/pterodactyl/

    echo -e "${GREEN}Instalasi security panel berhasil!${NC}"
    echo -e "${YELLOW}Security telah diaktifkan. Hanya user dengan ID 1 yang memiliki akses penuh.${NC}"
    read -p "Tekan Enter untuk melanjutkan..."
}

# Function to change error text
change_error_text() {
    display_header
    echo -e "${YELLOW}Ubah Teks Error${NC}"
    echo ""
    read -p "Masukkan teks error baru: " new_error_text
    
    if [ -n "$new_error_text" ]; then
        ERROR_MESSAGE="$new_error_text"
        echo -e "${YELLOW}Memperbarui teks error...${NC}"
        
        # Update teks error di semua file
        sudo find /var/www/pterodactyl -type f -name "*.php" -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_error_text}/g" {} \;
        
        # Update middleware
        if [ -f "/var/www/pterodactyl/app/Http/Middleware/SecurityMiddleware.php" ]; then
            sudo sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_error_text}/g" /var/www/pterodactyl/app/Http/Middleware/SecurityMiddleware.php
        fi
        
        # Update LocaleController
        if [ -f "/var/www/pterodactyl/app/Http/Controllers/LocaleController.php" ]; then
            sudo sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_error_text}/g" /var/www/pterodactyl/app/Http/Controllers/LocaleController.php
        fi
        
        # Clear cache
        sudo php /var/www/pterodactyl/artisan config:clear
        sudo php /var/www/pterodactyl/artisan route:clear
        sudo php /var/www/pterodactyl/artisan view:clear
        
        echo -e "${GREEN}Teks error berhasil diubah!${NC}"
    else
        echo -e "${RED}Teks error tidak boleh kosong!${NC}"
    fi
    read -p "Tekan Enter untuk melanjutkan..."
}

# Function to uninstall security
uninstall_security() {
    display_header
    echo -e "${YELLOW}Memulai uninstall security panel...${NC}"
    
    # Restore backup files
    if [ -f "/var/www/pterodactyl/app/Http/Kernel.php.backup" ]; then
        echo -e "${YELLOW}Memulihkan Kernel.php...${NC}"
        sudo cp /var/www/pterodactyl/app/Http/Kernel.php.backup /var/www/pterodactyl/app/Http/Kernel.php
    fi
    
    if [ -f "/var/www/pterodactyl/routes/web.php.backup" ]; then
        echo -e "${YELLOW}Memulihkan routes...${NC}"
        sudo cp /var/www/pterodactyl/routes/web.php.backup /var/www/pterodactyl/routes/web.php
    fi
    
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/AdminController.php.backup" ]; then
        echo -e "${YELLOW}Memulihkan AdminController...${NC}"
        sudo cp /var/www/pterodactyl/app/Http/Controllers/Admin/AdminController.php.backup /var/www/pterodactyl/app/Http/Controllers/Admin/AdminController.php
    fi
    
    # Hapus file security middleware
    if [ -f "/var/www/pterodactyl/app/Http/Middleware/SecurityMiddleware.php" ]; then
        echo -e "${YELLOW}Menghapus security middleware...${NC}"
        sudo rm /var/www/pterodactyl/app/Http/Middleware/SecurityMiddleware.php
    fi
    
    # Clear cache
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    sudo php /var/www/pterodactyl/artisan config:clear
    sudo php /var/www/pterodactyl/artisan route:clear
    sudo php /var/www/pterodactyl/artisan view:clear
    
    # Set permissions
    sudo chown -R www-data:www-data /var/www/pterodactyl/
    sudo chmod -R 755 /var/www/pterodactyl/
    
    echo -e "${GREEN}Uninstall security panel berhasil!${NC}"
    echo -e "${YELLOW}Panel Pterodactyl telah dikembalikan ke keadaan semula.${NC}"
    read -p "Tekan Enter untuk melanjutkan..."
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${GREEN}Pilihan Menu:${NC}"
        echo "1. Install Security Panel"
        echo "2. Ubah Teks Error" 
        echo "3. Uninstall Security Panel"
        echo "4. Exit"
        echo ""
        read -p "Pilih opsi [1-4]: " choice
        
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
                echo -e "${GREEN}Keluar dari script.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Pilihan tidak valid!${NC}"
                sleep 2
                ;;
        esac
    done
}

# Check if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Make script executable
    chmod +x "$0"
    
    # Check dependencies
    if ! command -v php &> /dev/null; then
        echo -e "${RED}Error: PHP tidak terinstall!${NC}"
        exit 1
    fi
    
    if ! command -v sudo &> /dev/null; then
        echo -e "${RED}Error: sudo tidak terinstall!${NC}"
        exit 1
    fi
    
    # Run main menu
    main_menu
fi
