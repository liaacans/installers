#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default error message
ERROR_MSG="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Pterodactyl paths
PANEL_PATH="/var/www/pterodactyl"
BACKUP_PATH="/root/pterodactyl_backup"

# Function to display menu
show_menu() {
    clear
    echo -e "${BLUE}"
    echo "=========================================="
    echo "    Pterodactyl Security Panel Installer"
    echo "=========================================="
    echo -e "${NC}"
    echo "1. Install Security Panel"
    echo "2. Ubah Teks Error"
    echo "3. Uninstall Security Panel"
    echo "4. Exit"
    echo
    read -p "Pilih opsi [1-4]: " choice
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup file...${NC}"
    mkdir -p $BACKUP_PATH
    
    # Backup important files
    cp $PANEL_PATH/app/Http/Controllers/Admin/*.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Middleware/Authenticate.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Providers/AuthServiceProvider.php $BACKUP_PATH/ 2>/dev/null
    
    echo -e "${GREEN}Backup berhasil dibuat di $BACKUP_PATH${NC}"
}

# Function to install security
install_security() {
    echo -e "${YELLOW}Memulai instalasi security panel...${NC}"
    
    # Check if panel path exists
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}Error: Pterodactyl panel tidak ditemukan di $PANEL_PATH${NC}"
        echo -e "${YELLOW}Silakan ubah PANEL_PATH di script sesuai instalasi Anda${NC}"
        return 1
    fi
    
    create_backup
    
    # Create custom middleware
    echo -e "${YELLOW}Membuat custom middleware...${NC}"
    
    cat > $PANEL_PATH/app/Http/Middleware/AdminSecurity.php << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class AdminSecurity
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        $route = $request->route()->getName();
        
        // ID 1 always has full access
        if ($user && $user->id === 1) {
            return $next($request);
        }
        
        // Define restricted routes and their required permissions
        $restrictedRoutes = [
            'admin.settings' => 'settings',
            'admin.nodes' => 'nodes', 
            'admin.locations' => 'locations',
            'admin.nests' => 'nests',
            'admin.users' => 'users',
            'admin.servers' => 'servers'
        ];
        
        // Check if current route is restricted
        foreach ($restrictedRoutes as $routePattern => $permission) {
            if (strpos($route, $routePattern) !== false) {
                throw new AccessDeniedHttpException(config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
            }
        }
        
        return $next($request);
    }
}
EOF

    # Modify AdminAuthenticate middleware
    echo -e "${YELLOW}Memodifikasi AdminAuthenticate middleware...${NC}"
    
    cat > $PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Pterodactyl\Models\User;

class AdminAuthenticate
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        
        if (!$user || !$user->root_admin) {
            return response()->view('errors.403', [
                'message' => config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati')
            ], 403);
        }
        
        // Apply security restrictions for non-ID 1 users
        if ($user->id !== 1) {
            $route = $request->route()->getName();
            
            // List of completely restricted areas for non-ID 1
            $fullyRestricted = [
                'admin.settings', 'admin.nodes', 'admin.locations', 
                'admin.nests', 'admin.users', 'admin.servers'
            ];
            
            foreach ($fullyRestricted as $restricted) {
                if (strpos($route, $restricted) !== false) {
                    return response()->view('errors.403', [
                        'message' => config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati')
                    ], 403);
                }
            }
        }
        
        return $next($request);
    }
}
EOF

    # Modify AuthServiceProvider
    echo -e "${YELLOW}Memodifikasi AuthServiceProvider...${NC}"
    
    cat > $PANEL_PATH/app/Providers/AuthServiceProvider.php << 'EOF'
<?php

namespace Pterodactyl\Providers;

use Illuminate\Support\Facades\Gate;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Pterodactyl\Models\User;

class AuthServiceProvider extends ServiceProvider
{
    public function boot()
    {
        $this->registerPolicies();
        
        // Custom security configuration
        config(['security.error_message' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati']);
        
        // Define gates for security
        Gate::define('admin-settings', function (User $user) {
            return $user->id === 1;
        });
        
        Gate::define('admin-nodes', function (User $user) {
            return $user->id === 1;
        });
        
        Gate::define('admin-locations', function (User $user) {
            return $user->id === 1;
        });
        
        Gate::define('admin-nests', function (User $user) {
            return $user->id === 1;
        });
        
        Gate::define('admin-users', function (User $user) {
            return $user->id === 1;
        });
        
        Gate::define('admin-servers', function (User $user) {
            return $user->id === 1;
        });
        
        // Server access control - only owner or ID 1 can access
        Gate::define('view-server', function (User $user, $server) {
            return $user->id === 1 || $user->id === $server->owner_id;
        });
        
        Gate::define('edit-server', function (User $user, $server) {
            return $user->id === 1 || $user->id === $server->owner_id;
        });
        
        Gate::define('delete-server', function (User $user, $server) {
            return $user->id === 1;
        });
    }
}
EOF

    # Create custom controller for settings
    echo -e "${YELLOW}Membuat custom controllers...${NC}"
    
    # Settings Controller
    cat > $PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Http\Requests\Admin\Settings\BaseSettingsFormRequest;

class SettingsController extends Controller
{
    public function __construct(private AlertsMessageBag $alert)
    {
    }

    public function index(): View
    {
        // Only user ID 1 can access settings
        if (auth()->user()->id !== 1) {
            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
        }
        
        return view('admin.settings.index', [
            'settings' => config()->get('pterodactyl.settings', []),
        ]);
    }

    public function update(BaseSettingsFormRequest $request): RedirectResponse
    {
        // Only user ID 1 can update settings
        if (auth()->user()->id !== 1) {
            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
        }
        
        foreach ($request->normalize() as $key => $value) {
            $this->settings->set('settings::' . $key, $value);
        }

        $this->alert->success('Settings have been updated successfully.')->flash();

        return redirect()->route('admin.settings');
    }
}
EOF

    # Nodes Controller
    cat > $PANEL_PATH/app/Http/Controllers/Admin/NodesController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Pterodactyl\Models\Node;
use Pterodactyl\Http\Controllers\Controller;

class NodesController extends Controller
{
    public function index(): View
    {
        // Only user ID 1 can view nodes
        if (auth()->user()->id !== 1) {
            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
        }
        
        return view('admin.nodes.index', [
            'nodes' => Node::with('location')->get(),
        ]);
    }
}
EOF

    # Update routes to apply middleware
    echo -e "${YELLOW}Memperbarui routes...${NC}"
    
    # Backup original routes
    cp $PANEL_PATH/routes/api.php $BACKUP_PATH/api.php.backup
    cp $PANEL_PATH/routes/web.php $BACKUP_PATH/web.php.backup
    
    # Add custom error message to config
    echo -e "${YELLOW}Menambahkan konfigurasi security...${NC}"
    
    # Create security config file
    mkdir -p $PANEL_PATH/config
    cat > $PANEL_PATH/config/security.php << EOF
<?php

return [
    'error_message' => '$ERROR_MSG',
    'restricted_access' => [
        'settings' => [1],
        'nodes' => [1],
        'locations' => [1],
        'nests' => [1],
        'users' => [1],
        'servers' => [1]
    ]
];
EOF

    # Run panel commands
    echo -e "${YELLOW}Menjalankan panel commands...${NC}"
    cd $PANEL_PATH
    php artisan config:cache
    php artisan view:clear
    php artisan route:clear

    echo -e "${GREEN}Security panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Note: Hanya user dengan ID 1 yang memiliki akses penuh.${NC}"
}

# Function to change error text
change_error_text() {
    echo -e "${YELLOW}Mengubah teks error...${NC}"
    
    read -p "Masukkan teks error baru: " new_error
    
    if [ -z "$new_error" ]; then
        echo -e "${RED}Teks error tidak boleh kosong!${NC}"
        return 1
    fi
    
    # Update security config
    if [ -f "$PANEL_PATH/config/security.php" ]; then
        sed -i "s/'error_message' => '.*'/'error_message' => '$new_error'/g" $PANEL_PATH/config/security.php
    fi
    
    # Update AuthServiceProvider
    if [ -f "$PANEL_PATH/app/Providers/AuthServiceProvider.php" ]; then
        sed -i "s/config('security.error_message', '.*')/config('security.error_message', '$new_error')/g" $PANEL_PATH/app/Providers/AuthServiceProvider.php
    fi
    
    # Update middleware files
    for file in $PANEL_PATH/app/Http/Middleware/*.php; do
        if [ -f "$file" ]; then
            sed -i "s/config('security.error_message', '.*')/config('security.error_message', '$new_error')/g" "$file"
            sed -i "s/'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'/'$new_error'/g" "$file"
        fi
    done
    
    # Update controllers
    for file in $PANEL_PATH/app/Http/Controllers/Admin/*.php; do
        if [ -f "$file" ]; then
            sed -i "s/config('security.error_message', '.*')/config('security.error_message', '$new_error')/g" "$file"
            sed -i "s/'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'/'$new_error'/g" "$file"
        fi
    done
    
    ERROR_MSG="$new_error"
    
    echo -e "${GREEN}Teks error berhasil diubah!${NC}"
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Memulai uninstall security panel...${NC}"
    
    if [ ! -d "$BACKUP_PATH" ]; then
        echo -e "${RED}Backup tidak ditemukan! Tidak dapat melakukan uninstall.${NC}"
        return 1
    fi
    
    # Restore backed up files
    echo -e "${YELLOW}Memulihkan file original...${NC}"
    
    # Restore middleware
    if [ -f "$BACKUP_PATH/AdminAuthenticate.php" ]; then
        cp $BACKUP_PATH/AdminAuthenticate.php $PANEL_PATH/app/Http/Middleware/
    fi
    
    if [ -f "$BACKUP_PATH/Authenticate.php" ]; then
        cp $BACKUP_PATH/Authenticate.php $PANEL_PATH/app/Http/Middleware/
    fi
    
    # Restore AuthServiceProvider
    if [ -f "$BACKUP_PATH/AuthServiceProvider.php" ]; then
        cp $BACKUP_PATH/AuthServiceProvider.php $PANEL_PATH/app/Providers/
    fi
    
    # Restore controllers
    if [ -d "$BACKUP_PATH" ]; then
        cp $BACKUP_PATH/*.php $PANEL_PATH/app/Http/Controllers/Admin/ 2>/dev/null
    fi
    
    # Remove security config
    rm -f $PANEL_PATH/config/security.php
    
    # Remove custom middleware
    rm -f $PANEL_PATH/app/Http/Middleware/AdminSecurity.php
    
    # Run panel commands
    echo -e "${YELLOW}Menjalankan panel commands...${NC}"
    cd $PANEL_PATH
    php artisan config:cache
    php artisan view:clear
    php artisan route:clear
    
    echo -e "${GREEN}Security panel berhasil diuninstall!${NC}"
}

# Main script
while true; do
    show_menu
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
            echo -e "${GREEN}Keluar...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            ;;
    esac
    
    echo
    read -p "Tekan Enter untuk melanjutkan..."
done
