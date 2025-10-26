#!/bin/bash

# Security Panel Pterodactyl
# By @ginaabaikhati

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SECURITY_TEXT="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"
ALLOWED_USER_ID="1"
BACKUP_DIR="/var/www/pterodactyl-backup"

# Function to display header
display_header() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════╗"
    echo "║           PTERODACTYL SECURITY PANEL          ║"
    echo "║              By @ginaabaikhati                ║"
    echo "╚════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}Error: Jangan jalankan script ini sebagai root!${NC}"
        exit 1
    fi
}

# Function to backup original files
backup_files() {
    echo -e "${YELLOW}Membuat backup file original...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        sudo mkdir -p "$BACKUP_DIR"
    fi
    
    # Backup important files
    sudo cp /var/www/pterodactyl/app/Http/Controllers/Admin/*.php "$BACKUP_DIR/" 2>/dev/null || true
    sudo cp /var/www/pterodactyl/app/Http/Middleware/AdminAuthenticate.php "$BACKUP_DIR/" 2>/dev/null || true
    sudo cp /var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/*.php "$BACKUP_DIR/" 2>/dev/null || true
    
    echo -e "${GREEN}Backup selesai di: $BACKUP_DIR${NC}"
}

# Function to install security
install_security() {
    echo -e "${YELLOW}Memulai instalasi security panel...${NC}"
    
    # Check if Pterodactyl is installed
    if [ ! -d "/var/www/pterodactyl" ]; then
        echo -e "${RED}Error: Pterodactyl tidak ditemukan di /var/www/pterodactyl${NC}"
        exit 1
    fi
    
    backup_files
    
    # Create security middleware
    echo -e "${YELLOW}Membuat security middleware...${NC}"
    
    cat > /tmp/AdminSecurityMiddleware.php << EOF
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminSecurityMiddleware
{
    public function handle(Request \$request, Closure \$next): Response
    {
        // Check if user is authenticated
        if (!\$request->user()) {
            abort(403, 'Unauthorized');
        }

        // Allow only user ID 1 for admin operations
        if (\$request->user()->id != $ALLOWED_USER_ID) {
            // Check for destructive actions
            \$destructiveMethods = ['DELETE', 'POST', 'PUT', 'PATCH'];
            \$destructiveRoutes = [
                'settings', 'nodes', 'locations', 'nests', 'users', 'servers',
                'delete', 'destroy', 'suspend', 'unsuspend', 'edit', 'update',
                'create', 'store'
            ];

            \$currentRoute = \$request->route()->getName();
            \$currentMethod = \$request->method();
            \$currentUri = \$request->getRequestUri();

            // Block if destructive method or admin route
            if (in_array(\$currentMethod, \$destructiveMethods) || 
                str_contains(\$currentUri, '/admin/') ||
                \$this->isDestructiveRoute(\$currentRoute, \$currentUri)) {
                abort(403, '$SECURITY_TEXT');
            }
        }

        return \$next(\$request);
    }

    private function isDestructiveRoute(\$route, \$uri): bool
    {
        \$destructivePatterns = [
            '/settings/',
            '/nodes/',
            '/locations/',
            '/nests/',
            '/users/',
            '/servers/',
            '/api/application/',
            '/admin/'
        ];

        foreach (\$destructivePatterns as \$pattern) {
            if (str_contains(\$uri, \$pattern) && !str_contains(\$uri, '/api/client/servers/')) {
                return true;
            }
        }

        return false;
    }
}
EOF

    sudo cp /tmp/AdminSecurityMiddleware.php /var/www/pterodactyl/app/Http/Middleware/AdminSecurityMiddleware.php
    
    # Modify AdminAuthenticate middleware
    echo -e "${YELLOW}Memodifikasi AdminAuthenticate middleware...${NC}"
    
    sudo cp /var/www/pterodactyl/app/Http/Middleware/AdminAuthenticate.php /tmp/AdminAuthenticate.php
    sudo sed -i '/use Closure;/a use App\\Http\\Middleware\\AdminSecurityMiddleware;' /tmp/AdminAuthenticate.php
    sudo sed -i '/public function handle/a \\        // Apply security middleware\\n        if ($request->user()) {\\n            $securityMiddleware = new AdminSecurityMiddleware();\\n            return $securityMiddleware->handle($request, $next);\\n        }' /tmp/AdminAuthenticate.php
    
    sudo cp /tmp/AdminAuthenticate.php /var/www/pterodactyl/app/Http/Middleware/AdminAuthenticate.php
    
    # Modify SettingsController
    echo -e "${YELLOW}Memodifikasi SettingsController...${NC}"
    
    sudo cp /var/www/pterodactyl/app/Http/Controllers/Admin/SettingsController.php /tmp/SettingsController.php
    sudo sed -i "/public function __construct()/a \\    public function __construct()\\    {\\        if (auth()->check() && auth()->user()->id != $ALLOWED_USER_ID) {\\            abort(403, '$SECURITY_TEXT');\\        }\\    }" /tmp/SettingsController.php
    
    sudo cp /tmp/SettingsController.php /var/www/pterodactyl/app/Http/Controllers/Admin/SettingsController.php
    
    # Modify NodeController
    echo -e "${YELLOW}Memodifikasi NodeController...${NC}"
    
    sudo cp /var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php /tmp/NodeController.php
    sudo sed -i "/public function __construct()/a \\    public function __construct()\\    {\\        if (auth()->check() && auth()->user()->id != $ALLOWED_USER_ID) {\\            abort(403, '$SECURITY_TEXT');\\        }\\    }" /tmp/NodeController.php
    
    sudo cp /tmp/NodeController.php /var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php
    
    # Modify LocationController
    echo -e "${YELLOW}Memodifikasi LocationController...${NC}"
    
    sudo cp /var/www/pterodactyl/app/Http/Controllers/Admin/LocationController.php /tmp/LocationController.php
    sudo sed -i "/public function __construct()/a \\    public function __construct()\\    {\\        if (auth()->check() && auth()->user()->id != $ALLOWED_USER_ID) {\\            abort(403, '$SECURITY_TEXT');\\        }\\    }" /tmp/LocationController.php
    
    sudo cp /tmp/LocationController.php /var/www/pterodactyl/app/Http/Controllers/Admin/LocationController.php
    
    # Modify NestsController
    echo -e "${YELLOW}Memodifikasi NestsController...${NC}"
    
    sudo cp /var/www/pterodactyl/app/Http/Controllers/Admin/NestsController.php /tmp/NestsController.php
    sudo sed -i "/public function __construct()/a \\    public function __construct()\\    {\\        if (auth()->check() && auth()->user()->id != $ALLOWED_USER_ID) {\\            abort(403, '$SECURITY_TEXT');\\        }\\    }" /tmp/NestsController.php
    
    sudo cp /tmp/NestsController.php /var/www/pterodactyl/app/Http/Controllers/Admin/NestsController.php
    
    # Modify UserController for server deletion protection
    echo -e "${YELLOW}Memodifikasi UserController...${NC}"
    
    sudo cp /var/www/pterodactyl/app/Http/Controllers/Admin/UserController.php /tmp/UserController.php
    sudo sed -i "/public function __construct()/a \\    public function __construct()\\    {\\        if (auth()->check() && auth()->user()->id != $ALLOWED_USER_ID) {\\            abort(403, '$SECURITY_TEXT');\\        }\\    }" /tmp/UserController.php
    
    sudo cp /tmp/UserController.php /var/www/pterodactyl/app/Http/Controllers/Admin/UserController.php
    
    # Modify ServerController for deletion protection
    echo -e "${YELLOW}Memodifikasi ServerController...${NC}"
    
    sudo cp /var/www/pterodactyl/app/Http/Controllers/Admin/ServersController.php /tmp/ServersController.php
    sudo sed -i "/public function __construct()/a \\    public function __construct()\\    {\\        if (auth()->check() && auth()->user()->id != $ALLOWED_USER_ID) {\\            abort(403, '$SECURITY_TEXT');\\        }\\    }" /tmp/ServersController.php
    
    sudo cp /tmp/ServersController.php /var/www/pterodactyl/app/Http/Controllers/Admin/ServersController.php
    
    # Add security to API routes
    echo -e "${YELLOW}Menambahkan security ke API routes...${NC}"
    
    sudo cp /var/www/pterodactyl/app/Providers/RouteServiceProvider.php /tmp/RouteServiceProvider.php
    sudo sed -i '/protected \$adminRoutes/a \\    protected function mapAdminRoutes()\\    {\\        Route::prefix("/admin")\\            ->middleware(["web", "auth", "admin"])\\            ->group(function () {\\                Route::middleware(["admin.security"])->group(base_path("routes/admin.php"));\\            });\\    }' /tmp/RouteServiceProvider.php
    
    sudo cp /tmp/RouteServiceProvider.php /var/www/pterodactyl/app/Providers/RouteServiceProvider.php
    
    # Clear cache and optimize
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    sudo php /var/www/pterodactyl/artisan config:clear
    sudo php /var/www/pterodactyl/artisan route:clear
    sudo php /var/www/pterodactyl/artisan view:clear
    sudo php /var/www/pterodactyl/artisan cache:clear
    
    echo -e "${GREEN}Security panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Hanya user dengan ID $ALLOWED_USER_ID yang dapat mengakses fitur admin.${NC}"
}

# Function to change error text
change_error_text() {
    echo -e "${YELLOW}Mengubah teks error security...${NC}"
    
    read -p "Masukkan teks error security baru: " new_text
    if [ -n "$new_text" ]; then
        SECURITY_TEXT="$new_text"
        echo -e "${GREEN}Teks error berhasil diubah!${NC}"
        echo -e "${YELLOW}Teks baru: $SECURITY_TEXT${NC}"
        
        # Update the security text in installed files
        if [ -f "/var/www/pterodactyl/app/Http/Middleware/AdminSecurityMiddleware.php" ]; then
            sudo sed -i "s/abort(403, '.*');/abort(403, '$SECURITY_TEXT');/g" /var/www/pterodactyl/app/Http/Middleware/AdminSecurityMiddleware.php
            sudo sed -i "s/abort(403, '.*');/abort(403, '$SECURITY_TEXT');/g" /var/www/pterodactyl/app/Http/Controllers/Admin/SettingsController.php
            sudo sed -i "s/abort(403, '.*');/abort(403, '$SECURITY_TEXT');/g" /var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php
            sudo sed -i "s/abort(403, '.*');/abort(403, '$SECURITY_TEXT');/g" /var/www/pterodactyl/app/Http/Controllers/Admin/LocationController.php
            sudo sed -i "s/abort(403, '.*');/abort(403, '$SECURITY_TEXT');/g" /var/www/pterodactyl/app/Http/Controllers/Admin/NestsController.php
            sudo sed -i "s/abort(403, '.*');/abort(403, '$SECURITY_TEXT');/g" /var/www/pterodactyl/app/Http/Controllers/Admin/UserController.php
            sudo sed -i "s/abort(403, '.*');/abort(403, '$SECURITY_TEXT');/g" /var/www/pterodactyl/app/Http/Controllers/Admin/ServersController.php
            
            # Clear cache
            sudo php /var/www/pterodactyl/artisan config:clear
            sudo php /var/www/pterodactyl/artisan cache:clear
            
            echo -e "${GREEN}Teks error berhasil diperbarui di semua file!${NC}"
        else
            echo -e "${RED}Security panel belum terinstall. Install terlebih dahulu.${NC}"
        fi
    else
        echo -e "${RED}Teks tidak boleh kosong!${NC}"
    fi
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Memulai uninstall security panel...${NC}"
    
    # Check if backup exists
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}Error: Backup directory tidak ditemukan!${NC}"
        echo -e "${YELLOW}Anda perlu mengembalikan file manual atau install ulang Pterodactyl.${NC}"
        exit 1
    fi
    
    # Restore original files
    echo -e "${YELLOW}Mengembalikan file original...${NC}"
    
    sudo cp $BACKUP_DIR/*.php /var/www/pterodactyl/app/Http/Controllers/Admin/ 2>/dev/null || true
    sudo cp $BACKUP_DIR/AdminAuthenticate.php /var/www/pterodactyl/app/Http/Middleware/ 2>/dev/null || true
    
    # Remove security middleware
    if [ -f "/var/www/pterodactyl/app/Http/Middleware/AdminSecurityMiddleware.php" ]; then
        sudo rm /var/www/pterodactyl/app/Http/Middleware/AdminSecurityMiddleware.php
    fi
    
    # Clear cache and optimize
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    sudo php /var/www/pterodactyl/artisan config:clear
    sudo php /var/www/pterodactyl/artisan route:clear
    sudo php /var/www/pterodactyl/artisan view:clear
    sudo php /var/www/pterodactyl/artisan cache:clear
    
    echo -e "${GREEN}Security panel berhasil diuninstall!${NC}"
    echo -e "${YELLOW}Panel Pterodactyl telah dikembalikan ke keadaan semula.${NC}"
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
        echo ""
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
                ;;
        esac
        
        echo ""
        read -p "Tekan Enter untuk melanjutkan..."
    done
}

# Check if running as root first
check_root

# Start the script
main_menu
