#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default error message
ERROR_MSG="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Pterodactyl paths (adjust these according to your installation)
PANEL_PATH="/var/www/pterodactyl"
BACKUP_PATH="/root/pterodactyl_backup"

# Function to display header
display_header() {
    clear
    echo -e "${BLUE}"
    echo "=========================================="
    echo "    Pterodactyl Security Panel Installer"
    echo "=========================================="
    echo -e "${NC}"
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup file original...${NC}"
    mkdir -p $BACKUP_PATH
    
    # Backup important files
    cp $PANEL_PATH/app/Http/Controllers/Admin/*.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/*.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Controllers/*.php $BACKUP_PATH/ 2>/dev/null
    
    echo -e "${GREEN}Backup berhasil dibuat di $BACKUP_PATH${NC}"
}

# Function to restore backup
restore_backup() {
    echo -e "${YELLOW}Mengembalikan file original dari backup...${NC}"
    
    if [ ! -d "$BACKUP_PATH" ]; then
        echo -e "${RED}Backup tidak ditemukan!${NC}"
        return 1
    fi
    
    # Restore files
    cp $BACKUP_PATH/*.php $PANEL_PATH/app/Http/Controllers/Admin/ 2>/dev/null
    cp $BACKUP_PATH/*.php $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ 2>/dev/null
    cp $BACKUP_PATH/AdminAuthenticate.php $PANEL_PATH/app/Http/Middleware/ 2>/dev/null
    cp $BACKUP_PATH/*.php $PANEL_PATH/app/Http/Controllers/ 2>/dev/null
    
    echo -e "${GREEN}Restore berhasil!${NC}"
    
    # Run artisan commands
    cd $PANEL_PATH
    php artisan view:clear
    php artisan cache:clear
    php artisan route:clear
    
    echo -e "${GREEN}Security panel berhasil diuninstall!${NC}"
}

# Function to check if user is admin ID 1
check_admin_id() {
    echo '<?php
if (auth()->check() && auth()->user()->id !== 1) {
    abort(403, "'"$ERROR_MSG"'");
}
?>'
}

# Function to install security
install_security() {
    display_header
    echo -e "${YELLOW}Menginstall Security Panel...${NC}"
    
    # Create backup first
    create_backup
    
    # Create security middleware
    cat > $PANEL_PATH/app/Http/Middleware/AdminSecurity.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminSecurity
{
    public function handle(Request $request, Closure $next)
    {
        // Allow API requests
        if ($request->is('api/*')) {
            return $next($request);
        }

        // Check if user is authenticated and is admin ID 1
        if (auth()->check()) {
            $user = auth()->user();
            $route = $request->route();
            $routeName = $route ? $route->getName() : '';
            
            // Define restricted routes
            $restrictedSettings = [
                'admin.settings',
                'admin.settings.*',
                'admin.nodes',
                'admin.nodes.*', 
                'admin.locations',
                'admin.locations.*',
                'admin.nests',
                'admin.nests.*',
                'admin.users',
                'admin.users.*',
                'admin.servers',
                'admin.servers.*'
            ];
            
            // Check if current route is restricted
            $isRestricted = false;
            foreach ($restrictedSettings as $pattern) {
                if (fnmatch($pattern, $routeName)) {
                    $isRestricted = true;
                    break;
                }
            }
            
            // If route is restricted and user is not ID 1, block access
            if ($isRestricted && $user->id !== 1) {
                abort(403, config('app.security_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
            }
        }

        return $next($request);
    }
}
EOF

    # Modify Admin Controller
    cat > $PANEL_PATH/app/Http/Controllers/Admin/AdminController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\Admin\ServerViewService;
use Illuminate\View\View;

class AdminController extends Controller
{
    public function index(ServerViewService $viewService): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, config('app.security_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
        }
        
        return view('admin.index', [
            'servers' => $viewService->setFilter('all')->getServers(),
        ]);
    }
}
EOF

    # Modify Settings Controller
    cat > $PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\View\View;

class SettingsController extends Controller
{
    public function index(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, config('app.security_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
        }
        
        return view('admin.settings.index');
    }
}
EOF

    # Modify Nodes Controller
    cat > $PANEL_PATH/app/Http/Controllers/Admin/NodesController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\View\View;

class NodesController extends Controller
{
    public function index(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, config('app.security_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
        }
        
        return view('admin.nodes.index');
    }
}
EOF

    # Modify Locations Controller  
    cat > $PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\View\View;

class LocationsController extends Controller
{
    public function index(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, config('app.security_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
        }
        
        return view('admin.locations.index');
    }
}
EOF

    # Modify Nests Controller
    cat > $PANEL_PATH/app/Http/Controllers/Admin/NestsController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\View\View;

class NestsController extends Controller
{
    public function index(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, config('app.security_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
        }
        
        return view('admin.nests.index');
    }
}
EOF

    # Modify Users Controller
    cat > $PANEL_PATH/app/Http/Controllers/Admin/UsersController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\View\View;

class UsersController extends Controller
{
    public function index(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, config('app.security_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
        }
        
        return view('admin.users.index');
    }
}
EOF

    # Modify Server Controller for file manager security
    cat > $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/FileManagerController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Client\Servers;

use App\Http\Controllers\Controller;
use App\Models\Server;
use App\Services\Servers\CloudService;
use Illuminate\Http\Request;

class FileManagerController extends Controller
{
    public function __construct(private CloudService $cloudService) {}
    
    public function index(Request $request, Server $server)
    {
        // Block if user is not owner and not admin ID 1
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, config('app.security_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
        }
        
        return $this->cloudService->setServer($server)->getDirectory(
            $request->input('directory', '/')
        );
    }
}
EOF

    # Add security message to config
    if ! grep -q "security_message" $PANEL_PATH/config/app.php; then
        sed -i "/'name' => env('APP_NAME', 'Pterodactyl'),/a\\\n    'security_message' => '$ERROR_MSG'," $PANEL_PATH/config/app.php
    fi

    # Update Kernel.php to include middleware
    if ! grep -q "AdminSecurity" $PANEL_PATH/app/Http/Kernel.php; then
        sed -i "/protected \$middlewareGroups = \[/a\\\n        'web' => [\n            // ... other middleware\n            \App\Http\Middleware\AdminSecurity::class,\n        ]," $PANEL_PATH/app/Http/Kernel.php
    fi

    # Run artisan commands
    cd $PANEL_PATH
    php artisan view:clear
    php artisan cache:clear
    php artisan route:clear

    echo -e "${GREEN}Security Panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Note: Hanya user dengan ID 1 yang dapat mengakses settings, nodes, locations, nests, dan file manager.${NC}"
}

# Function to change error text
change_error_text() {
    display_header
    echo -e "${YELLOW}Mengubah Teks Error...${NC}"
    
    read -p "Masukkan teks error baru: " new_error_msg
    
    if [ -z "$new_error_msg" ]; then
        echo -e "${RED}Teks error tidak boleh kosong!${NC}"
        return 1
    fi
    
    ERROR_MSG="$new_error_msg"
    
    # Update config file
    if grep -q "security_message" $PANEL_PATH/config/app.php; then
        sed -i "s/'security_message' => '.*'/'security_message' => '$ERROR_MSG'/" $PANEL_PATH/config/app.php
    else
        sed -i "/'name' => env('APP_NAME', 'Pterodactyl'),/a\\\n    'security_message' => '$ERROR_MSG'," $PANEL_PATH/config/app.php
    fi
    
    # Update all controller files with new message
    find $PANEL_PATH/app/Http/Controllers -name "*.php" -type f -exec sed -i "s/abort(403, \".*\")/abort(403, \"$ERROR_MSG\")/g" {} \;
    
    # Run artisan commands
    cd $PANEL_PATH
    php artisan view:clear
    php artisan cache:clear
    php artisan route:clear
    
    echo -e "${GREEN}Teks error berhasil diubah menjadi: $ERROR_MSG${NC}"
}

# Main menu
while true; do
    display_header
    echo -e "${GREEN}Pilihan Menu:${NC}"
    echo "1. Install Security Panel"
    echo "2. Ubah Teks Error" 
    echo "3. Uninstall Security Panel"
    echo "4. Exit"
    echo ""
    read -p "Pilih opsi [1-4]: " choice

    case $choice in
        1)
            install_security
            ;;
        2)
            change_error_text
            ;;
        3)
            restore_backup
            ;;
        4)
            echo -e "${GREEN}Keluar dari script.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            ;;
    esac
    
    echo ""
    read -p "Tekan Enter untuk melanjutkan..."
done
