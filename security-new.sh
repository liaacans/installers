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
    
    # 1. Anti Delete Server & User Protection (Admin masih bisa akses)
    echo -e "${BLUE}Menginstall Anti Delete Server & User...${NC}"
    
    # Modify ServersController.php for anti delete (non-admin)
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
        if ($request->user() && $request->user()->root_admin) {
            $server = Server::findOrFail($id);
            $server->delete();
            
            $this->alerts->success('Server berhasil dihapus.')->flash();
            return redirect()->route('admin.servers');
        }
        
        // Non-admin trying to delete
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function destroy(Request $request, $id)
    {
        // Allow admin to destroy servers
        if ($request->user() && $request->user()->root_admin) {
            $server = Server::findOrFail($id);
            $server->forceDelete();
            
            $this->alerts->success('Server berhasil dihapus permanen.')->flash();
            return redirect()->route('admin.servers');
        }
        
        // Non-admin trying to destroy
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function view(Request $request, $id)
    {
        // Allow admin to view servers
        if ($request->user() && $request->user()->root_admin) {
            $server = Server::findOrFail($id);
            return view('admin.servers.view', ['server' => $server]);
        }
        
        // Non-admin trying to view
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function index()
    {
        // Allow admin to view server list
        if (request()->user() && request()->user()->root_admin) {
            $servers = Server::all();
            return view('admin.servers.index', ['servers' => $servers]);
        }
        
        // Non-admin trying to access
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # Modify UsersController.php for anti delete (non-admin)
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
        if ($request->user() && $request->user()->root_admin) {
            $user = User::findOrFail($id);
            
            // Prevent admin from deleting themselves
            if ($user->id === $request->user()->id) {
                $this->alerts->danger('Tidak bisa menghapus akun sendiri.')->flash();
                return redirect()->route('admin.users');
            }
            
            $user->delete();
            $this->alerts->success('User berhasil dihapus.')->flash();
            return redirect()->route('admin.users');
        }
        
        // Non-admin trying to delete users
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function destroy(Request $request, $id)
    {
        // Allow admin to destroy users permanently
        if ($request->user() && $request->user()->root_admin) {
            $user = User::findOrFail($id);
            
            // Prevent admin from destroying themselves
            if ($user->id === $request->user()->id) {
                $this->alerts->danger('Tidak bisa menghapus akun sendiri.')->flash();
                return redirect()->route('admin.users');
            }
            
            $user->forceDelete();
            $this->alerts->success('User berhasil dihapus permanen.')->flash();
            return redirect()->route('admin.users');
        }
        
        // Non-admin trying to destroy users
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function view(Request $request, $id)
    {
        // Allow admin to view users
        if ($request->user() && $request->user()->root_admin) {
            $user = User::findOrFail($id);
            return view('admin.users.view', ['user' => $user]);
        }
        
        // Non-admin trying to view users
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function index()
    {
        // Allow admin to view user list
        if (request()->user() && request()->user()->root_admin) {
            $users = User::all();
            return view('admin.users.index', ['users' => $users]);
        }
        
        // Non-admin trying to access user list
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # 2. Anti Intip Location, Nodes, Nest (Error 500 untuk non-admin)
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
        if ($request->user() && $request->user()->root_admin) {
            $node = Node::findOrFail($id);
            return view('admin.nodes.view', ['node' => $node]);
        }
        
        // Non-admin trying to view nodes
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function index()
    {
        // Allow admin to view node list
        if (request()->user() && request()->user()->root_admin) {
            $nodes = Node::all();
            return view('admin.nodes.index', ['nodes' => $nodes]);
        }
        
        // Non-admin trying to access node list
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function create()
    {
        // Allow admin to create nodes
        if (request()->user() && request()->user()->root_admin) {
            return view('admin.nodes.create');
        }
        
        // Non-admin trying to create nodes
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
use Pterodactyl\Models\Nest;
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
        if ($request->user() && $request->user()->root_admin) {
            $nest = Nest::findOrFail($id);
            return view('admin.nests.view', ['nest' => $nest]);
        }
        
        // Non-admin trying to view nests
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function index()
    {
        // Allow admin to view nest list
        if (request()->user() && request()->user()->root_admin) {
            $nests = Nest::all();
            return view('admin.nests.index', ['nests' => $nests]);
        }
        
        // Non-admin trying to access nest list
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
use Pterodactyl\Models\Location;
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
        if ($request->user() && $request->user()->root_admin) {
            $location = Location::findOrFail($id);
            return view('admin.locations.view', ['location' => $location]);
        }
        
        // Non-admin trying to view locations
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function index()
    {
        // Allow admin to view location list
        if (request()->user() && request()->user()->root_admin) {
            $locations = Location::all();
            return view('admin.locations.index', ['locations' => $locations]);
        }
        
        // Non-admin trying to access location list
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function create()
    {
        // Allow admin to create locations
        if (request()->user() && request()->user()->root_admin) {
            return view('admin.locations.create');
        }
        
        // Non-admin trying to create locations
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # 3. Anti Akses Server Orang Lain (Client API Protection)
    echo -e "${BLUE}Menginstall Anti Akses Server Orang Lain...${NC}"
    
    # Modify ServerController for client API
    cat > "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Illuminate\Http\Response;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Models\Server;
use Pterodactyl\Repositories\Wings\DaemonServerRepository;

class ServerController extends ClientApiController
{
    protected $daemonServerRepository;

    public function __construct(DaemonServerRepository $daemonServerRepository)
    {
        $this->daemonServerRepository = $daemonServerRepository;
    }

    public function index()
    {
        // User can only see their own servers
        $user = auth()->user();
        $servers = Server::where('user_id', $user->id)->get();
        
        return response()->json([
            'data' => $servers->map(function ($server) {
                return [
                    'id' => $server->id,
                    'name' => $server->name,
                    'status' => $server->status,
                ];
            })
        ]);
    }

    public function view($server)
    {
        // Check if user owns the server
        if ($server->user_id !== auth()->user()->id) {
            abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
        }

        return parent::view($server);
    }

    public function websocket($server)
    {
        // Check if user owns the server
        if ($server->user_id !== auth()->user()->id) {
            abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
        }

        return parent::websocket($server);
    }

    public function resources($server)
    {
        // Check if user owns the server
        if ($server->user_id !== auth()->user()->id) {
            abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
        }

        return parent::resources($server);
    }

    public function command($server)
    {
        // Check if user owns the server
        if ($server->user_id !== auth()->user()->id) {
            abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
        }

        return parent::command($server);
    }
}
EOF

    # 4. Enhanced Middleware Protection dengan Error 500
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
            // Non-admin trying to access admin area
            if ($request->expectsJson()) {
                abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
            }

            abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
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
use Symfony\Component\HttpKernel\Exception\HttpException;

class Handler extends ExceptionHandler
{
    public function render($request, Exception $exception)
    {
        // Custom 500 error for security violations
        if ($exception instanceof \Illuminate\Auth\Access\AuthorizationException) {
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
                ], 500);
            }
            
            // Return 500 error page with custom message
            return response()->view('errors.500', [
                'message' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 500);
        }

        // For 404 errors, show normal 404 page but with custom message if unauthorized
        if ($exception instanceof \Symfony\Component\HttpKernel\Exception\NotFoundHttpException) {
            // Check if it's an unauthorized access attempt
            $referer = $request->header('referer');
            if (str_contains($request->url(), ['/admin/', '/api/']) && !$request->user()?->root_admin) {
                if ($request->expectsJson()) {
                    return response()->json([
                        'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
                    ], 500);
                }
                return response()->view('errors.500', [
                    'message' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
                ], 500);
            }
        }

        // Handle other 403 Forbidden errors
        if ($exception instanceof HttpException && $exception->getStatusCode() === 403) {
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
                ], 500);
            }
            
            return response()->view('errors.500', [
                'message' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 500);
        }

        return parent::render($request, $exception);
    }
}
EOF

    # Create custom 500 error page if not exists
    if [ ! -f "$PANEL_PATH/resources/views/errors/500.blade.php" ]; then
        mkdir -p "$PANEL_PATH/resources/views/errors"
        cat > "$PANEL_PATH/resources/views/errors/500.blade.php" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 Internal Server Error</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f8f9fa;
            color: #333;
            text-align: center;
            padding: 50px;
        }
        .error-container {
            max-width: 600px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .error-code {
            font-size: 48px;
            font-weight: bold;
            color: #dc3545;
        }
        .error-message {
            font-size: 18px;
            margin: 20px 0;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">500</div>
        <div class="error-message">
            {{ $message ?? 'hayoloh mau ngapainnn? - by @ginaabaikhati' }}
        </div>
        <a href="{{ url('/') }}">Kembali ke Home</a>
    </div>
</body>
</html>
EOF
    fi

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
    echo -e "  ✓ Admin bisa akses semua fitur"
    echo -e "  ✓ User hanya bisa akses server sendiri"
    echo -e "  ✓ Non-admin yang intip nodes/nests/locations kena error 500"
    echo -e "  ✓ Anti akses server orang lain"
    echo -e "  ✓ Custom error message 'hayoloh mau ngapainnn? - by @ginaabaikhati'"
}

# Function to change error texts
change_error_texts() {
    echo -e "${YELLOW}Mengganti teks error...${NC}"
    
    # Update all files with new error message
    find "$PANEL_PATH" -name "*.php" -type f -exec sed -i 's/Ngapain sih? mau nyolong sc org? - By @ginaabaikhati/hayoloh mau ngapainnn? - by @ginaabaikhati/g' {} \;
    
    # Update the custom 500 error page
    if [ -f "$PANEL_PATH/resources/views/errors/500.blade.php" ]; then
        sed -i 's/Ngapain sih? mau nyolong sc org? - By @ginaabaikhati/hayoloh mau ngapainnn? - by @ginaabaikhati/g' "$PANEL_PATH/resources/views/errors/500.blade.php"
    fi
    
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
    if grep -q "hayoloh mau ngapainnn" "$PANEL_PATH/app/Http/Controllers/Admin/ServersController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Delete Server aktif${NC}"
    else
        echo -e "${RED}✗ Anti Delete Server tidak aktif${NC}"
    fi
    
    if grep -q "hayoloh mau ngapainnn" "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Intip Nodes aktif${NC}"
    else
        echo -e "${RED}✗ Anti Intip Nodes tidak aktif${NC}"
    fi

    if grep -q "hayoloh mau ngapainnn" "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Intip Locations aktif${NC}"
    else
        echo -e "${RED}✗ Anti Intip Locations tidak aktif${NC}"
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
