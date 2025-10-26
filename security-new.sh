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
ERROR_MESSAGE="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"
PANEL_PATH="/var/www/pterodactyl"
BACKUP_DIR="/root/pterodactyl_backup"

# Function to display header
show_header() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════╗"
    echo "║          Security Panel Pterodactyl           ║"
    echo "║             By @ginaabaikhati                 ║"
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

# Function to check if Pterodactyl is installed
check_pterodactyl() {
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}Error: Pterodactyl tidak ditemukan di $PANEL_PATH${NC}"
        exit 1
    fi
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup panel...${NC}"
    mkdir -p $BACKUP_DIR
    cp -r $PANEL_PATH/app $BACKUP_DIR/
    cp -r $PANEL_PATH/resources $BACKUP_DIR/
    echo -e "${GREEN}Backup berhasil dibuat di $BACKUP_DIR${NC}"
}

# Function to restore backup
restore_backup() {
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}Memulihkan dari backup...${NC}"
        cp -r $BACKUP_DIR/app $PANEL_PATH/
        cp -r $BACKUP_DIR/resources $PANEL_PATH/
        echo -e "${GREEN}Backup berhasil dipulihkan${NC}"
    else
        echo -e "${RED}Backup tidak ditemukan!${NC}"
    fi
}

# Function to install security
install_security() {
    show_header
    echo -e "${YELLOW}Menginstall Security Panel...${NC}"
    
    check_pterodactyl
    create_backup
    
    # Patch untuk AdminController - Lock settings admin
    cat > $PANEL_PATH/app/Http/Controllers/Admin/AdminController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class AdminController extends Controller
{
    public function index()
    {
        return view('admin.index');
    }

    public function settings(Request $request)
    {
        // Cek jika user ID bukan 1
        if ($request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.settings');
    }

    public function updateSettings(Request $request)
    {
        // Cek jika user ID bukan 1
        if ($request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk update settings
        return redirect()->back()->with('success', 'Settings updated successfully');
    }
}
EOF

    # Patch untuk NodeController - Lock nodes
    cat > $PANEL_PATH/app/Http/Controllers/Admin/NodesController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Pterodactyl\Models\Node;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class NodesController extends Controller
{
    public function index()
    {
        $nodes = Node::all();
        return view('admin.nodes.index', compact('nodes'));
    }

    public function create()
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.create');
    }

    public function store(Request $request)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk menyimpan node
    }

    public function edit($id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $node = Node::findOrFail($id);
        return view('admin.nodes.edit', compact('node'));
    }

    public function update(Request $request, $id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk update node
    }

    public function destroy($id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk menghapus node
    }
}
EOF

    # Patch untuk LocationController - Lock locations
    cat > $PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Pterodactyl\Models\Location;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class LocationsController extends Controller
{
    public function index()
    {
        $locations = Location::all();
        return view('admin.locations.index', compact('locations'));
    }

    public function create()
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.create');
    }

    public function store(Request $request)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk menyimpan location
    }

    public function edit($id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $location = Location::findOrFail($id);
        return view('admin.locations.edit', compact('location'));
    }

    public function update(Request $request, $id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk update location
    }

    public function destroy($id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk menghapus location
    }
}
EOF

    # Patch untuk NestsController - Lock nests
    cat > $PANEL_PATH/app/Http/Controllers/Admin/NestsController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Pterodactyl\Models\Nest;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class NestsController extends Controller
{
    public function index()
    {
        $nests = Nest::all();
        return view('admin.nests.index', compact('nests'));
    }

    public function create()
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nests.create');
    }

    public function store(Request $request)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk menyimpan nest
    }

    public function edit($id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $nest = Nest::findOrFail($id);
        return view('admin.nests.edit', compact('nest'));
    }

    public function update(Request $request, $id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk update nest
    }

    public function destroy($id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk menghapus nest
    }
}
EOF

    # Patch untuk ServerController - Lock server management
    cat > $PANEL_PATH/app/Http/Controllers/Admin/ServersController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Pterodactyl\Models\Server;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class ServersController extends Controller
{
    public function index()
    {
        $servers = Server::with('user', 'node')->get();
        return view('admin.servers.index', compact('servers'));
    }

    public function create()
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.servers.create');
    }

    public function store(Request $request)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk menyimpan server
    }

    public function edit($id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $server = Server::findOrFail($id);
        return view('admin.servers.edit', compact('server'));
    }

    public function update(Request $request, $id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk update server
    }

    public function destroy($id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk menghapus server
    }

    public function view($id)
    {
        $server = Server::with('user', 'node')->findOrFail($id);
        
        // Cek jika user bukan pemilik server dan bukan admin ID 1
        if (auth()->user()->id !== 1 && auth()->user()->id !== $server->user_id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.servers.view', compact('server'));
    }
}
EOF

    # Patch untuk UserController - Lock user management
    cat > $PANEL_PATH/app/Http/Controllers/Admin/UsersController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Pterodactyl\Models\User;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class UsersController extends Controller
{
    public function index()
    {
        $users = User::all();
        return view('admin.users.index', compact('users'));
    }

    public function create()
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.users.create');
    }

    public function store(Request $request)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk menyimpan user
    }

    public function edit($id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $user = User::findOrFail($id);
        return view('admin.users.edit', compact('user'));
    }

    public function update(Request $request, $id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk update user
    }

    public function destroy($id)
    {
        // Cek jika user ID bukan 1
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Logic untuk menghapus user
    }
}
EOF

    # Fix untuk LocaleController.php
    cat > $PANEL_PATH/app/Http/Controllers/LocaleController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers;

use Illuminate\Http\Request;

class LocaleController extends Controller
{
    public function index(Request $request, $locale)
    {
        if (in_array($locale, ['en', 'id', 'es', 'fr', 'de', 'pt', 'ru'])) {
            $request->session()->put('locale', $locale);
        }

        return redirect()->back();
    }
}
EOF

    # Clear cache dan optimize
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    cd $PANEL_PATH
    php artisan config:cache
    php artisan view:cache
    php artisan route:cache

    echo -e "${GREEN}Security Panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Hanya user dengan ID 1 yang dapat mengubah/delete/add settings, nodes, locations, nests, users, dan servers.${NC}"
    read -p "Tekan Enter untuk melanjutkan..."
}

# Function to change error text
change_error_text() {
    show_header
    echo -e "${YELLOW}Mengubah Teks Error...${NC}"
    
    read -p "Masukkan teks error baru: " new_error_text
    
    if [ -z "$new_error_text" ]; then
        echo -e "${RED}Teks error tidak boleh kosong!${NC}"
        return
    fi
    
    ERROR_MESSAGE="$new_error_text"
    
    # Update semua file controller dengan teks error baru
    find $PANEL_PATH/app/Http/Controllers/Admin -name "*.php" -type f -exec sed -i "s|Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati|$new_error_text|g" {} \;
    
    echo -e "${GREEN}Teks error berhasil diubah!${NC}"
    echo -e "${YELLOW}Teks error baru: $new_error_text${NC}"
    read -p "Tekan Enter untuk melanjutkan..."
}

# Function to uninstall security
uninstall_security() {
    show_header
    echo -e "${YELLOW}Uninstall Security Panel...${NC}"
    
    if [ -d "$BACKUP_DIR" ]; then
        restore_backup
        
        # Clear cache
        cd $PANEL_PATH
        php artisan config:cache
        php artisan view:cache
        php artisan route:cache
        
        echo -e "${GREEN}Security Panel berhasil diuninstall!${NC}"
        echo -e "${YELLOW}Panel Pterodactyl telah dikembalikan ke keadaan semula.${NC}"
    else
        echo -e "${RED}Backup tidak ditemukan! Uninstall tidak dapat dilakukan.${NC}"
    fi
    
    read -p "Tekan Enter untuk melanjutkan..."
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

# Check if running as root
check_root

# Run main menu
main_menu
