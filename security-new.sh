#!/bin/bash

# security.sh - Security Panel Pterodactyl
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

# Function to display header
display_header() {
    clear
    echo -e "${BLUE}"
    echo "================================================"
    echo "    Pterodactyl Security Panel Installer"
    echo "    By @ginaabaikhati"
    echo "================================================"
    echo -e "${NC}"
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup file...${NC}"
    mkdir -p $BACKUP_PATH
    
    # Backup important files
    cp $PANEL_PATH/app/Http/Controllers/Admin/*.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/*.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Middleware/*.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/routes/api.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/routes/admin.php $BACKUP_PATH/ 2>/dev/null
    
    echo -e "${GREEN}Backup berhasil dibuat di: $BACKUP_PATH${NC}"
}

# Function to restore backup
restore_backup() {
    echo -e "${YELLOW}Memulihkan dari backup...${NC}"
    
    if [ ! -d "$BACKUP_PATH" ]; then
        echo -e "${RED}Backup tidak ditemukan!${NC}"
        return 1
    fi
    
    # Restore files
    cp $BACKUP_PATH/*.php $PANEL_PATH/app/Http/Controllers/Admin/ 2>/dev/null
    cp $BACKUP_PATH/*.php $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ 2>/dev/null
    cp $BACKUP_PATH/*.php $PANEL_PATH/app/Http/Middleware/ 2>/dev/null
    cp $BACKUP_PATH/api.php $PANEL_PATH/routes/ 2>/dev/null
    cp $BACKUP_PATH/admin.php $PANEL_PATH/routes/ 2>/dev/null
    
    # Clear cache
    cd $PANEL_PATH && php artisan cache:clear && php artisan view:clear
    
    echo -e "${GREEN}Restore berhasil!${NC}"
}

# Function to check panel path
check_panel_path() {
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}Directory Pterodactyl tidak ditemukan di: $PANEL_PATH${NC}"
        echo -e "${YELLOW}Silakan edit PANEL_PATH dalam script sesuai instalasi Anda${NC}"
        exit 1
    fi
}

# Function to install security
install_security() {
    display_header
    echo -e "${YELLOW}Memulai instalasi security panel...${NC}"
    
    check_panel_path
    create_backup
    
    # Create custom middleware for nodes, locations, nests
    cat > $PANEL_PATH/app/Http/Middleware/StrictAdminSecurity.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class StrictAdminSecurity
{
    public function handle(Request $request, Closure $next)
    {
        // Check if user is authenticated and has admin role
        if (!$request->user() || !$request->user()->root_admin) {
            if ($request->expectsJson()) {
                return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 500);
            }
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Check if user ID is 1 for strict areas
        if ($request->user()->id !== 1) {
            if ($request->expectsJson()) {
                return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 500);
            }
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return $next($request);
    }
}
EOF

    # Modify Admin Controller - Settings bebas untuk semua admin
    cat > $PANEL_PATH/app/Http/Controllers/Admin/AdminController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\Users\UserCreationService;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Prologue\Alerts\AlertsMessageBag;

class AdminController extends Controller
{
    public function __construct(
        private AlertsMessageBag $alert,
        private UserCreationService $creationService
    ) {}

    public function index(): View
    {
        // All admin can access admin index
        return view('admin.index', [
            'users' => User::all(),
        ]);
    }

    public function settings(): View
    {
        // All admin can access settings - TIDAK DIKUNCI
        return view('admin.settings');
    }

    public function nodes(): View
    {
        // Only user ID 1 can access nodes
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.index');
    }

    public function locations(): View
    {
        // Only user ID 1 can access locations
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.index');
    }

    public function nests(): View
    {
        // Only user ID 1 can access nests
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nests.index');
    }

    public function destroyUser(Request $request, User $user): RedirectResponse
    {
        // Only user ID 1 can delete users
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Prevent deletion of user ID 1
        if ($user->id === 1) {
            $this->alert->danger('Cannot delete the primary administrator.')->flash();
            return redirect()->route('admin.users');
        }

        $user->delete();

        $this->alert->success('User was deleted successfully.')->flash();
        return redirect()->route('admin.users');
    }

    public function updateUser(Request $request, User $user): RedirectResponse
    {
        // Only user ID 1 can update users
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Prevent modification of user ID 1 by other users
        if ($user->id === 1 && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $data = $request->validate([
            'email' => 'required|email',
            'username' => 'required|string|max:255',
            'name_first' => 'required|string|max:255',
            'name_last' => 'required|string|max:255',
            'root_admin' => 'sometimes|boolean',
        ]);

        $user->update($data);

        $this->alert->success('User was updated successfully.')->flash();
        return redirect()->route('admin.users');
    }
}
EOF

    # Modify Node Controller - Hanya ID 1
    cat > $PANEL_PATH/app/Http/Controllers/Admin/NodeController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Node;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Prologue\Alerts\AlertsMessageBag;

class NodeController extends Controller
{
    public function __construct(private AlertsMessageBag $alert) {}

    public function index(): View
    {
        // Only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.index', [
            'nodes' => Node::all(),
        ]);
    }

    public function create(): View
    {
        // Only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.create');
    }

    public function store(Request $request): RedirectResponse
    {
        // Only user ID 1 can create nodes
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'location_id' => 'required|exists:locations,id',
            'fqdn' => 'required|string|max:255',
            'scheme' => 'required|in:http,https',
            'memory' => 'required|numeric',
            'memory_overallocate' => 'required|numeric',
            'disk' => 'required|numeric',
            'disk_overallocate' => 'required|numeric',
        ]);

        Node::create($data);

        $this->alert->success('Node was created successfully.')->flash();
        return redirect()->route('admin.nodes');
    }

    public function edit(Node $node): View
    {
        // Only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.edit', compact('node'));
    }

    public function update(Request $request, Node $node): RedirectResponse
    {
        // Only user ID 1 can update nodes
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'location_id' => 'required|exists:locations,id',
            'fqdn' => 'required|string|max:255',
            'scheme' => 'required|in:http,https',
            'memory' => 'required|numeric',
            'memory_overallocate' => 'required|numeric',
            'disk' => 'required|numeric',
            'disk_overallocate' => 'required|numeric',
        ]);

        $node->update($data);

        $this->alert->success('Node was updated successfully.')->flash();
        return redirect()->route('admin.nodes');
    }

    public function destroy(Node $node): RedirectResponse
    {
        // Only user ID 1 can delete nodes
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $node->delete();

        $this->alert->success('Node was deleted successfully.')->flash();
        return redirect()->route('admin.nodes');
    }
}
EOF

    # Modify Location Controller - Hanya ID 1
    cat > $PANEL_PATH/app/Http/Controllers/Admin/LocationController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Location;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Prologue\Alerts\AlertsMessageBag;

class LocationController extends Controller
{
    public function __construct(private AlertsMessageBag $alert) {}

    public function index(): View
    {
        // Only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.index', [
            'locations' => Location::all(),
        ]);
    }

    public function create(): View
    {
        // Only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.create');
    }

    public function store(Request $request): RedirectResponse
    {
        // Only user ID 1 can create locations
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $data = $request->validate([
            'short' => 'required|string|max:255',
            'long' => 'required|string|max:255',
        ]);

        Location::create($data);

        $this->alert->success('Location was created successfully.')->flash();
        return redirect()->route('admin.locations');
    }

    public function edit(Location $location): View
    {
        // Only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.edit', compact('location'));
    }

    public function update(Request $request, Location $location): RedirectResponse
    {
        // Only user ID 1 can update locations
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $data = $request->validate([
            'short' => 'required|string|max:255',
            'long' => 'required|string|max:255',
        ]);

        $location->update($data);

        $this->alert->success('Location was updated successfully.')->flash();
        return redirect()->route('admin.locations');
    }

    public function destroy(Location $location): RedirectResponse
    {
        // Only user ID 1 can delete locations
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $location->delete();

        $this->alert->success('Location was deleted successfully.')->flash();
        return redirect()->route('admin.locations');
    }
}
EOF

    # Modify Nest Controller - Hanya ID 1
    cat > $PANEL_PATH/app/Http/Controllers/Admin/NestController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Nest;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Prologue\Alerts\AlertsMessageBag;

class NestController extends Controller
{
    public function __construct(private AlertsMessageBag $alert) {}

    public function index(): View
    {
        // Only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nests.index', [
            'nests' => Nest::all(),
        ]);
    }

    public function edit(Nest $nest): View
    {
        // Only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nests.edit', compact('nest'));
    }

    public function update(Request $request, Nest $nest): RedirectResponse
    {
        // Only user ID 1 can update nests
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'sometimes|string|nullable',
        ]);

        $nest->update($data);

        $this->alert->success('Nest was updated successfully.')->flash();
        return redirect()->route('admin.nests');
    }

    public function destroy(Nest $nest): RedirectResponse
    {
        // Only user ID 1 can delete nests
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $nest->delete();

        $this->alert->success('Nest was deleted successfully.')->flash();
        return redirect()->route('admin.nests');
    }
}
EOF

    # Modify User Controller - Hanya ID 1 bisa edit/delete
    cat > $PANEL_PATH/app/Http/Controllers/Admin/UserController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Prologue\Alerts\AlertsMessageBag;

class UserController extends Controller
{
    public function __construct(private AlertsMessageBag $alert) {}

    public function index(): View
    {
        // All admin can view users list
        return view('admin.users.index', [
            'users' => User::all(),
        ]);
    }

    public function view(User $user): View
    {
        // All admin can view user details
        return view('admin.users.view', compact('user'));
    }

    public function edit(User $user): View
    {
        // Only user ID 1 can edit users
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.users.edit', compact('user'));
    }

    public function update(Request $request, User $user): RedirectResponse
    {
        // Only user ID 1 can update users
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $data = $request->validate([
            'email' => 'required|email',
            'username' => 'required|string|max:255',
            'name_first' => 'required|string|max:255',
            'name_last' => 'required|string|max:255',
            'root_admin' => 'sometimes|boolean',
        ]);

        $user->update($data);

        $this->alert->success('User was updated successfully.')->flash();
        return redirect()->route('admin.users');
    }

    public function destroy(User $user): RedirectResponse
    {
        // Only user ID 1 can delete users
        if (auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Prevent deletion of user ID 1
        if ($user->id === 1) {
            $this->alert->danger('Cannot delete the primary administrator.')->flash();
            return redirect()->route('admin.users');
        }

        $user->delete();

        $this->alert->success('User was deleted successfully.')->flash();
        return redirect()->route('admin.users');
    }
}
EOF

    # Modify Server Controller for security
    cat > $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Client\Servers;

use App\Http\Controllers\Controller;
use App\Models\Server;
use Illuminate\Http\Request;

class ServerController
{
    public function index(Request $request)
    {
        // Only allow users to see their own servers
        $servers = $request->user()->servers;
        
        return response()->json($servers);
    }

    public function view(Request $request, Server $server)
    {
        // Check if user owns this server
        if ($request->user()->id !== $server->owner_id) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 500);
        }

        return response()->json($server);
    }

    public function delete(Request $request, Server $server)
    {
        // Check if user owns this server
        if ($request->user()->id !== $server->owner_id) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 500);
        }

        // Prevent deletion if not owner
        $server->delete();

        return response()->json(['success' => true]);
    }
}
EOF

    # Update routes - Settings bebas, nodes/locations/nests strict
    cat > $PANEL_PATH/routes/admin.php << 'EOF'
<?php

use App\Http\Middleware\StrictAdminSecurity;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'admin', 'namespace' => 'Admin', 'middleware' => ['auth']], function () {
    // Public admin routes - accessible by all admins
    Route::get('/', 'AdminController@index')->name('admin.index');
    Route::get('/settings', 'AdminController@settings')->name('admin.settings');
    
    // Users - view only for all admins
    Route::get('/users', 'UserController@index')->name('admin.users');
    Route::get('/users/{user}', 'UserController@view')->name('admin.users.view');
});

Route::group(['prefix' => 'admin', 'namespace' => 'Admin', 'middleware' => ['auth', StrictAdminSecurity::class]], function () {
    // Strict routes - only user ID 1 can access
    
    // Nodes
    Route::get('/nodes', 'NodeController@index')->name('admin.nodes');
    Route::get('/nodes/create', 'NodeController@create')->name('admin.nodes.create');
    Route::post('/nodes', 'NodeController@store')->name('admin.nodes.store');
    Route::get('/nodes/{node}/edit', 'NodeController@edit')->name('admin.nodes.edit');
    Route::put('/nodes/{node}', 'NodeController@update')->name('admin.nodes.update');
    Route::delete('/nodes/{node}', 'NodeController@destroy')->name('admin.nodes.destroy');
    
    // Locations
    Route::get('/locations', 'LocationController@index')->name('admin.locations');
    Route::get('/locations/create', 'LocationController@create')->name('admin.locations.create');
    Route::post('/locations', 'LocationController@store')->name('admin.locations.store');
    Route::get('/locations/{location}/edit', 'LocationController@edit')->name('admin.locations.edit');
    Route::put('/locations/{location}', 'LocationController@update')->name('admin.locations.update');
    Route::delete('/locations/{location}', 'LocationController@destroy')->name('admin.locations.destroy');
    
    // Nests
    Route::get('/nests', 'NestController@index')->name('admin.nests');
    Route::get('/nests/{nest}/edit', 'NestController@edit')->name('admin.nests.edit');
    Route::put('/nests/{nest}', 'NestController@update')->name('admin.nests.update');
    Route::delete('/nests/{nest}', 'NestController@destroy')->name('admin.nests.destroy');
    
    // User management (edit/delete)
    Route::get('/users/{user}/edit', 'UserController@edit')->name('admin.users.edit');
    Route::put('/users/{user}', 'UserController@update')->name('admin.users.update');
    Route::delete('/users/{user}', 'UserController@destroy')->name('admin.users.destroy');
});
EOF

    # Clear cache
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    cd $PANEL_PATH && php artisan cache:clear && php artisan view:clear

    echo -e "${GREEN}Instalasi security panel berhasil!${NC}"
    echo -e "${YELLOW}Konfigurasi:${NC}"
    echo -e "  - ${GREEN}Admin Settings: BEBAS${NC} (semua admin bisa akses)"
    echo -e "  - ${RED}Nodes Management: DIKUNCI${NC} (hanya ID 1)"
    echo -e "  - ${RED}Locations Management: DIKUNCI${NC} (hanya ID 1)"
    echo -e "  - ${RED}Nests Management: DIKUNCI${NC} (hanya ID 1)"
    echo -e "  - ${RED}Edit/Delete Users: DIKUNCI${NC} (hanya ID 1)"
}

# Function to change error message
change_error_message() {
    display_header
    echo -e "${YELLOW}Mengubah pesan error...${NC}"
    
    read -p "Masukkan pesan error baru: " new_message
    
    if [ -z "$new_message" ]; then
        echo -e "${RED}Pesan error tidak boleh kosong!${NC}"
        return 1
    fi
    
    ERROR_MESSAGE="$new_message"
    
    # Update all PHP files with new error message
    find $PANEL_PATH/app/Http/Controllers/Admin -name "*.php" -type f -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_message//\//\\/}/g" {} \;
    find $PANEL_PATH/app/Http/Controllers/Api/Client/Servers -name "*.php" -type f -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_message//\//\\/}/g" {} \;
    find $PANEL_PATH/app/Http/Middleware -name "*.php" -type f -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_message//\//\\/}/g" {} \;
    
    # Clear cache
    cd $PANEL_PATH && php artisan cache:clear && php artisan view:clear
    
    echo -e "${GREEN}Pesan error berhasil diubah!${NC}"
}

# Function to uninstall security
uninstall_security() {
    display_header
    echo -e "${YELLOW}Memulai uninstall security panel...${NC}"
    
    restore_backup
    
    # Remove custom middleware
    rm -f $PANEL_PATH/app/Http/Middleware/StrictAdminSecurity.php
    
    # Clear cache
    cd $PANEL_PATH && php artisan cache:clear && php artisan view:clear
    
    echo -e "${GREEN}Uninstall security panel berhasil!${NC}"
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${GREEN}Pilihan Menu:${NC}"
        echo -e "1. Install Security Panel"
        echo -e "2. Ubah Teks Error"
        echo -e "3. Uninstall Security Panel"
        echo -e "4. Exit"
        echo ""
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
        
        echo ""
        read -p "Tekan Enter untuk melanjutkan..."
    done
}

# Check if panel path exists
check_panel_path

# Run main menu
main_menu
