#!/bin/bash

# Pterodactyl Security Protection
# By @ginaabaikhati
# Features: Anti Delete, Anti Intip, Anti Akses Server Orang Lain

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PANEL_PATH="/var/www/pterodactyl"
BACKUP_PATH="/root/pterodactyl_backup"
SECURITY_BACKUP="$BACKUP_PATH/security_backup"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Script harus dijalankan sebagai root${NC}"
   exit 1
fi

# Function to display banner
show_banner() {
    clear
    echo -e "${BLUE}"
    echo "================================================"
    echo "    Pterodactyl Security Protection Installer"
    echo "    By: @ginaabaikhati"
    echo "================================================"
    echo -e "${NC}"
}

# Function to backup original files
backup_files() {
    echo -e "${YELLOW}Membuat backup file original...${NC}"
    mkdir -p "$SECURITY_BACKUP"
    
    # Backup important files
    cp "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" "$SECURITY_BACKUP/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" "$SECURITY_BACKUP/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Controllers/Admin/NestsController.php" "$SECURITY_BACKUP/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php" "$SECURITY_BACKUP/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Controllers/Admin/ServersController.php" "$SECURITY_BACKUP/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Controllers/Admin/UsersController.php" "$SECURITY_BACKUP/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php" "$SECURITY_BACKUP/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Middleware/ClientAuthenticate.php" "$SECURITY_BACKUP/" 2>/dev/null
    cp "$PANEL_PATH/app/Exceptions/Handler.php" "$SECURITY_BACKUP/" 2>/dev/null
    
    echo -e "${GREEN}Backup selesai!${NC}"
}

# Function to restore from backup
restore_backup() {
    echo -e "${YELLOW}Memulihkan file dari backup...${NC}"
    
    if [ ! -d "$SECURITY_BACKUP" ]; then
        echo -e "${RED}Backup tidak ditemukan!${NC}"
        return 1
    fi
    
    # Restore files
    cp "$SECURITY_BACKUP/ServerController.php" "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/" 2>/dev/null
    cp "$SECURITY_BACKUP/NodesController.php" "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
    cp "$SECURITY_BACKUP/NestsController.php" "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
    cp "$SECURITY_BACKUP/LocationsController.php" "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
    cp "$SECURITY_BACKUP/ServersController.php" "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
    cp "$SECURITY_BACKUP/UsersController.php" "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
    cp "$SECURITY_BACKUP/AdminAuthenticate.php" "$PANEL_PATH/app/Http/Middleware/" 2>/dev/null
    cp "$SECURITY_BACKUP/ClientAuthenticate.php" "$PANEL_PATH/app/Http/Middleware/" 2>/dev/null
    cp "$SECURITY_BACKUP/Handler.php" "$PANEL_PATH/app/Exceptions/" 2>/dev/null
    
    echo -e "${GREEN}Restore selesai!${NC}"
}

# Function to install security protection
install_security() {
    echo -e "${YELLOW}Memulai instalasi security protection...${NC}"
    
    # Backup original files first
    backup_files
    
    # 1. Anti Delete Server & User Protection
    echo -e "${BLUE}Menginstall Anti Delete Server & User...${NC}"
    
    # Modify ServersController.php for anti delete
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/ServersController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Server;
use Prologue\Alerts\AlertsMessageBag;

class ServersController extends Controller
{
    protected $alerts;

    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    public function delete(Request $request, $id)
    {
        // Allow admin to delete servers
        if (auth()->check() && auth()->user()->root_admin) {
            // Admin can delete servers, proceed with original logic
            $server = Server::findOrFail($id);
            return parent::delete($request, $id);
        }

        // Non-admin users get error
        $this->alerts->danger('hayoloh mau ngapainnn? - by @ginaabaikhati')->flash();
        return redirect()->route('admin.servers');
    }

    public function destroy(Request $request, $id)
    {
        // Allow admin to destroy servers
        if (auth()->check() && auth()->user()->root_admin) {
            // Admin can destroy servers, proceed with original logic
            return parent::destroy($request, $id);
        }

        // Non-admin users get error
        $this->alerts->danger('hayoloh mau ngapainnn? - by @ginaabaikhati')->flash();
        return redirect()->route('admin.servers');
    }

    public function view(Request $request, $id)
    {
        // Allow admin to view all servers
        if (auth()->check() && auth()->user()->root_admin) {
            return parent::view($request, $id);
        }

        // Non-admin users get error 500
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function index()
    {
        // Allow admin to view server list
        if (auth()->check() && auth()->user()->root_admin) {
            return parent::index();
        }

        // Non-admin users get error 500
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # Modify UsersController.php for anti delete
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/UsersController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\User;
use Prologue\Alerts\AlertsMessageBag;

class UsersController extends Controller
{
    protected $alerts;

    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    public function delete(Request $request, $id)
    {
        // Allow admin to delete users
        if (auth()->check() && auth()->user()->root_admin) {
            // Admin can delete users, proceed with original logic
            return parent::delete($request, $id);
        }

        // Non-admin users get error
        $this->alerts->danger('hayoloh mau ngapainnn? - by @ginaabaikhati')->flash();
        return redirect()->route('admin.users');
    }

    public function destroy(Request $request, $id)
    {
        // Allow admin to destroy users
        if (auth()->check() && auth()->user()->root_admin) {
            // Admin can destroy users, proceed with original logic
            return parent::destroy($request, $id);
        }

        // Non-admin users get error
        $this->alerts->danger('hayoloh mau ngapainnn? - by @ginaabaikhati')->flash();
        return redirect()->route('admin.users');
    }

    public function view(Request $request, $id)
    {
        // Allow admin to view all users
        if (auth()->check() && auth()->user()->root_admin) {
            return parent::view($request, $id);
        }

        // Non-admin users get error 500
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function index()
    {
        // Allow admin to view user list
        if (auth()->check() && auth()->user()->root_admin) {
            return parent::index();
        }

        // Non-admin users get error 500
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # 2. Anti Intip Location, Nodes, Nest dengan Error 500
    echo -e "${BLUE}Menginstall Anti Intip Location, Nodes, Nest...${NC}"
    
    # Modify NodesController.php
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Node;
use Prologue\Alerts\AlertsMessageBag;

class NodesController extends Controller
{
    protected $alerts;

    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    public function view(Request $request, $id)
    {
        // Allow admin to view nodes
        if (auth()->check() && auth()->user()->root_admin) {
            return parent::view($request, $id);
        }

        // Non-admin users get error 500
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function index()
    {
        // Allow admin to view node list
        if (auth()->check() && auth()->user()->root_admin) {
            return parent::index();
        }

        // Non-admin users get error 500
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function create()
    {
        // Allow admin to create nodes
        if (auth()->check() && auth()->user()->root_admin) {
            return parent::create();
        }

        // Non-admin users get error 500
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # Modify NestsController.php
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NestsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Prologue\Alerts\AlertsMessageBag;

class NestsController extends Controller
{
    protected $alerts;

    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    public function view(Request $request, $id)
    {
        // Allow admin to view nests
        if (auth()->check() && auth()->user()->root_admin) {
            return parent::view($request, $id);
        }

        // Non-admin users get error 500
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function index()
    {
        // Allow admin to view nest list
        if (auth()->check() && auth()->user()->root_admin) {
            return parent::index();
        }

        // Non-admin users get error 500
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # Modify LocationsController.php
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Prologue\Alerts\AlertsMessageBag;

class LocationsController extends Controller
{
    protected $alerts;

    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    public function view(Request $request, $id)
    {
        // Allow admin to view locations
        if (auth()->check() && auth()->user()->root_admin) {
            return parent::view($request, $id);
        }

        // Non-admin users get error 500
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function index()
    {
        // Allow admin to view location list
        if (auth()->check() && auth()->user()->root_admin) {
            return parent::index();
        }

        // Non-admin users get error 500
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # 3. Anti Akses Server Orang Lain dengan Validasi Kepemilikan
    echo -e "${BLUE}Menginstall Anti Akses Server Orang Lain...${NC}"
    
    # Modify ServerController for client API
    cat > "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Illuminate\Http\Response;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Models\Server;
use Prologue\Alerts\AlertsMessageBag;

class ServerController extends ClientApiController
{
    protected $alerts;

    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    public function index()
    {
        // Users can see their own servers
        return parent::index();
    }

    public function view($server)
    {
        // Check if user owns the server or is admin
        if ($server->user_id !== auth()->user()->id && !auth()->user()->root_admin) {
            // Return error 500 for unauthorized access
            abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
        }

        return parent::view($server);
    }

    public function websocket($server)
    {
        // Check if user owns the server or is admin
        if ($server->user_id !== auth()->user()->id && !auth()->user()->root_admin) {
            abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
        }

        return parent::websocket($server);
    }

    public function resources($server)
    {
        // Check if user owns the server or is admin
        if ($server->user_id !== auth()->user()->id && !auth()->user()->root_admin) {
            abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
        }

        return parent::resources($server);
    }
}
EOF

    # 4. Enhanced Middleware Protection dengan Admin Access
    echo -e "${BLUE}Menginstall Enhanced Middleware Protection...${NC}"
    
    # Modify AdminAuthenticate middleware
    cat > "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminAuthenticate
{
    public function handle(Request $request, Closure $next)
    {
        if (!$request->user() || !$request->user()->root_admin) {
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
                ], 500);
            }

            abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
        }

        return $next($request);
    }
}
EOF

    # Modify ClientAuthenticate middleware
    cat > "$PANEL_PATH/app/Http/Middleware/ClientAuthenticate.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ClientAuthenticate
{
    public function handle(Request $request, Closure $next)
    {
        if (!$request->user()) {
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
                ], 401);
            }

            abort(401, 'Unauthorized');
        }

        return $next($request);
    }
}
EOF

    # 5. Custom Error Handler dengan Error 500
    echo -e "${BLUE}Menginstall Custom Error Handler...${NC}"
    
    # Modify Exception Handler
    cat > "$PANEL_PATH/app/Exceptions/Handler.php" << 'EOF'
<?php

namespace Pterodactyl\Exceptions;

use Exception;
use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Prologue\Alerts\AlertsMessageBag;

class Handler extends ExceptionHandler
{
    protected $alerts;

    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    public function render($request, Exception $exception)
    {
        // For 403 Forbidden errors - show custom message but don't break the site
        if ($exception instanceof \Illuminate\Auth\Access\AuthorizationException) {
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
                ], 500);
            }
            
            $this->alerts->danger('hayoloh mau ngapainnn? - by @ginaabaikhati')->flash();
            return redirect()->back();
        }

        // For 404 Not Found errors - don't break the site
        if ($exception instanceof \Symfony\Component\HttpKernel\Exception\NotFoundHttpException) {
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
                ], 500);
            }
            
            // Return to home instead of showing 500 error for 404
            $this->alerts->danger('hayoloh mau ngapainnn? - by @ginaabaikhati')->flash();
            return redirect()->route('index');
        }

        // For custom security violations - return 500 error
        if (strpos($exception->getMessage(), 'hayoloh mau ngapainnn?') !== false) {
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
                ], 500);
            }

            // Show error page but don't break the entire site
            return response()->view('errors.500', [
                'message' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 500);
        }

        return parent::render($request, $exception);
    }
}
EOF

    # Run panel optimizations
    echo -e "${YELLOW}Menjalankan optimasi panel...${NC}"
    cd "$PANEL_PATH" || exit 1
    php artisan config:cache
    php artisan view:cache
    php artisan route:cache

    # Set proper permissions
    chown -R www-data:www-data "$PANEL_PATH"
    chmod -R 755 "$PANEL_PATH"
    chmod -R 755 "$PANEL_PATH/storage"
    chmod -R 755 "$PANEL_PATH/bootstrap/cache"

    echo -e "${GREEN}Security protection berhasil diinstall!${NC}"
    echo -e "${YELLOW}Fiturnya:${NC}"
    echo -e "  ${GREEN}✓ Anti Delete Server & User (Admin bisa, user tidak)${NC}"
    echo -e "  ${GREEN}✓ Anti Intip Location, Nodes, Nest (Error 500 untuk non-admin)${NC}"
    echo -e "  ${GREEN}✓ Anti Akses Server Orang Lain (Error 500)${NC}"
    echo -e "  ${GREEN}✓ User bisa akses server sendiri${NC}"
    echo -e "  ${GREEN}✓ Admin bisa akses semua${NC}"
}

# Function to change error texts
change_error_texts() {
    echo -e "${YELLOW}Mengganti teks error...${NC}"
    
    # Replace all existing error messages with new one
    find "$PANEL_PATH" -name "*.php" -type f -exec sed -i 's/Ngapain sih? mau nyolong sc org? - By @ginaabaikhati/hayoloh mau ngapainnn? - by @ginaabaikhati/g' {} \;
    
    echo -e "${GREEN}Teks error berhasil diganti!${NC}"
    echo -e "${BLUE}Custom message: 'hayoloh mau ngapainnn? - by @ginaabaikhati'${NC}"
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Memulai uninstall security protection...${NC}"
    
    if [ ! -d "$SECURITY_BACKUP" ]; then
        echo -e "${RED}Backup tidak ditemukan! Tidak bisa melakukan uninstall.${NC}"
        return 1
    fi
    
    # Restore from backup
    restore_backup
    
    # Run panel optimizations
    echo -e "${YELLOW}Menjalankan optimasi panel...${NC}"
    cd "$PANEL_PATH" || exit 1
    php artisan config:clear
    php artisan view:clear
    php artisan route:clear
    php artisan cache:clear
    
    php artisan config:cache
    php artisan view:cache
    php artisan route:cache

    echo -e "${GREEN}Security protection berhasil diuninstall!${NC}"
}

# Function to check security status
check_status() {
    echo -e "${YELLOW}Memeriksa status security...${NC}"
    
    if [ -d "$SECURITY_BACKUP" ]; then
        echo -e "${GREEN}Security protection terdeteksi terinstall.${NC}"
        echo -e "${BLUE}Backup files tersedia di: $SECURITY_BACKUP${NC}"
    else
        echo -e "${RED}Security protection tidak terdeteksi.${NC}"
    fi
    
    # Check if modified files exist
    if grep -q "ginaabaikhati" "$PANEL_PATH/app/Http/Controllers/Admin/ServersController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Delete Server aktif${NC}"
    else
        echo -e "${RED}✗ Anti Delete Server tidak aktif${NC}"
    fi
    
    if grep -q "ginaabaikhati" "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Intip Nodes aktif${NC}"
    else
        echo -e "${RED}✗ Anti Intip Nodes tidak aktif${NC}"
    fi
}

# Main menu
main_menu() {
    while true; do
        show_banner
        echo -e "${GREEN}Pilih opsi:${NC}"
        echo -e "1. Install Security Panel"
        echo -e "2. Ganti Teks Error" 
        echo -e "3. Uninstall Security Panel"
        echo -e "4. Check Status Security"
        echo -e "5. Exit Security Panel"
        echo -e ""
        read -p "Masukkan pilihan [1-5]: " choice
        
        case $choice in
            1)
                install_security
                ;;
            2)
                change_error_texts
                ;;
            3)
                uninstall_security
                ;;
            4)
                check_status
                ;;
            5)
                echo -e "${GREEN}Keluar dari Security Panel.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Pilihan tidak valid!${NC}"
                ;;
        esac
        
        echo -e ""
        read -p "Tekan Enter untuk melanjutkan..."
    done
}

# Check if panel path exists
if [ ! -d "$PANEL_PATH" ]; then
    echo -e "${RED}Directory panel Pterodactyl tidak ditemukan di: $PANEL_PATH${NC}"
    echo -e "${YELLOW}Silakan edit variabel PANEL_PATH di script ini sesuai dengan path instalasi panel Anda.${NC}"
    exit 1
fi

# Start the script
main_menu
