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
SECURITY_BACKUP="$BACKUP_PATH/security_backup"
CUSTOM_ERROR_500="hayoloh mau ngapainnn? - by @ginaabaikhati"
CUSTOM_ERROR_403="Ngapain sih? mau nyolong sc org? - By @ginaabaikhati"

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
        "app/Providers/AppServiceProvider.php"
        "routes/api.php"
        "routes/web.php"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$PANEL_PATH/$file" ]; then
            cp "$PANEL_PATH/$file" "$SECURITY_BACKUP/" 2>/dev/null
            echo -e "${GREEN}✓ Backup $file${NC}"
        else
            echo -e "${RED}✗ File $file tidak ditemukan${NC}"
        fi
    done
    
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
        "AppServiceProvider.php"
        "api.php"
        "web.php"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$SECURITY_BACKUP/$file" ]; then
            # Determine destination based on file type
            case $file in
                "ServerController.php")
                    cp "$SECURITY_BACKUP/$file" "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/" 2>/dev/null
                    ;;
                "NodesController.php"|"NestsController.php"|"LocationsController.php"|"ServersController.php"|"UsersController.php")
                    cp "$SECURITY_BACKUP/$file" "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
                    ;;
                "AdminAuthenticate.php"|"ClientAuthenticate.php")
                    cp "$SECURITY_BACKUP/$file" "$PANEL_PATH/app/Http/Middleware/" 2>/dev/null
                    ;;
                "Handler.php")
                    cp "$SECURITY_BACKUP/$file" "$PANEL_PATH/app/Exceptions/" 2>/dev/null
                    ;;
                "AppServiceProvider.php")
                    cp "$SECURITY_BACKUP/$file" "$PANEL_PATH/app/Providers/" 2>/dev/null
                    ;;
                "api.php")
                    cp "$SECURITY_BACKUP/$file" "$PANEL_PATH/routes/" 2>/dev/null
                    ;;
                "web.php")
                    cp "$SECURITY_BACKUP/$file" "$PANEL_PATH/routes/" 2>/dev/null
                    ;;
            esac
            echo -e "${GREEN}✓ Restore $file${NC}"
        fi
    done
    
    echo -e "${GREEN}Restore selesai!${NC}"
}

# Function to create custom error response
create_error_response() {
    local error_code=$1
    local message=$2
    
    cat << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Error $error_code</title>
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
            background: rgba(0,0,0,0.7);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        .error-code {
            font-size: 72px;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .error-message {
            font-size: 24px;
            margin-bottom: 30px;
        }
        .signature {
            font-size: 14px;
            opacity: 0.8;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">$error_code</div>
        <div class="error-message">$message</div>
        <div class="signature">Protected by @ginaabaikhati</div>
    </div>
</body>
</html>
EOF
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

    public function index()
    {
        // Allow admin to see servers list
        return view('admin.servers.index', [
            'servers' => Server::with('user', 'node', 'nest')->get()
        ]);
    }

    public function view(Request $request, $id)
    {
        try {
            $server = Server::with('user', 'node', 'nest')->findOrFail($id);
            return view('admin.servers.view', ['server' => $server]);
        } catch (\Exception $e) {
            abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
        }
    }

    public function delete(Request $request, $id)
    {
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function destroy(Request $request, $id)
    {
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

    public function index()
    {
        // Allow admin to see users list
        return view('admin.users.index', [
            'users' => User::all()
        ]);
    }

    public function view(Request $request, $id)
    {
        try {
            $user = User::findOrFail($id);
            return view('admin.users.view', ['user' => $user]);
        } catch (\Exception $e) {
            abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
        }
    }

    public function delete(Request $request, $id)
    {
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function destroy(Request $request, $id)
    {
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

    public function index()
    {
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function view(Request $request, $id)
    {
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function create()
    {
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function edit($id)
    {
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

    public function index()
    {
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function view(Request $request, $id)
    {
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

    public function index()
    {
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function view(Request $request, $id)
    {
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }

    public function create()
    {
        abort(500, 'hayoloh mau ngapainnn? - by @ginaabaikhati');
    }
}
EOF

    # 3. Anti Akses Server Orang Lain dengan Error 500
    echo -e "${BLUE}Menginstall Anti Akses Server Orang Lain...${NC}"
    
    # Modify ServerController for client API - Allow access only to own servers
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
        // User can only see their own servers
        $servers = Server::where('user_id', auth()->user()->id)->get();
        
        return response()->json([
            'data' => $servers
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
}
EOF

    # 4. Enhanced Middleware Protection
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
                    'error' => 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'
                ], 403);
            }

            // Return custom error page for web requests
            return response()->view('errors.custom-403', [], 403);
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
use Symfony\Component\HttpKernel\Exception\HttpException;

class Handler extends ExceptionHandler
{
    public function render($request, Exception $exception)
    {
        // Handle 500 errors
        if ($exception instanceof \Symfony\Component\HttpKernel\Exception\HttpException && 
            $exception->getStatusCode() === 500) {
            
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
                ], 500);
            }
            
            return response()->view('errors.500', [
                'message' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'
            ], 500);
        }

        // Handle 403 errors
        if ($exception instanceof \Illuminate\Auth\Access\AuthorizationException) {
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'
                ], 403);
            }
            
            return response()->view('errors.403', [
                'message' => 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'
            ], 403);
        }

        // Handle 404 errors
        if ($exception instanceof \Symfony\Component\HttpKernel\Exception\NotFoundHttpException) {
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'
                ], 404);
            }
            
            return response()->view('errors.404', [
                'message' => 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'
            ], 404);
        }

        return parent::render($request, $exception);
    }
}
EOF

    # 6. Create custom error views
    echo -e "${BLUE}Membuat custom error views...${NC}"
    
    # Create custom error directory if not exists
    mkdir -p "$PANEL_PATH/resources/views/errors"
    
    # Create custom 500 error view
    create_error_response "500" "hayoloh mau ngapainnn? - by @ginaabaikhati" > "$PANEL_PATH/resources/views/errors/500.blade.php"
    
    # Create custom 403 error view
    create_error_response "403" "Ngapain sih? mau nyolong sc org? - By @ginaabaikhati" > "$PANEL_PATH/resources/views/errors/403.blade.php"
    
    # Create custom 404 error view  
    create_error_response "404" "Ngapain sih? mau nyolong sc org? - By @ginaabaikhati" > "$PANEL_PATH/resources/views/errors/404.blade.php"

    # 7. Add custom routes protection
    echo -e "${BLUE}Menambahkan route protection...${NC}"
    
    # Backup original routes
    cp "$PANEL_PATH/routes/web.php" "$SECURITY_BACKUP/web_original.php"
    cp "$PANEL_PATH/routes/api.php" "$SECURITY_BACKUP/api_original.php"

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
    echo -e "✓ Anti Intip Location, Nodes, Nest (Error 500)"
    echo -e "✓ Anti Akses Server Orang Lain (Error 500)" 
    echo -e "✓ Custom Error Messages"
    echo -e "✓ User bisa akses server sendiri"
    echo -e "✓ Admin tetap bisa lihat list servers/users"
}

# Function to change error texts
change_error_texts() {
    echo -e "${YELLOW}Mengganti teks error...${NC}"
    
    # Update error views dengan teks baru
    create_error_response "500" "hayoloh mau ngapainnn? - by @ginaabaikhati" > "$PANEL_PATH/resources/views/errors/500.blade.php"
    create_error_response "403" "Ngapain sih? mau nyolong sc org? - By @ginaabaikhati" > "$PANEL_PATH/resources/views/errors/403.blade.php"
    create_error_response "404" "Ngapain sih? mau nyolong sc org? - By @ginaabaikhati" > "$PANEL_PATH/resources/views/errors/404.blade.php"
    
    # Update exception handler
    sed -i "s|'error' => '.*'|'error' => 'hayoloh mau ngapainnn? - by @ginaabaikhati'|g" "$PANEL_PATH/app/Exceptions/Handler.php"
    sed -i "s|'error' => '.*'|'error' => 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'|g" "$PANEL_PATH/app/Exceptions/Handler.php"
    
    echo -e "${GREEN}Teks error berhasil diganti!${NC}"
    echo -e "${BLUE}Error 500: 'hayoloh mau ngapainnn? - by @ginaabaikhati'${NC}"
    echo -e "${BLUE}Error 403/404: 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'${NC}"
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
    
    # Remove custom error views
    rm -f "$PANEL_PATH/resources/views/errors/500.blade.php"
    rm -f "$PANEL_PATH/resources/views/errors/403.blade.php" 
    rm -f "$PANEL_PATH/resources/views/errors/404.blade.php"
    
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
        echo -e "${GREEN}✓ Security protection terdeteksi terinstall${NC}"
        echo -e "${BLUE}  Backup files tersedia di: $SECURITY_BACKUP${NC}"
    else
        echo -e "${RED}✗ Security protection tidak terdeteksi${NC}"
    fi
    
    # Check specific security features
    local features=(
        "Anti Delete Server:app/Http/Controllers/Admin/ServersController.php"
        "Anti Intip Nodes:app/Http/Controllers/Admin/NodesController.php"
        "Anti Intip Nests:app/Http/Controllers/Admin/NestsController.php"
        "Anti Intip Locations:app/Http/Controllers/Admin/LocationsController.php"
        "Client Server Protection:app/Http/Controllers/Api/Client/Servers/ServerController.php"
        "Custom Error Handler:app/Exceptions/Handler.php"
    )
    
    for feature in "${features[@]}"; do
        name="${feature%%:*}"
        file="${feature##*:}"
        
        if grep -q "ginaabaikhati\|hayoloh" "$PANEL_PATH/$file" 2>/dev/null; then
            echo -e "${GREEN}✓ $name aktif${NC}"
        else
            echo -e "${RED}✗ $name tidak aktif${NC}"
        fi
    done
    
    # Check error views
    if [ -f "$PANEL_PATH/resources/views/errors/500.blade.php" ]; then
        echo -e "${GREEN}✓ Custom error views aktif${NC}"
    else
        echo -e "${RED}✗ Custom error views tidak aktif${NC}"
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
