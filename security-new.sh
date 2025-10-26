#!/bin/bash

# Security Panel Pterodactyl
# By @ginaabaikhati

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PANEL_PATH="/var/www/pterodactyl"
BACKUP_DIR="/root/pterodactyl_backup"
SECURITY_LOG="/var/log/pterodactyl_security.log"

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$SECURITY_LOG"
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Error function
error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log "ERROR: $1"
}

# Success function
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log "SUCCESS: $1"
}

# Warning function
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log "WARNING: $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Script harus dijalankan sebagai root"
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
        "app/Http/Controllers/Admin"
        "app/Http/Middleware"
        "resources/views/admin"
        "app/Models/User.php"
        "routes/web.php"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$PANEL_PATH/$file" || -d "$PANEL_PATH/$file" ]]; then
            cp -r "$PANEL_PATH/$file" "$BACKUP_DIR/" 2>/dev/null
        fi
    done
    
    success "Backup berhasil disimpan di $BACKUP_DIR"
}

# Restore from backup
restore_backup() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        error "Backup directory tidak ditemukan"
        return 1
    fi
    
    log "Memulihkan file dari backup..."
    
    cp -r "$BACKUP_DIR/"* "$PANEL_PATH/" 2>/dev/null
    
    success "File berhasil dipulihkan dari backup"
}

# Install security modifications
install_security() {
    log "Memulai instalasi security panel..."
    
    # Backup files first
    backup_files
    
    # 1. Modify User Model to add security check
    modify_user_model
    
    # 2. Create custom middleware
    create_security_middleware
    
    # 3. Modify admin controllers
    modify_admin_controllers
    
    # 4. Modify routes
    modify_routes
    
    # 5. Create error views
    create_error_views
    
    # 6. Update dependencies
    update_dependencies
    
    success "Instalasi security panel selesai"
}

# Modify User Model
modify_user_model() {
    log "Memodifikasi User Model..."
    
    cat > "$PANEL_PATH/app/Models/User.php" << 'EOF'
<?php

namespace App\Models;

use Illuminate\Notifications\Notifiable;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'root_admin',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
    ];

    // Security check function
    public function isSuperAdmin()
    {
        return $this->id === 1 && $this->root_admin === 1;
    }

    public function canAccessAdminPanel()
    {
        return $this->isSuperAdmin();
    }

    public function canManageServers()
    {
        return $this->isSuperAdmin();
    }

    public function canManageNodes()
    {
        return $this->isSuperAdmin();
    }

    public function canManageNests()
    {
        return $this->isSuperAdmin();
    }

    public function canManageLocations()
    {
        return $this->isSuperAdmin();
    }

    public function canManageSettings()
    {
        return $this->isSuperAdmin();
    }
}
EOF
    success "User Model berhasil dimodifikasi"
}

# Create security middleware
create_security_middleware() {
    log "Membuat Security Middleware..."
    
    mkdir -p "$PANEL_PATH/app/Http/Middleware"
    
    cat > "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php" << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Models\User;

class AdminSecurity
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        
        // Check if user is authenticated
        if (!$user) {
            return redirect('/auth/login');
        }

        // Only user ID 1 can access admin features
        if (!$user->isSuperAdmin()) {
            $path = $request->path();
            
            // Check if trying to access restricted admin areas
            if (str_starts_with($path, 'admin') || 
                str_contains($path, 'servers') ||
                str_contains($path, 'nodes') ||
                str_contains($path, 'nests') ||
                str_contains($path, 'locations') ||
                str_contains($path, 'settings')) {
                
                return response()->view('errors.security', [], 403);
            }
        }

        return $next($request);
    }
}
EOF
    success "Security Middleware berhasil dibuat"
}

# Modify admin controllers
modify_admin_controllers() {
    log "Memodifikasi Admin Controllers..."
    
    # Create or modify admin controllers directory
    mkdir -p "$PANEL_PATH/app/Http/Controllers/Admin"
    
    # BaseAdminController for all admin controllers
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/BaseAdminController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;

class BaseAdminController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('admin.security');
        
        // Additional security check
        $this->checkAdminAccess();
    }
    
    protected function checkAdminAccess()
    {
        $user = auth()->user();
        
        if (!$user || !$user->isSuperAdmin()) {
            abort(403, 'Unauthorized');
        }
    }
}
EOF

    # Modify existing controllers or create security checks
    local controllers=(
        "ServerController.php"
        "NodeController.php" 
        "NestController.php"
        "LocationController.php"
        "SettingsController.php"
    )
    
    for controller in "${controllers[@]}"; do
        if [[ -f "$PANEL_PATH/app/Http/Controllers/Admin/$controller" ]]; then
            # Add security check to existing controllers
            sed -i 's/use App\\Http\\Controllers\\Controller;/use App\\Http\\Controllers\\Admin\\BaseAdminController;/g' "$PANEL_PATH/app/Http/Controllers/Admin/$controller"
            sed -i 's/extends Controller/extends BaseAdminController/g' "$PANEL_PATH/app/Http/Controllers/Admin/$controller"
        fi
    done
    
    success "Admin Controllers berhasil dimodifikasi"
}

# Modify routes
modify_routes() {
    log "Memodifikasi routes..."
    
    # Backup original routes
    cp "$PANEL_PATH/routes/web.php" "$BACKUP_DIR/web.php.backup"
    
    # Add middleware to routes
    cat >> "$PANEL_PATH/routes/web.php" << 'EOF'

// Security Middleware
Route::group(['middleware' => ['auth', 'admin.security']], function () {
    // Admin routes - only accessible by user ID 1
    Route::group(['prefix' => 'admin', 'namespace' => 'Admin'], function () {
        Route::get('/servers', function () {
            $user = auth()->user();
            if (!$user->isSuperAdmin()) {
                return response()->view('errors.security', [], 403);
            }
            return app('App\Http\Controllers\Admin\ServerController')->index();
        });
        
        Route::get('/nodes', function () {
            $user = auth()->user();
            if (!$user->isSuperAdmin()) {
                return response()->view('errors.security', [], 403);
            }
            return app('App\Http\Controllers\Admin\NodeController')->index();
        });
        
        Route::get('/nests', function () {
            $user = auth()->user();
            if (!$user->isSuperAdmin()) {
                return response()->view('errors.security', [], 403);
            }
            return app('App\Http\Controllers\Admin\NestController')->index();
        });
        
        Route::get('/locations', function () {
            $user = auth()->user();
            if (!$user->isSuperAdmin()) {
                return response()->view('errors.security', [], 403);
            }
            return app('App\Http\Controllers\Admin\LocationController')->index();
        });
        
        Route::get('/settings', function () {
            $user = auth()->user();
            if (!$user->isSuperAdmin()) {
                return response()->view('errors.security', [], 403);
            }
            return app('App\Http\Controllers\Admin\SettingsController')->index();
        });
    });
});

// Register middleware
app('router')->aliasMiddleware('admin.security', \App\Http\Middleware\AdminSecurity::class);
EOF
    success "Routes berhasil dimodifikasi"
}

# Create error views
create_error_views() {
    log "Membuat error views..."
    
    mkdir -p "$PANEL_PATH/resources/views/errors"
    
    cat > "$PANEL_PATH/resources/views/errors/security.blade.php" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied - Security Restriction</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
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
            border-radius: 10px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 500px;
            width: 90%;
        }
        .error-icon {
            font-size: 64px;
            color: #e74c3c;
            margin-bottom: 20px;
        }
        .error-title {
            font-size: 28px;
            color: #e74c3c;
            margin-bottom: 15px;
            font-weight: bold;
        }
        .error-message {
            font-size: 18px;
            color: #666;
            margin-bottom: 25px;
            line-height: 1.5;
        }
        .security-note {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 5px;
            padding: 15px;
            margin: 20px 0;
            font-size: 14px;
            color: #856404;
        }
        .home-button {
            background: #3498db;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background 0.3s;
        }
        .home-button:hover {
            background: #2980b9;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">🚫</div>
        <div class="error-title">Access Denied</div>
        <div class="error-message">
            Ngapain sih? mau nyolong sc org? - By @ginaabaikhati
        </div>
        <div class="security-note">
            <strong>Security Notice:</strong> This action has been logged and monitored.
        </div>
        <a href="/" class="home-button">Return to Home</a>
    </div>
</body>
</html>
EOF
    success "Error views berhasil dibuat"
}

# Update dependencies
update_dependencies() {
    log "Update dependencies..."
    
    cd "$PANEL_PATH" || exit 1
    
    # Clear cache and update
    php artisan config:clear
    php artisan cache:clear
    php artisan view:clear
    
    # Run composer dump-autoload
    composer dump-autoload
    
    success "Dependencies berhasil diupdate"
}

# Change error text
change_error_text() {
    log "Mengganti teks error..."
    
    if [[ ! -f "$PANEL_PATH/resources/views/errors/security.blade.php" ]]; then
        error "File error view tidak ditemukan. Install security terlebih dahulu."
        return 1
    fi
    
    read -p "Masukkan teks error baru: " new_error_text
    
    if [[ -z "$new_error_text" ]]; then
        error "Teks error tidak boleh kosong"
        return 1
    fi
    
    # Escape special characters for sed
    escaped_text=$(printf '%s\n' "$new_error_text" | sed 's/[[\.*^$/]/\\&/g')
    
    # Replace the error text
    sed -i "s/Ngapain sih? mau nyolong sc org? - By @ginaabaikhati/$escaped_text/g" "$PANEL_PATH/resources/views/errors/security.blade.php"
    
    # Clear cache
    cd "$PANEL_PATH" && php artisan view:clear
    
    success "Teks error berhasil diganti"
    log "Teks error diubah menjadi: $new_error_text"
}

# Uninstall security
uninstall_security() {
    log "Memulai uninstall security panel..."
    
    read -p "Apakah Anda yakin ingin uninstall security panel? (y/n): " confirm
    
    if [[ $confirm != "y" && $confirm != "Y" ]]; then
        log "Uninstall dibatalkan"
        return
    fi
    
    if restore_backup; then
        # Clear cache
        cd "$PANEL_PATH" && php artisan config:clear && php artisan cache:clear && php artisan view:clear
        
        success "Security panel berhasil diuninstall"
        log "Security panel diuninstall"
    else
        error "Gagal menguninstall security panel"
    fi
}

# Main menu
main_menu() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║    Security Panel Pterodactyl       ║"
    echo "║        By @ginaabaikhati            ║"
    echo "╠══════════════════════════════════════╣"
    echo "║${NC}${GREEN} 1. Install Security Panel${BLUE}           ║"
    echo "║${NC}${YELLOW} 2. Ganti Teks Error${BLUE}                ║"
    echo "║${NC}${RED} 3. Uninstall Security Panel${BLUE}        ║"
    echo "║${NC}${BLUE} 4. Exit Security Panel${BLUE}              ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
    
    read -p "Pilih opsi [1-4]: " choice
    
    case $choice in
        1)
            check_root
            check_panel
            install_security
            ;;
        2)
            check_root
            check_panel
            change_error_text
            ;;
        3)
            check_root
            check_panel
            uninstall_security
            ;;
        4)
            log "Keluar dari Security Panel"
            echo "Terima kasih telah menggunakan Security Panel!"
            exit 0
            ;;
        *)
            error "Pilihan tidak valid"
            ;;
    esac
    
    read -p "Tekan Enter untuk melanjutkan..."
    main_menu
}

# Check if script is sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Create log directory if not exists
    mkdir -p "/var/log"
    
    # Show welcome message
    echo -e "${GREEN}"
    echo "=========================================="
    echo "    Security Panel Pterodactyl"
    echo "        By @ginaabaikhati"
    echo "=========================================="
    echo -e "${NC}"
    
    # Run main menu
    main_menu
fi
