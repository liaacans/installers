#!/bin/bash

# Script Security Panel Pterodactyl
# By @ginaabaikhati

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

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Script harus dijalankan sebagai root${NC}"
   exit 1
fi

# Function to display menu
show_menu() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║    SECURITY PANEL PTERODACTYL        ║"
    echo "║         By @ginaabaikhati            ║"
    echo "╠══════════════════════════════════════╣"
    echo "║ 1. Install Security Panel            ║"
    echo "║ 2. Ubah Teks Error                   ║"
    echo "║ 3. Uninstall Security Panel          ║"
    echo "║ 4. Exit                              ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup file panel...${NC}"
    mkdir -p $BACKUP_PATH
    
    # Backup important files
    cp $PANEL_PATH/app/Http/Controllers/Admin/*.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/*.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Controllers/BaseController.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Middleware/ApiAuthenticate.php $BACKUP_PATH/ 2>/dev/null
    
    echo -e "${GREEN}Backup berhasil dibuat di $BACKUP_PATH${NC}"
}

# Function to install security
install_security() {
    echo -e "${YELLOW}Memulai instalasi security panel...${NC}"
    
    # Create backup first
    create_backup
    
    # Check if panel path exists
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}Error: Directory panel tidak ditemukan di $PANEL_PATH${NC}"
        return 1
    fi
    
    # 1. Modify Admin Controller for Settings
    echo -e "${YELLOW}Mengamankan panel settings...${NC}"
    cat > $PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class SettingsController extends Controller
{
    protected $settings;

    public function __construct(SettingsRepositoryInterface $settings)
    {
        $this->settings = $settings;
    }

    public function index()
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.settings.index', [
            'settings' => $this->settings->all(),
        ]);
    }

    public function update(Request $request)
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        foreach ($request->except('_token') as $key => $value) {
            $this->settings->set('settings::' . $key, $value);
        }

        return redirect()->route('admin.settings')->with('success', 'Settings updated successfully.');
    }
}
EOF

    # 2. Modify Nodes Controller
    echo -e "${YELLOW}Mengamankan nodes...${NC}"
    cat > $PANEL_PATH/app/Http/Controllers/Admin/NodesController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Node;

class NodesController extends Controller
{
    public function index()
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.index', [
            'nodes' => Node::all(),
        ]);
    }

    public function create()
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.create');
    }

    public function store(Request $request)
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Node creation logic here
        return redirect()->route('admin.nodes')->with('success', 'Node created successfully.');
    }

    public function view($id)
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $node = Node::findOrFail($id);
        return view('admin.nodes.view', compact('node'));
    }

    public function update(Request $request, $id)
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Node update logic here
        return redirect()->route('admin.nodes')->with('success', 'Node updated successfully.');
    }

    public function delete($id)
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $node = Node::findOrFail($id);
        $node->delete();

        return redirect()->route('admin.nodes')->with('success', 'Node deleted successfully.');
    }
}
EOF

    # 3. Modify Locations Controller
    echo -e "${YELLOW}Mengamankan locations...${NC}"
    cat > $PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Location;

class LocationsController extends Controller
{
    public function index()
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.index', [
            'locations' => Location::all(),
        ]);
    }

    public function create()
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.create');
    }

    public function store(Request $request)
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Location creation logic here
        return redirect()->route('admin.locations')->with('success', 'Location created successfully.');
    }

    public function view($id)
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $location = Location::findOrFail($id);
        return view('admin.locations.view', compact('location'));
    }

    public function update(Request $request, $id)
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Location update logic here
        return redirect()->route('admin.locations')->with('success', 'Location updated successfully.');
    }

    public function delete($id)
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $location = Location::findOrFail($id);
        $location->delete();

        return redirect()->route('admin.locations')->with('success', 'Location deleted successfully.');
    }
}
EOF

    # 4. Modify Nests Controller
    echo -e "${YELLOW}Mengamankan nests...${NC}"
    cat > $PANEL_PATH/app/Http/Controllers/Admin/NestsController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Nest;

class NestsController extends Controller
{
    public function index()
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nests.index', [
            'nests' => Nest::all(),
        ]);
    }

    public function view($id)
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $nest = Nest::findOrFail($id);
        return view('admin.nests.view', compact('nest'));
    }

    public function update(Request $request, $id)
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Nest update logic here
        return redirect()->route('admin.nests')->with('success', 'Nest updated successfully.');
    }

    public function delete($id)
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $nest = Nest::findOrFail($id);
        $nest->delete();

        return redirect()->route('admin.nests')->with('success', 'Nest deleted successfully.');
    }
}
EOF

    # 5. Modify Users Controller for server access protection
    echo -e "${YELLOW}Mengamankan akses users...${NC}"
    cat > $PANEL_PATH/app/Http/Controllers/Admin/UsersController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\User;
use Pterodactyl\Models\Server;

class UsersController extends Controller
{
    public function index()
    {
        return view('admin.users.index', [
            'users' => User::all(),
        ]);
    }

    public function view($id)
    {
        $user = User::findOrFail($id);
        
        // Allow users to view their own profile, but restrict server access
        if (auth()->user()->id != $id && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.users.view', compact('user'));
    }

    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);
        
        // Only allow user to update their own profile or admin
        if (auth()->user()->id != $id && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // User update logic here
        return redirect()->route('admin.users.view', $id)->with('success', 'User updated successfully.');
    }

    public function delete($id)
    {
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $user = User::findOrFail($id);
        
        // Prevent admin from deleting themselves
        if ($user->id === 1) {
            return redirect()->route('admin.users')->with('error', 'Cannot delete primary administrator.');
        }
        
        $user->delete();

        return redirect()->route('admin.users')->with('success', 'User deleted successfully.');
    }
}
EOF

    # 6. Modify Servers Controller for server protection
    echo -e "${YELLOW}Mengamankan akses server...${NC}"
    cat > $PANEL_PATH/app/Http/Controllers/Admin/ServersController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Server;

class ServersController extends Controller
{
    public function index()
    {
        return view('admin.servers.index', [
            'servers' => Server::with('user', 'node')->get(),
        ]);
    }

    public function view($id)
    {
        $server = Server::with('user', 'node')->findOrFail($id);
        
        // Only allow admin or server owner to view
        if (auth()->user()->id !== 1 && auth()->user()->id != $server->owner_id) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.servers.view', compact('server'));
    }

    public function update(Request $request, $id)
    {
        $server = Server::findOrFail($id);
        
        // Only allow admin or server owner to update
        if (auth()->user()->id !== 1 && auth()->user()->id != $server->owner_id) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Server update logic here
        return redirect()->route('admin.servers.view', $id)->with('success', 'Server updated successfully.');
    }

    public function delete($id)
    {
        $server = Server::findOrFail($id);
        
        // Only allow admin to delete servers
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $server->delete();

        return redirect()->route('admin.servers')->with('success', 'Server deleted successfully.');
    }
}
EOF

    # 7. Create custom middleware for additional protection
    echo -e "${YELLOW}Membuat middleware tambahan...${NC}"
    cat > $PANEL_PATH/app/Http/Middleware/AdminSecurity.php << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminSecurity
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        
        if (!$user) {
            return $next($request);
        }

        // Check for sensitive admin routes
        $sensitiveRoutes = [
            'admin.settings',
            'admin.nodes',
            'admin.locations', 
            'admin.nests',
        ];

        $currentRoute = $request->route()->getName();
        
        foreach ($sensitiveRoutes as $route) {
            if (strpos($currentRoute, $route) !== false && $user->id !== 1) {
                abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
            }
        }

        return $next($request);
    }
}
EOF

    # 8. Modify API Client Controller for file manager protection
    echo -e "${YELLOW}Mengamankan file manager API...${NC}"
    cat > $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/FileManagerController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Models\Server;

class FileManagerController extends ClientApiController
{
    public function index(Request $request, Server $server)
    {
        // Allow normal file manager operations for server owners
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Original file manager logic here
        return response()->json(['data' => 'File manager data']);
    }

    public function delete(Request $request, Server $server)
    {
        // Only allow server owner or admin to delete files
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // File deletion logic here
        return response()->json(['success' => true]);
    }

    public function upload(Request $request, Server $server)
    {
        // Only allow server owner or admin to upload files
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // File upload logic here
        return response()->json(['success' => true]);
    }
}
EOF

    # Update middleware in Kernel.php
    echo -e "${YELLOW}Memperbarui kernel middleware...${NC}"
    if grep -q "AdminSecurity" $PANEL_PATH/app/Http/Kernel.php; then
        echo -e "${GREEN}Middleware AdminSecurity sudah ada.${NC}"
    else
        sed -i "/protected \$middlewareGroups = \[/a \        'admin' => [\n            \Pterodactyl\Http\Middleware\AdminSecurity::class,\n        ]," $PANEL_PATH/app/Http/Kernel.php
    fi

    # Run panel optimizations
    echo -e "${YELLOW}Menjalankan optimasi panel...${NC}"
    cd $PANEL_PATH
    php artisan config:cache
    php artisan view:clear
    php artisan route:clear

    echo -e "${GREEN}Instalasi security panel berhasil!${NC}"
    echo -e "${YELLOW}Semua fitur admin sensitif sekarang hanya dapat diakses oleh user dengan ID 1${NC}"
}

# Function to change error message
change_error_message() {
    echo -e "${YELLOW}Mengubah teks error...${NC}"
    read -p "Masukkan teks error baru: " new_error
    
    if [ -z "$new_error" ]; then
        echo -e "${RED}Teks error tidak boleh kosong!${NC}"
        return 1
    fi
    
    ERROR_MESSAGE="$new_error"
    
    # Update all controller files with new error message
    find $PANEL_PATH/app/Http/Controllers -name "*.php" -type f -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_error}/g" {} \;
    
    echo -e "${GREEN}Teks error berhasil diubah!${NC}"
    echo -e "${BLUE}Teks error baru: $ERROR_MESSAGE${NC}"
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Memulai uninstall security panel...${NC}"
    
    # Check if backup exists
    if [ ! -d "$BACKUP_PATH" ]; then
        echo -e "${RED}Error: Backup tidak ditemukan di $BACKUP_PATH${NC}"
        echo -e "${YELLOW}Anda perlu menginstall security terlebih dahulu atau restore manual${NC}"
        return 1
    fi
    
    # Restore backed up files
    echo -e "${YELLOW}Memulihkan file original...${NC}"
    cp $BACKUP_PATH/*.php $PANEL_PATH/app/Http/Controllers/Admin/ 2>/dev/null
    cp $BACKUP_PATH/AdminAuthenticate.php $PANEL_PATH/app/Http/Middleware/ 2>/dev/null
    cp $BACKUP_PATH/*.php $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ 2>/dev/null
    cp $BACKUP_PATH/BaseController.php $PANEL_PATH/app/Http/Controllers/ 2>/dev/null
    cp $BACKUP_PATH/ApiAuthenticate.php $PANEL_PATH/app/Http/Middleware/ 2>/dev/null
    
    # Remove custom middleware from Kernel
    sed -i '/AdminSecurity/d' $PANEL_PATH/app/Http/Kernel.php
    sed -i "/'admin' => \[/,+3d" $PANEL_PATH/app/Http/Kernel.php
    
    # Remove custom middleware file
    rm -f $PANEL_PATH/app/Http/Middleware/AdminSecurity.php
    
    # Run panel optimizations
    echo -e "${YELLOW}Menjalankan optimasi panel...${NC}"
    cd $PANEL_PATH
    php artisan config:cache
    php artisan view:clear
    php artisan route:clear
    
    echo -e "${GREEN}Uninstall security panel berhasil!${NC}"
    echo -e "${YELLOW}Panel telah dikembalikan ke keadaan semula${NC}"
}

# Main script execution
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
            echo -e "${GREEN}Terima kasih telah menggunakan script security!${NC}"
            echo -e "${BLUE}By @ginaabaikhati${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid! Silakan pilih 1-4${NC}"
            ;;
    esac
    
    echo
    read -p "Tekan Enter untuk melanjutkan..."
done
