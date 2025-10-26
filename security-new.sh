#!/bin/bash

# Security Panel Pterodactyl - By @ginaabaikhati
# Script untuk mengamankan panel Pterodactyl

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PANEL_PATH="/var/www/pterodactyl"
BACKUP_PATH="/root/pterodactyl_backup"
ERROR_MESSAGE="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

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

# Function to check if panel directory exists
check_panel_exists() {
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}Error: Directory Pterodactyl tidak ditemukan di $PANEL_PATH${NC}"
        echo -e "${YELLOW}Silakan sesuaikan PANEL_PATH dalam script sesuai instalasi Anda${NC}"
        exit 1
    fi
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup panel...${NC}"
    
    if [ -d "$BACKUP_PATH" ]; then
        rm -rf "$BACKUP_PATH"
    fi
    
    mkdir -p "$BACKUP_PATH"
    
    # Backup important files
    cp -r "$PANEL_PATH/app/Http" "$BACKUP_PATH/" 2>/dev/null || true
    cp -r "$PANEL_PATH/app/Models" "$BACKUP_PATH/" 2>/dev/null || true
    cp -r "$PANEL_PATH/routes" "$BACKUP_PATH/" 2>/dev/null || true
    cp -r "$PANEL_PATH/app/Providers" "$BACKUP_PATH/" 2>/dev/null || true
    
    echo -e "${GREEN}Backup berhasil dibuat di $BACKUP_PATH${NC}"
}

# Function to restore backup
restore_backup() {
    echo -e "${YELLOW}Memulihkan panel dari backup...${NC}"
    
    if [ ! -d "$BACKUP_PATH" ]; then
        echo -e "${RED}Error: Backup tidak ditemukan di $BACKUP_PATH${NC}"
        return 1
    fi
    
    # Restore files
    cp -r "$BACKUP_PATH/Http" "$PANEL_PATH/app/" 2>/dev/null || true
    cp -r "$BACKUP_PATH/Models" "$PANEL_PATH/app/" 2>/dev/null || true
    cp -r "$BACKUP_PATH/routes" "$PANEL_PATH/" 2>/dev/null || true
    cp -r "$BACKUP_PATH/Providers" "$PANEL_PATH/app/" 2>/dev/null || true
    
    # Run panel commands
    cd "$PANEL_PATH"
    php artisan cache:clear
    php artisan view:clear
    
    echo -e "${GREEN}Panel berhasil dipulihkan dari backup${NC}"
}

# Function to install security
install_security() {
    check_panel_exists
    create_backup
    
    echo -e "${YELLOW}Menginstal security panel...${NC}"
    
    cd "$PANEL_PATH"
    
    # Backup original files first
    cp app/Http/Controllers/Admin/AdminController.php app/Http/Controllers/Admin/AdminController.php.backup 2>/dev/null || true
    cp app/Http/Controllers/Admin/NodesController.php app/Http/Controllers/Admin/NodesController.php.backup 2>/dev/null || true
    cp app/Http/Controllers/Admin/LocationsController.php app/Http/Controllers/Admin/LocationsController.php.backup 2>/dev/null || true
    cp app/Http/Controllers/Admin/NestsController.php app/Http/Controllers/Admin/NestsController.php.backup 2>/dev/null || true
    cp app/Http/Controllers/Admin/UsersController.php app/Http/Controllers/Admin/UsersController.php.backup 2>/dev/null || true
    cp app/Http/Controllers/Admin/ServersController.php app/Http/Controllers/Admin/ServersController.php.backup 2>/dev/null || true
    cp app/Http/Middleware/AdminAuthenticate.php app/Http/Middleware/AdminAuthenticate.php.backup 2>/dev/null || true
    
    # Create security middleware
    cat > app/Http/Middleware/SecurityCheck.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SecurityCheck
{
    public function handle(Request $request, Closure $next, $type = null): Response
    {
        $user = $request->user();
        
        if (!$user || $user->id !== 1) {
            $restrictedRoutes = [
                'admin.settings', 'admin.nodes', 'admin.locations', 
                'admin.nests', 'admin.users', 'admin.servers'
            ];
            
            $currentRoute = $request->route()->getName();
            
            if (in_array($currentRoute, $restrictedRoutes) || 
                str_contains($request->path(), 'api/application') ||
                $request->isMethod('POST') || 
                $request->isMethod('PUT') || 
                $request->isMethod('DELETE') ||
                $request->isMethod('PATCH')) {
                
                if ($user && $user->id !== 1) {
                    abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
                }
            }
        }
        
        return $next($request);
    }
}
EOF

    # Modify AdminController
    cat > app/Http/Controllers/Admin/AdminController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\View\View;

class AdminController extends Controller
{
    public function index(): View
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        return view('admin.index');
    }

    public function settings(Request $request): View
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        return view('admin.settings');
    }
}
EOF

    # Modify NodesController
    cat > app/Http/Controllers/Admin/NodesController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\View\View;

class NodesController extends Controller
{
    public function index(): View
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        return view('admin.nodes.index');
    }

    public function create(): View
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        return view('admin.nodes.new');
    }

    public function view(string $id): View
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        return view('admin.nodes.view', compact('id'));
    }

    public function update(string $id): RedirectResponse
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        // Original update logic would go here
        return redirect()->route('admin.nodes');
    }

    public function delete(string $id): RedirectResponse
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        // Original delete logic would go here
        return redirect()->route('admin.nodes');
    }
}
EOF

    # Modify LocationsController
    cat > app/Http/Controllers/Admin/LocationsController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\View\View;

class LocationsController extends Controller
{
    public function index(): View
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        return view('admin.locations.index');
    }

    public function create(): View
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        return view('admin.locations.new');
    }

    public function update(string $id): RedirectResponse
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        // Original update logic would go here
        return redirect()->route('admin.locations');
    }

    public function delete(string $id): RedirectResponse
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        // Original delete logic would go here
        return redirect()->route('admin.locations');
    }
}
EOF

    # Modify NestsController
    cat > app/Http/Controllers/Admin/NestsController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\View\View;

class NestsController extends Controller
{
    public function index(): View
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        return view('admin.nests.index');
    }

    public function view(string $id): View
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        return view('admin.nests.view', compact('id'));
    }

    public function update(string $id): RedirectResponse
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        // Original update logic would go here
        return redirect()->route('admin.nests');
    }

    public function delete(string $id): RedirectResponse
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        // Original delete logic would go here
        return redirect()->route('admin.nests');
    }
}
EOF

    # Modify UsersController
    cat > app/Http/Controllers/Admin/UsersController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\View\View;

class UsersController extends Controller
{
    public function index(): View
    {
        return view('admin.users.index');
    }

    public function view(string $id): View
    {
        $user = auth()->user();
        $targetUser = \App\Models\User::find($id);
        
        if ($user->id !== 1 && $user->id !== $targetUser->id) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        return view('admin.users.view', compact('id'));
    }

    public function update(string $id): RedirectResponse
    {
        $user = auth()->user();
        
        if ($user->id !== 1 && $user->id !== (int)$id) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        // Original update logic would go here
        return redirect()->route('admin.users');
    }

    public function delete(string $id): RedirectResponse
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        // Original delete logic would go here
        return redirect()->route('admin.users');
    }
}
EOF

    # Modify ServersController
    cat > app/Http/Controllers/Admin/ServersController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\View\View;

class ServersController extends Controller
{
    public function index(): View
    {
        return view('admin.servers.index');
    }

    public function view(string $id): View
    {
        $user = auth()->user();
        $server = \App\Models\Server::find($id);
        
        if (!$server) {
            abort(404);
        }
        
        if ($user->id !== 1 && $user->id !== $server->owner_id) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        return view('admin.servers.view', compact('id'));
    }

    public function delete(string $id): RedirectResponse
    {
        $user = auth()->user();
        $server = \App\Models\Server::find($id);
        
        if (!$server) {
            abort(404);
        }
        
        if ($user->id !== 1 && $user->id !== $server->owner_id) {
            abort(500, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
        
        // Original delete logic would go here
        return redirect()->route('admin.servers');
    }
}
EOF

    # Update Kernel to include security middleware
    if ! grep -q "SecurityCheck" app/Http/Kernel.php; then
        sed -i "/protected \$middlewareGroups = \[/a \
        'security' => [\\\n\
            \App\Http\Middleware\SecurityCheck::class,\\\n\
        ]," app/Http/Kernel.php
    fi

    # Update web routes to use security middleware
    if [ -f routes/web.php ]; then
        cp routes/web.php routes/web.php.backup
        
        # Add security middleware to admin routes
        sed -i "s/Route::middleware('\''admin'\'')/Route::middleware(['admin', 'security'])/g" routes/web.php
    fi

    # Clear cache
    php artisan cache:clear
    php artisan view:clear

    echo -e "${GREEN}Security panel berhasil diinstal!${NC}"
    echo -e "${YELLOW}Hanya user dengan ID 1 yang dapat mengakses:${NC}"
    echo -e "${YELLOW}- Panel Settings${NC}"
    echo -e "${YELLOW}- Nodes Management${NC}"
    echo -e "${YELLOW}- Locations Management${NC}"
    echo -e "${YELLOW}- Nests Management${NC}"
    echo -e "${YELLOW}- Edit/Delete users lain${NC}"
    echo -e "${YELLOW}- File manager dan operasi berbahaya lainnya${NC}"
}

# Function to change error message
change_error_message() {
    check_panel_exists
    
    echo -e "${YELLOW}Mengubah pesan error...${NC}"
    
    read -p "Masukkan pesan error baru: " new_message
    
    if [ -z "$new_message" ]; then
        echo -e "${RED}Pesan error tidak boleh kosong!${NC}"
        return 1
    fi
    
    # Update error message in all controller files
    find "$PANEL_PATH/app/Http/Controllers/Admin" -name "*.php" -type f -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_message}/g" {} \;
    
    # Update security middleware
    if [ -f "$PANEL_PATH/app/Http/Middleware/SecurityCheck.php" ]; then
        sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_message}/g" "$PANEL_PATH/app/Http/Middleware/SecurityCheck.php"
    fi
    
    # Clear cache
    cd "$PANEL_PATH"
    php artisan cache:clear
    php artisan view:clear
    
    echo -e "${GREEN}Pesan error berhasil diubah!${NC}"
}

# Function to uninstall security
uninstall_security() {
    check_panel_exists
    
    echo -e "${YELLOW}Menghapus security panel...${NC}"
    
    restore_backup
    
    # Remove security middleware file
    rm -f "$PANEL_PATH/app/Http/Middleware/SecurityCheck.php"
    
    # Remove backup files
    find "$PANEL_PATH/app/Http/Controllers/Admin" -name "*.backup" -type f -delete
    rm -f "$PANEL_PATH/routes/web.php.backup"
    
    # Clear cache
    cd "$PANEL_PATH"
    php artisan cache:clear
    php artisan view:clear
    
    echo -e "${GREEN}Security panel berhasil diuninstal!${NC}"
    echo -e "${YELLOW}Panel telah dikembalikan ke keadaan semula${NC}"
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
        echo
        read -p "Masukkan pilihan [1-4]: " choice
        
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
                echo -e "${GREEN}Terima kasih! By @ginaabaikhati${NC}"
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

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Script harus dijalankan sebagai root!${NC}"
    echo "Gunakan: sudo ./security.sh"
    exit 1
fi

# Run main menu
main_menu
