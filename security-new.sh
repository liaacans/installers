#!/bin/bash

# Security Panel Pterodactyl - By @ginaabaikhati
# Hanya admin ID 1 yang bisa mengakses semua fitur

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PANEL_PATH="/var/www/pterodactyl"
BACKUP_PATH="/root/pterodactyl_backup"
SECURITY_LOG="/var/log/pterodactyl_security.log"

# Log function
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$SECURITY_LOG"
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Error function
log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $1" >> "$SECURITY_LOG"
    echo -e "${RED}[ERROR]${NC} $1"
}

# Warning function
log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Script ini harus dijalankan sebagai root!"
        exit 1
    fi
}

# Check if Pterodactyl panel exists
check_panel_exists() {
    if [[ ! -d "$PANEL_PATH" ]]; then
        log_error "Directory Pterodactyl tidak ditemukan di $PANEL_PATH"
        exit 1
    fi
}

# Backup original files
backup_files() {
    log_action "Membuat backup file original..."
    
    mkdir -p "$BACKUP_PATH"
    
    # Backup important files
    local files=(
        "app/Http/Controllers/Admin"
        "app/Http/Middleware"
        "app/Http/Controllers/Controller.php"
        "routes/api.php"
        "routes/web.php"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$PANEL_PATH/$file" || -d "$PANEL_PATH/$file" ]]; then
            cp -r "$PANEL_PATH/$file" "$BACKUP_PATH/${file//\//_}.backup"
        fi
    done
    
    log_action "Backup selesai disimpan di $BACKUP_PATH"
}

# Create security middleware
create_security_middleware() {
    log_action "Membuat security middleware..."
    
    cat > "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php" << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminSecurity
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Check if user is authenticated
        if (!auth()->check()) {
            return redirect()->route('auth.login');
        }

        $user = auth()->user();
        $route = $request->route()->getName();
        
        // Admin ID 1 has full access
        if ($user->id === 1) {
            return $next($request);
        }

        // Define restricted routes for other admins
        $restrictedRoutes = [
            'admin.servers', 'admin.servers.view', 'admin.servers.manage',
            'admin.nodes', 'admin.nodes.view', 'admin.nodes.manage',
            'admin.nests', 'admin.nests.view', 'admin.nests.manage', 
            'admin.locations', 'admin.locations.view', 'admin.locations.manage',
            'admin.settings', 'admin.settings.*'
        ];

        // Check if current route is restricted
        foreach ($restrictedRoutes as $restricted) {
            if (fnmatch($restricted, $route)) {
                abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
            }
        }

        return $next($request);
    }
}
EOF
}

# Modify admin controller for servers
modify_admin_controllers() {
    log_action "Memodifikasi admin controllers..."
    
    # Servers Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/ServersController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Server;
use App\Repositories\Daemon\DaemonServerRepository;
use App\Services\Servers\ServerDeletionService;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Prologue\Alerts\AlertsMessageBag;

class ServersController extends Controller
{
    public function __construct(
        private AlertsMessageBag $alert,
        private DaemonServerRepository $daemonServerRepository,
        private ServerDeletionService $deletionService
    ) {}

    public function index()
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return view('admin.servers.index', [
            'servers' => Server::with(['user', 'node', 'allocation'])->paginate(50),
        ]);
    }

    public function view(Server $server)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return view('admin.servers.view', [
            'server' => $server->load(['user', 'egg', 'node']),
            'egg' => $server->egg,
        ]);
    }

    public function settings(Server $server)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return view('admin.servers.settings', [
            'server' => $server,
        ]);
    }

    public function delete(Request $request, Server $server)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        $this->deletionService->handle($server);
        $this->alert->success('Server was successfully deleted from the system.')->flash();

        return response('', Response::HTTP_NO_CONTENT);
    }
}
EOF

    # Nodes Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Node;
use Illuminate\View\View;
use Illuminate\Http\Request;

class NodesController extends Controller
{
    public function index(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return view('admin.nodes.index', [
            'nodes' => Node::with('location')->get(),
        ]);
    }

    public function view(Node $node): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return view('admin.nodes.view', [
            'node' => $node->load('location'),
        ]);
    }

    public function settings(Node $node): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return view('admin.nodes.settings', [
            'node' => $node,
        ]);
    }
}
EOF

    # Nests Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NestsController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Nest;
use Illuminate\View\View;

class NestsController extends Controller
{
    public function index(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return view('admin.nests.index', [
            'nests' => Nest::with('eggs')->get(),
        ]);
    }

    public function view(Nest $nest): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return view('admin.nests.view', [
            'nest' => $nest->load('eggs'),
        ]);
    }
}
EOF

    # Locations Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Location;
use Illuminate\View\View;

class LocationsController extends Controller
{
    public function index(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return view('admin.locations.index', [
            'locations' => Location::with('nodes')->get(),
        ]);
    }

    public function view(Location $location): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return view('admin.locations.view', [
            'location' => $location->load('nodes'),
        ]);
    }
}
EOF
}

# Modify base controller
modify_base_controller() {
    log_action "Memodifikasi base controller..."
    
    # Backup original controller
    cp "$PANEL_PATH/app/Http/Controllers/Controller.php" "$BACKUP_PATH/Controller.php.backup"
    
    # Create modified controller
    cat > "$PANEL_PATH/app/Http/Controllers/Controller.php" << 'EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Routing\Controller as BaseController;

class Controller extends BaseController
{
    use AuthorizesRequests, ValidatesRequests;

    public function __construct()
    {
        $this->middleware('auth');
        
        // Apply security middleware to all admin routes
        $this->middleware('admin.security')->only([
            'index', 'view', 'create', 'edit', 'update', 'destroy', 
            'settings', 'manage', 'delete'
        ]);
    }

    /**
     * Custom security check for admin routes
     */
    protected function checkAdminAccess()
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
    }
}
EOF
}

# Update routes
update_routes() {
    log_action "Memperbarui routes..."
    
    # Backup original routes
    cp "$PANEL_PATH/routes/web.php" "$BACKUP_PATH/web.php.backup"
    
    # Add middleware to routes
    if ! grep -q "AdminSecurity" "$PANEL_PATH/routes/web.php"; then
        sed -i '1i use App\Http\Middleware\AdminSecurity;' "$PANEL_PATH/routes/web.php"
    fi
}

# Register middleware
register_middleware() {
    log_action "Mendaftarkan middleware..."
    
    # Backup kernel
    cp "$PANEL_PATH/app/Http/Kernel.php" "$BACKUP_PATH/Kernel.php.backup"
    
    # Add middleware to kernel
    if ! grep -q "AdminSecurity" "$PANEL_PATH/app/Http/Kernel.php"; then
        sed -i "/protected \$routeMiddleware = \[/a\        'admin.security' => \\App\\Http\\Middleware\\AdminSecurity::class," "$PANEL_PATH/app/Http/Kernel.php"
    fi
}

# Update admin routes with middleware
update_admin_routes() {
    log_action "Memperbarui admin routes..."
    
    # This would require more complex route modifications
    # For now, we rely on the controller modifications
    log_warning "Pastikan routes admin sudah dilindungi oleh middleware yang sesuai"
}

# Clear cache and optimize
clear_cache() {
    log_action "Membersihkan cache..."
    
    cd "$PANEL_PATH" || exit 1
    
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    
    log_action "Cache berhasil dibersihkan"
}

# Set permissions
set_permissions() {
    log_action "Mengatur permissions..."
    
    chown -R www-data:www-data "$PANEL_PATH"
    chmod -R 755 "$PANEL_PATH"
    chmod -R 755 "$PANEL_PATH/storage"
    chmod -R 755 "$PANEL_PATH/bootstrap/cache"
    
    log_action "Permissions berhasil diatur"
}

# Install security
install_security() {
    echo -e "${BLUE}=== INSTALL SECURITY PANEL ===${NC}"
    check_root
    check_panel_exists
    
    log_action "Memulai instalasi security panel..."
    
    # Create backup
    backup_files
    
    # Create security middleware
    create_security_middleware
    
    # Modify controllers
    modify_admin_controllers
    modify_base_controller
    
    # Update routes and middleware
    update_routes
    register_middleware
    update_admin_routes
    
    # Final steps
    clear_cache
    set_permissions
    
    log_action "Security panel berhasil diinstal!"
    log_action "Hanya admin dengan ID 1 yang bisa mengakses semua fitur."
    log_action "Admin lain akan melihat pesan error saat mencoba akses."
}

# Change error text
change_error_text() {
    echo -e "${BLUE}=== GANTI TEKS ERROR ===${NC}"
    
    local new_text=""
    read -p "Masukkan teks error baru: " new_text
    
    if [[ -z "$new_text" ]]; then
        log_error "Teks error tidak boleh kosong!"
        return 1
    fi
    
    # Update all controllers with new text
    find "$PANEL_PATH/app/Http/Controllers/Admin" -name "*.php" -type f -exec sed -i "s/abort(403, '.*')/abort(403, '$new_text')/g" {} \;
    
    # Update middleware
    sed -i "s/abort(403, '.*')/abort(403, '$new_text')/g" "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php"
    
    clear_cache
    
    log_action "Teks error berhasil diganti menjadi: $new_text"
}

# Uninstall security
uninstall_security() {
    echo -e "${BLUE}=== UNINSTALL SECURITY PANEL ===${NC}"
    check_root
    
    if [[ ! -d "$BACKUP_PATH" ]]; then
        log_error "Backup tidak ditemukan! Tidak bisa uninstall."
        exit 1
    fi
    
    log_action "Memulai uninstall security panel..."
    
    # Restore backed up files
    for backup_file in "$BACKUP_PATH"/*.backup; do
        if [[ -f "$backup_file" ]]; then
            filename=$(basename "$backup_file" .backup)
            original_path="${filename//_/\/}"
            
            if [[ -f "$PANEL_PATH/$original_path" || -d "$PANEL_PATH/$original_path" ]]; then
                cp -r "$backup_file" "$PANEL_PATH/$original_path"
                log_action "Restored: $original_path"
            fi
        fi
    done
    
    # Remove security middleware
    if [[ -f "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php" ]]; then
        rm "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php"
    fi
    
    # Remove middleware from kernel
    sed -i "/'admin.security' =>.*/d" "$PANEL_PATH/app/Http/Kernel.php"
    
    clear_cache
    set_permissions
    
    log_action "Security panel berhasil diuninstall!"
    log_warning "Backup files masih disimpan di $BACKUP_PATH untuk keamanan"
}

# Main menu
show_menu() {
    echo -e "${BLUE}"
    echo "=========================================="
    echo "    SECURITY PANEL PTERODACTYL"
    echo "         By @ginaabaikhati"
    echo "=========================================="
    echo -e "${NC}"
    echo -e "${GREEN}1.${NC} Install Security Panel"
    echo -e "${GREEN}2.${NC} Ganti Teks Error" 
    echo -e "${GREEN}3.${NC} Uninstall Security Panel"
    echo -e "${GREEN}4.${NC} Exit Security Panel"
    echo -e "${BLUE}==========================================${NC}"
}

# Main function
main() {
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
                log_action "Keluar dari Security Panel"
                exit 0
                ;;
            *)
                log_error "Pilihan tidak valid! Silakan pilih 1-4."
                ;;
        esac
        
        echo
        read -p "Tekan Enter untuk melanjutkan..."
        clear
    done
}

# Check if script is sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    clear
    main
fi
