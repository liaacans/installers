#!/bin/bash

# Pterodactyl Security Protection
# By @ginaabaikhati
# Features: Anti Delete, Anti Intip, Anti Akses Server Orang Lain

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PANEL_PATH="/var/www/pterodactyl"
BACKUP_PATH="/root/pterodactyl_backup"
SECURITY_BACKUP="$BACKUP_PATH/security_backup_$(date +%Y%m%d_%H%M%S)"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Script harus dijalankan sebagai root${NC}"
   exit 1
fi

# Function to display banner
show_banner() {
    clear
    echo -e "${PURPLE}"
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
    local files=(
        "app/Http/Controllers/Api/Client/Servers/ServerController.php"
        "app/Http/Controllers/Admin/NodesController.php"
        "app/Http/Controllers/Admin/NestsController.php"
        "app/Http/Controllers/Admin/LocationsController.php"
        "app/Http/Controllers/Admin/ServersController.php"
        "app/Http/Controllers/Admin/UsersController.php"
        "app/Http/Middleware/AdminAuthenticate.php"
        "app/Http/Middleware/ClientAuthenticate.php"
        "app/Exceptions/Handler.php"
        "app/Http/Middleware/Api/Client/Server/AuthenticateServerAccess.php"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$PANEL_PATH/$file" ]; then
            cp "$PANEL_PATH/$file" "$SECURITY_BACKUP/" 2>/dev/null
            echo -e "${GREEN}✓ Backup $file${NC}"
        else
            echo -e "${RED}✗ File $file tidak ditemukan${NC}"
        fi
    done
    
    echo -e "${GREEN}Backup selesai! File disimpan di: $SECURITY_BACKUP${NC}"
}

# Function to restore from backup
restore_backup() {
    echo -e "${YELLOW}Memulihkan file dari backup...${NC}"
    
    local backup_dir="$1"
    
    if [ ! -d "$backup_dir" ]; then
        echo -e "${RED}Backup directory tidak ditemukan!${NC}"
        echo -e "${YELLOW}Available backups:${NC}"
        find /root/pterodactyl_backup -name "security_backup_*" -type d 2>/dev/null
        return 1
    fi
    
    # Restore files
    local files=(
        "ServerController.php"
        "NodesController.php" 
        "NestsController.php"
        "LocationsController.php"
        "ServersController.php"
        "UsersController.php"
        "AdminAuthenticate.php"
        "ClientAuthenticate.php"
        "Handler.php"
        "AuthenticateServerAccess.php"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$backup_dir/$file" ]; then
            # Find the original location
            case $file in
                "ServerController.php")
                    cp "$backup_dir/$file" "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/" 2>/dev/null
                    ;;
                "AuthenticateServerAccess.php")
                    cp "$backup_dir/$file" "$PANEL_PATH/app/Http/Middleware/Api/Client/Server/" 2>/dev/null
                    ;;
                *)
                    cp "$backup_dir/$file" "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
                    ;;
            esac
            echo -e "${GREEN}✓ Restore $file${NC}"
        fi
    done
    
    echo -e "${GREEN}Restore selesai!${NC}"
}

# Function to install security protection
install_security() {
    echo -e "${YELLOW}Memulai instalasi security protection...${NC}"
    
    # Backup original files first
    backup_files
    
    # 1. Anti Delete Server & User Protection - FIXED UNTUK TIDAK ERROR 500
    echo -e "${BLUE}Menginstall Anti Delete Server & User...${NC}"
    
    # Modify ServersController.php for anti delete - FIXED COMPATIBILITY
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/ServersController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Server;
use Prologue\Alerts\AlertsMessageBag;

class ServersController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    protected $alerts;

    /**
     * ServersController constructor.
     */
    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    /**
     * Handle request to delete a server.
     */
    public function delete(Request $request, $id)
    {
        // Block server deletion with custom error
        $this->alerts->danger('hayoloh mau ngapainnn? - by @ginaabaikhati')->flash();
        return redirect()->route('admin.servers');
    }

    /**
     * Handle request to destroy a server.
     */
    public function destroy(Request $request, $id)
    {
        // Block server destruction with custom error
        $this->alerts->danger('hayoloh mau ngapainnn? - by @ginaabaikhati')->flash();
        return redirect()->route('admin.servers');
    }
}
EOF

    # Modify UsersController.php for anti delete - FIXED COMPATIBILITY
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/UsersController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\User;
use Prologue\Alerts\AlertsMessageBag;

class UsersController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    protected $alerts;

    /**
     * UsersController constructor.
     */
    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    /**
     * Handle request to delete a user.
     */
    public function delete(Request $request, $id)
    {
        // Block user deletion with custom error
        $this->alerts->danger('hayoloh mau ngapainnn? - by @ginaabaikhati')->flash();
        return redirect()->route('admin.users');
    }

    /**
     * Handle request to destroy a user.
     */
    public function destroy(Request $request, $id)
    {
        // Block user destruction with custom error
        $this->alerts->danger('hayoloh mau ngapainnn? - by @ginaabaikhati')->flash();
        return redirect()->route('admin.users');
    }
}
EOF

    # 2. Anti Intip Location, Nodes, Nest - FIXED UNTUK TIDAK ERROR 500
    echo -e "${BLUE}Menginstall Anti Intip Location, Nodes, Nest...${NC}"
    
    # Modify NodesController.php - FIXED COMPATIBILITY
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Node;
use Prologue\Alerts\AlertsMessageBag;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class NodesController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    protected $alerts;

    /**
     * NodesController constructor.
     */
    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    /**
     * Return listing of all nodes.
     */
    public function index(Request $request)
    {
        // Block node listing with 403 error
        if ($request->expectsJson()) {
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }
        
        throw new AccessDeniedHttpException('hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    /**
     * Return a single node.
     */
    public function view(Request $request, $id)
    {
        // Block node viewing with 403 error
        if ($request->expectsJson()) {
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }
        
        throw new AccessDeniedHttpException('hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # Modify NestsController.php - FIXED COMPATIBILITY
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NestsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Nest;
use Prologue\Alerts\AlertsMessageBag;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class NestsController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    protected $alerts;

    /**
     * NestsController constructor.
     */
    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    /**
     * Return listing of all nests.
     */
    public function index(Request $request)
    {
        // Block nest listing with 403 error
        if ($request->expectsJson()) {
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }
        
        throw new AccessDeniedHttpException('hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    /**
     * Return a single nest.
     */
    public function view(Request $request, $id)
    {
        // Block nest viewing with 403 error
        if ($request->expectsJson()) {
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }
        
        throw new AccessDeniedHttpException('hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # Modify LocationsController.php - FIXED COMPATIBILITY
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Location;
use Prologue\Alerts\AlertsMessageBag;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class LocationsController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    protected $alerts;

    /**
     * LocationsController constructor.
     */
    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    /**
     * Return listing of all locations.
     */
    public function index(Request $request)
    {
        // Block location listing with 403 error
        if ($request->expectsJson()) {
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }
        
        throw new AccessDeniedHttpException('hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    /**
     * Return a single location.
     */
    public function view(Request $request, $id)
    {
        // Block location viewing with 403 error
        if ($request->expectsJson()) {
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }
        
        throw new AccessDeniedHttpException('hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # 3. Anti Akses Server Orang Lain - FIXED UNTUK SERVER SENDIRI TIDAK ERROR 500
    echo -e "${BLUE}Menginstall Anti Akses Server Orang Lain...${NC}"
    
    # Backup original ServerController first
    cp "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" "$SECURITY_BACKUP/ServerController.original.php"
    
    # Modify ServerController for client API - MINIMAL MODIFICATION APPROACH
    cat > "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Illuminate\Http\JsonResponse;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Models\Server;
use Pterodactyl\Transformers\Api\Client\ServerTransformer;

class ServerController extends ClientApiController
{
    /**
     * Returns an individual server resource.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return array
     */
    public function view(Server $server)
    {
        // Check if user owns the server or is admin
        if ($server->user_id !== $this->request->user()->id && !$this->request->user()->root_admin) {
            // Block access to other people's servers with 403 error
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }

        // Allow access to own server or if admin - call parent method
        return parent::view($server);
    }

    /**
     * Returns websocket connection details for a server.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\Http\JsonResponse
     */
    public function websocket(Server $server)
    {
        // Check if user owns the server or is admin
        if ($server->user_id !== $this->request->user()->id && !$this->request->user()->root_admin) {
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }

        return parent::websocket($server);
    }

    /**
     * Returns resource usage for a server.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\Http\JsonResponse
     */
    public function resources(Server $server)
    {
        // Check if user owns the server or is admin
        if ($server->user_id !== $this->request->user()->id && !$this->request->user()->root_admin) {
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }

        return parent::resources($server);
    }
}
EOF

    # 4. Enhanced Middleware Protection for Server Access - FIXED
    echo -e "${BLUE}Menginstall Enhanced Middleware Protection...${NC}"
    
    # Create directory if not exists
    mkdir -p "$PANEL_PATH/app/Http/Middleware/Api/Client/Server"
    
    # Modify AuthenticateServerAccess middleware - SIMPLE VERSION
    cat > "$PANEL_PATH/app/Http/Middleware/Api/Client/Server/AuthenticateServerAccess.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware\Api\Client\Server;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Pterodactyl\Models\Server;

class AuthenticateServerAccess
{
    /**
     * Handle an incoming request.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Closure $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        $server = $request->route()->parameter('server');

        if ($server instanceof Server) {
            $user = $request->user();
            
            // Check if user owns the server or is admin
            if ($server->user_id !== $user->id && !$user->root_admin) {
                // Block access with custom error message
                if ($request->expectsJson()) {
                    return response()->json([
                        'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
                    ], 403);
                }
                
                throw new AccessDeniedHttpException('hayoloh mau ngapainnn? - by @ginaabaikhati');
            }
        }

        return $next($request);
    }
}
EOF

    # 5. Custom Error Handler for 403 Errors - FIXED
    echo -e "${BLUE}Menginstall Custom Error Handler...${NC}"
    
    # Modify Exception Handler - SIMPLE VERSION
    cat > "$PANEL_PATH/app/Exceptions/Handler.php" << 'EOF'
<?php

namespace Pterodactyl\Exceptions;

use Exception;
use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class Handler extends ExceptionHandler
{
    /**
     * Render an exception into an HTTP response.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Exception $exception
     * @return \Illuminate\Http\Response|\Illuminate\Http\JsonResponse
     */
    public function render($request, Exception $exception)
    {
        // Handle 403 Forbidden errors with custom message
        if ($exception instanceof AccessDeniedHttpException) {
            $message = $exception->getMessage() ?: 'hayoloh mau ngapainnn? - by @ginaabaikhati';
            
            if ($request->expectsJson()) {
                return new JsonResponse([
                    'error' => $message
                ], 403);
            }
            
            // For web requests, show error page but don't crash the site
            return response()->view('errors.403', [
                'message' => $message
            ], 403);
        }

        return parent::render($request, $exception);
    }
}
EOF

    # Create custom 403 error view if not exists
    mkdir -p "$PANEL_PATH/resources/views/errors"
    cat > "$PANEL_PATH/resources/views/errors/403.blade.php" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>403 Forbidden - Pterodactyl</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            color: #333;
        }
        
        .error-container {
            background: rgba(255, 255, 255, 0.95);
            padding: 3rem;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            text-align: center;
            max-width: 500px;
            width: 90%;
            backdrop-filter: blur(10px);
        }
        
        .error-code {
            font-size: 4rem;
            font-weight: bold;
            color: #e74c3c;
            margin-bottom: 1rem;
        }
        
        .error-title {
            font-size: 1.5rem;
            margin-bottom: 1rem;
            color: #2c3e50;
        }
        
        .error-message {
            font-size: 1.1rem;
            margin-bottom: 2rem;
            color: #7f8c8d;
            line-height: 1.6;
        }
        
        .signature {
            margin-top: 2rem;
            padding-top: 1rem;
            border-top: 1px solid #ecf0f1;
            font-style: italic;
            color: #95a5a6;
        }
        
        .btn {
            display: inline-block;
            padding: 12px 30px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 25px;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            font-size: 1rem;
        }
        
        .btn:hover {
            background: #2980b9;
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">403</div>
        <div class="error-title">Forbidden</div>
        <div class="error-message">
            {{ $message ?? 'hayoloh mau ngapainnn?' }}
        </div>
        <a href="javascript:history.back()" class="btn">Go Back</a>
        <div class="signature">- by @ginaabaikhati</div>
    </div>
</body>
</html>
EOF

    # Run panel optimizations
    echo -e "${YELLOW}Menjalankan optimasi panel...${NC}"
    cd "$PANEL_PATH" || exit 1
    
    # Clear caches first
    php artisan config:clear
    php artisan view:clear
    php artisan route:clear
    php artisan cache:clear
    
    # Recache
    php artisan config:cache
    php artisan view:cache
    php artisan route:cache

    # Set proper permissions
    chown -R www-data:www-data "$PANEL_PATH"
    chmod -R 755 "$PANEL_PATH"
    chmod -R 755 "$PANEL_PATH/storage"
    chmod -R 755 "$PANEL_PATH/bootstrap/cache"

    echo -e "${GREEN}Security protection berhasil diinstall!${NC}"
    echo -e "${CYAN}Fitur yang aktif:${NC}"
    echo -e "✓ Anti Delete Server & User"
    echo -e "✓ Anti Intip Nodes, Nests, Locations (Error 403)"
    echo -e "✓ Anti Akses Server Orang Lain (Server sendiri bisa diakses)"
    echo -e "✓ Custom Error Message"
    echo -e "✓ Protection untuk Admin & User"
    
    echo -e "${YELLOW}Pastikan untuk melakukan testing:${NC}"
    echo -e "1. Akses server sendiri (harus normal)"
    echo -e "2. Coba akses server orang lain (harus error 403)"
    echo -e "3. Coba delete server (harus error dengan alert)"
}

# Function to change error texts
change_error_texts() {
    echo -e "${YELLOW}Mengganti teks error...${NC}"
    
    # Update all files with new error message
    local files=(
        "app/Http/Controllers/Admin/ServersController.php"
        "app/Http/Controllers/Admin/UsersController.php"
        "app/Http/Controllers/Admin/NodesController.php"
        "app/Http/Controllers/Admin/NestsController.php"
        "app/Http/Controllers/Admin/LocationsController.php"
        "app/Http/Controllers/Api/Client/Servers/ServerController.php"
        "app/Http/Middleware/Api/Client/Server/AuthenticateServerAccess.php"
        "app/Exceptions/Handler.php"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$PANEL_PATH/$file" ]; then
            sed -i 's/hayoloh mau ngapainnn? - by @ginaabaikhati/hayoloh mau ngapainnn? - by @ginaabaikhati/g' "$PANEL_PATH/$file"
            echo -e "${GREEN}✓ Updated $file${NC}"
        fi
    done
    
    # Update error view
    if [ -f "$PANEL_PATH/resources/views/errors/403.blade.php" ]; then
        sed -i 's/hayoloh mau ngapainnn? - by @ginaabaikhati/hayoloh mau ngapainnn? - by @ginaabaikhati/g' "$PANEL_PATH/resources/views/errors/403.blade.php"
        echo -e "${GREEN}✓ Updated error view${NC}"
    fi
    
    echo -e "${GREEN}Teks error berhasil diganti!${NC}"
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Memulai uninstall security protection...${NC}"
    
    echo -e "${CYAN}Available backups:${NC}"
    local backups=($(find /root/pterodactyl_backup -name "security_backup_*" -type d 2>/dev/null | sort -r))
    
    if [ ${#backups[@]} -eq 0 ]; then
        echo -e "${RED}Tidak ada backup yang ditemukan!${NC}"
        return 1
    fi
    
    for i in "${!backups[@]}"; do
        echo -e "${YELLOW}$((i+1)). ${backups[$i]}${NC}"
    done
    
    read -p "Pilih backup untuk restore [1-${#backups[@]}]: " backup_choice
    local selected_backup="${backups[$((backup_choice-1))]}"
    
    if [ -z "$selected_backup" ]; then
        echo -e "${RED}Pilihan backup tidak valid!${NC}"
        return 1
    fi
    
    # Restore from selected backup
    restore_backup "$selected_backup"
    
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
    
    local backups=($(find /root/pterodactyl_backup -name "security_backup_*" -type d 2>/dev/null))
    if [ ${#backups[@]} -gt 0 ]; then
        echo -e "${GREEN}✓ Security protection terdeteksi terinstall${NC}"
        echo -e "${CYAN}Backups tersedia:${NC}"
        for backup in "${backups[@]}"; do
            echo -e "  - $backup"
        done
    else
        echo -e "${RED}✗ Security protection tidak terdeteksi${NC}"
    fi
    
    # Check security features
    echo -e "${CYAN}Status Fitur Security:${NC}"
    
    local security_active=true
    
    # Check Anti Delete
    if grep -q "hayoloh mau ngapainnn?" "$PANEL_PATH/app/Http/Controllers/Admin/ServersController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Delete Server aktif${NC}"
    else
        echo -e "${RED}✗ Anti Delete Server tidak aktif${NC}"
        security_active=false
    fi
    
    # Check Anti Intip Nodes
    if grep -q "hayoloh mau ngapainnn?" "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Intip Nodes aktif${NC}"
    else
        echo -e "${RED}✗ Anti Intip Nodes tidak aktif${NC}"
        security_active=false
    fi
    
    # Check Anti Access Server
    if grep -q "hayoloh mau ngapainnn?" "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Akses Server Orang Lain aktif${NC}"
    else
        echo -e "${RED}✗ Anti Akses Server Orang Lain tidak aktif${NC}"
        security_active=false
    fi
    
    if [ "$security_active" = true ]; then
        echo -e "${GREEN}✓ Semua fitur security aktif dan berjalan normal${NC}"
    else
        echo -e "${YELLOW}⚠ Beberapa fitur security tidak aktif${NC}"
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
