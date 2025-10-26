#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Security message
SECURITY_MESSAGE="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Pterodactyl paths (adjust according to your installation)
PANEL_PATH="/var/www/pterodactyl"
BACKUP_DIR="/root/pterodactyl_backup"

# Function to display menu
show_menu() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║    Pterodactyl Security Panel        ║"
    echo "║          By @ginaabaikhati           ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
    echo "1. Install Security Panel"
    echo "2. Ubah Teks Error"
    echo "3. Uninstall Security Panel"
    echo "4. Exit"
    echo
    echo -n "Pilih opsi [1-4]: "
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup files...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi
    
    # Backup important files
    cp "$PANEL_PATH/app/Http/Controllers/Admin"/*.php "$BACKUP_DIR/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php" "$BACKUP_DIR/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Controllers/Api/Client"/*.php "$BACKUP_DIR/" 2>/dev/null
    cp "$PANEL_PATH/routes/api.php" "$BACKUP_DIR/" 2>/dev/null
    cp "$PANEL_PATH/routes/admin.php" "$BACKUP_DIR/" 2>/dev/null
    
    echo -e "${GREEN}Backup created in $BACKUP_DIR${NC}"
}

# Function to install security
install_security() {
    echo -e "${YELLOW}Menginstall Security Panel...${NC}"
    
    # Create backup first
    create_backup
    
    # Check if panel path exists
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}Error: Pterodactyl panel path not found at $PANEL_PATH${NC}"
        echo "Please update PANEL_PATH variable in the script"
        return 1
    fi
    
    # Create security middleware
    create_security_middleware
    
    # Modify admin controllers
    secure_admin_controllers
    
    # Modify API controllers
    secure_api_controllers
    
    # Modify routes
    secure_routes
    
    # Clear cache
    echo -e "${YELLOW}Clearing cache...${NC}"
    cd "$PANEL_PATH" && php artisan cache:clear
    cd "$PANEL_PATH" && php artisan view:clear
    
    echo -e "${GREEN}Security Panel installed successfully!${NC}"
    echo -e "${YELLOW}Please restart your webserver (nginx/apache)${NC}"
}

# Function to create security middleware
create_security_middleware() {
    cat > "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php" << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminSecurity
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        
        // Only user ID 1 can access admin settings
        if (!$user || $user->id !== 1) {
            if ($request->is('admin/settings*') || 
                $request->is('admin/nodes*') || 
                $request->is('admin/locations*') ||
                $request->is('admin/nests*')) {
                
                abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
            }
        }

        return $next($request);
    }
}
EOF
}

# Function to secure admin controllers
secure_admin_controllers() {
    # Secure SettingsController
    if [ -f "$PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php" ]; then
        sed -i 's/public function __construct()/public function __construct()\n    {\n        if (auth()->check() && auth()->user()->id !== 1) {\n            abort(500, \"Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati\");\n        }\n    }/g' "$PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php"
    fi

    # Secure NodeController
    if [ -f "$PANEL_PATH/app/Http/Controllers/Admin/NodeController.php" ]; then
        cat > "$PANEL_PATH/app/Http/Controllers/Admin/NodeController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Node;
use App\Repositories\NodeRepository;
use App\Services\Nodes\NodeCreationService;
use App\Services\Nodes\NodeDeletionService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Prologue\Alerts\AlertsMessageBag;

class NodeController extends Controller
{
    public function __construct(
        private AlertsMessageBag $alert,
        private NodeCreationService $creationService,
        private NodeDeletionService $deletionService,
        private NodeRepository $repository
    ) {}

    public function index(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.index', [
            'nodes' => $this->repository->getAllNodes(true),
        ]);
    }

    public function create(): View
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.create');
    }

    public function store(Request $request): RedirectResponse
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $node = $this->creationService->handle($request->normalize());
        $this->alert->success('Node was created successfully.')->flash();

        return redirect()->route('admin.nodes.view.configuration', $node->id);
    }

    public function view(Node $node): View
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.view.index', [
            'node' => $node,
            'locations' => $this->repository->getLocationsForNode($node),
        ]);
    }

    public function update(Request $request, Node $node): RedirectResponse
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $this->repository->update($node->id, $request->normalize(), $request->input('reset_secret') === 'on');
        $this->alert->success('Node was updated successfully.')->flash();

        return redirect()->route('admin.nodes.view.settings', $node->id);
    }

    public function destroy(Request $request, Node $node): RedirectResponse
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $this->deletionService->handle($node->id);
        $this->alert->success('Node was deleted successfully.')->flash();

        return redirect()->route('admin.nodes');
    }
}
EOF
    fi

    # Secure LocationController
    if [ -f "$PANEL_PATH/app/Http/Controllers/Admin/LocationController.php" ]; then
        cat > "$PANEL_PATH/app/Http/Controllers/Admin/LocationController.php" << 'EOF'
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
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.index', [
            'locations' => Location::all(),
        ]);
    }

    public function create(): View
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.create');
    }

    public function store(Request $request): RedirectResponse
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        Location::query()->create($request->normalize());
        $this->alert->success('Location created successfully.')->flash();

        return redirect()->route('admin.locations');
    }

    public function update(Request $request, Location $location): RedirectResponse
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $location->update($request->normalize());
        $this->alert->success('Location updated successfully.')->flash();

        return redirect()->route('admin.locations');
    }

    public function destroy(Location $location): RedirectResponse
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $location->delete();
        $this->alert->success('Location deleted successfully.')->flash();

        return redirect()->route('admin.locations');
    }
}
EOF
    fi

    # Secure NestController
    if [ -f "$PANEL_PATH/app/Http/Controllers/Admin/NestController.php" ]; then
        cat > "$PANEL_PATH/app/Http/Controllers/Admin/NestController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Nest;
use App\Repositories\NestRepository;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Prologue\Alerts\AlertsMessageBag;

class NestController extends Controller
{
    public function __construct(private AlertsMessageBag $alert, private NestRepository $repository) {}

    public function index(): View
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nests.index', [
            'nests' => $this->repository->getAllWithEggs(),
        ]);
    }

    public function view(Nest $nest): View
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nests.view', [
            'nest' => $nest->load('eggs'),
            'eggs' => $nest->eggs,
        ]);
    }

    public function update(Request $request, Nest $nest): RedirectResponse
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(500, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $this->repository->update($nest->id, $request->normalize());
        $this->alert->success('Nest updated successfully.')->flash();

        return redirect()->route('admin.nests.view', $nest->id);
    }
}
EOF
    fi
}

# Function to secure API controllers
secure_api_controllers() {
    # Secure Client ServerController for file manager and other operations
    if [ -f "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" ]; then
        # Add security check to prevent accessing other users' servers
        sed -i '/public function __construct(/a \    {\n        $this->middleware(function ($request, $next) {\n            $server = $request->route()->parameter(\"server\");\n            $user = $request->user();\n            \n            if ($user && $server && $server->user_id !== $user->id) {\n                if ($user->id !== 1) {\n                    abort(500, \"Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati\");\n                }\n            }\n            \n            return $next($request);\n        });\n    }' "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php"
    fi

    # Secure file operations
    if [ -f "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/FileManagerController.php" ]; then
        sed -i '/public function __construct(/a \    {\n        $this->middleware(function ($request, $next) {\n            $server = $request->route()->parameter(\"server\");\n            $user = $request->user();\n            \n            if ($user && $server && $server->user_id !== $user->id && $user->id !== 1) {\n                abort(500, \"Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati\");\n            }\n            \n            return $next($request);\n        });\n    }' "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/FileManagerController.php"
    fi
}

# Function to secure routes
secure_routes() {
    # Add security middleware to admin routes
    if [ -f "$PANEL_PATH/app/Providers/RouteServiceProvider.php" ]; then
        sed -i '/protected function mapAdminRoutes()/a \    {\n        Route::prefix(\"admin\")\n            ->middleware([\"web\", \"auth\", \"admin\", \"admin.security\"])\n            ->group(base_path(\"routes/admin.php\"));\n    }' "$PANEL_PATH/app/Providers/RouteServiceProvider.php"
        
        # Register the middleware
        if grep -q "protected \$middlewareAliases" "$PANEL_PATH/app/Http/Kernel.php"; then
            sed -i "/protected \$middlewareAliases = \[/a \        'admin.security' => \\\\App\\\\Http\\\\Middleware\\\\AdminSecurity::class," "$PANEL_PATH/app/Http/Kernel.php"
        fi
    fi
}

# Function to change error text
change_error_text() {
    echo -e "${YELLOW}Mengubah teks error...${NC}"
    read -p "Masukkan teks error baru: " new_text
    
    if [ -n "$new_text" ]; then
        SECURITY_MESSAGE="$new_text"
        echo -e "${GREEN}Teks error berhasil diubah!${NC}"
        echo -e "${YELLOW}Teks baru: $SECURITY_MESSAGE${NC}"
    else
        echo -e "${RED}Teks error tidak boleh kosong!${NC}"
    fi
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Uninstalling Security Panel...${NC}"
    
    # Restore from backup
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}Restoring files from backup...${NC}"
        
        # Restore admin controllers
        cp "$BACKUP_DIR"/*.php "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
        
        # Restore middleware
        if [ -f "$BACKUP_DIR/AdminAuthenticate.php" ]; then
            cp "$BACKUP_DIR/AdminAuthenticate.php" "$PANEL_PATH/app/Http/Middleware/"
        fi
        
        # Restore API controllers
        cp "$BACKUP_DIR"/*.php "$PANEL_PATH/app/Http/Controllers/Api/Client/" 2>/dev/null
        
        # Remove security middleware
        rm -f "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php"
        
        # Restore RouteServiceProvider
        if [ -f "$BACKUP_DIR/RouteServiceProvider.php" ]; then
            cp "$BACKUP_DIR/RouteServiceProvider.php" "$PANEL_PATH/app/Providers/"
        fi
        
        # Remove middleware from Kernel
        sed -i "/'admin.security' =>.*/d" "$PANEL_PATH/app/Http/Kernel.php"
        
        echo -e "${GREEN}Security Panel uninstalled successfully!${NC}"
        echo -e "${YELLOW}Please restart your webserver (nginx/apache)${NC}"
    else
        echo -e "${RED}Backup directory not found! Cannot uninstall.${NC}"
        echo -e "${YELLOW}You may need to manually restore your Pterodactyl installation.${NC}"
    fi
}

# Main script execution
while true; do
    show_menu
    read choice
    
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
            ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
done
