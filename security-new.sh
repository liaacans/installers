#!/bin/bash

# Security Panel Pterodactyl
# By @ginaabaikhati

PANEL_PATH="/var/www/pterodactyl"
BACKUP_PATH="/root/pterodactyl_backup"
ERROR_MESSAGE="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display header
display_header() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════╗"
    echo "║           Pterodactyl Security Panel           ║"
    echo "║              By @ginaabaikhati                 ║"
    echo "╚════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to check if panel directory exists
check_panel_exists() {
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}Error: Pterodactyl panel directory not found at $PANEL_PATH${NC}"
        echo "Please update PANEL_PATH variable in the script to match your installation"
        exit 1
    fi
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Creating backup...${NC}"
    mkdir -p "$BACKUP_PATH"
    cp -r "$PANEL_PATH/app" "$BACKUP_PATH/app_backup_$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}Backup created successfully!${NC}"
}

# Function to restore from backup
restore_backup() {
    local latest_backup=$(ls -dt "$BACKUP_PATH/app_backup_"* | head -1)
    
    if [ -z "$latest_backup" ]; then
        echo -e "${RED}No backup found!${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Restoring from backup: $latest_backup${NC}"
    rm -rf "$PANEL_PATH/app"
    cp -r "$latest_backup" "$PANEL_PATH/app"
    echo -e "${GREEN}Backup restored successfully!${NC}"
}

# Function to install security
install_security() {
    check_panel_exists
    create_backup
    
    echo -e "${YELLOW}Installing security features...${NC}"
    
    # Backup original files first
    cp "$PANEL_PATH/app/Http/Controllers/Admin"/*.php "$BACKUP_PATH/" 2>/dev/null || true
    cp "$PANEL_PATH/app/Http/Controllers/Api/Client"/*.php "$BACKUP_PATH/" 2>/dev/null || true
    cp "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php" "$BACKUP_PATH/" 2>/dev/null || true
    
    # 1. Modify Admin Settings Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use App\Http\Controllers\Controller;
use App\Services\Helpers\SettingsValidationService;
use App\Traits\Controllers\JavascriptInjection;
use App\Services\Settings\SettingsUpdateService;
use App\Services\Settings\SettingsCreationService;
use Illuminate\Contracts\Console\Kernel;
use App\Models\Settings;
use Illuminate\Http\Response;

class SettingsController extends Controller
{
    use JavascriptInjection;

    public function __construct(
        private SettingsCreationService $creationService,
        private SettingsUpdateService $updateService,
        private Kernel $kernel,
        private SettingsValidationService $validator,
    ) {
    }

    /**
     * Render the UI for basic panel settings.
     */
    public function index(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.settings.index', [
            'settings' => Settings::first(),
        ]);
    }

    /**
     * Handle request to update basic panel settings.
     *
     * @throws \App\Exceptions\Model\DataValidationException
     * @throws \App\Exceptions\Service\Settings\UnexpectedConfigValueException
     */
    public function update(): RedirectResponse
    {
        // Security check - only user ID 1 can update
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $settings = Settings::first();
        $this->validator->handle(config('panel.validation.settings'), $settings);

        $this->updateService->handle($settings, $settings->toArray());
        $this->kernel->call('queue:restart');

        return redirect()->route('admin.settings');
    }
}
EOF

    # 2. Modify Nodes Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use App\Http\Controllers\Controller;
use App\Repositories\Eloquent\NodeRepository;
use App\Services\Nodes\NodeUpdateService;
use App\Services\Nodes\NodeCreationService;
use App\Services\Nodes\NodeDeletionService;

class NodesController extends Controller
{
    public function __construct(
        protected NodeRepository $repository,
        protected NodeCreationService $creationService,
        protected NodeUpdateService $updateService,
        protected NodeDeletionService $deletionService,
    ) {
    }

    /**
     * Display node index page.
     */
    public function index(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $nodes = $this->repository->all();
        
        return view('admin.nodes.index', [
            'nodes' => $nodes,
        ]);
    }

    /**
     * Display node create page.
     */
    public function create(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.create');
    }

    /**
     * Store a new node.
     */
    public function store(Request $request)
    {
        // Security check - only user ID 1 can create
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $node = $this->creationService->handle($request->normalize());
        return redirect()->route('admin.nodes.view', $node->id);
    }

    /**
     * Display node detail page.
     */
    public function view(int $id): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $node = $this->repository->getNodeForUpdate($id);
        
        return view('admin.nodes.view', [
            'node' => $node,
        ]);
    }

    /**
     * Update a node.
     */
    public function update(Request $request, int $id)
    {
        // Security check - only user ID 1 can update
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $node = $this->repository->getNodeForUpdate($id);
        $this->updateService->handle($node, $request->normalize());
        
        return redirect()->route('admin.nodes.view', $node->id);
    }

    /**
     * Delete a node.
     */
    public function delete(int $id)
    {
        // Security check - only user ID 1 can delete
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $node = $this->repository->getNodeForUpdate($id);
        $this->deletionService->handle($node);
        
        return redirect()->route('admin.nodes');
    }
}
EOF

    # 3. Modify Locations Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Repositories\Eloquent\LocationRepository;
use App\Services\Locations\LocationUpdateService;
use App\Services\Locations\LocationCreationService;
use App\Services\Locations\LocationDeletionService;

class LocationsController extends Controller
{
    public function __construct(
        protected LocationRepository $repository,
        protected LocationCreationService $creationService,
        protected LocationUpdateService $updateService,
        protected LocationDeletionService $deletionService,
    ) {
    }

    /**
     * Display location index page.
     */
    public function index(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $locations = $this->repository->all();
        
        return view('admin.locations.index', [
            'locations' => $locations,
        ]);
    }

    /**
     * Display location create page.
     */
    public function create(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.create');
    }

    /**
     * Store a new location.
     */
    public function store(Request $request)
    {
        // Security check - only user ID 1 can create
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $location = $this->creationService->handle($request->normalize());
        return redirect()->route('admin.locations.view', $location->id);
    }

    /**
     * Display location detail page.
     */
    public function view(int $id): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $location = $this->repository->getWithNodes($id);
        
        return view('admin.locations.view', [
            'location' => $location,
        ]);
    }

    /**
     * Update a location.
     */
    public function update(Request $request, int $id)
    {
        // Security check - only user ID 1 can update
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $location = $this->repository->getWithNodes($id);
        $this->updateService->handle($location, $request->normalize());
        
        return redirect()->route('admin.locations.view', $location->id);
    }

    /**
     * Delete a location.
     */
    public function delete(int $id)
    {
        // Security check - only user ID 1 can delete
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $location = $this->repository->getWithNodes($id);
        $this->deletionService->handle($location);
        
        return redirect()->route('admin.locations');
    }
}
EOF

    # 4. Modify Nests Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NestsController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Repositories\Eloquent\NestRepository;
use App\Services\Nests\NestUpdateService;
use App\Services\Nests\NestCreationService;
use App\Services\Nests\NestDeletionService;
use App\Services\Eggs\EggUpdateService;
use App\Services\Eggs\EggCreationService;
use App\Services\Eggs\EggDeletionService;

class NestsController extends Controller
{
    public function __construct(
        protected NestRepository $repository,
        protected NestCreationService $creationService,
        protected NestUpdateService $updateService,
        protected NestDeletionService $deletionService,
        protected EggCreationService $eggCreationService,
        protected EggUpdateService $eggUpdateService,
        protected EggDeletionService $eggDeletionService,
    ) {
    }

    /**
     * Display nest index page.
     */
    public function index(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $nests = $this->repository->getWithEggs();
        
        return view('admin.nests.index', [
            'nests' => $nests,
        ]);
    }

    /**
     * Display nest create page.
     */
    public function create(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nests.create');
    }

    /**
     * Store a new nest.
     */
    public function store(Request $request)
    {
        // Security check - only user ID 1 can create
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $nest = $this->creationService->handle($request->normalize());
        return redirect()->route('admin.nests.view', $nest->id);
    }

    /**
     * Display nest detail page.
     */
    public function view(int $id): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $nest = $this->repository->getWithEggs($id);
        
        return view('admin.nests.view', [
            'nest' => $nest,
        ]);
    }

    /**
     * Update a nest.
     */
    public function update(Request $request, int $id)
    {
        // Security check - only user ID 1 can update
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $nest = $this->repository->getWithEggs($id);
        $this->updateService->handle($nest, $request->normalize());
        
        return redirect()->route('admin.nests.view', $nest->id);
    }

    /**
     * Delete a nest.
     */
    public function delete(int $id)
    {
        // Security check - only user ID 1 can delete
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $nest = $this->repository->getWithEggs($id);
        $this->deletionService->handle($nest);
        
        return redirect()->route('admin.nests');
    }
}
EOF

    # 5. Modify Users Controller for additional security
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/UsersController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\Request;
use App\Models\User;
use App\Http\Controllers\Controller;
use App\Repositories\Eloquent\UserRepository;
use App\Services\Users\UserUpdateService;
use App\Services\Users\UserCreationService;
use App\Services\Users\UserDeletionService;

class UsersController extends Controller
{
    public function __construct(
        protected UserRepository $repository,
        protected UserCreationService $creationService,
        protected UserUpdateService $updateService,
        protected UserDeletionService $deletionService,
    ) {
    }

    /**
     * Display user index page.
     */
    public function index(): View
    {
        $users = $this->repository->all();
        
        return view('admin.users.index', [
            'users' => $users,
        ]);
    }

    /**
     * Display user create page.
     */
    public function create(): View
    {
        return view('admin.users.create');
    }

    /**
     * Store a new user.
     */
    public function store(Request $request)
    {
        // Security check - only user ID 1 can create users
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $user = $this->creationService->handle($request->normalize());
        return redirect()->route('admin.users.view', $user->id);
    }

    /**
     * Display user detail page.
     */
    public function view(int $id): View
    {
        $user = $this->repository->getWithServers($id);
        
        // Security check - users can only view their own profile unless ID 1
        if (auth()->user()->id !== 1 && auth()->user()->id !== $user->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.users.view', [
            'user' => $user,
        ]);
    }

    /**
     * Update a user.
     */
    public function update(Request $request, int $id)
    {
        $user = $this->repository->getWithServers($id);
        
        // Security check - only user ID 1 can update other users
        if (auth()->user()->id !== 1 && auth()->user()->id !== $user->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $this->updateService->handle($user, $request->normalize());
        
        return redirect()->route('admin.users.view', $user->id);
    }

    /**
     * Delete a user.
     */
    public function delete(int $id)
    {
        // Security check - only user ID 1 can delete users
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $user = $this->repository->getWithServers($id);
        $this->deletionService->handle($user);
        
        return redirect()->route('admin.users');
    }
}
EOF

    # 6. Modify Server Controller for security
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/ServersController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Repositories\Eloquent\ServerRepository;
use App\Services\Servers\ServerUpdateService;
use App\Services\Servers\ServerCreationService;
use App\Services\Servers\ServerDeletionService;
use App\Services\Servers\ServerSuspensionService;

class ServersController extends Controller
{
    public function __construct(
        protected ServerRepository $repository,
        protected ServerCreationService $creationService,
        protected ServerUpdateService $updateService,
        protected ServerDeletionService $deletionService,
        protected ServerSuspensionService $suspensionService,
    ) {
    }

    /**
     * Display server index page.
     */
    public function index(): View
    {
        $servers = $this->repository->getAllServers();
        
        return view('admin.servers.index', [
            'servers' => $servers,
        ]);
    }

    /**
     * Display server detail page.
     */
    public function view(int $id): View
    {
        $server = $this->repository->getServerForView($id);
        
        // Security check - users can only view their own servers unless ID 1
        if (auth()->user()->id !== 1 && auth()->user()->id !== $server->user_id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.servers.view', [
            'server' => $server,
        ]);
    }

    /**
     * Update a server.
     */
    public function update(Request $request, int $id)
    {
        $server = $this->repository->getServerForView($id);
        
        // Security check - only user ID 1 can update other users' servers
        if (auth()->user()->id !== 1 && auth()->user()->id !== $server->user_id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $this->updateService->handle($server, $request->normalize());
        
        return redirect()->route('admin.servers.view', $server->id);
    }

    /**
     * Delete a server.
     */
    public function delete(int $id)
    {
        $server = $this->repository->getServerForView($id);
        
        // Security check - only user ID 1 can delete other users' servers
        if (auth()->user()->id !== 1 && auth()->user()->id !== $server->user_id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $this->deletionService->handle($server);
        
        return redirect()->route('admin.servers');
    }
}
EOF

    # 7. Create custom middleware for additional security
    cat > "$PANEL_PATH/app/Http/Middleware/CheckAdminAccess.php" << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckAdminAccess
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next, string $permission = null)
    {
        $user = $request->user();
        
        // Check if user is authenticated
        if (!$user) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Routes that only user ID 1 can access
        $restrictedRoutes = [
            'admin.settings',
            'admin.nodes',
            'admin.locations', 
            'admin.nests',
        ];
        
        $currentRoute = $request->route()->getName();
        
        // Check if current route is restricted to user ID 1 only
        if (in_array($currentRoute, $restrictedRoutes) && $user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return $next($request);
    }
}
EOF

    echo -e "${GREEN}Security features installed successfully!${NC}"
    echo -e "${YELLOW}Please run: php artisan optimize${NC}"
}

# Function to change error message
change_error_message() {
    check_panel_exists
    
    echo -e "${YELLOW}Current error message: $ERROR_MESSAGE${NC}"
    read -p "Enter new error message: " new_message
    
    if [ -z "$new_message" ]; then
        echo -e "${RED}Error message cannot be empty!${NC}"
        return 1
    fi
    
    # Update error message in all controller files
    find "$PANEL_PATH/app/Http/Controllers/Admin" -name "*.php" -type f -exec sed -i "s|Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati|$new_message|g" {} \;
    
    # Update middleware
    sed -i "s|Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati|$new_message|g" "$PANEL_PATH/app/Http/Middleware/CheckAdminAccess.php" 2>/dev/null || true
    
    ERROR_MESSAGE="$new_message"
    echo -e "${GREEN}Error message updated successfully!${NC}"
    echo -e "${YELLOW}Please run: php artisan optimize${NC}"
}

# Function to uninstall security
uninstall_security() {
    check_panel_exists
    
    echo -e "${YELLOW}Uninstalling security features...${NC}"
    
    if restore_backup; then
        echo -e "${GREEN}Security features uninstalled successfully!${NC}"
        echo -e "${YELLOW}Please run: php artisan optimize${NC}"
    else
        echo -e "${RED}Failed to uninstall security features!${NC}"
    fi
}

# Function to optimize panel
optimize_panel() {
    echo -e "${YELLOW}Optimizing panel...${NC}"
    cd "$PANEL_PATH" && php artisan optimize
    echo -e "${GREEN}Panel optimized successfully!${NC}"
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${GREEN}1. Install Security Panel${NC}"
        echo -e "${GREEN}2. Ubah Teks Error${NC}"
        echo -e "${GREEN}3. Uninstall Security Panel${NC}"
        echo -e "${GREEN}4. Optimize Panel${NC}"
        echo -e "${RED}5. Exit${NC}"
        echo
        read -p "Pilih opsi [1-5]: " choice
        
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
                optimize_panel
                ;;
            5)
                echo -e "${BLUE}Terima kasih! By @ginaabaikhati${NC}"
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
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Run main menu
main_menu
