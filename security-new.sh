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

    public function index()
    {
        // Admin tetap bisa melihat daftar server
        return parent::index();
    }

    public function view(Request $request, $id)
    {
        // Admin tetap bisa melihat detail server
        return parent::view($request, $id);
    }

    public function delete(Request $request, $id)
    {
        // Blok delete untuk semua user termasuk admin
        abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
    }

    public function destroy(Request $request, $id)
    {
        // Blok destroy untuk semua user termasuk admin
        abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
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

    public function index()
    {
        // Admin tetap bisa melihat daftar user
        return parent::index();
    }

    public function view(Request $request, $id)
    {
        // Admin tetap bisa melihat detail user
        return parent::view($request, $id);
    }

    public function delete(Request $request, $id)
    {
        // Blok delete untuk semua user termasuk admin
        abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
    }

    public function destroy(Request $request, $id)
    {
        // Blok destroy untuk semua user termasuk admin
        abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
    }
}
EOF

    # 2. Anti Intip Location, Nodes, Nest (Error 500 untuk non-admin)
    echo -e "${BLUE}Menginstall Anti Intip Location, Nodes, Nest...${NC}"
    
    # Modify NodesController.php - Error 500 untuk semua akses
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
        // Error 500 untuk semua yang akses nodes
        abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
    }

    public function view(Request $request, $id)
    {
        // Error 500 untuk semua yang akses detail node
        abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
    }

    public function create()
    {
        // Error 500 untuk create node
        abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
    }

    public function edit($id)
    {
        // Error 500 untuk edit node
        abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
    }
}
EOF

    # Modify NestsController.php - Error 500 untuk semua akses
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
        // Error 500 untuk semua yang akses nests
        abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
    }

    public function view(Request $request, $id)
    {
        // Error 500 untuk semua yang akses detail nest
        abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
    }
}
EOF

    # Modify LocationsController.php - Error 500 untuk semua akses
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
        // Error 500 untuk semua yang akses locations
        abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
    }

    public function view(Request $request, $id)
    {
        // Error 500 untuk semua yang akses detail location
        abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
    }

    public function create()
    {
        // Error 500 untuk create location
        abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
    }

    public function edit($id)
    {
        // Error 500 untuk edit location
        abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
    }
}
EOF

    # 3. Anti Akses Server Orang Lain (Error 500 untuk akses server bukan miliknya)
    echo -e "${BLUE}Menginstall Anti Akses Server Orang Lain...${NC}"
    
    # Modify ServerController for client API - Error 500 untuk akses server orang lain
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
        // User hanya bisa melihat server miliknya sendiri
        $servers = Server::where('user_id', auth()->user()->id)->get();
        
        return response()->json([
            'data' => $servers
        ]);
    }

    public function view($server)
    {
        // Check if user owns the server
        if ($server->user_id !== auth()->user()->id) {
            // Error 500 jika mencoba akses server orang lain
            abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return parent::view($server);
    }

    public function websocket($server)
    {
        // Check if user owns the server
        if ($server->user_id !== auth()->user()->id) {
            // Error 500 jika mencoba akses websocket server orang lain
            abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return parent::websocket($server);
    }

    public function resources($server)
    {
        // Check if user owns the server
        if ($server->user_id !== auth()->user()->id) {
            // Error 500 jika mencoba akses resources server orang lain
            abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return parent::resources($server);
    }
}
EOF

    # 4. Enhanced Middleware Protection dengan akses admin
    echo -e "${BLUE}Menginstall Enhanced Middleware Protection...${NC}"
    
    # Modify AdminAuthenticate middleware - Admin tetap bisa akses
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
                ], 500);
            }

            abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
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
                    'error' => 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'
                ], 500);
            }

            abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
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
        // For 403 Forbidden errors - return 500 dengan custom message
        if ($exception instanceof \Illuminate\Auth\Access\AuthorizationException) {
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'
                ], 500);
            }
            
            abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        // For 404 Not Found errors - return 500 dengan custom message
        if ($exception instanceof \Symfony\Component\HttpKernel\Exception\NotFoundHttpException) {
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'
                ], 500);
            }
            
            abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        // For MethodNotAllowed - return 500 dengan custom message
        if ($exception instanceof \Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException) {
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'
                ], 500);
            }
            
            abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return parent::render($request, $exception);
    }
}
EOF

    # 6. Additional API Protection
    echo -e "${BLUE}Menginstall Additional API Protection...${NC}"
    
    # Create additional security middleware
    cat > "$PANEL_PATH/app/Http/Middleware/BlockSensitiveRoutes.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class BlockSensitiveRoutes
{
    public function handle(Request $request, Closure $next)
    {
        $blockedPaths = [
            'nodes', 'nests', 'locations', 'api/application/nodes', 
            'api/application/nests', 'api/application/locations'
        ];

        $currentPath = $request->path();

        foreach ($blockedPaths as $path) {
            if (strpos($currentPath, $path) !== false) {
                if ($request->expectsJson()) {
                    return response()->json([
                        'error' => 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'
                    ], 500);
                }
                abort(500, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
            }
        }

        return $next($request);
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
    echo -e "  ${GREEN}✓ Anti Delete Server & User${NC}"
    echo -e "  ${GREEN}✓ Anti Intip Location, Nodes, Nest (Error 500)${NC}"
    echo -e "  ${GREEN}✓ Anti Akses Server Orang Lain (Error 500)${NC}"
    echo -e "  ${GREEN}✓ Custom Error Message${NC}"
    echo -e "${YELLOW}Admin tetap bisa akses panel utama, tapi tidak bisa delete!${NC}"
}

# Function to change error texts
change_error_texts() {
    echo -e "${YELLOW}Mengganti teks error...${NC}"
    
    # Replace all error messages in modified files
    find "$PANEL_PATH/app/Http/Controllers" -name "*.php" -exec sed -i 's/message_error_placeholder/Ngapain sih? mau nyolong sc org? - By @ginaabaikhati/g' {} \; 2>/dev/null
    find "$PANEL_PATH/app/Http/Middleware" -name "*.php" -exec sed -i 's/message_error_placeholder/Ngapain sih? mau nyolong sc org? - By @ginaabaikhati/g' {} \; 2>/dev/null
    find "$PANEL_PATH/app/Exceptions" -name "*.php" -exec sed -i 's/message_error_placeholder/Ngapain sih? mau nyolong sc org? - By @ginaabaikhati/g' {} \; 2>/dev/null
    
    echo -e "${GREEN}Teks error berhasil diganti!${NC}"
    echo -e "${BLUE}Custom message: 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'${NC}"
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
    
    # Remove additional security middleware
    rm -f "$PANEL_PATH/app/Http/Middleware/BlockSensitiveRoutes.php" 2>/dev/null
    
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
    
    # Check if modified files exist with error 500
    if grep -q "abort(500," "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Intip Nodes aktif (Error 500)${NC}"
    else
        echo -e "${RED}✗ Anti Intip Nodes tidak aktif${NC}"
    fi
    
    if grep -q "abort(500," "$PANEL_PATH/app/Http/Controllers/Admin/NestsController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Intip Nests aktif (Error 500)${NC}"
    else
        echo -e "${RED}✗ Anti Intip Nests tidak aktif${NC}"
    fi
    
    if grep -q "abort(500," "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Intip Locations aktif (Error 500)${NC}"
    else
        echo -e "${RED}✗ Anti Intip Locations tidak aktif${NC}"
    fi
    
    if grep -q "abort(500," "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" 2>/dev/null; then
        echo -e "${GREEN}✓ Anti Akses Server Orang Lain aktif (Error 500)${NC}"
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
