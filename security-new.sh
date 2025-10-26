#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default error message
ERROR_MSG="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Backup directory
BACKUP_DIR="/var/www/pterodactyl-backup"

# Function to display header
show_header() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║    Pterodactyl Security Panel        ║"
    echo "║          By @ginaabaikhati           ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup file...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi
    
    # Backup important files
    cp /var/www/pterodactyl/app/Http/Controllers/Admin/*.php "$BACKUP_DIR/" 2>/dev/null || true
    cp /var/www/pterodactyl/app/Http/Middleware/*.php "$BACKUP_DIR/" 2>/dev/null || true
    cp /var/www/pterodactyl/app/Http/Controllers/Controller.php "$BACKUP_DIR/" 2>/dev/null || true
    
    echo -e "${GREEN}Backup berhasil dibuat di: $BACKUP_DIR${NC}"
}

# Function to restore backup
restore_backup() {
    echo -e "${YELLOW}Memulihkan dari backup...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}Backup directory tidak ditemukan!${NC}"
        return 1
    fi
    
    # Restore files
    cp "$BACKUP_DIR"/*.php /var/www/pterodactyl/app/Http/Controllers/Admin/ 2>/dev/null || true
    cp "$BACKUP_DIR"/*.php /var/www/pterodactyl/app/Http/Middleware/ 2>/dev/null || true
    cp "$BACKUP_DIR"/Controller.php /var/www/pterodactyl/app/Http/Controllers/ 2>/dev/null || true
    
    # Run migrations and clear cache
    cd /var/www/pterodactyl
    php artisan migrate --force
    php artisan config:cache
    php artisan view:cache
    
    echo -e "${GREEN}Restore berhasil! Security panel telah diuninstall.${NC}"
}

# Function to install security
install_security() {
    echo -e "${YELLOW}Menginstall Security Panel...${NC}"
    
    # Create backup first
    create_backup
    
    # Navigate to Pterodactyl directory
    cd /var/www/pterodactyl
    
    # Create custom middleware
    cat > /var/www/pterodactyl/app/Http/Middleware/AdminSecurity.php << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class AdminSecurity
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        $route = $request->route()->getName();
        
        // ID 1 has full access
        if ($user && $user->id === 1) {
            return $next($request);
        }
        
        // Define restricted routes
        $restrictedRoutes = [
            'admin.settings', 'admin.settings.*',
            'admin.nodes', 'admin.nodes.*', 
            'admin.locations', 'admin.locations.*',
            'admin.nests', 'admin.nests.*',
            'admin.servers.view', 'admin.servers.view.*',
            'admin.users.delete', 'admin.users.edit',
            'admin.servers.delete', 'admin.servers.edit'
        ];
        
        // Check if current route is restricted
        foreach ($restrictedRoutes as $restricted) {
            if (strpos($restricted, '.*') !== false) {
                $baseRoute = str_replace('.*', '', $restricted);
                if (strpos($route, $baseRoute) === 0) {
                    throw new AccessDeniedHttpException(config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
                }
            } elseif ($route === $restricted) {
                throw new AccessDeniedHttpException(config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
            }
        }
        
        return $next($request);
    }
}
EOF

    # Modify AdminController
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/AdminController.php" ]; then
        cp "/var/www/pterodactyl/app/Http/Controllers/Admin/AdminController.php" "/var/www/pterodactyl/app/Http/Controllers/Admin/AdminController.php.backup"
        
        # Create secured AdminController
        cat > /var/www/pterodactyl/app/Http/Controllers/Admin/AdminController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class AdminController extends Controller
{
    protected $alert;
    protected $settings;

    public function __construct(AlertsMessageBag $alert, SettingsRepositoryInterface $settings)
    {
        $this->alert = $alert;
        $this->settings = $settings;
    }

    public function index()
    {
        return view('admin.index');
    }

    public function settings(Request $request)
    {
        // Security check - only user ID 1 can access settings
        if ($request->user()->id !== 1) {
            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
        }

        return view('admin.settings');
    }

    public function updateSettings(Request $request)
    {
        // Security check - only user ID 1 can update settings
        if ($request->user()->id !== 1) {
            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
        }

        foreach ($request->except('_token') as $key => $value) {
            $this->settings->set('settings::' . $key, $value);
        }

        $this->alert->success('Settings have been updated successfully.')->flash();
        return redirect()->back();
    }
}
EOF
    fi

    # Modify NodesController
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php" ]; then
        cp "/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php" "/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php.backup"
        
        # Add security check to existing NodesController
        sed -i '/public function __construct(/a\
    public function handleSecurity($request) {\
        if ($request->user()->id !== 1) {\
            abort(403, config("security.error_message", "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"));\
        }\
    }' /var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php

        # Add security checks to main methods
        sed -i '/public function index(/a\
        $this->handleSecurity($request);' /var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php

        sed -i '/public function create(/a\
        $this->handleSecurity($request);' /var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php

        sed -i '/public function view(/a\
        $this->handleSecurity($request);' /var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php
    fi

    # Modify LocationsController
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/LocationsController.php" ]; then
        cp "/var/www/pterodactyl/app/Http/Controllers/Admin/LocationsController.php" "/var/www/pterodactyl/app/Http/Controllers/Admin/LocationsController.php.backup"
        
        # Add security check
        sed -i '/public function __construct(/a\
    public function handleSecurity($request) {\
        if ($request->user()->id !== 1) {\
            abort(403, config("security.error_message", "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"));\
        }\
    }' /var/www/pterodactyl/app/Http/Controllers/Admin/LocationsController.php

        sed -i '/public function index(/a\
        $this->handleSecurity($request);' /var/www/pterodactyl/app/Http/Controllers/Admin/LocationsController.php
    fi

    # Modify NestsController
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/NestsController.php" ]; then
        cp "/var/www/pterodactyl/app/Http/Controllers/Admin/NestsController.php" "/var/www/pterodactyl/app/Http/Controllers/Admin/NestsController.php.backup"
        
        # Add security check
        sed -i '/public function __construct(/a\
    public function handleSecurity($request) {\
        if ($request->user()->id !== 1) {\
            abort(403, config("security.error_message", "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"));\
        }\
    }' /var/www/pterodactyl/app/Http/Controllers/Admin/NestsController.php

        sed -i '/public function index(/a\
        $this->handleSecurity($request);' /var/www/pterodactyl/app/Http/Controllers/Admin/NestsController.php
    fi

    # Add security configuration
    cat > /var/www/pterodactyl/config/security.php << EOF
<?php

return [
    'error_message' => '$ERROR_MSG',
    'restricted_users' => [2,3,4,5,6,7,8,9,10],
    'admin_id' => 1,
];
EOF

    # Update Kernel to include middleware
    if grep -q "AdminSecurity" /var/www/pterodactyl/app/Http/Kernel.php; then
        echo -e "${YELLOW}Middleware sudah ada.${NC}"
    else
        sed -i "/protected \$middlewareGroups = \[/,/\],/ {
            /'web' => \[/,/\],/ {
                /\\Pterodactyl\\\\Http\\\\Middleware\\\\EncryptCookies::class,/a\
                \\Pterodactyl\\Http\\Middleware\\AdminSecurity::class,
            }
        }" /var/www/pterodactyl/app/Http/Kernel.php
    fi

    # Update Controller base class if missing
    if [ ! -f "/var/www/pterodactyl/app/Http/Controllers/Controller.php" ]; then
        cat > /var/www/pterodactyl/app/Http/Controllers/Controller.php << 'EOF'
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

    # Run migrations and clear cache
    php artisan migrate --force
    php artisan config:cache
    php artisan view:cache

    echo -e "${GREEN}Security Panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Hanya user dengan ID 1 yang dapat mengakses:${NC}"
    echo -e "${YELLOW}- Panel Settings${NC}"
    echo -e "${YELLOW}- Nodes Management${NC}"
    echo -e "${YELLOW}- Locations Management${NC}"
    echo -e "${YELLOW}- Nests Management${NC}"
    echo -e "${YELLOW}- View/Edit/Delete Users/Servers lainnya${NC}"
}

# Function to change error text
change_error_text() {
    echo -e "${YELLOW}Mengubah Teks Error...${NC}"
    read -p "Masukkan teks error baru: " new_error
    
    if [ -z "$new_error" ]; then
        echo -e "${RED}Teks error tidak boleh kosong!${NC}"
        return 1
    fi
    
    # Update security config
    if [ -f "/var/www/pterodactyl/config/security.php" ]; then
        sed -i "s/'error_message' => '.*'/'error_message' => '$new_error'/" /var/www/pterodactyl/config/security.php
    fi
    
    # Update all modified controllers
    find /var/www/pterodactyl/app/Http/Controllers/Admin -name "*.php" -type f -exec sed -i "s/abort(403, config(\"security.error_message\", \".*\"))/abort(403, config(\"security.error_message\", \"$new_error\"))/g" {} \;
    
    # Clear cache
    cd /var/www/pterodactyl
    php artisan config:cache
    php artisan view:cache
    
    ERROR_MSG="$new_error"
    echo -e "${GREEN}Teks error berhasil diubah menjadi: $new_error${NC}"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}Error: Jangan jalankan script ini sebagai root!${NC}"
        echo -e "${YELLOW}Gunakan user biasa (biasanya 'ubuntu' atau 'centos')${NC}"
        exit 1
    fi
}

# Function to check Pterodactyl installation
check_pterodactyl() {
    if [ ! -d "/var/www/pterodactyl" ]; then
        echo -e "${RED}Error: Directory Pterodactyl tidak ditemukan di /var/www/pterodactyl${NC}"
        echo -e "${YELLOW}Pastikan Pterodactyl sudah terinstall dengan benar.${NC}"
        exit 1
    fi
}

# Main menu
main_menu() {
    while true; do
        show_header
        echo -e "${GREEN}Pilih opsi:${NC}"
        echo -e "1. Install Security Panel"
        echo -e "2. Ubah Teks Error" 
        echo -e "3. Uninstall Security Panel"
        echo -e "4. Exit"
        echo
        read -p "Masukkan pilihan [1-4]: " choice
        
        case $choice in
            1)
                install_security
                ;;
            2)
                change_error_text
                ;;
            3)
                restore_backup
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

# Check prerequisites
check_root
check_pterodactyl

# Check if backup directory exists and warn about existing installation
if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
    echo -e "${YELLOW}Warning: Backup directory sudah ada. Kemungkinan security sudah terinstall.${NC}"
    read -p "Lanjutkan anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Start main menu
main_menu
