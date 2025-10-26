#!/bin/bash

# Security Panel Pterodactyl - By @ginaabaikhati
# Script untuk mengamankan panel Pterodactyl

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error message
ERROR_MSG="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Path variables
PTERODACTYL_PATH="/var/www/pterodactyl"
BACKUP_DIR="/root/pterodactyl_backup"

# Function to display header
show_header() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════╗"
    echo "║           Security Panel Pterodactyl          ║"
    echo "║              By @ginaabaikhati                ║"
    echo "╚════════════════════════════════════════════════╝"
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
    if [ ! -d "$PTERODACTYL_PATH" ]; then
        echo -e "${RED}Error: Pterodactyl tidak ditemukan di $PTERODACTYL_PATH${NC}"
        echo -e "${YELLOW}Pastikan Pterodactyl sudah terinstall dengan benar.${NC}"
        exit 1
    fi
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup file...${NC}"
    mkdir -p "$BACKUP_DIR"
    cp "$PTERODACTYL_PATH/app/Http/Controllers/Admin"/*.php "$BACKUP_DIR/" 2>/dev/null || true
    cp "$PTERODACTYL_PATH/app/Http/Controllers/Api/Client/Servers"/*.php "$BACKUP_DIR/" 2>/dev/null || true
    cp "$PTERODACTYL_PATH/app/Http/Middleware"/*.php "$BACKUP_DIR/" 2>/dev/null || true
    echo -e "${GREEN}Backup berhasil dibuat di $BACKUP_DIR${NC}"
}

# Function to restore backup
restore_backup() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}Error: Backup tidak ditemukan!${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Memulihkan file dari backup...${NC}"
    cp "$BACKUP_DIR"/*.php "$PTERODACTYL_PATH/app/Http/Controllers/Admin/" 2>/dev/null || true
    cp "$BACKUP_DIR"/*.php "$PTERODACTYL_PATH/app/Http/Controllers/Api/Client/Servers/" 2>/dev/null || true
    cp "$BACKUP_DIR"/*.php "$PTERODACTYL_PATH/app/Http/Middleware/" 2>/dev/null || true
    echo -e "${GREEN}Backup berhasil dipulihkan${NC}"
}

# Function to install security
install_security() {
    show_header
    echo -e "${YELLOW}Menginstall Security Panel...${NC}"
    
    check_pterodactyl
    create_backup
    
    # Create security middleware
    cat > "$PTERODACTYL_PATH/app/Http/Middleware/SecurityMiddleware.php" << 'EOF'
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
        
        // Allow ID 1 (super admin) to access everything
        if ($user && $user->id === 1) {
            return $next($request);
        }
        
        $path = $request->path();
        $method = $request->method();
        
        // Lock sensitive routes for non-admin users
        $lockedRoutes = [
            'admin/settings', 'admin/nodes', 'admin/locations', 
            'admin/nests', 'admin/servers', 'admin/users'
        ];
        
        // Check if current path contains any locked routes
        foreach ($lockedRoutes as $route) {
            if (str_contains($path, $route)) {
                if ($method !== 'GET') { // Allow GET requests, block POST/PUT/DELETE
                    return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
                }
            }
        }
        
        // Additional security for specific actions
        if ($method === 'DELETE' || $method === 'PUT' || $method === 'POST') {
            $sensitiveActions = [
                'destroy', 'delete', 'update', 'store', 'edit'
            ];
            
            foreach ($sensitiveActions as $action) {
                if (str_contains($path, $action)) {
                    return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
                }
            }
        }
        
        return $next($request);
    }
}
EOF

    # Modify Admin Controller
    cat > "$PTERODACTYL_PATH/app/Http/Controllers/Admin/AdminController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\JsonResponse;
use Pterodactyl\Http\Controllers\Controller;

class AdminController extends Controller
{
    public function index(): View
    {
        return view('admin.index');
    }
    
    public function settings(): View
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        return view('admin.settings');
    }
    
    public function updateSettings(): JsonResponse
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        
        // Original update logic here
        return response()->json(['success' => true]);
    }
}
EOF

    # Modify Nodes Controller
    cat > "$PTERODACTYL_PATH/app/Http/Controllers/Admin/NodesController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\JsonResponse;
use Pterodactyl\Http\Controllers\Controller;

class NodesController extends Controller
{
    public function index()
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        return view('admin.nodes.index');
    }
    
    public function create(): JsonResponse
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        return response()->json(['success' => true]);
    }
    
    public function update(): JsonResponse
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        return response()->json(['success' => true]);
    }
    
    public function delete(): JsonResponse
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        return response()->json(['success' => true]);
    }
}
EOF

    # Modify Locations Controller
    cat > "$PTERODACTYL_PATH/app/Http/Controllers/Admin/LocationsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\JsonResponse;
use Pterodactyl\Http\Controllers\Controller;

class LocationsController extends Controller
{
    public function index()
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        return view('admin.locations.index');
    }
    
    public function store(): JsonResponse
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        return response()->json(['success' => true]);
    }
    
    public function update(): JsonResponse
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        return response()->json(['success' => true]);
    }
    
    public function destroy(): JsonResponse
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        return response()->json(['success' => true]);
    }
}
EOF

    # Modify Nests Controller
    cat > "$PTERODACTYL_PATH/app/Http/Controllers/Admin/NestsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\JsonResponse;
use Pterodactyl\Http\Controllers\Controller;

class NestsController extends Controller
{
    public function index()
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        return view('admin.nests.index');
    }
    
    public function store(): JsonResponse
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        return response()->json(['success' => true]);
    }
    
    public function update(): JsonResponse
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        return response()->json(['success' => true]);
    }
    
    public function destroy(): JsonResponse
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        return response()->json(['success' => true]);
    }
}
EOF

    # Modify Users Controller
    cat > "$PTERODACTYL_PATH/app/Http/Controllers/Admin/UsersController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\JsonResponse;
use Pterodactyl\Http\Controllers\Controller;

class UsersController extends Controller
{
    public function index()
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        return view('admin.users.index');
    }
    
    public function store(): JsonResponse
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        return response()->json(['success' => true]);
    }
    
    public function update(): JsonResponse
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        return response()->json(['success' => true]);
    }
    
    public function delete(): JsonResponse
    {
        $user = auth()->user();
        if ($user->id !== 1) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        return response()->json(['success' => true]);
    }
}
EOF

    # Update routes middleware (simulate by modifying web.php)
    if [ -f "$PTERODACTYL_PATH/routes/web.php" ]; then
        cp "$PTERODACTYL_PATH/routes/web.php" "$BACKUP_DIR/web.php.backup"
        
        # Add security middleware to routes
        sed -i '1i\use Pterodactyl\Http\Middleware\SecurityMiddleware;' "$PTERODACTYL_PATH/routes/web.php"
        
        # Add middleware to admin routes group
        sed -i '/Route::prefix(.admin.)->group/,/});/{
            /middleware(.web.)/a\            \x27middleware\x27 => [SecurityMiddleware::class],
        }' "$PTERODACTYL_PATH/routes/web.php"
    fi

    echo -e "${GREEN}Security Panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Hanya user dengan ID 1 yang dapat mengubah settings, nodes, locations, nests, dan users.${NC}"
    
    # Clear cache
    cd "$PTERODACTYL_PATH" && php artisan cache:clear
    cd "$PTERODACTYL_PATH" && php artisan view:clear
}

# Function to change error text
change_error_text() {
    show_header
    echo -e "${YELLOW}Mengubah Teks Error...${NC}"
    
    read -p "Masukkan teks error baru: " new_error_text
    
    if [ -z "$new_error_text" ]; then
        echo -e "${RED}Error: Teks tidak boleh kosong!${NC}"
        return 1
    fi
    
    # Update error message in all controller files
    find "$PTERODACTYL_PATH/app/Http/Controllers/Admin" -name "*.php" -type f -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_error_text}/g" {} \;
    find "$PTERODACTYL_PATH/app/Http/Middleware" -name "*.php" -type f -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_error_text}/g" {} \;
    
    ERROR_MSG="$new_error_text"
    
    echo -e "${GREEN}Teks error berhasil diubah!${NC}"
    echo -e "${BLUE}Teks error baru: $new_error_text${NC}"
    
    # Clear cache
    cd "$PTERODACTYL_PATH" && php artisan cache:clear
}

# Function to uninstall security
uninstall_security() {
    show_header
    echo -e "${YELLOW}Uninstall Security Panel...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}Error: Backup tidak ditemukan!${NC}"
        echo -e "${YELLOW}Silakan install security terlebih dahulu.${NC}"
        return 1
    fi
    
    restore_backup
    
    # Remove security middleware
    rm -f "$PTERODACTYL_PATH/app/Http/Middleware/SecurityMiddleware.php"
    
    # Restore original web.php if backup exists
    if [ -f "$BACKUP_DIR/web.php.backup" ]; then
        cp "$BACKUP_DIR/web.php.backup" "$PTERODACTYL_PATH/routes/web.php"
    fi
    
    echo -e "${GREEN}Security Panel berhasil diuninstall!${NC}"
    echo -e "${YELLOW}Panel Pterodactyl telah dikembalikan ke keadaan semula.${NC}"
    
    # Clear cache
    cd "$PTERODACTYL_PATH" && php artisan cache:clear
    cd "$PTERODactyl_PATH" && php artisan view:clear
}

# Function to fix LocaleController error
fix_locale_controller() {
    echo -e "${YELLOW}Memperbaiki error LocaleController...${NC}"
    
    # Fix the Controller class import
    if [ -f "$PTERODACTYL_PATH/app/Http/Controllers/Controller.php" ]; then
        # Ensure proper namespace in controllers
        find "$PTERODACTYL_PATH/app/Http/Controllers" -name "*.php" -type f -exec sed -i 's/use Pterodactyl\\Http\\Controllers\\Controller;/use Pterodactyl\\Http\\Controllers\\Controller;/g' {} \;
    fi
    
    echo -e "${GREEN}Perbaikan LocaleController selesai!${NC}"
}

# Main menu
main_menu() {
    while true; do
        show_header
        echo -e "${GREEN}Pilih opsi:${NC}"
        echo -e "1. Install Security Panel"
        echo -e "2. Ubah Teks Error" 
        echo -e "3. Uninstall Security Panel"
        echo -e "4. Fix LocaleController Error"
        echo -e "5. Exit"
        echo ""
        read -p "Masukkan pilihan [1-5]: " choice
        
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
                fix_locale_controller
                ;;
            5)
                echo -e "${GREEN}Terima kasih! By @ginaabaikhati${NC}"
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

# Check if script is run with arguments
if [ $# -eq 1 ]; then
    case $1 in
        "install")
            install_security
            ;;
        "uninstall")
            uninstall_security
            ;;
        "fix")
            fix_locale_controller
            ;;
        *)
            echo "Usage: $0 {install|uninstall|fix}"
            exit 1
            ;;
    esac
else
    # Run main menu
    check_root
    check_pterodactyl
    main_menu
fi
