#!/bin/bash

# security.sh - Security Panel Pterodactyl
# Script untuk mengamankan panel Pterodactyl
# By @ginaabaikhati

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Error message
ERROR_MSG="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Backup directory
BACKUP_DIR="/var/www/pterodactyl-backup"

# Function to display header
display_header() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║               PTERODACTYL SECURITY PANEL                ║"
    echo "║                  By @ginaabaikhati                      ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: Script harus dijalankan sebagai root!${NC}"
        exit 1
    fi
}

# Function to check Pterodactyl installation
check_pterodactyl() {
    if [ ! -d "/var/www/pterodactyl" ]; then
        echo -e "${RED}Error: Pterodactyl tidak ditemukan di /var/www/pterodactyl${NC}"
        exit 1
    fi
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup...${NC}"
    mkdir -p $BACKUP_DIR
    
    # Backup important files
    cp -r /var/www/pterodactyl/app $BACKUP_DIR/
    cp -r /var/www/pterodactyl/resources $BACKUP_DIR/
    cp -r /var/www/pterodactyl/routes $BACKUP_DIR/
    
    echo -e "${GREEN}Backup berhasil dibuat di $BACKUP_DIR${NC}"
}

# Function to restore backup
restore_backup() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}Error: Backup tidak ditemukan!${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Memulihkan dari backup...${NC}"
    
    # Restore files
    cp -r $BACKUP_DIR/app /var/www/pterodactyl/
    cp -r $BACKUP_DIR/resources /var/www/pterodactyl/
    cp -r $BACKUP_DIR/routes /var/www/pterodactyl/
    
    # Run Pterodactyl commands
    cd /var/www/pterodactyl
    php artisan cache:clear
    php artisan view:clear
    
    echo -e "${GREEN}Restore berhasil!${NC}"
}

# Function to install security
install_security() {
    display_header
    echo -e "${YELLOW}Menginstall Security Panel...${NC}"
    
    check_root
    check_pterodactyl
    create_backup
    
    cd /var/www/pterodactyl
    
    # Create middleware for security
    cat > /var/www/pterodactyl/app/Http/Middleware/AdminSecurity.php << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Pterodactyl\Models\User;

class AdminSecurity
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        
        // Allow ID 1 (super admin) to access everything
        if ($user && $user->id === 1) {
            return $next($request);
        }
        
        $route = $request->route()->getName();
        $path = $request->path();
        
        // Block sensitive routes for non-admin users
        $blockedPatterns = [
            'admin/settings',
            'admin/nodes',
            'admin/locations',
            'admin/nests',
            'admin/users',
            'admin/servers',
            'api/application'
        ];
        
        foreach ($blockedPatterns as $pattern) {
            if (strpos($path, $pattern) !== false) {
                abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
            }
        }
        
        return $next($request);
    }
}
EOF

    # Modify AdminController to add security checks
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/AdminController.php" ]; then
        cp /var/www/pterodactyl/app/Http/Controllers/Admin/AdminController.php $BACKUP_DIR/AdminController.php.backup
        
        # Create secured AdminController
        cat > /var/www/pterodactyl/app/Http/Controllers/Admin/AdminController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class AdminController extends Controller
{
    public function __construct(
        private AlertsMessageBag $alert,
        private SettingsRepositoryInterface $settings
    ) {
    }

    public function index(): View
    {
        $user = auth()->user();
        
        // Only allow ID 1 to access admin settings
        if ($user->id !== 1) {
            abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        return view('admin.index', [
            'version' => config('app.version', 'unknown'),
        ]);
    }

    public function settings(): View
    {
        $user = auth()->user();
        
        // Only allow ID 1 to access settings
        if ($user->id !== 1) {
            abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        return view('admin.settings');
    }

    public function updateSettings(): RedirectResponse
    {
        $user = auth()->user();
        
        // Only allow ID 1 to update settings
        if ($user->id !== 1) {
            abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        foreach (request()->all() as $key => $value) {
            if (strpos($key, 'app:') === 0) {
                $this->settings->set($key, $value);
            }
        }

        $this->alert->success('Settings have been updated successfully.')->flash();

        return redirect()->route('admin.settings');
    }
}
EOF
    fi

    # Secure Nodes Controller
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php" ]; then
        cp /var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php $BACKUP_DIR/NodesController.php.backup
        
        # Add security check to NodesController
        sed -i '/public function __construct(/a\        $this->middleware(function ($request, $next) {\n            if (auth()->user()->id !== 1) {\n                abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");\n            }\n            return $next($request);\n        });' /var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php
    fi

    # Secure Locations Controller
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/LocationsController.php" ]; then
        cp /var/www/pterodactyl/app/Http/Controllers/Admin/LocationsController.php $BACKUP_DIR/LocationsController.php.backup
        
        # Add security check to LocationsController
        sed -i '/public function __construct(/a\        $this->middleware(function ($request, $next) {\n            if (auth()->user()->id !== 1) {\n                abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");\n            }\n            return $next($request);\n        });' /var/www/pterodactyl/app/Http/Controllers/Admin/LocationsController.php
    fi

    # Secure Nests Controller
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/NestsController.php" ]; then
        cp /var/www/pterodactyl/app/Http/Controllers/Admin/NestsController.php $BACKUP_DIR/NestsController.php.backup
        
        # Add security check to NestsController
        sed -i '/public function __construct(/a\        $this->middleware(function ($request, $next) {\n            if (auth()->user()->id !== 1) {\n                abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");\n            }\n            return $next($request);\n        });' /var/www/pterodactyl/app/Http/Controllers/Admin/NestsController.php
    fi

    # Secure Users Controller
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/UsersController.php" ]; then
        cp /var/www/pterodactyl/app/Http/Controllers/Admin/UsersController.php $BACKUP_DIR/UsersController.php.backup
        
        # Add security check to UsersController
        sed -i '/public function __construct(/a\        $this->middleware(function ($request, $next) {\n            if (auth()->user()->id !== 1) {\n                abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");\n            }\n            return $next($request);\n        });' /var/www/pterodactyl/app/Http/Controllers/Admin/UsersController.php
    fi

    # Secure Servers Controller
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/ServersController.php" ]; then
        cp /var/www/pterodactyl/app/Http/Controllers/Admin/ServersController.php $BACKUP_DIR/ServersController.php.backup
        
        # Add security check to ServersController
        sed -i '/public function __construct(/a\        $this->middleware(function ($request, $next) {\n            if (auth()->user()->id !== 1) {\n                abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");\n            }\n            return $next($request);\n        });' /var/www/pterodactyl/app/Http/Controllers/Admin/ServersController.php
    fi

    # Modify routes to add middleware
    if [ -f "/var/www/pterodactyl/routes/admin.php" ]; then
        cp /var/www/pterodactyl/routes/admin.php $BACKUP_DIR/admin.php.backup
        
        # Add middleware to admin routes
        sed -i '1i\<?php\nuse Pterodactyl\Http\Middleware\AdminSecurity;' /var/www/pterodactyl/routes/admin.php
        sed -i '/Route::group(\[.prefix.*\], function () {/a\    Route::group(["middleware" => [AdminSecurity::class]], function () {' /var/www/pterodactyl/routes/admin.php
        sed -i '/});\s*$/i\    });' /var/www/pterodactyl/routes/admin.php
    fi

    # Update Kernel to register middleware
    if [ -f "/var/www/pterodactyl/app/Http/Kernel.php" ]; then
        cp /var/www/pterodactyl/app/Http/Kernel.php $BACKUP_DIR/Kernel.php.backup
        
        # Add middleware to Kernel
        grep -q "AdminSecurity" /var/www/pterodactyl/app/Http/Kernel.php || sed -i '/protected \$routeMiddleware = \[/a\        \x27admin.security\x27 => \Pterodactyl\Http\Middleware\AdminSecurity::class,' /var/www/pterodactyl/app/Http/Kernel.php
    fi

    # Clear cache and run optimizations
    php artisan cache:clear
    php artisan view:clear
    php artisan route:clear
    
    echo -e "${GREEN}Security Panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Hanya user dengan ID 1 yang dapat mengakses semua fitur admin.${NC}"
    read -p "Tekan enter untuk melanjutkan..."
}

# Function to change error text
change_error_text() {
    display_header
    echo -e "${YELLOW}Mengubah Teks Error...${NC}"
    
    read -p "Masukkan teks error baru: " new_error
    
    if [ -z "$new_error" ]; then
        echo -e "${RED}Error: Teks tidak boleh kosong!${NC}"
        read -p "Tekan enter untuk melanjutkan..."
        return
    fi
    
    # Update error message in all modified files
    find /var/www/pterodactyl/app/Http/Controllers/Admin -name "*.php" -type f -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_error}/g" {} \;
    
    if [ -f "/var/www/pterodactyl/app/Http/Middleware/AdminSecurity.php" ]; then
        sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_error}/g" /var/www/pterodactyl/app/Http/Middleware/AdminSecurity.php
    fi
    
    # Clear cache
    cd /var/www/pterodactyl
    php artisan cache:clear
    php artisan view:clear
    
    echo -e "${GREEN}Teks error berhasil diubah!${NC}"
    read -p "Tekan enter untuk melanjutkan..."
}

# Function to uninstall security
uninstall_security() {
    display_header
    echo -e "${YELLOW}Uninstall Security Panel...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}Error: Backup tidak ditemukan!${NC}"
        echo -e "${YELLOW}Anda perlu menginstall security terlebih dahulu.${NC}"
        read -p "Tekan enter untuk melanjutkan..."
        return
    fi
    
    read -p "Apakah Anda yakin ingin uninstall security? (y/n): " confirm
    if [[ $confirm != [yY] ]]; then
        echo -e "${YELLOW}Uninstall dibatalkan.${NC}"
        read -p "Tekan enter untuk melanjutkan..."
        return
    fi
    
    restore_backup
    
    # Remove middleware file
    if [ -f "/var/www/pterodactyl/app/Http/Middleware/AdminSecurity.php" ]; then
        rm -f /var/www/pterodactyl/app/Http/Middleware/AdminSecurity.php
    fi
    
    # Clear cache
    cd /var/www/pterodactyl
    php artisan cache:clear
    php artisan view:clear
    php artisan route:clear
    
    echo -e "${GREEN}Security Panel berhasil diuninstall!${NC}"
    read -p "Tekan enter untuk melanjutkan..."
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${GREEN}Pilih opsi:${NC}"
        echo -e "1. Install Security Panel"
        echo -e "2. Ubah Teks Error" 
        echo -e "3. Uninstall Security Panel"
        echo -e "4. Exit"
        echo -e ""
        read -p "Masukkan pilihan [1-4]: " choice
        
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
                echo -e "${GREEN}Terima kasih!${NC}"
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
    main_menu
fi
