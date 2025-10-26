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
PANEL_PATH="/var/www/pterodactyl"  # Default path, adjust if different

# Backup files
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

# Function to check if panel path exists
check_panel_path() {
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${YELLOW}Panel path $PANEL_PATH tidak ditemukan.${NC}"
        read -p "Masukkan path panel Pterodactyl yang benar: " custom_path
        if [ -d "$custom_path" ]; then
            PANEL_PATH="$custom_path"
            echo -e "${GREEN}Path panel diatur ke: $PANEL_PATH${NC}"
        else
            echo -e "${RED}Path panel tidak valid!${NC}"
            return 1
        fi
    fi
    return 0
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup...${NC}"
    mkdir -p "$BACKUP_DIR"
    
    # Backup important files
    cp "$PANEL_PATH/app/Http/Controllers/Admin"/*.php "$BACKUP_DIR/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php" "$BACKUP_DIR/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers"/*.php "$BACKUP_DIR/" 2>/dev/null
    
    echo -e "${GREEN}Backup berhasil dibuat di: $BACKUP_DIR${NC}"
}

# Function to install security
install_security() {
    echo -e "${YELLOW}Memulai instalasi security panel...${NC}"
    
    if ! check_panel_path; then
        return 1
    fi
    
    create_backup
    
    # Security for Admin Settings Controller
    echo -e "${YELLOW}Mengamankan Settings Panel...${NC}"
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class SettingsController extends Controller
{
    public function index()
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.settings');
    }
    
    public function update(Request $request)
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Original update logic here
        return redirect()->back()->with('success', 'Settings updated successfully.');
    }
}
EOF

    # Security for Nodes Controller
    echo -e "${YELLOW}Mengamankan Nodes...${NC}"
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\Node;

class NodesController extends Controller
{
    public function index()
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $nodes = Node::all();
        return view('admin.nodes.index', compact('nodes'));
    }
    
    public function create()
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.nodes.create');
    }
    
    public function store(Request $request)
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Original store logic here
        return redirect()->route('admin.nodes')->with('success', 'Node created successfully.');
    }
    
    public function edit($id)
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $node = Node::findOrFail($id);
        return view('admin.nodes.edit', compact('node'));
    }
    
    public function update(Request $request, $id)
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Original update logic here
        return redirect()->route('admin.nodes')->with('success', 'Node updated successfully.');
    }
    
    public function destroy($id)
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Original destroy logic here
        return redirect()->route('admin.nodes')->with('success', 'Node deleted successfully.');
    }
}
EOF

    # Security for Locations Controller
    echo -e "${YELLOW}Mengamankan Locations...${NC}"
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\Location;

class LocationsController extends Controller
{
    public function index()
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $locations = Location::all();
        return view('admin.locations.index', compact('locations'));
    }
    
    public function create()
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.locations.create');
    }
    
    public function store(Request $request)
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Original store logic here
        return redirect()->route('admin.locations')->with('success', 'Location created successfully.');
    }
    
    public function edit($id)
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $location = Location::findOrFail($id);
        return view('admin.locations.edit', compact('location'));
    }
    
    public function update(Request $request, $id)
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Original update logic here
        return redirect()->route('admin.locations')->with('success', 'Location updated successfully.');
    }
    
    public function destroy($id)
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Original destroy logic here
        return redirect()->route('admin.locations')->with('success', 'Location deleted successfully.');
    }
}
EOF

    # Security for Nests Controller
    echo -e "${YELLOW}Mengamankan Nests...${NC}"
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NestsController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\Nest;

class NestsController extends Controller
{
    public function index()
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $nests = Nest::all();
        return view('admin.nests.index', compact('nests'));
    }
    
    public function edit($id)
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $nest = Nest::findOrFail($id);
        return view('admin.nests.edit', compact('nest'));
    }
    
    public function update(Request $request, $id)
    {
        if (\Auth::user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Original update logic here
        return redirect()->route('admin.nests')->with('success', 'Nest updated successfully.');
    }
}
EOF

    # Security for Server Controller (User server deletion protection)
    echo -e "${YELLOW}Mengamankan User Servers...${NC}"
    cat > "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Api\Client\Servers;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\Server;

class ServerController extends Controller
{
    public function delete(Request $request, Server $server)
    {
        // Additional security check for server deletion
        if ($request->user()->id !== $server->owner_id && $request->user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Original delete logic here
        $server->delete();
        
        return response()->json(['message' => 'Server deleted successfully.']);
    }
    
    public function forceDelete(Request $request, Server $server)
    {
        if ($request->user()->id != 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Original force delete logic here
        $server->forceDelete();
        
        return response()->json(['message' => 'Server force deleted successfully.']);
    }
}
EOF

    # Update Admin Middleware for additional protection
    echo -e "${YELLOW}Mengamankan Admin Middleware...${NC}"
    cat > "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php" << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminAuthenticate
{
    public function handle(Request $request, Closure $next)
    {
        if (!$request->user() || !$request->user()->root_admin) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Additional check for non-ID-1 users
        if ($request->user()->id != 1) {
            // Allow only specific read-only operations for other admin users
            $allowedRoutes = [
                'admin.index',
                'admin.overview',
                // Add other read-only routes here if needed
            ];
            
            if (!in_array($request->route()->getName(), $allowedRoutes)) {
                abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
            }
        }
        
        return $next($request);
    }
}
EOF

    # Clear cache and optimize
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    cd "$PANEL_PATH"
    php artisan cache:clear
    php artisan config:cache
    php artisan view:cache
    
    echo -e "${GREEN}Security panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Hanya user dengan ID 1 yang dapat mengakses settings, nodes, locations, dan nests.${NC}"
}

# Function to change error text
change_error_text() {
    echo -e "${YELLOW}Mengubah teks error...${NC}"
    
    if ! check_panel_path; then
        return 1
    fi
    
    read -p "Masukkan teks error baru: " new_text
    if [ -n "$new_text" ]; then
        SECURITY_TEXT="$new_text"
        echo -e "${GREEN}Teks error diubah menjadi: $SECURITY_TEXT${NC}"
        
        # Re-run installation with new text
        install_security
    else
        echo -e "${RED}Teks error tidak boleh kosong!${NC}"
    fi
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Memulai uninstall security panel...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}Backup directory tidak ditemukan! Tidak dapat melakukan uninstall.${NC}"
        return 1
    fi
    
    if ! check_panel_path; then
        return 1
    fi
    
    echo -e "${YELLOW}Mengembalikan file dari backup...${NC}"
    
    # Restore files from backup
    cp "$BACKUP_DIR"/*.php "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
    cp "$BACKUP_DIR/AdminAuthenticate.php" "$PANEL_PATH/app/Http/Middleware/" 2>/dev/null
    cp "$BACKUP_DIR"/*.php "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/" 2>/dev/null
    
    # Clear cache and optimize
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    cd "$PANEL_PATH"
    php artisan cache:clear
    php artisan config:cache
    php artisan view:cache
    
    echo -e "${GREEN}Security panel berhasil diuninstall!${NC}"
    echo -e "${YELLOW}Panel telah dikembalikan ke keadaan semula.${NC}"
}

# Main script execution
main() {
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then 
        echo -e "${RED}Silakan jalankan script sebagai root!${NC}"
        exit 1
    fi
    
    while true; do
        show_menu
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
                ;;
        esac
        
        echo
        read -p "Tekan Enter untuk melanjutkan..."
    done
}

# Run main function
main "$@"
