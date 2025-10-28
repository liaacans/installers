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
    
    # 1. Anti Delete Server & User Protection
    echo -e "${BLUE}Menginstall Anti Delete Server & User...${NC}"
    
    # Modify ServersController.php for anti delete (admin panel)
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

    public function index()
    {
        // Allow admin to see server list
        return parent::index();
    }

    public function view(Request $request, $id)
    {
        // Allow admin to view server details
        return parent::view($request, $id);
    }

    public function delete(Request $request, $id)
    {
        // Block server deletion with custom error
        $this->alerts->danger('hayoloh mau ngapainnn? - by @ginaabaikhati')->flash();
        return redirect()->route('admin.servers');
    }

    public function destroy(Request $request, $id)
    {
        // Block server destruction with custom error
        $this->alerts->danger('hayoloh mau ngapainnn? - by @ginaabaikhati')->flash();
        return redirect()->route('admin.servers');
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

    public function index()
    {
        // Allow admin to see user list
        return parent::index();
    }

    public function view(Request $request, $id)
    {
        // Allow admin to view user details
        return parent::view($request, $id);
    }

    public function delete(Request $request, $id)
    {
        // Block user deletion with custom error
        $this->alerts->danger('hayoloh mau ngapainnn? - by @ginaabaikhati')->flash();
        return redirect()->route('admin.users');
    }

    public function destroy(Request $request, $id)
    {
        // Block user destruction with custom error
        $this->alerts->danger('hayoloh mau ngapainnn? - by @ginaabaikhati')->flash();
        return redirect()->route('admin.users');
    }
}
EOF

    # 2. Anti Intip Location, Nodes, Nest - TAMPILKAN ERROR 403
    echo -e "${BLUE}Menginstall Anti Intip Location, Nodes, Nest...${NC}"
    
    # Modify NodesController.php - BLOCK ACCESS
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Node;
use Prologue\Alerts\AlertsMessageBag;
use Illuminate\Http\JsonResponse;

class NodesController extends Controller
{
    protected $alerts;

    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    public function index()
    {
        // Block node listing with 403 error
        if (request()->expectsJson()) {
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }
        
        abort(403, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function view(Request $request, $id)
    {
        // Block node viewing with 403 error
        if (request()->expectsJson()) {
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }
        
        abort(403, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function create()
    {
        // Block node creation page
        abort(403, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # Modify NestsController.php - BLOCK ACCESS
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NestsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Prologue\Alerts\AlertsMessageBag;
use Illuminate\Http\JsonResponse;

class NestsController extends Controller
{
    protected $alerts;

    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    public function index()
    {
        // Block nest listing with 403 error
        if (request()->expectsJson()) {
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }
        
        abort(403, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function view(Request $request, $id)
    {
        // Block nest viewing with 403 error
        if (request()->expectsJson()) {
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }
        
        abort(403, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # Modify LocationsController.php - BLOCK ACCESS
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Prologue\Alerts\AlertsMessageBag;
use Illuminate\Http\JsonResponse;

class LocationsController extends Controller
{
    protected $alerts;

    public function __construct(AlertsMessageBag $alerts)
    {
        $this->alerts = $alerts;
    }

    public function index()
    {
        // Block location listing with 403 error
        if (request()->expectsJson()) {
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }
        
        abort(403, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function view(Request $request, $id)
    {
        // Block location viewing with 403 error
        if (request()->expectsJson()) {
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }
        
        abort(403, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # 3. Anti Akses Server Orang Lain - Protection untuk User Client
    echo -e "${BLUE}Menginstall Anti Akses Server Orang Lain...${NC}"
    
    # Modify ServerController for client API - ALLOW OWN SERVER, BLOCK OTHERS
    cat > "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Illuminate\Http\Response;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Models\Server;
use Illuminate\Http\JsonResponse;

class ServerController extends ClientApiController
{
    public function index()
    {
        // Allow user to see their own servers
        return parent::index();
    }

    public function view(Server $server)
    {
        // Check if user owns the server or is admin
        if ($server->user_id !== $this->request->user()->id && !$this->request->user()->root_admin) {
            // Block access to other people's servers with 403 error
            return new JsonResponse([
                'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 403);
        }

        // Allow access to own server or if admin
        return parent::view($server);
    }

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

    # 4. Enhanced Middleware Protection for Server Access
    echo -e "${BLUE}Menginstall Enhanced Middleware Protection...${NC}"
    
    # Modify AuthenticateServerAccess middleware
    mkdir -p "$PANEL_PATH/app/Http/Middleware/Api/Client/Server"
    cat > "$PANEL_PATH/app/Http/Middleware/Api/Client/Server/AuthenticateServerAccess.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware\Api\Client\Server;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Pterodactyl\Models\Server;

class AuthenticateServerAccess
{
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

    # 5. Custom Error Handler for 403 Errors
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
use Symfony\Component\HttpKernel\Exception\HttpException;
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
        // Handle 403 Forbidden errors with custom message
        if ($exception instanceof \Illuminate\Auth\Access\AuthorizationException || 
            $exception instanceof \Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException) {
            
            if ($request->expectsJson()) {
                return new JsonResponse([
                    'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
                ], 403);
            }
            
            // For web requests, show error page but don't crash the site
            return response()->view('errors.403', [
                'message' => 'hayoloh mau ngapainnn? - by @ginaabaikhati',
                'exception' => $exception
            ], 403);
        }

        // For 404 Not Found errors
        if ($exception instanceof \Symfony\Component\HttpKernel\Exception\NotFoundHttpException) {
            if ($request->expectsJson()) {
                return new JsonResponse([
                    'error' => 'Resource tidak ditemukan'
                ], 404);
            }
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
    <title>403 Forbidden</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            color: white;
        }
        .error-container {
            text-align: center;
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 {
            font-size: 48px;
            margin-bottom: 20px;
        }
        p {
            font-size: 18px;
            margin-bottom: 10px;
        }
        .signature {
            margin-top: 20px;
            font-style: italic;
            color: #ffeb3b;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <h1>403</h1>
        <p>Forbidden</p>
        <p>{{ $message ?? 'hayoloh mau ngapainnn?' }}</p>
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
    echo -e "✓ Anti Akses Server Orang Lain" 
    echo -e "✓ Custom Error Message"
    echo -e "✓ Protection untuk Admin & User"
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
    
    # Check Anti Delete
    if grep -q "hayoloh mau ngapainnn?" "$PANEL_PATH/app/Http/Controllers/Admin/ServersController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Delete Server aktif${NC}"
    else
        echo -e "${RED}✗ Anti Delete Server tidak aktif${NC}"
    fi
    
    # Check Anti Intip Nodes
    if grep -q "hayoloh mau ngapainnn?" "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Intip Nodes aktif${NC}"
    else
        echo -e "${RED}✗ Anti Intip Nodes tidak aktif${NC}"
    fi
    
    # Check Anti Access Server
    if grep -q "hayoloh mau ngapainnn?" "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Akses Server Orang Lain aktif${NC}"
    else
        echo -e "${RED}✗ Anti Akses Server Orang Lain tidak aktif${NC}"
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
