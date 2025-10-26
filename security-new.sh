#!/bin/bash

# security.sh - Security Panel Pterodactyl
# Script untuk mengamankan panel Pterodactyl dengan restriksi admin ID 1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default error message
ERROR_MSG="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Path to Pterodactyl installation
PTERODACTYL_PATH="/var/www/pterodactyl"
BACKUP_DIR="/root/pterodactyl_backup"

# Function to display header
display_header() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════╗"
    echo "║           Pterodactyl Security Panel           ║"
    echo "║              By @ginaabaikhati                 ║"
    echo "╚════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: Script harus dijalankan sebagai root${NC}"
        exit 1
    fi
}

# Function to check Pterodactyl installation
check_pterodactyl() {
    if [[ ! -d "$PTERODACTYL_PATH" ]]; then
        echo -e "${RED}Error: Pterodactyl tidak ditemukan di $PTERODACTYL_PATH${NC}"
        echo -e "${YELLOW}Pastikan Pterodactyl sudah terinstall dengan benar${NC}"
        exit 1
    fi
    
    if [[ ! -f "$PTERODACTYL_PATH/app/Http/Controllers/Admin/AdminController.php" ]]; then
        echo -e "${RED}Error: Struktur Pterodactyl tidak valid${NC}"
        exit 1
    fi
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup file Pterodactyl...${NC}"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
    fi
    
    BACKUP_TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_PATH="$BACKUP_DIR/backup_$BACKUP_TIMESTAMP"
    
    mkdir -p "$BACKUP_PATH"
    
    # Backup important files
    cp -r "$PTERODACTYL_PATH/app/Http/Controllers" "$BACKUP_PATH/" 2>/dev/null
    cp -r "$PTERODACTYL_PATH/app/Http/Middleware" "$BACKUP_PATH/" 2>/dev/null
    cp -r "$PTERODACTYL_PATH/routes" "$BACKUP_PATH/" 2>/dev/null
    
    echo -e "${GREEN}Backup berhasil dibuat: $BACKUP_PATH${NC}"
}

# Function to restore backup
restore_backup() {
    echo -e "${YELLOW}Mencari backup terbaru...${NC}"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        echo -e "${RED}Tidak ada backup yang ditemukan${NC}"
        return 1
    fi
    
    LATEST_BACKUP=$(ls -td "$BACKUP_DIR"/*/ | head -1)
    
    if [[ -z "$LATEST_BACKUP" ]]; then
        echo -e "${RED}Tidak ada backup yang ditemukan${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Memulihkan dari: $LATEST_BACKUP${NC}"
    
    # Restore files
    cp -r "$LATEST_BACKUP/Controllers/"* "$PTERODACTYL_PATH/app/Http/Controllers/" 2>/dev/null
    cp -r "$LATEST_BACKUP/Middleware/"* "$PTERODACTYL_PATH/app/Http/Middleware/" 2>/dev/null
    cp -r "$LATEST_BACKUP/routes/"* "$PTERODACTYL_PATH/routes/" 2>/dev/null
    
    echo -e "${GREEN}Restore backup berhasil${NC}"
}

# Function to install security
install_security() {
    echo -e "${YELLOW}Menginstall security panel...${NC}"
    
    create_backup
    
    # Create custom middleware
    cat > "$PTERODACTYL_PATH/app/Http/Middleware/AdminRestriction.php" << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminRestriction
{
    public function handle(Request $request, Closure $next, $type = null)
    {
        $user = $request->user();
        
        if (!$user || $user->id !== 1) {
            $errorMessage = config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
            
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json(['error' => $errorMessage], 403);
            }
            
            abort(403, $errorMessage);
        }
        
        return $next($request);
    }
}
EOF

    # Modify AdminController
    if [[ -f "$PTERODACTYL_PATH/app/Http/Controllers/Admin/AdminController.php" ]]; then
        sed -i 's/use Illuminate\\Http\\Request;/use Illuminate\\Http\\Request;\nuse Illuminate\\Support\\Facades\\Auth;/' "$PTERODACTYL_PATH/app/Http/Controllers/Admin/AdminController.php"
        
        # Add security check to index method
        sed -i '/public function index/,/^    }/{
            /public function index/a\
\    public function index()\
\    {\
\        if (Auth::user()->id !== 1) {\
\            abort(403, config('\''security.error_message'\'', '\''Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'\''));\
\        }\
\        return view('\''admin.index'\'');\
\    }
        }' "$PTERODACTYL_PATH/app/Http/Controllers/Admin/AdminController.php"
    fi

    # Modify UserController for user restrictions
    if [[ -f "$PTERODACTYL_PATH/app/Http/Controllers/Api/Client/AccountController.php" ]]; then
        sed -i 's/use Illuminate\\Http\\Request;/use Illuminate\\Http\\Request;\nuse Illuminate\\Support\\Facades\\Auth;/' "$PTERODACTYL_PATH/app/Http/Controllers/Api/Client/AccountController.php"
    fi

    # Modify routes for security
    if [[ -f "$PTERODACTYL_PATH/routes/admin.php" ]]; then
        # Backup original routes
        cp "$PTERODACTYL_PATH/routes/admin.php" "$PTERODACTYL_PATH/routes/admin.php.backup"
        
        # Add middleware to admin routes
        cat > "$PTERODACTYL_PATH/routes/admin_secured.php" << EOF
<?php

use App\Http\Middleware\AdminRestriction;
use Illuminate\Support\Facades\Route;

// Panel Settings - Only ID 1
Route::group(['prefix' => 'settings', 'middleware' => ['auth', AdminRestriction::class . ':panel']], function () {
    Route::get('/', 'SettingsController@index')->name('admin.settings');
    Route::post('/', 'SettingsController@update');
});

// Nodes - Only ID 1
Route::group(['prefix' => 'nodes', 'middleware' => ['auth', AdminRestriction::class . ':nodes']], function () {
    Route::get('/', 'NodeController@index')->name('admin.nodes');
    Route::get('/view/{id}', 'NodeController@view')->name('admin.nodes.view');
    Route::get('/create', 'NodeController@create')->name('admin.nodes.create');
    Route::post('/create', 'NodeController@store');
    Route::get('/update/{id}', 'NodeController@update')->name('admin.nodes.update');
    Route::post('/update/{id}', 'NodeController@update');
    Route::post('/delete/{id}', 'NodeController@delete')->name('admin.nodes.delete');
});

// Locations - Only ID 1
Route::group(['prefix' => 'locations', 'middleware' => ['auth', AdminRestriction::class . ':locations']], function () {
    Route::get('/', 'LocationController@index')->name('admin.locations');
    Route::get('/create', 'LocationController@create')->name('admin.locations.create');
    Route::post('/create', 'LocationController@store');
    Route::get('/update/{id}', 'LocationController@update')->name('admin.locations.update');
    Route::post('/update/{id}', 'LocationController@update');
    Route::post('/delete/{id}', 'LocationController@delete')->name('admin.locations.delete');
});

// Nests - Only ID 1
Route::group(['prefix' => 'nests', 'middleware' => ['auth', AdminRestriction::class . ':nests']], function () {
    Route::get('/', 'NestController@index')->name('admin.nests');
    Route::get('/create', 'NestController@create')->name('admin.nests.create');
    Route::post('/create', 'NestController@store');
    Route::get('/update/{id}', 'NestController@update')->name('admin.nests.update');
    Route::post('/update/{id}', 'NestController@update');
    Route::post('/delete/{id}', 'NestController@delete')->name('admin.nests.delete');
});

// Users - Restricted operations
Route::group(['prefix' => 'users', 'middleware' => ['auth']], function () {
    Route::get('/', 'UserController@index')->name('admin.users');
    Route::get('/view/{id}', 'UserController@view')->name('admin.users.view');
    
    // Only ID 1 can modify users
    Route::group(['middleware' => [AdminRestriction::class . ':users']], function () {
        Route::get('/create', 'UserController@create')->name('admin.users.create');
        Route::post('/create', 'UserController@store');
        Route::get('/update/{id}', 'UserController@update')->name('admin.users.update');
        Route::post('/update/{id}', 'UserController@update');
        Route::post('/delete/{id}', 'UserController@delete')->name('admin.users.delete');
    });
});

// Servers - Restricted operations
Route::group(['prefix' => 'servers', 'middleware' => ['auth']], function () {
    Route::get('/', 'ServerController@index')->name('admin.servers');
    
    // Only ID 1 can modify servers and access file manager
    Route::group(['middleware' => [AdminRestriction::class . ':servers']], function () {
        Route::get('/view/{id}', 'ServerController@view')->name('admin.servers.view');
        Route::get('/create', 'ServerController@create')->name('admin.servers.create');
        Route::post('/create', 'ServerController@store');
        Route::get('/update/{id}', 'ServerController@update')->name('admin.servers.update');
        Route::post('/update/{id}', 'ServerController@update');
        Route::post('/delete/{id}', 'ServerController@delete')->name('admin.servers.delete');
        Route::get('/file-manager/{id}', 'ServerController@fileManager')->name('admin.servers.file-manager');
    });
});

// Include other admin routes
require base_path('routes/admin.php');
EOF

        # Replace admin routes
        mv "$PTERODACTYL_PATH/routes/admin_secured.php" "$PTERODACTYL_PATH/routes/admin.php"
    fi

    # Create security configuration
    cat > "$PTERODACTYL_PATH/config/security.php" << EOF
<?php

return [
    'error_message' => '$ERROR_MSG',
    'installed' => true,
    'installed_at' => now(),
];
EOF

    # Update composer autoload
    if [[ -f "$PTERODACTYL_PATH/composer.json" ]]; then
        sed -i 's/"App\\\\": "app\/"/"App\\\\": "app\/",\n        "App\\\\Http\\\\Middleware\\\\": "app\/Http\/Middleware\/"/' "$PTERODACTYL_PATH/composer.json"
    fi

    echo -e "${GREEN}Security panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Jangan lupa menjalankan: php artisan optimize:clear${NC}"
}

# Function to change error message
change_error_message() {
    echo -e "${YELLOW}Mengubah teks error...${NC}"
    echo -e "${BLUE}Teks error saat ini: $ERROR_MSG${NC}"
    read -p "Masukkan teks error baru: " new_error_msg
    
    if [[ -n "$new_error_msg" ]]; then
        ERROR_MSG="$new_error_msg"
        
        # Update security config
        if [[ -f "$PTERODACTYL_PATH/config/security.php" ]]; then
            sed -i "s/'error_message' => '.*'/'error_message' => '$ERROR_MSG'/" "$PTERODACTYL_PATH/config/security.php"
        fi
        
        # Update middleware
        if [[ -f "$PTERODACTYL_PATH/app/Http/Middleware/AdminRestriction.php" ]]; then
            sed -i "s/config('security.error_message', '.*')/config('security.error_message', '$ERROR_MSG')/" "$PTERODACTYL_PATH/app/Http/Middleware/AdminRestriction.php"
        fi
        
        echo -e "${GREEN}Teks error berhasil diubah!${NC}"
    else
        echo -e "${RED}Teks error tidak boleh kosong${NC}"
    fi
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Uninstall security panel...${NC}"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        echo -e "${RED}Tidak ada backup yang ditemukan${NC}"
        echo -e "${YELLOW}Melakukan uninstall manual...${NC}"
        
        # Remove security files
        rm -f "$PTERODACTYL_PATH/app/Http/Middleware/AdminRestriction.php"
        rm -f "$PTERODACTYL_PATH/config/security.php"
        
        # Restore original admin.php if backup exists
        if [[ -f "$PTERODACTYL_PATH/routes/admin.php.backup" ]]; then
            mv "$PTERODACTYL_PATH/routes/admin.php.backup" "$PTERODACTYL_PATH/routes/admin.php"
        fi
        
        echo -e "${GREEN}Security panel berhasil diuninstall!${NC}"
        return
    fi
    
    read -p "Apakah Anda yakin ingin menguninstall security panel? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        restore_backup
        
        # Remove security files
        rm -f "$PTERODACTYL_PATH/app/Http/Middleware/AdminRestriction.php"
        rm -f "$PTERODACTYL_PATH/config/security.php"
        
        echo -e "${GREEN}Security panel berhasil diuninstall!${NC}"
        echo -e "${YELLOW}Jangan lupa menjalankan: php artisan optimize:clear${NC}"
    else
        echo -e "${YELLOW}Uninstall dibatalkan${NC}"
    fi
}

# Function to optimize application
optimize_application() {
    echo -e "${YELLOW}Mengoptimalkan aplikasi...${NC}"
    cd "$PTERODACTYL_PATH" || exit 1
    
    # Run optimization commands
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    php artisan optimize
    
    echo -e "${GREEN}Optimasi selesai!${NC}"
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${GREEN}Pilih opsi:${NC}"
        echo "1. Install Security Panel"
        echo "2. Ubah Teks Error"
        echo "3. Uninstall Security Panel"
        echo "4. Optimize Application"
        echo "5. Exit"
        echo ""
        read -p "Masukkan pilihan [1-5]: " choice
        
        case $choice in
            1)
                check_root
                check_pterodactyl
                install_security
                ;;
            2)
                check_root
                check_pterodactyl
                change_error_message
                ;;
            3)
                check_root
                check_pterodactyl
                uninstall_security
                ;;
            4)
                check_root
                check_pterodactyl
                optimize_application
                ;;
            5)
                echo -e "${GREEN}Keluar...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Pilihan tidak valid!${NC}"
                ;;
        esac
        
        echo ""
        read -p "Tekan Enter untuk melanjutkan..."
    done
}

# Check if script is sourced or directly executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        install)
            check_root
            check_pterodactyl
            install_security
            ;;
        uninstall)
            check_root
            check_pterodactyl
            uninstall_security
            ;;
        change-error)
            check_root
            check_pterodactyl
            change_error_message
            ;;
        optimize)
            check_root
            check_pterodactyl
            optimize_application
            ;;
        *)
            main_menu
            ;;
    esac
fi
