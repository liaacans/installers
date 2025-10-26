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

# Function to display header
show_header() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════╗"
    echo "║          Pterodactyl Security Panel           ║"
    echo "║              By @ginaabaikhati                ║"
    echo "╚════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup file...${NC}"
    mkdir -p $BACKUP_PATH
    
    # Backup important files
    cp $PANEL_PATH/app/Http/Controllers/Admin/*.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Middleware/*.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Providers/*.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/routes/api.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/routes/web.php $BACKUP_PATH/ 2>/dev/null
    
    echo -e "${GREEN}Backup berhasil dibuat di $BACKUP_PATH${NC}"
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
    cp $BACKUP_PATH/*.php $PANEL_PATH/app/Http/Middleware/ 2>/dev/null
    cp $BACKUP_PATH/*.php $PANEL_PATH/app/Providers/ 2>/dev/null
    cp $BACKUP_PATH/api.php $PANEL_PATH/routes/ 2>/dev/null
    cp $BACKUP_PATH/web.php $PANEL_PATH/routes/ 2>/dev/null
    
    # Clear cache
    cd $PANEL_PATH
    php artisan cache:clear
    php artisan view:clear
    
    echo -e "${GREEN}Restore berhasil!${NC}"
}

# Function to install security
install_security() {
    echo -e "${YELLOW}Menginstall security panel...${NC}"
    
    # Check if panel path exists
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}Directory Pterodactyl tidak ditemukan!${NC}"
        echo -e "${YELLOW}Pastikan Pterodactyl terinstall di $PANEL_PATH${NC}"
        return 1
    fi
    
    create_backup
    
    # Create custom middleware
    cat > $PANEL_PATH/app/Http/Middleware/CheckAdminAccess.php << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Pterodactyl\Models\User;

class CheckAdminAccess
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        
        // Allow user with ID 1 full access
        if ($user && $user->id === 1) {
            return $next($request);
        }
        
        $path = $request->path();
        $method = $request->method();
        
        // Check for restricted actions
        $restrictedPaths = [
            'admin/nodes', 'admin/locations', 'admin/nests', 
            'admin/users', 'admin/servers', 'admin/settings'
        ];
        
        $restrictedActions = ['edit', 'update', 'delete', 'destroy', 'create', 'store'];
        
        // Block access to restricted paths for non-ID 1 users
        foreach ($restrictedPaths as $restrictedPath) {
            if (strpos($path, $restrictedPath) !== false && $user->id !== 1) {
                abort(403, config('app.security_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
            }
        }
        
        // Block destructive actions for non-ID 1 users
        foreach ($restrictedActions as $action) {
            if (strpos($path, $action) !== false && $user->id !== 1) {
                abort(403, config('app.security_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
            }
        }
        
        return $next($request);
    }
}
EOF

    # Modify AdminController to add security checks
    cat > $PANEL_PATH/app/Http/Controllers/Admin/AdminController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Http\Requests\Admin\Settings\BaseSettingsFormRequest;

class AdminController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    private $alert;

    /**
     * AdminController constructor.
     */
    public function __construct(AlertsMessageBag $alert)
    {
        $this->alert = $alert;
    }

    /**
     * Return the admin index view.
     */
    public function index(): View
    {
        return view('admin.index');
    }

    /**
     * @throws \ReflectionException
     */
    public function overrideSettings(BaseSettingsFormRequest $request): RedirectResponse
    {
        foreach ($request->normalize() as $key => $value) {
            if ($key === 'app:security_message') {
                config()->set('pterodactyl.security_message', $value);
            }
        }

        $this->alert->success('Settings have been updated successfully.')->flash();

        return redirect()->route('admin.settings');
    }
}
EOF

    # Create custom controller for handling security
    cat > $PANEL_PATH/app/Http/Controllers/SecurityController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers;

use Illuminate\Http\Request;
use Pterodactyl\Models\User;

class SecurityController extends Controller
{
    public function checkAccess(Request $request)
    {
        $user = $request->user();
        
        if (!$user) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Only user ID 1 has full access
        if ($user->id !== 1) {
            $path = $request->path();
            $method = $request->method();
            
            // Block settings access
            if (strpos($path, 'admin/settings') !== false && $method !== 'GET') {
                abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
            }
            
            // Block nodes management
            if (strpos($path, 'admin/nodes') !== false && !in_array($method, ['GET', 'POST'])) {
                abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
            }
            
            // Block locations management
            if (strpos($path, 'admin/locations') !== false) {
                abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
            }
            
            // Block nests management
            if (strpos($path, 'admin/nests') !== false) {
                abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
            }
            
            // Block user management
            if (strpos($path, 'admin/users') !== false && $user->id !== 1) {
                abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
            }
            
            // Block server modifications for other users
            if (strpos($path, 'admin/servers') !== false) {
                if ($method === 'DELETE' || strpos($path, 'edit') !== false) {
                    abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
                }
            }
        }
    }
}
EOF

    # Modify routes to add security middleware
    if [ -f "$PANEL_PATH/routes/web.php" ]; then
        # Backup original routes
        cp $PANEL_PATH/routes/web.php $PANEL_PATH/routes/web.php.backup
        
        # Add security middleware to routes
        sed -i '/^<?php/a \
// Security Middleware by @ginaabaikhati\
Route::middleware(['web', 'auth', 'admin'])->group(function () {' $PANEL_PATH/routes/web.php
        
        # Close the group at the end
        echo "});" >> $PANEL_PATH/routes/web.php
    fi

    # Update AppServiceProvider to register security
    cat > $PANEL_PATH/app/Providers/AppServiceProvider.php << 'EOF'
<?php

namespace Pterodactyl\Providers;

use Illuminate\Support\ServiceProvider;
use Pterodactyl\Http\Middleware\CheckAdminAccess;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     */
    public function boot()
    {
        // Add security message to config
        config(['app.security_message' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati']);
    }

    /**
     * Register any application services.
     */
    public function register()
    {
        // Register security middleware
        $this->app['router']->aliasMiddleware('admin.security', CheckAdminAccess::class);
    }
}
EOF

    # Update Kernel to include security middleware
    if [ -f "$PANEL_PATH/app/Http/Kernel.php" ]; then
        # Add middleware to Kernel
        sed -i "/protected \$routeMiddleware = \[/a \
        'admin.security' => \\\Pterodactyl\\Http\\Middleware\\CheckAdminAccess::class," $PANEL_PATH/app/Http/Kernel.php
    fi

    # Clear cache
    cd $PANEL_PATH
    php artisan cache:clear
    php artisan view:clear
    
    echo -e "${GREEN}Security panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Hanya user dengan ID 1 yang memiliki akses penuh.${NC}"
}

# Function to change error message
change_error_message() {
    echo -e "${YELLOW}Mengubah pesan error...${NC}"
    read -p "Masukkan pesan error baru: " new_message
    
    if [ -z "$new_message" ]; then
        echo -e "${RED}Pesan tidak boleh kosong!${NC}"
        return 1
    fi
    
    ERROR_MSG="$new_message"
    
    # Update security message in middleware
    if [ -f "$PANEL_PATH/app/Http/Middleware/CheckAdminAccess.php" ]; then
        sed -i "s/'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'/'$ERROR_MSG'/g" $PANEL_PATH/app/Http/Middleware/CheckAdminAccess.php
    fi
    
    # Update security message in SecurityController
    if [ -f "$PANEL_PATH/app/Http/Controllers/SecurityController.php" ]; then
        sed -i "s/'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'/'$ERROR_MSG'/g" $PANEL_PATH/app/Http/Controllers/SecurityController.php
    fi
    
    # Clear cache
    cd $PANEL_PATH
    php artisan cache:clear
    
    echo -e "${GREEN}Pesan error berhasil diubah!${NC}"
    echo -e "${BLUE}Pesan baru: $ERROR_MSG${NC}"
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Uninstall security panel...${NC}"
    
    restore_backup
    
    # Remove custom files
    rm -f $PANEL_PATH/app/Http/Middleware/CheckAdminAccess.php
    rm -f $PANEL_PATH/app/Http/Controllers/SecurityController.php
    
    # Restore original routes if backup exists
    if [ -f "$PANEL_PATH/routes/web.php.backup" ]; then
        cp $PANEL_PATH/routes/web.php.backup $PANEL_PATH/routes/web.php
    fi
    
    # Clear cache
    cd $PANEL_PATH
    php artisan cache:clear
    php artisan view:clear
    
    echo -e "${GREEN}Security panel berhasil diuninstall!${NC}"
}

# Main menu
while true; do
    show_header
    echo -e "${GREEN}Pilih opsi:${NC}"
    echo -e "1. Install Security Panel"
    echo -e "2. Ubah Teks Error" 
    echo -e "3. Uninstall Security Panel"
    echo -e "4. Exit"
    echo -e "${YELLOW}Current error message: $ERROR_MSG${NC}"
    echo -e "${BLUE}=================================${NC}"
    read -p "Masukkan pilihan [1-4]: " choice
    
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
    
    echo
    read -p "Tekan Enter untuk melanjutkan..."
done
