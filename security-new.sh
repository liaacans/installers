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
ERROR_MESSAGE="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"
PANEL_PATH="/var/www/pterodactyl"
BACKUP_DIR="/root/pterodactyl_backup"

# Function to display menu
show_menu() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║    Security Panel Pterodactyl       ║"
    echo "║        By @ginaabaikhati            ║"
    echo "╠══════════════════════════════════════╣"
    echo "║ 1. Install Security Panel           ║"
    echo "║ 2. Ubah Teks Error                  ║"
    echo "║ 3. Uninstall Security Panel         ║"
    echo "║ 4. Exit                             ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup panel...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi
    
    # Backup important files
    cp -r "$PANEL_PATH/app/Http/Controllers" "$BACKUP_DIR/Controllers_$(date +%Y%m%d_%H%M%S)"
    cp -r "$PANEL_PATH/app/Http/Middleware" "$BACKUP_DIR/Middleware_$(date +%Y%m%d_%H%M%S)"
    cp "$PANEL_PATH/app/Providers/AppServiceProvider.php" "$BACKUP_DIR/AppServiceProvider_$(date +%Y%m%d_%H%M%S).php"
    
    echo -e "${GREEN}Backup berhasil dibuat di $BACKUP_DIR${NC}"
}

# Function to install security
install_security() {
    echo -e "${YELLOW}Menginstall Security Panel...${NC}"
    
    # Check if panel path exists
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}Error: Panel path $PANEL_PATH tidak ditemukan!${NC}"
        echo -e "${YELLOW}Silakan edit variabel PANEL_PATH di script ini${NC}"
        return 1
    fi
    
    create_backup
    
    # Create or update middleware
    cat > "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminSecurity
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        $routeName = $request->route()->getName();
        
        // List of restricted routes
        $restrictedRoutes = [
            'admin.settings', 'admin.settings.*',
            'admin.nodes', 'admin.nodes.*', 
            'admin.locations', 'admin.locations.*',
            'admin.nests', 'admin.nests.*',
            'admin.users', 'admin.users.*',
            'admin.servers', 'admin.servers.*',
        ];
        
        // Check if current route is restricted
        $isRestricted = false;
        foreach ($restrictedRoutes as $route) {
            if (strpos($route, '.*') !== false) {
                $baseRoute = str_replace('.*', '', $route);
                if (strpos($routeName, $baseRoute) === 0) {
                    $isRestricted = true;
                    break;
                }
            } elseif ($routeName === $route) {
                $isRestricted = true;
                break;
            }
        }
        
        // Allow only user ID 1 for restricted routes
        if ($isRestricted && (!$user || $user->id !== 1)) {
            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
        }
        
        return $next($request);
    }
}
EOF

    # Update AppServiceProvider to register middleware
    cat > "$PANEL_PATH/app/Providers/AppServiceProvider.php" << 'EOF'
<?php

namespace Pterodactyl\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Contracts\Http\Kernel;
use Pterodactyl\Http\Middleware\AdminSecurity;

class AppServiceProvider extends ServiceProvider
{
    public function boot()
    {
        // Add security configuration
        config(['security.error_message' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati']);
        
        $kernel = $this->app->make(Kernel::class);
        $kernel->appendMiddlewareToGroup('web', AdminSecurity::class);
    }

    public function register()
    {
        //
    }
}
EOF

    # Create security configuration
    cat > "$PANEL_PATH/config/security.php" << EOF
<?php

return [
    'error_message' => '$ERROR_MESSAGE',
    'installed' => true,
    'installed_at' => now(),
];
EOF

    # Update base controller to handle security
    if [ -f "$PANEL_PATH/app/Http/Controllers/Controller.php" ]; then
        cat > "$PANEL_PATH/app/Http/Controllers/Controller.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers;

use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Routing\Controller as BaseController;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class Controller extends BaseController
{
    use AuthorizesRequests, DispatchesJobs, ValidatesRequests;
    
    protected function checkAdminAccess()
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
        }
    }
}
EOF
    fi

    # Update specific controllers for additional security
    update_controllers

    echo -e "${GREEN}Security Panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Menjalankan optimasi...${NC}"
    
    # Run optimizations
    cd "$PANEL_PATH" || exit
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    
    echo -e "${GREEN}Optimasi selesai!${NC}"
}

# Function to update controllers
update_controllers() {
    # Update AdminController if exists
    if [ -f "$PANEL_PATH/app/Http/Controllers/Admin/AdminController.php" ]; then
        sed -i 's/public function __construct()/public function __construct()\n    {\n        $this->checkAdminAccess();\n    }/g' "$PANEL_PATH/app/Http/Controllers/Admin/AdminController.php"
    fi

    # Update other important controllers
    controllers=(
        "Admin/SettingsController"
        "Admin/NodeController" 
        "Admin/LocationController"
        "Admin/NestController"
        "Admin/UserController"
        "Admin/ServerController"
    )

    for controller in "${controllers[@]}"; do
        controller_file="$PANEL_PATH/app/Http/Controllers/$controller.php"
        if [ -f "$controller_file" ]; then
            # Add security check to constructor
            sed -i '/public function __construct()/{n;a\        $this->checkAdminAccess();' "$controller_file"
        fi
    done
}

# Function to change error message
change_error_message() {
    echo -e "${YELLOW}Mengubah teks error...${NC}"
    read -p "Masukkan teks error baru: " new_message
    
    if [ -z "$new_message" ]; then
        echo -e "${RED}Teks error tidak boleh kosong!${NC}"
        return 1
    fi
    
    # Update security config
    if [ -f "$PANEL_PATH/config/security.php" ]; then
        sed -i "s/'error_message' => '.*'/'error_message' => '$new_message'/g" "$PANEL_PATH/config/security.php"
    fi
    
    # Update AppServiceProvider
    if [ -f "$PANEL_PATH/app/Providers/AppServiceProvider.php" ]; then
        sed -i "s/config(\['security.error_message' => '.*'\])/config(['security.error_message' => '$new_message'])/g" "$PANEL_PATH/app/Providers/AppServiceProvider.php"
    fi
    
    # Update middleware
    if [ -f "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php" ]; then
        sed -i "s/config('security.error_message', '.*')/config('security.error_message', '$new_message')/g" "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php"
    fi
    
    echo -e "${GREEN}Teks error berhasil diubah!${NC}"
    echo -e "${YELLOW}Menjalankan optimasi...${NC}"
    
    cd "$PANEL_PATH" || exit
    php artisan config:cache
    php artisan route:cache
    
    echo -e "${GREEN}Optimasi selesai!${NC}"
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Uninstall Security Panel...${NC}"
    
    # Check if security is installed
    if [ ! -f "$PANEL_PATH/config/security.php" ]; then
        echo -e "${RED}Security panel tidak terinstall!${NC}"
        return 1
    fi
    
    # Restore from backup
    latest_backup=$(ls -td "$BACKUP_DIR"/* | head -1)
    
    if [ -n "$latest_backup" ]; then
        echo -e "${YELLOW}Memulihkan dari backup...${NC}"
        
        # Restore controllers
        if [ -d "$latest_backup/Controllers" ]; then
            cp -r "$latest_backup/Controllers"/* "$PANEL_PATH/app/Http/Controllers/"
        fi
        
        # Restore middleware  
        if [ -d "$latest_backup/Middleware" ]; then
            cp -r "$latest_backup/Middleware"/* "$PANEL_PATH/app/Http/Middleware/"
        fi
        
        # Restore AppServiceProvider
        if [ -f "$latest_backup/AppServiceProvider.php" ]; then
            cp "$latest_backup/AppServiceProvider.php" "$PANEL_PATH/app/Providers/AppServiceProvider.php"
        fi
        
        # Remove security config
        rm -f "$PANEL_PATH/config/security.php"
        
        # Remove security middleware
        rm -f "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php"
        
        echo -e "${GREEN}Security panel berhasil diuninstall!${NC}"
        echo -e "${YELLOW}Menjalankan optimasi...${NC}"
        
        cd "$PANEL_PATH" || exit
        php artisan config:cache
        php artisan route:cache
        php artisan view:cache
        
        echo -e "${GREEN}Optimasi selesai!${NC}"
    else
        echo -e "${RED}Tidak ada backup yang ditemukan!${NC}"
        echo -e "${YELLOW}Melakukan uninstall manual...${NC}"
        
        # Manual cleanup
        rm -f "$PANEL_PATH/config/security.php"
        rm -f "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php"
        
        # Restore original AppServiceProvider
        cat > "$PANEL_PATH/app/Providers/AppServiceProvider.php" << 'EOF'
<?php

namespace Pterodactyl\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function boot()
    {
        //
    }

    public function register()
    {
        //
    }
}
EOF

        echo -e "${GREEN}Uninstall manual selesai!${NC}"
    fi
}

# Function to check requirements
check_requirements() {
    echo -e "${YELLOW}Memeriksa requirements...${NC}"
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: Script harus dijalankan sebagai root!${NC}"
        exit 1
    fi
    
    # Check panel directory
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}Error: Directory panel tidak ditemukan di $PANEL_PATH${NC}"
        echo -e "${YELLOW}Silakan edit variabel PANEL_PATH di script ini${NC}"
        exit 1
    fi
    
    # Check if Laravel exists
    if [ ! -f "$PANEL_PATH/artisan" ]; then
        echo -e "${RED}Error: File artisan tidak ditemukan! Pastikan ini adalah panel Pterodactyl${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Requirements terpenuhi!${NC}"
}

# Main script
main() {
    check_requirements
    
    while true; do
        show_menu
        read -p "Pilih opsi [1-4]: " choice
        
        case $choice in
            1)
                install_security
                ;;
            2)
                change_error_message
                ;;
            3)
                uninstall_security
                ;;
            4)
                echo -e "${GREEN}Keluar...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Pilihan tidak valid!${NC}"
                ;;
        esac
        
        echo
        read -p "Tekan Enter untuk melanjutkan..."
    done
}

# Handle command line arguments
case "${1:-}" in
    install)
        install_security
        ;;
    uninstall)
        uninstall_security
        ;;
    change-message)
        change_error_message
        ;;
    *)
        main
        ;;
esac
