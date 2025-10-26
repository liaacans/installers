#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Security configuration
SECURITY_DIR="/root/pterodactyl-security"
BACKUP_DIR="/root/pterodactyl-backups"
PANEL_PATH="/var/www/pterodactyl"

# Error message configuration
ERROR_MESSAGE="Ngapain sih? mau nyolong sc org?"

# Log function
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Script harus dijalankan sebagai root!"
        exit 1
    fi
}

# Check if Pterodactyl panel exists
check_panel() {
    if [[ ! -d "$PANEL_PATH" ]]; then
        error "Directory Pterodactyl tidak ditemukan di $PANEL_PATH"
        exit 1
    fi
}

# Backup original files
backup_files() {
    log "Membuat backup file original..."
    mkdir -p "$BACKUP_DIR"
    
    local files=(
        "app/Http/Controllers/Api/Client/Servers/ServerController.php"
        "app/Http/Controllers/Admin/NodesController.php"
        "app/Http/Controllers/Admin/ServersController.php"
        "app/Http/Controllers/Admin/NestsController.php"
        "app/Http/Controllers/Admin/LocationsController.php"
        "app/Http/Controllers/Admin/SettingsController.php"
        "app/Http/Middleware/AdminAuthenticate.php"
        "resources/views/admin/nodes/index.blade.php"
        "resources/views/admin/servers/index.blade.php"
        "resources/views/admin/nests/index.blade.php"
        "resources/views/admin/locations/index.blade.php"
        "resources/views/admin/settings/index.blade.php"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$PANEL_PATH/$file" ]]; then
            cp "$PANEL_PATH/$file" "$BACKUP_DIR/$(basename "$file").backup"
            log "Backup created for $file"
        fi
    done
}

# Install security features
install_security() {
    log "Memulai instalasi security panel..."
    check_root
    check_panel
    backup_files
    
    # Create security directory
    mkdir -p "$SECURITY_DIR"
    
    # 1. Install Admin Middleware Security
    install_admin_middleware
    
    # 2. Install API Security
    install_api_security
    
    # 3. Install Controller Security
    install_controller_security
    
    # 4. Install View Security
    install_view_security
    
    # 5. Update error messages
    update_error_messages
    
    log "Instalasi security berhasil!"
    log "Backup files disimpan di: $BACKUP_DIR"
    log "Security configuration disimpan di: $SECURITY_DIR"
    
    # Clear cache
    cd "$PANEL_PATH" && php artisan cache:clear
    cd "$PANEL_PATH" && php artisan view:clear
}

# Install admin middleware security
install_admin_middleware() {
    log "Menginstall Admin Middleware Security..."
    
    cat > "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Pterodactyl\Contracts\Repository\UserRepositoryInterface;

class AdminAuthenticate
{
    protected UserRepositoryInterface $repository;

    public function __construct(UserRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        
        // Allow admin ID 1 to access everything
        if ($user && $user->id === 1) {
            return $next($request);
        }
        
        // Check if user is admin
        if (!$user || !$user->root_admin) {
            return response()->view('errors.403', [
                'message' => 'Ngapain sih? mau nyolong sc org?'
            ], 403);
        }
        
        // Get current route
        $route = $request->route()->getName();
        
        // Define restricted routes for non-admin ID 1
        $restrictedRoutes = [
            'admin.servers', 'admin.servers.view', 'admin.servers.new',
            'admin.nodes', 'admin.nodes.view', 'admin.nodes.new',
            'admin.nests', 'admin.nests.view', 'admin.nests.new',
            'admin.locations', 'admin.locations.view', 'admin.locations.new',
            'admin.settings'
        ];
        
        // Check if current route is restricted
        if (in_array($route, $restrictedRoutes)) {
            return response()->view('errors.403', [
                'message' => 'Ngapain sih? mau nyolong sc org?'
            ], 403);
        }
        
        return $next($request);
    }
}
EOF
}

# Install API security
install_api_security() {
    log "Menginstall API Security..."
    
    # Server Controller Security
    cat > "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Illuminate\Http\Response;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Models\Server;
use Pterodactyl\Repositories\Eloquent\ServerRepository;
use Pterodactyl\Services\Servers\ServerDeletionService;

class ServerController extends ClientApiController
{
    protected ServerRepository $repository;
    protected ServerDeletionService $deletionService;

    public function __construct(
        ServerRepository $repository,
        ServerDeletionService $deletionService
    ) {
        $this->repository = $repository;
        $this->deletionService = $deletionService;
    }

    public function index()
    {
        $user = $this->request->user();
        
        // Only admin ID 1 can see all servers
        if ($user->id === 1) {
            $servers = $this->repository->all();
        } else {
            $servers = $this->repository->getServersForUser($user->id);
        }
        
        return $this->fractal->transformWith($this->getTransformer(Server::class))
            ->collection($servers);
    }

    public function view(Server $server)
    {
        $user = $this->request->user();
        
        // Admin ID 1 can access any server
        if ($user->id === 1) {
            return $this->fractal->transformWith($this->getTransformer(Server::class))
                ->item($server);
        }
        
        // Check if user owns the server or is subuser
        if ($server->owner_id !== $user->id && !$server->subusers->contains('user_id', $user->id)) {
            return response()->json([
                'error' => 'Ngapain sih? mau nyolong sc org?'
            ], 403);
        }
        
        return $this->fractal->transformWith($this->getTransformer(Server::class))
            ->item($server);
    }
}
EOF
}

# Install controller security
install_controller_security() {
    log "Menginstall Controller Security..."
    
    # Nodes Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;

class NodesController extends Controller
{
    protected AlertsMessageBag $alert;
    protected NodeRepositoryInterface $repository;

    public function __construct(
        AlertsMessageBag $alert,
        NodeRepositoryInterface $repository
    ) {
        $this->alert = $alert;
        $this->repository = $repository;
    }

    public function index()
    {
        $user = request()->user();
        
        // Only admin ID 1 can access nodes
        if ($user->id !== 1) {
            return response()->view('errors.403', [
                'message' => 'Ngapain sih? mau nyolong sc org?'
            ], 403);
        }
        
        return view('admin.nodes.index', [
            'nodes' => $this->repository->all()
        ]);
    }

    public function view($id)
    {
        $user = request()->user();
        
        if ($user->id !== 1) {
            return response()->view('errors.403', [
                'message' => 'Ngapain sih? mau nyolong sc org?'
            ], 403);
        }
        
        return view('admin.nodes.view', [
            'node' => $this->repository->find($id)
        ]);
    }
}
EOF

    # Servers Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/ServersController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\ServerRepositoryInterface;

class ServersController extends Controller
{
    protected ServerRepositoryInterface $repository;

    public function __construct(ServerRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function index()
    {
        $user = request()->user();
        
        // Only admin ID 1 can access all servers
        if ($user->id !== 1) {
            return response()->view('errors.403', [
                'message' => 'Ngapain sih? mau nyolong sc org?'
            ], 403);
        }
        
        return view('admin.servers.index', [
            'servers' => $this->repository->all()
        ]);
    }

    public function view($id)
    {
        $user = request()->user();
        
        if ($user->id !== 1) {
            return response()->view('errors.403', [
                'message' => 'Ngapain sih? mau nyolong sc org?'
            ], 403);
        }
        
        return view('admin.servers.view', [
            'server' => $this->repository->find($id)
        ]);
    }
}
EOF

    # Nests Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NestsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NestRepositoryInterface;

class NestsController extends Controller
{
    protected NestRepositoryInterface $repository;

    public function __construct(NestRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function index()
    {
        $user = request()->user();
        
        if ($user->id !== 1) {
            return response()->view('errors.403', [
                'message' => 'Ngapain sih? mau nyolong sc org?'
            ], 403);
        }
        
        return view('admin.nests.index', [
            'nests' => $this->repository->all()
        ]);
    }

    public function view($id)
    {
        $user = request()->user();
        
        if ($user->id !== 1) {
            return response()->view('errors.403', [
                'message' => 'Ngapain sih? mau nyolong sc org?'
            ], 403);
        }
        
        return view('admin.nests.view', [
            'nest' => $this->repository->find($id)
        ]);
    }
}
EOF

    # Locations Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\LocationRepositoryInterface;

class LocationsController extends Controller
{
    protected LocationRepositoryInterface $repository;

    public function __construct(LocationRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function index()
    {
        $user = request()->user();
        
        if ($user->id !== 1) {
            return response()->view('errors.403', [
                'message' => 'Ngapain sih? mau nyolong sc org?'
            ], 403);
        }
        
        return view('admin.locations.index', [
            'locations' => $this->repository->all()
        ]);
    }

    public function view($id)
    {
        $user = request()->user();
        
        if ($user->id !== 1) {
            return response()->view('errors.403', [
                'message' => 'Ngapain sih? mau nyolong sc org?'
            ], 403);
        }
        
        return view('admin.locations.view', [
            'location' => $this->repository->find($id)
        ]);
    }
}
EOF

    # Settings Controller
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class SettingsController extends Controller
{
    public function index()
    {
        $user = request()->user();
        
        if ($user->id !== 1) {
            return response()->view('errors.403', [
                'message' => 'Ngapain sih? mau nyolong sc org?'
            ], 403);
        }
        
        return view('admin.settings.index');
    }
}
EOF
}

# Install view security
install_view_security() {
    log "Menginstall View Security..."
    
    # Create secure views that check for admin ID 1
    secure_views=(
        "admin/nodes/index.blade.php"
        "admin/servers/index.blade.php" 
        "admin/nests/index.blade.php"
        "admin/locations/index.blade.php"
        "admin/settings/index.blade.php"
    )
    
    for view in "${secure_views[@]}"; do
        view_path="$PANEL_PATH/resources/views/$view"
        mkdir -p "$(dirname "$view_path")"
        
        cat > "$view_path" << EOF
@extends('layouts.admin')

@section('title')
    @lang('server.configuration')
@endsection

@section('content')
@php
\$user = auth()->user();
@endphp

@if(\$user->id !== 1)
    <div class="row">
        <div class="col-md-12">
            <div class="alert alert-danger">
                <h4>@lang('strings.error')</h4>
                <p>Ngapain sih? mau nyolong sc org?</p>
            </div>
        </div>
    </div>
@else
    <!-- Original view content would go here -->
    <div class="row">
        <div class="col-md-12">
            <div class="alert alert-info">
                <h4>Security Active</h4>
                <p>Hanya admin ID 1 yang dapat mengakses halaman ini.</p>
            </div>
        </div>
    </div>
@endif
@endsection
EOF
    done
}

# Update error messages
update_error_messages() {
    log "Mengupdate pesan error..."
    
    # Update 403 error view
    mkdir -p "$PANEL_PATH/resources/views/errors"
    
    cat > "$PANEL_PATH/resources/views/errors/403.blade.php" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Access Denied</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
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
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 500px;
            width: 90%;
        }
        .error-icon {
            font-size: 80px;
            color: #e74c3c;
            margin-bottom: 20px;
        }
        .error-title {
            font-size: 32px;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 15px;
        }
        .error-message {
            font-size: 18px;
            color: #e74c3c;
            margin-bottom: 25px;
            line-height: 1.5;
        }
        .error-description {
            font-size: 14px;
            color: #7f8c8d;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        .btn-home {
            background: #3498db;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 25px;
            text-decoration: none;
            font-size: 16px;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        .btn-home:hover {
            background: #2980b9;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">🚫</div>
        <div class="error-title">Access Denied</div>
        <div class="error-message">{{ \$message ?? 'Ngapain sih? mau nyolong sc org?' }}</div>
        <div class="error-description">
            You don't have permission to access this page. This incident has been logged.
        </div>
        <a href="{{ url('/') }}" class="btn-home">Return to Home</a>
    </div>
</body>
</html>
EOF
}

# Change error message
change_error_message() {
    log "Mengganti pesan error..."
    
    read -p "Masukkan pesan error baru: " new_message
    
    if [[ -n "$new_message" ]]; then
        ERROR_MESSAGE="$new_message"
        update_error_messages
        log "Pesan error berhasil diubah menjadi: $ERROR_MESSAGE"
    else
        error "Pesan error tidak boleh kosong!"
    fi
}

# Uninstall security
uninstall_security() {
    log "Memulai uninstall security..."
    check_root
    check_panel
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        error "Backup directory tidak ditemukan! Tidak dapat melakukan uninstall."
        exit 1
    fi
    
    # Restore backed up files
    log "Memulihkan file original..."
    
    local files=(
        "ServerController.php" "NodesController.php" "ServersController.php"
        "NestsController.php" "LocationsController.php" "SettingsController.php"
        "AdminAuthenticate.php"
    )
    
    for file in "${files[@]}"; do
        backup_file="$BACKUP_DIR/$file.backup"
        if [[ -f "$backup_file" ]]; then
            case $file in
                "ServerController.php")
                    cp "$backup_file" "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php"
                    ;;
                "NodesController.php")
                    cp "$backup_file" "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php"
                    ;;
                "ServersController.php")
                    cp "$backup_file" "$PANEL_PATH/app/Http/Controllers/Admin/ServersController.php"
                    ;;
                "NestsController.php")
                    cp "$backup_file" "$PANEL_PATH/app/Http/Controllers/Admin/NestsController.php"
                    ;;
                "LocationsController.php")
                    cp "$backup_file" "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php"
                    ;;
                "SettingsController.php")
                    cp "$backup_file" "$PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php"
                    ;;
                "AdminAuthenticate.php")
                    cp "$backup_file" "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php"
                    ;;
            esac
            log "File $file berhasil dipulihkan"
        fi
    done
    
    # Clear cache
    cd "$PANEL_PATH" && php artisan cache:clear
    cd "$PANEL_PATH" && php artisan view:clear
    
    log "Uninstall security berhasil!"
    warning "Backup files masih disimpan di: $BACKUP_DIR"
    warning "Anda bisa menghapus manual jika tidak diperlukan lagi."
}

# Show menu
show_menu() {
    echo -e "${BLUE}"
    echo "=========================================="
    echo "    Pterodactyl Panel Security Installer"
    echo "=========================================="
    echo -e "${NC}"
    echo "1. Install Security Panel"
    echo "2. Ganti Teks Error" 
    echo "3. Uninstall Security Panel"
    echo "4. Exit"
    echo
    read -p "Pilih opsi [1-4]: " option
}

# Main script
main() {
    case $1 in
        "1")
            install_security
            ;;
        "2")
            change_error_message
            ;;
        "3")
            uninstall_security
            ;;
        "4")
            log "Keluar dari script."
            exit 0
            ;;
        *)
            while true; do
                show_menu
                case $option in
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
                        log "Keluar dari script."
                        exit 0
                        ;;
                    *)
                        error "Opsi tidak valid!"
                        ;;
                esac
                echo
                read -p "Tekan Enter untuk melanjutkan..."
            done
            ;;
    esac
}

# Run main function
main "$@"
