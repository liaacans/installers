#!/bin/bash

# security.sh - Security Panel Pterodactyl
# By @ginaabaikhati

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Security message
SECURITY_MSG="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Check if running on correct VPS
CHECK_VPS() {
    echo -e "${YELLOW}Memeriksa sistem...${NC}"
    sleep 2
    
    # Check if Pterodactyl is installed
    if [ ! -f "/var/www/pterodactyl/app/Http/Controllers/Controller.php" ] && [ ! -f "/var/www/pterodactyl/app/Models/User.php" ]; then
        echo -e "${RED}ERROR: Pterodactyl tidak terdeteksi di sistem ini!${NC}"
        echo -e "${RED}Script hanya bisa dijalankan di VPS yang sudah terinstall Pterodactyl.${NC}"
        exit 1
    fi
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}ERROR: Script harus dijalankan sebagai root!${NC}"
        exit 1
    fi
}

# Backup original files
BACKUP_FILES() {
    echo -e "${YELLOW}Membuat backup file original...${NC}"
    
    # Backup important files
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/ServerController.php" ]; then
        cp "/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/ServerController.php" "/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/ServerController.php.backup"
    fi
    
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin" ]; then
        cp -r "/var/www/pterodactyl/app/Http/Controllers/Admin" "/var/www/pterodactyl/app/Http/Controllers/Admin.backup"
    fi
    
    if [ -f "/var/www/pterodactyl/app/Models/User.php" ]; then
        cp "/var/www/pterodactyl/app/Models/User.php" "/var/www/pterodactyl/app/Models/User.php.backup"
    fi
    
    echo -e "${GREEN}Backup berhasil dibuat!${NC}"
}

# Install security
INSTALL_SECURITY() {
    echo -e "${YELLOW}Menginstall Security Panel Pterodactyl...${NC}"
    
    # Create security middleware
    cat > /var/www/pterodactyl/app/Http/Middleware/SecurityCheck.php << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Pterodactyl\Models\User;

class SecurityCheck
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        
        // Block all admin actions except for user ID 1
        if ($user && $user->id !== 1) {
            $path = $request->path();
            
            // Check for sensitive actions
            $sensitivePaths = [
                'admin/nodes', 'admin/locations', 'admin/nests', 
                'admin/settings', 'admin/users', 'api/application'
            ];
            
            $sensitiveActions = ['store', 'update', 'destroy', 'delete'];
            
            foreach ($sensitivePaths as $sensitivePath) {
                if (str_contains($path, $sensitivePath)) {
                    foreach ($sensitiveActions as $action) {
                        if (str_contains($path, $action) || $request->isMethod('post') || $request->isMethod('put') || $request->isMethod('delete')) {
                            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
                        }
                    }
                }
            }
        }
        
        return $next($request);
    }
}
EOF

    # Modify User model to add security check
    if [ -f "/var/www/pterodactyl/app/Models/User.php" ]; then
        # Backup original
        cp "/var/www/pterodactyl/app/Models/User.php" "/var/www/pterodactyl/app/Models/User.php.original"
        
        # Add security method to User model
        sed -i '/class User extends.*/a \
\    \
\    public function isSuperAdmin() \
\    { \
\        return $this->id === 1; \
\    }' "/var/www/pterodactyl/app/Models/User.php"
    fi

    # Modify Admin Controller files to add security
    MODIFY_ADMIN_CONTROLLERS

    # Update middleware in Kernel
    if [ -f "/var/www/pterodactyl/app/Http/Kernel.php" ]; then
        # Check if middleware already exists
        if ! grep -q "SecurityCheck" "/var/www/pterodactyl/app/Http/Kernel.php"; then
            sed -i "/protected \$routeMiddleware = \[/a \
        'security' => \\\Pterodactyl\\Http\\Middleware\\SecurityCheck::class," "/var/www/pterodactyl/app/Http/Kernel.php"
        fi
    fi

    # Apply security to routes
    APPLY_ROUTE_SECURITY

    echo -e "${GREEN}Security Panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Hanya user dengan ID 1 yang bisa mengubah settings, nodes, locations, nests, dan users.${NC}"
}

# Modify admin controllers
MODIFY_ADMIN_CONTROLLERS() {
    echo -e "${YELLOW}Memodifikasi controller admin...${NC}"
    
    # NodeController security
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php" ]; then
        sed -i '/public function __construct(/a \
\        $this->middleware(\"security\");' "/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php"
    fi
    
    # LocationController security  
    if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/LocationsController.php" ]; then
        # Fix the missing Controller class issue
        if grep -q "Class.*Controller.*not found" "/var/www/pterodactyl/app/Http/Controllers/Admin/LocationsController.php" 2>/dev/null; then
            cat > "/var/www/pterodactyl/app/Http/Controllers/Admin/LocationsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Models\Location;
use Prologue\Alerts\AlertsMessageBag;

class LocationsController extends AdminController
{
    public function __construct()
    {
        parent::__construct();
        $this->middleware("security");
    }

    public function index()
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return parent::index();
    }

    public function create()
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return parent::create();
    }

    public function store(Request $request)
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return parent::store($request);
    }

    public function update(Request $request, $id)
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return parent::update($request, $id);
    }

    public function destroy($id)
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return parent::destroy($id);
    }
}
EOF
        else
            sed -i '/public function __construct(/a \
\        $this->middleware(\"security\");' "/var/www/pterodactyl/app/Http/Controllers/Admin/LocationsController.php"
        fi
    fi
    
    # Add security to other admin controllers
    ADMIN_FILES=(
        "NestsController.php" "SettingsController.php" "UsersController.php" 
        "ServersController.php" "DatabaseController.php"
    )
    
    for file in "${ADMIN_FILES[@]}"; do
        if [ -f "/var/www/pterodactyl/app/Http/Controllers/Admin/$file" ]; then
            if ! grep -q "security" "/var/www/pterodactyl/app/Http/Controllers/Admin/$file"; then
                sed -i '/public function __construct(/a \
\        $this->middleware(\"security\");' "/var/www/pterodactyl/app/Http/Controllers/Admin/$file"
            fi
        fi
    done
}

# Apply security to routes
APPLY_ROUTE_SECURITY() {
    echo -e "${YELLOW}Menerapkan security ke routes...${NC}"
    
    # Backup routes
    if [ -f "/var/www/pterodactyl/routes/api.php" ]; then
        cp "/var/www/pterodactyl/routes/api.php" "/var/www/pterodactyl/routes/api.php.backup"
        
        # Add security middleware to admin API routes
        sed -i '/Route::group(\[\x27prefix\x27 => \x27application\x27, \x27domain\x27 => config(\x27pterodactyl.api\x27)\x27domain\x27\], function () {/a \
\    Route::group([\"middleware\" => \"security\"], function () {' "/var/www/pterodactyl/routes/api.php"
        
        # Close the security group
        sed -i '/}); \/\/ End application routes group/a \
\    });' "/var/www/pterodactyl/routes/api.php"
    fi
}

# Change error text
CHANGE_ERROR_TEXT() {
    echo -e "${YELLOW}Mengubah teks error security...${NC}"
    
    read -p "Masukkan teks error security baru: " NEW_TEXT
    
    if [ -z "$NEW_TEXT" ]; then
        echo -e "${RED}Teks tidak boleh kosong!${NC}"
        return 1
    fi
    
    SECURITY_MSG="$NEW_TEXT"
    
    # Update security message in all files
    find /var/www/pterodactyl/app/Http/Controllers/Admin -name "*.php" -type f -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${NEW_TEXT//\//\\/}/g" {} \;
    
    if [ -f "/var/www/pterodactyl/app/Http/Middleware/SecurityCheck.php" ]; then
        sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${NEW_TEXT//\//\\/}/g" "/var/www/pterodactyl/app/Http/Middleware/SecurityCheck.php"
    fi
    
    echo -e "${GREEN}Teks error berhasil diubah!${NC}"
}

# Uninstall security
UNINSTALL_SECURITY() {
    echo -e "${YELLOW}Menghapus security panel...${NC}"
    
    # Remove security middleware file
    if [ -f "/var/www/pterodactyl/app/Http/Middleware/SecurityCheck.php" ]; then
        rm -f "/var/www/pterodactyl/app/Http/Middleware/SecurityCheck.php"
    fi
    
    # Restore original files from backup
    if [ -f "/var/www/pterodactyl/app/Models/User.php.original" ]; then
        mv "/var/www/pterodactyl/app/Models/User.php.original" "/var/www/pterodactyl/app/Models/User.php"
    fi
    
    # Restore admin controllers
    if [ -d "/var/www/pterodactyl/app/Http/Controllers/Admin.backup" ]; then
        rm -rf "/var/www/pterodactyl/app/Http/Controllers/Admin"
        mv "/var/www/pterodactyl/app/Http/Controllers/Admin.backup" "/var/www/pterodactyl/app/Http/Controllers/Admin"
    fi
    
    # Restore API routes
    if [ -f "/var/www/pterodactyl/routes/api.php.backup" ]; then
        mv "/var/www/pterodactyl/routes/api.php.backup" "/var/www/pterodactyl/routes/api.php"
    fi
    
    # Remove security middleware from Kernel
    if [ -f "/var/www/pterodactyl/app/Http/Kernel.php" ]; then
        sed -i "/'security' =>.*SecurityCheck::class,/d" "/var/www/pterodactyl/app/Http/Kernel.php"
    fi
    
    echo -e "${GREEN}Security panel berhasil diuninstall!${NC}"
    echo -e "${YELLOW}Panel Pterodactyl kembali ke keadaan semula.${NC}"
}

# Main menu
show_menu() {
    echo -e "${BLUE}"
    echo "=========================================="
    echo "    Security Panel Pterodactyl"
    echo "    By @ginaabaikhati"
    echo "=========================================="
    echo -e "${NC}"
    echo "1. Install Security Panel"
    echo "2. Ubah Teks Error" 
    echo "3. Uninstall Security Panel"
    echo "4. Exit"
    echo
    read -p "Pilih opsi [1-4]: " choice
}

# Main script
main() {
    # Check VPS first
    CHECK_VPS
    
    while true; do
        show_menu
        case $choice in
            1)
                BACKUP_FILES
                INSTALL_SECURITY
                echo -e "${YELLOW}Jangan lupa jalankan: php artisan optimize:clear${NC}"
                ;;
            2)
                CHANGE_ERROR_TEXT
                ;;
            3)
                UNINSTALL_SECURITY
                ;;
            4)
                echo -e "${GREEN}Keluar dari script.${NC}"
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

# Run main function
main "$@"
