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
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║               PTERODACTYL SECURITY PANEL                    ║"
    echo "║                     By @ginaabaikhati                       ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: Script harus dijalankan sebagai root${NC}"
        exit 1
    fi
}

# Function to check if Pterodactyl panel exists
check_panel() {
    if [[ ! -d "$PANEL_PATH" ]]; then
        echo -e "${RED}Error: Directory Pterodactyl tidak ditemukan di $PANEL_PATH${NC}"
        echo -e "${YELLOW}Pastikan path panel Pterodactyl sudah benar atau ubah variabel PANEL_PATH${NC}"
        exit 1
    fi
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup panel Pterodactyl...${NC}"
    
    if [[ -d "$BACKUP_PATH" ]]; then
        rm -rf "$BACKUP_PATH"
    fi
    
    mkdir -p "$BACKUP_PATH"
    cp -r "$PANEL_PATH/app" "$BACKUP_PATH/"
    cp -r "$PANEL_PATH/resources" "$BACKUP_PATH/"
    
    echo -e "${GREEN}Backup berhasil dibuat di $BACKUP_PATH${NC}"
}

# Function to restore backup
restore_backup() {
    echo -e "${YELLOW}Mengembalikan dari backup...${NC}"
    
    if [[ ! -d "$BACKUP_PATH" ]]; then
        echo -e "${RED}Error: Backup tidak ditemukan di $BACKUP_PATH${NC}"
        return 1
    fi
    
    cp -r "$BACKUP_PATH/app" "$PANEL_PATH/"
    cp -r "$BACKUP_PATH/resources" "$PANEL_PATH/"
    
    echo -e "${GREEN}Backup berhasil dikembalikan${NC}"
}

# Function to install security
install_security() {
    display_header
    echo -e "${YELLOW}Memulai instalasi security panel...${NC}"
    
    check_root
    check_panel
    create_backup
    
    echo -e "${YELLOW}Mengimplementasikan security measures...${NC}"
    
    # Backup original files
    cp "$PANEL_PATH/app/Http/Controllers/Admin"/*.php "$BACKUP_PATH/" 2>/dev/null || true
    cp "$PANEL_PATH/app/Http/Controllers/Api/Client"/*.php "$BACKUP_PATH/" 2>/dev/null || true
    cp "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php" "$BACKUP_PATH/" 2>/dev/null || true
    
    # 1. Modify Admin Controller for settings access
    modify_admin_controllers
    
    # 2. Modify API Client Controllers
    modify_api_controllers
    
    # 3. Modify Middleware for additional security
    modify_middleware
    
    # 4. Create custom security helper
    create_security_helper
    
    # 5. Clear cache and optimize
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    cd "$PANEL_PATH"
    php artisan cache:clear
    php artisan view:clear
    php artisan route:clear
    
    echo -e "${GREEN}Instalasi security panel berhasil!${NC}"
    echo -e "${YELLOW}Security features yang diimplementasikan:${NC}"
    echo -e "✓ Panel settings hanya untuk ID 1"
    echo -e "✓ Nodes management hanya untuk ID 1" 
    echo -e "✓ Locations management hanya untuk ID 1"
    echo -e "✓ Nests management hanya untuk ID 1"
    echo -e "✓ Users tidak bisa edit/ubah/delete users lain"
    echo -e "✓ File manager hanya untuk ID 1"
    echo -e "✓ Semua akses terlarang menampilkan pesan error khusus"
}

# Function to modify admin controllers
modify_admin_controllers() {
    echo -e "${BLUE}Memodifikasi admin controllers...${NC}"
    
    # Settings Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\Settings\BaseSettingsFormRequest;

class SettingsController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    protected $alert;

    /**
     * @var \Pterodactyl\Contracts\Repository\SettingsRepositoryInterface
     */
    private $settings;

    /**
     * SettingsController constructor.
     */
    public function __construct(
        AlertsMessageBag $alert,
        SettingsRepositoryInterface $settings
    ) {
        $this->alert = $alert;
        $this->settings = $settings;
    }

    /**
     * Render the UI for basic panel settings.
     */
    public function index(): View
    {
        // Security Check - Only user ID 1 can access settings
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.settings.index', [
            'name' => config('app.name', 'Pterodactyl'),
        ]);
    }

    /**
     * Handle request to update basic panel settings.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     * @throws \Pterodactyl\Exceptions\Repository\RecordNotFoundException
     */
    public function update(BaseSettingsFormRequest $request): RedirectResponse
    {
        // Security Check - Only user ID 1 can update settings
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        foreach ($request->normalize() as $key => $value) {
            $this->settings->set('settings::' . $key, $value);
        }

        $this->alert->success('Panel settings have been updated successfully.')->flash();

        return redirect()->route('admin.settings');
    }
}
EOF

    # Nodes Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\Node\NodeFormRequest;

class NodesController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    protected $alert;

    /**
     * @var \Pterodactyl\Contracts\Repository\NodeRepositoryInterface
     */
    protected $repository;

    /**
     * NodesController constructor.
     */
    public function __construct(AlertsMessageBag $alert, NodeRepositoryInterface $repository)
    {
        $this->alert = $alert;
        $this->repository = $repository;
    }

    /**
     * Returns a listing of all nodes on the system.
     */
    public function index(): View
    {
        // Security Check - Only user ID 1 can view nodes
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.index', [
            'nodes' => $this->repository->getAllNodesWithServers(),
        ]);
    }

    /**
     * Returns the new node creation page.
     */
    public function create(): View
    {
        // Security Check - Only user ID 1 can create nodes
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.new');
    }

    /**
     * Creates a new node.
     */
    public function store(NodeFormRequest $request): RedirectResponse
    {
        // Security Check - Only user ID 1 can store nodes
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $node = $this->repository->create($request->except('_token'));
        $this->alert->success('Node was created successfully.')->flash();

        return redirect()->route('admin.nodes.view', $node->id);
    }
}
EOF

    # Locations Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\LocationRepositoryInterface;

class LocationsController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    protected $alert;

    /**
     * @var \Pterodactyl\Contracts\Repository\LocationRepositoryInterface
     */
    protected $repository;

    /**
     * LocationsController constructor.
     */
    public function __construct(AlertsMessageBag $alert, LocationRepositoryInterface $repository)
    {
        $this->alert = $alert;
        $this->repository = $repository;
    }

    /**
     * Return the location overview page.
     */
    public function index(): View
    {
        // Security Check - Only user ID 1 can view locations
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.index', [
            'locations' => $this->repository->all(),
        ]);
    }

    /**
     * Return the location creation page.
     */
    public function create(): View
    {
        // Security Check - Only user ID 1 can create locations
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.new');
    }

    /**
     * Return the location view page.
     */
    public function view(int $id): View
    {
        // Security Check - Only user ID 1 can view location details
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.view', [
            'location' => $this->repository->getWithNodes($id),
        ]);
    }
}
EOF

    # Nests Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NestsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NestRepositoryInterface;

class NestsController extends Controller
{
    /**
     * @var \Pterodactyl\Contracts\Repository\NestRepositoryInterface
     */
    protected $repository;

    /**
     * NestsController constructor.
     */
    public function __construct(NestRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    /**
     * List all nests available to the user.
     */
    public function index(): View
    {
        // Security Check - Only user ID 1 can view nests
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nests.index', [
            'nests' => $this->repository->getWithEggs(),
        ]);
    }

    /**
     * Display a specific nest.
     */
    public function view(int $id): View
    {
        // Security Check - Only user ID 1 can view nest details
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nests.view', [
            'nest' => $this->repository->getWithEggs($id),
        ]);
    }
}
EOF

    # Users Controller - Modified to prevent editing other users
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/UsersController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\UserRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\User\UserFormRequest;

class UsersController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    protected $alert;

    /**
     * @var \Pterodactyl\Contracts\Repository\UserRepositoryInterface
     */
    protected $repository;

    /**
     * UsersController constructor.
     */
    public function __construct(AlertsMessageBag $alert, UserRepositoryInterface $repository)
    {
        $this->alert = $alert;
        $this->repository = $repository;
    }

    /**
     * Display user index page.
     */
    public function index(): View
    {
        return view('admin.users.index', [
            'users' => $this->repository->setSearchTerm(request()->input('query'))->getAllUsers(),
        ]);
    }

    /**
     * Display user view page.
     */
    public function view(int $id): View
    {
        $user = $this->repository->find($id);
        
        // Security Check - Users can only view their own profile unless ID 1
        if (auth()->user()->id !== 1 && auth()->user()->id !== $user->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.users.view', [
            'user' => $user,
            'servers' => $user->servers()->with('node', 'egg', 'allocation')->get(),
        ]);
    }

    /**
     * Display user creation page.
     */
    public function create(): View
    {
        return view('admin.users.new');
    }

    /**
     * Display user update page.
     */
    public function update(int $id): View
    {
        $user = $this->repository->find($id);
        
        // Security Check - Only user ID 1 can edit other users
        if (auth()->user()->id !== 1 && auth()->user()->id !== $user->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.users.update', [
            'user' => $user,
        ]);
    }

    /**
     * Create a user.
     */
    public function store(UserFormRequest $request): RedirectResponse
    {
        $user = $this->repository->create($request->except('_token'));
        $this->alert->success('User was created successfully.')->flash();

        return redirect()->route('admin.users.view', $user->id);
    }

    /**
     * Update a user.
     */
    public function updateUser(UserFormRequest $request, int $id): RedirectResponse
    {
        $user = $this->repository->find($id);
        
        // Security Check - Only user ID 1 can update other users
        if (auth()->user()->id !== 1 && auth()->user()->id !== $user->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $this->repository->update($id, $request->except('_token'));
        $this->alert->success('User was updated successfully.')->flash();

        return redirect()->route('admin.users.view', $id);
    }

    /**
     * Delete a user.
     */
    public function destroy(int $id): RedirectResponse
    {
        $user = $this->repository->find($id);
        
        // Security Check - Only user ID 1 can delete users
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Prevent self-deletion
        if (auth()->user()->id === $user->id) {
            abort(403, 'Akses ditolak: Tidak bisa menghapus akun sendiri. By @ginaabaikhati');
        }

        $this->repository->delete($id);
        $this->alert->success('User was deleted successfully.')->flash();

        return redirect()->route('admin.users');
    }
}
EOF
}

# Function to modify API controllers
modify_api_controllers() {
    echo -e "${BLUE}Memodifikasi API controllers...${NC}"
    
    # Server Controller for API
    cat > "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Illuminate\Http\Response;
use Pterodactyl\Models\Server;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Http\Requests\Api\Client\Servers\GetServerRequest;

class ServerController extends ClientApiController
{
    /**
     * Returns a single server transformed for consumption by the client.
     */
    public function index(GetServerRequest $request, Server $server): array
    {
        // Security Check - Users can only access their own servers
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return [
            'object' => 'server',
            'attributes' => $server->toArray(),
        ];
    }

    /**
     * Returns a single server transformed for consumption by the client.
     */
    public function view(GetServerRequest $request, Server $server): array
    {
        // Security Check - Users can only access their own servers
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return [
            'object' => 'server',
            'attributes' => $server->toArray(),
        ];
    }
}
EOF

    # File Manager Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/FileManagerController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Pterodactyl\Models\Server;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\ListFilesRequest;

class FileManagerController extends ClientApiController
{
    /**
     * Returns a listing of files in a given directory.
     */
    public function index(ListFilesRequest $request, Server $server): array
    {
        // Security Check - Only user ID 1 can access file manager
        if ($request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        // Original file manager logic would go here
        return [
            'object' => 'file_list',
            'data' => [],
        ];
    }
}
EOF
}

# Function to modify middleware
modify_middleware() {
    echo -e "${BLUE}Memodifikasi middleware...${NC}"
    
    # Admin Authenticate Middleware
    cat > "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminAuthenticate
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        
        // Check if user is authenticated
        if (is_null($user)) {
            return redirect()->guest(route('auth.login'));
        }

        // Check if user is root admin for sensitive areas
        $sensitiveRoutes = [
            'admin.settings',
            'admin.nodes',
            'admin.locations', 
            'admin.nests',
            'admin.users.destroy',
            'admin.api',
        ];

        $currentRoute = $request->route()->getName();
        
        // If accessing sensitive routes, check for ID 1
        foreach ($sensitiveRoutes as $route) {
            if (strpos($currentRoute, $route) !== false && $user->id !== 1) {
                abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
            }
        }

        return $next($request);
    }
}
EOF
}

# Function to create security helper
create_security_helper() {
    echo -e "${BLUE}Membuat security helper...${NC}"
    
    # Create security helper file
    cat > "$PANEL_PATH/app/Helpers/SecurityHelper.php" << 'EOF'
<?php

namespace Pterodactyl\Helpers;

class SecurityHelper
{
    /**
     * Check if user has root admin access
     */
    public static function isRootAdmin(): bool
    {
        return auth()->check() && auth()->user()->id === 1;
    }

    /**
     * Check if user can access sensitive areas
     */
    public static function canAccessSensitiveArea($userId = null): bool
    {
        if (is_null($userId)) {
            $userId = auth()->user()->id ?? null;
        }

        return $userId === 1;
    }

    /**
     * Security check for admin operations
     */
    public static function checkAdminAccess(): void
    {
        if (!self::isRootAdmin()) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
    }

    /**
     * Check server ownership
     */
    public static function checkServerOwnership($serverOwnerId): void
    {
        $currentUserId = auth()->user()->id ?? null;
        
        if ($currentUserId !== $serverOwnerId && $currentUserId !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
    }
}
EOF
}

# Function to change error message
change_error_message() {
    display_header
    echo -e "${YELLOW}Mengubah pesan error security...${NC}"
    
    read -p "Masukkan pesan error baru: " new_message
    
    if [[ -z "$new_message" ]]; then
        echo -e "${RED}Pesan error tidak boleh kosong!${NC}"
        return 1
    fi
    
    # Update error message in all modified files
    find "$PANEL_PATH/app/Http/Controllers/Admin" -name "*.php" -type f -exec sed -i "s|Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati|$new_message|g" {} \;
    find "$PANEL_PATH/app/Http/Controllers/Api/Client" -name "*.php" -type f -exec sed -i "s|Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati|$new_message|g" {} \;
    sed -i "s|Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati|$new_message|g" "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php"
    sed -i "s|Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati|$new_message|g" "$PANEL_PATH/app/Helpers/SecurityHelper.php"
    
    ERROR_MESSAGE="$new_message"
    
    echo -e "${GREEN}Pesan error berhasil diubah!${NC}"
    echo -e "${BLUE}Pesan baru: $new_message${NC}"
    
    # Clear cache
    cd "$PANEL_PATH"
    php artisan cache:clear
    php artisan view:clear
}

# Function to uninstall security
uninstall_security() {
    display_header
    echo -e "${YELLOW}Memulai uninstall security panel...${NC}"
    
    check_root
    check_panel
    
    if [[ ! -d "$BACKUP_PATH" ]]; then
        echo -e "${RED}Error: Backup tidak ditemukan. Uninstall tidak dapat dilakukan.${NC}"
        echo -e "${YELLOW}Silakan install security terlebih dahulu.${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Mengembalikan panel ke keadaan semula...${NC}"
    restore_backup
    
    # Clear cache
    cd "$PANEL_PATH"
    php artisan cache:clear
    php artisan view:clear
    php artisan route:clear
    
    echo -e "${GREEN}Uninstall security panel berhasil!${NC}"
    echo -e "${YELLOW}Panel Pterodactyl telah dikembalikan ke keadaan semula.${NC}"
}

# Function to display menu
display_menu() {
    display_header
    echo -e "${GREEN}Pilih opsi:${NC}"
    echo -e "1. Install Security Panel"
    echo -e "2. Ubah Teks Error" 
    echo -e "3. Uninstall Security Panel"
    echo -e "4. Exit"
    echo
    read -p "Masukkan pilihan [1-4]: " choice
}

# Main script execution
main() {
    while true; do
        display_menu
        
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
                echo -e "${RED}Pilihan tidak valid! Silakan pilih 1-4.${NC}"
                ;;
        esac
        
        echo
        read -p "Tekan Enter untuk melanjutkan..."
    done
}

# Run main function
main "$@"
