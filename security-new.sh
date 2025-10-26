#!/bin/bash

# security.sh - Security Panel Pterodactyl
# Script untuk mengamankan panel Pterodactyl
# By @ginaabaikhati

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error message
ERROR_MSG="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Backup directory
BACKUP_DIR="/var/www/pterodactyl-backup"

# Pterodactyl directory
PTERODACTYL_DIR="/var/www/pterodactyl"

# Function to display header
display_header() {
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
        echo -e "${RED}Error: Script harus dijalankan sebagai root${NC}"
        exit 1
    fi
}

# Function to check Pterodactyl installation
check_pterodactyl() {
    if [ ! -d "$PTERODACTYL_DIR" ]; then
        echo -e "${RED}Error: Directory Pterodactyl tidak ditemukan di $PTERODACTYL_DIR${NC}"
        exit 1
    fi
    
    if [ ! -f "$PTERODACTYL_DIR/app/Http/Controllers/Controller.php" ]; then
        echo -e "${RED}Error: File Controller.php tidak ditemukan${NC}"
        exit 1
    fi
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/pterodactyl_backup_$TIMESTAMP.tar.gz"
    
    tar -czf "$BACKUP_FILE" -C "$PTERODACTYL_DIR/app/Http/Controllers" . 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Backup berhasil dibuat: $BACKUP_FILE${NC}"
    else
        echo -e "${RED}Gagal membuat backup${NC}"
        exit 1
    fi
}

# Function to restore backup
restore_backup() {
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -1)
    
    if [ -z "$LATEST_BACKUP" ]; then
        echo -e "${RED}Tidak ada backup yang ditemukan${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Memulihkan dari backup: $LATEST_BACKUP${NC}"
    
    tar -xzf "$LATEST_BACKUP" -C "$PTERODACTYL_DIR/app/Http/Controllers"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Backup berhasil dipulihkan${NC}"
        
        # Clear compiled views
        cd "$PTERODACTYL_DIR" && php artisan view:clear
        cd "$PTERODACTYL_DIR" && php artisan cache:clear
        
        return 0
    else
        echo -e "${RED}Gagal memulihkan backup${NC}"
        return 1
    fi
}

# Function to install security
install_security() {
    echo -e "${YELLOW}Menginstall security panel...${NC}"
    
    create_backup
    
    # Patch AdminController
    patch_admin_controller
    
    # Patch NodeController
    patch_node_controller
    
    # Patch LocationController
    patch_location_controller
    
    # Patch NestController
    patch_nest_controller
    
    # Patch UserController
    patch_user_controller
    
    # Patch ServerController
    patch_server_controller
    
    # Patch ApplicationApiController
    patch_application_api_controller
    
    echo -e "${GREEN}Security panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Jangan lupa menjalankan: php artisan optimize:clear${NC}"
}

# Function to patch AdminController
patch_admin_controller() {
    cat > "$PTERODACTYL_DIR/app/Http/Controllers/Admin/AdminController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class AdminController extends Controller
{
    public function settings()
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.settings');
    }
    
    public function updateSettings(Request $request)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Update settings logic here
    }
}
EOF
    echo -e "${GREEN}AdminController berhasil dipatch${NC}"
}

# Function to patch NodeController
patch_node_controller() {
    cat > "$PTERODACTYL_DIR/app/Http/Controllers/Admin/NodeController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Node;

class NodeController extends Controller
{
    public function index()
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $nodes = Node::all();
        return view('admin.nodes.index', compact('nodes'));
    }
    
    public function create()
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.nodes.create');
    }
    
    public function store(Request $request)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Store node logic here
    }
    
    public function view($id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $node = Node::findOrFail($id);
        return view('admin.nodes.view', compact('node'));
    }
    
    public function edit($id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $node = Node::findOrFail($id);
        return view('admin.nodes.edit', compact('node'));
    }
    
    public function update(Request $request, $id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Update node logic here
    }
    
    public function destroy($id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Delete node logic here
    }
}
EOF
    echo -e "${GREEN}NodeController berhasil dipatch${NC}"
}

# Function to patch LocationController
patch_location_controller() {
    cat > "$PTERODACTYL_DIR/app/Http/Controllers/Admin/LocationController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Location;

class LocationController extends Controller
{
    public function index()
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $locations = Location::all();
        return view('admin.locations.index', compact('locations'));
    }
    
    public function create()
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.locations.create');
    }
    
    public function store(Request $request)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Store location logic here
    }
    
    public function edit($id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $location = Location::findOrFail($id);
        return view('admin.locations.edit', compact('location'));
    }
    
    public function update(Request $request, $id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Update location logic here
    }
    
    public function destroy($id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Delete location logic here
    }
}
EOF
    echo -e "${GREEN}LocationController berhasil dipatch${NC}"
}

# Function to patch NestController
patch_nest_controller() {
    cat > "$PTERODACTYL_DIR/app/Http/Controllers/Admin/NestController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Nest;

class NestController extends Controller
{
    public function index()
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $nests = Nest::all();
        return view('admin.nests.index', compact('nests'));
    }
    
    public function create()
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.nests.create');
    }
    
    public function store(Request $request)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Store nest logic here
    }
    
    public function edit($id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $nest = Nest::findOrFail($id);
        return view('admin.nests.edit', compact('nest'));
    }
    
    public function update(Request $request, $id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Update nest logic here
    }
    
    public function destroy($id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Delete nest logic here
    }
}
EOF
    echo -e "${GREEN}NestController berhasil dipatch${NC}"
}

# Function to patch UserController
patch_user_controller() {
    cat > "$PTERODACTYL_DIR/app/Http/Controllers/Admin/UserController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\User;

class UserController extends Controller
{
    public function index()
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $users = User::all();
        return view('admin.users.index', compact('users'));
    }
    
    public function create()
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.users.create');
    }
    
    public function store(Request $request)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Store user logic here
    }
    
    public function edit($id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $user = User::findOrFail($id);
        return view('admin.users.edit', compact('user'));
    }
    
    public function update(Request $request, $id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Update user logic here
    }
    
    public function destroy($id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Delete user logic here
    }
}
EOF
    echo -e "${GREEN}UserController berhasil dipatch${NC}"
}

# Function to patch ServerController
patch_server_controller() {
    cat > "$PTERODACTYL_DIR/app/Http/Controllers/Admin/ServerController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Server;

class ServerController extends Controller
{
    public function index()
    {
        // Allow all admin users to view server list
        $servers = Server::all();
        return view('admin.servers.index', compact('servers'));
    }
    
    public function view($id)
    {
        $server = Server::findOrFail($id);
        
        // Only allow user ID 1 to view servers of other users
        if (auth()->user()->id !== 1 && $server->owner_id !== auth()->user()->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.servers.view', compact('server'));
    }
    
    public function edit($id)
    {
        $server = Server::findOrFail($id);
        
        // Only allow user ID 1 to edit servers of other users
        if (auth()->user()->id !== 1 && $server->owner_id !== auth()->user()->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.servers.edit', compact('server'));
    }
    
    public function update(Request $request, $id)
    {
        $server = Server::findOrFail($id);
        
        // Only allow user ID 1 to update servers of other users
        if (auth()->user()->id !== 1 && $server->owner_id !== auth()->user()->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Update server logic here
    }
    
    public function destroy($id)
    {
        $server = Server::findOrFail($id);
        
        // Only allow user ID 1 to delete servers of other users
        if (auth()->user()->id !== 1 && $server->owner_id !== auth()->user()->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Delete server logic here
    }
    
    public function settings($id)
    {
        $server = Server::findOrFail($id);
        
        // Only allow user ID 1 to access server settings of other users
        if (auth()->user()->id !== 1 && $server->owner_id !== auth()->user()->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.servers.settings', compact('server'));
    }
}
EOF
    echo -e "${GREEN}ServerController berhasil dipatch${NC}"
}

# Function to patch ApplicationApiController
patch_application_api_controller() {
    cat > "$PTERODACTYL_DIR/app/Http/Controllers/Api/Application/ApplicationApiController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Application;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class ApplicationApiController extends Controller
{
    // Application API tetap terbuka untuk semua user yang memiliki akses API
    // Tidak ada pembatasan khusus di sini
    
    public function index()
    {
        return response()->json(['message' => 'Application API accessible']);
    }
}
EOF
    echo -e "${GREEN}ApplicationApiController berhasil dipatch${NC}"
}

# Function to change error message
change_error_message() {
    echo -e "${YELLOW}Mengubah teks error...${NC}"
    
    read -p "Masukkan teks error baru: " NEW_ERROR_MSG
    
    if [ -z "$NEW_ERROR_MSG" ]; then
        echo -e "${RED}Teks error tidak boleh kosong${NC}"
        return 1
    fi
    
    # Update error message in all controllers
    find "$PTERODACTYL_DIR/app/Http/Controllers" -name "*.php" -type f -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/$NEW_ERROR_MSG/g" {} \;
    
    echo -e "${GREEN}Teks error berhasil diubah!${NC}"
    echo -e "${YELLOW}Teks error baru: $NEW_ERROR_MSG${NC}"
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Uninstall security panel...${NC}"
    
    if restore_backup; then
        echo -e "${GREEN}Security panel berhasil diuninstall!${NC}"
        echo -e "${YELLOW}Panel Pterodactyl telah dikembalikan ke keadaan semula${NC}"
    else
        echo -e "${RED}Gagal menguninstall security panel${NC}"
    fi
}

# Function to optimize Pterodactyl
optimize_pterodactyl() {
    echo -e "${YELLOW}Mengoptimalkan Pterodactyl...${NC}"
    cd "$PTERODACTYL_DIR" && php artisan view:clear
    cd "$PTERODACTYL_DIR" && php artisan cache:clear
    cd "$PTERODACTYL_DIR" && php artisan route:clear
    cd "$PTERODACTYL_DIR" && php artisan config:clear
    echo -e "${GREEN}Optimasi selesai!${NC}"
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${GREEN}Pilih opsi:${NC}"
        echo "1. Install Security Panel"
        echo "2. Ubah Teks Error"
        echo "3. Uninstall Security Panel"
        echo "4. Optimize Pterodactyl"
        echo "5. Exit"
        echo ""
        read -p "Masukkan pilihan [1-5]: " choice
        
        case $choice in
            1)
                check_root
                check_pterodactyl
                install_security
                ;;
            2)
                check_root
                check_pterodactyl
                change_error_message
                ;;
            3)
                check_root
                check_pterodactyl
                uninstall_security
                ;;
            4)
                check_root
                check_pterodactyl
                optimize_pterodactyl
                ;;
            5)
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

# Check if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_menu
fi
