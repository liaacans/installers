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
BACKUP_PATH="/root/pterodactyl_backup"
SECURITY_MESSAGE="Ngapain sih? mau nyolong sc org? - By @ginaabaikhati"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Script harus dijalankan sebagai root${NC}"
   exit 1
fi

# Function to display header
display_header() {
    clear
    echo -e "${BLUE}"
    echo "=========================================="
    echo "    Pterodactyl Security Panel"
    echo "    By @ginaabaikhati"
    echo "=========================================="
    echo -e "${NC}"
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup file...${NC}"
    mkdir -p $BACKUP_PATH
    
    # Backup important files
    cp $PANEL_PATH/app/Http/Controllers/Admin/*.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/routes/admin.php $BACKUP_PATH/ 2>/dev/null
    
    echo -e "${GREEN}Backup berhasil dibuat di: $BACKUP_PATH${NC}"
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
    cp $BACKUP_PATH/AdminAuthenticate.php $PANEL_PATH/app/Http/Middleware/ 2>/dev/null
    cp $BACKUP_PATH/admin.php $PANEL_PATH/routes/ 2>/dev/null
    
    echo -e "${GREEN}Restore backup berhasil!${NC}"
}

# Function to install security
install_security() {
    display_header
    echo -e "${YELLOW}Menginstal Security Panel...${NC}"
    
    # Check if panel path exists
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}Directory Pterodactyl tidak ditemukan di: $PANEL_PATH${NC}"
        echo -e "${YELLOW}Silakan edit PANEL_PATH dalam script jika directory berbeda${NC}"
        return 1
    fi
    
    create_backup
    
    # Create custom middleware for admin ID 1 restriction
    cat > $PANEL_PATH/app/Http/Middleware/AdminIdRestriction.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminIdRestriction
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, string $resource): Response
    {
        // Allow only admin with ID 1
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return $next($request);
    }
}
EOF

    # Modify Admin Controller to add security checks
    cat > $PANEL_PATH/app/Http/Controllers/Admin/AdminControllerSecure.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\User;

class AdminControllerSecure extends Controller
{
    /**
     * Check if current user is admin ID 1
     */
    protected function checkAdminIdOne()
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
    }

    /**
     * Display admin settings page
     */
    public function settings()
    {
        // Allow access to settings for all admins
        return app('App\Http\Controllers\Admin\SettingsController')->index();
    }

    /**
     * Restrict access to servers for non-admin ID 1
     */
    public function servers()
    {
        $this->checkAdminIdOne();
        return app('App\Http\Controllers\Admin\ServersController')->index();
    }

    /**
     * Restrict access to nodes for non-admin ID 1
     */
    public function nodes()
    {
        $this->checkAdminIdOne();
        return app('App\Http\Controllers\Admin\NodesController')->index();
    }

    /**
     * Restrict access to nests for non-admin ID 1
     */
    public function nests()
    {
        $this->checkAdminIdOne();
        return app('App\Http\Controllers\Admin\NestsController')->index();
    }

    /**
     * Restrict access to locations for non-admin ID 1
     */
    public function locations()
    {
        $this->checkAdminIdOne();
        return app('App\Http\Controllers\Admin\LocationsController')->index();
    }
}
EOF

    # Create custom error page handler
    cat > $PANEL_PATH/app/Exceptions/HandlerSecure.php << 'EOF'
<?php

namespace App\Exceptions;

use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Throwable;
use Symfony\Component\HttpKernel\Exception\HttpException;

class HandlerSecure extends ExceptionHandler
{
    /**
     * Render an exception into an HTTP response.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Throwable  $exception
     * @return \Symfony\Component\HttpFoundation\Response
     *
     * @throws \Throwable
     */
    public function render($request, Throwable $exception)
    {
        // Custom message for 403 errors
        if ($exception instanceof HttpException && $exception->getStatusCode() === 403) {
            $message = $exception->getMessage();
            if (strpos($message, 'Ngapain sih? mau nyolong sc org?') !== false) {
                return response()->view('errors.403_custom', [
                    'message' => $message
                ], 403);
            }
        }

        return parent::render($request, $exception);
    }
}
EOF

    # Create custom error view
    mkdir -p $PANEL_PATH/resources/views/errors
    cat > $PANEL_PATH/resources/views/errors/403_custom.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
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
            background: rgba(0, 0, 0, 0.7);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }
        .error-code {
            font-size: 72px;
            font-weight: bold;
            margin-bottom: 20px;
            color: #ff6b6b;
        }
        .error-message {
            font-size: 24px;
            margin-bottom: 30px;
            line-height: 1.5;
        }
        .signature {
            font-size: 14px;
            color: #ccc;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">403</div>
        <div class="error-message">{{ $message ?? 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati' }}</div>
        <div class="signature">Security System Activated</div>
    </div>
</body>
</html>
EOF

    # Modify routes to use security middleware
    if [ -f "$PANEL_PATH/routes/admin.php" ]; then
        cp $PANEL_PATH/routes/admin.php $BACKUP_PATH/admin_original.php
        
        # Add custom routes with security
        cat >> $PANEL_PATH/routes/admin.php << 'EOF'

// =====================
// SECURITY ROUTES - ADMIN ID 1 ONLY
// By @ginaabaikhati
// =====================

Route::group(['prefix' => 'security', 'middleware' => 'admin'], function () {
    // Servers - Admin ID 1 only
    Route::get('/servers', [\App\Http\Controllers\Admin\AdminControllerSecure::class, 'servers'])
        ->name('admin.security.servers');
    
    // Nodes - Admin ID 1 only  
    Route::get('/nodes', [\App\Http\Controllers\Admin\AdminControllerSecure::class, 'nodes'])
        ->name('admin.security.nodes');
    
    // Nests - Admin ID 1 only
    Route::get('/nests', [\App\Http\Controllers\Admin\AdminControllerSecure::class, 'nests'])
        ->name('admin.security.nests');
    
    // Locations - Admin ID 1 only
    Route::get('/locations', [\App\Http\Controllers\Admin\AdminControllerSecure::class, 'locations'])
        ->name('admin.security.locations');
    
    // Settings - All admins can access
    Route::get('/settings', [\App\Http\Controllers\Admin\AdminControllerSecure::class, 'settings'])
        ->name('admin.security.settings');
});

EOF
    fi

    # Update middleware registration
    if [ -f "$PANEL_PATH/app/Http/Kernel.php" ]; then
        # Check if middleware already exists
        if ! grep -q "AdminIdRestriction" $PANEL_PATH/app/Http/Kernel.php; then
            sed -i "/protected \$routeMiddleware = \[/a\
        'admin.restrict' => \\App\\Http\\Middleware\\AdminIdRestriction::class," $PANEL_PATH/app/Http/Kernel.php
        fi
    fi

    # Run Laravel commands
    echo -e "${YELLOW}Menjalankan optimasi Laravel...${NC}"
    cd $PANEL_PATH
    php artisan route:clear
    php artisan view:clear
    php artisan cache:clear

    echo -e "${GREEN}Security Panel berhasil diinstal!${NC}"
    echo -e "${YELLOW}Catatan: Hanya admin dengan ID 1 yang bisa mengakses:${NC}"
    echo -e "${YELLOW}- Servers${NC}"
    echo -e "${YELLOW}- Nodes${NC}" 
    echo -e "${YELLOW}- Nests${NC}"
    echo -e "${YELLOW}- Locations${NC}"
    echo -e "${GREEN}Settings dapat diakses oleh semua admin${NC}"
}

# Function to change error text
change_error_text() {
    display_header
    echo -e "${YELLOW}Mengganti Teks Error...${NC}"
    
    read -p "Masukkan teks error baru: " new_text
    
    if [ -z "$new_text" ]; then
        echo -e "${RED}Teks error tidak boleh kosong!${NC}"
        return 1
    fi
    
    # Update text in middleware
    sed -i "s/Ngapain sih? mau nyolong sc org? - By @ginaabaikhati/${new_text}/g" $PANEL_PATH/app/Http/Middleware/AdminIdRestriction.php 2>/dev/null
    sed -i "s/Ngapain sih? mau nyolong sc org? - By @ginaabaikhati/${new_text}/g" $PANEL_PATH/app/Http/Controllers/Admin/AdminControllerSecure.php 2>/dev/null
    sed -i "s/Ngapain sih? mau nyolong sc org? - By @ginaabaikhati/${new_text}/g" $PANEL_PATH/resources/views/errors/403_custom.blade.php 2>/dev/null
    
    # Clear cache
    cd $PANEL_PATH
    php artisan view:clear
    php artisan cache:clear
    
    echo -e "${GREEN}Teks error berhasil diubah!${NC}"
    echo -e "${BLUE}Teks baru: ${new_text}${NC}"
}

# Function to uninstall security
uninstall_security() {
    display_header
    echo -e "${YELLOW}Uninstalling Security Panel...${NC}"
    
    if [ ! -d "$BACKUP_PATH" ]; then
        echo -e "${RED}Backup tidak ditemukan! Tidak bisa uninstall.${NC}"
        return 1
    fi
    
    restore_backup
    
    # Remove created files
    rm -f $PANEL_PATH/app/Http/Middleware/AdminIdRestriction.php
    rm -f $PANEL_PATH/app/Http/Controllers/Admin/AdminControllerSecure.php
    rm -f $PANEL_PATH/app/Exceptions/HandlerSecure.php
    rm -f $PANEL_PATH/resources/views/errors/403_custom.blade.php
    
    # Clear cache
    cd $PANEL_PATH
    php artisan route:clear
    php artisan view:clear
    php artisan cache:clear
    
    echo -e "${GREEN}Security Panel berhasil diuninstall!${NC}"
}

# Function to check security status
check_status() {
    display_header
    echo -e "${YELLOW}Checking Security Status...${NC}"
    
    if [ -f "$PANEL_PATH/app/Http/Middleware/AdminIdRestriction.php" ]; then
        echo -e "${GREEN}✓ Security Middleware: Installed${NC}"
    else
        echo -e "${RED}✗ Security Middleware: Not Installed${NC}"
    fi
    
    if [ -f "$PANEL_PATH/app/Http/Controllers/Admin/AdminControllerSecure.php" ]; then
        echo -e "${GREEN}✓ Security Controller: Installed${NC}"
    else
        echo -e "${RED}✗ Security Controller: Not Installed${NC}"
    fi
    
    if [ -f "$PANEL_PATH/resources/views/errors/403_custom.blade.php" ]; then
        echo -e "${GREEN}✓ Custom Error Page: Installed${NC}"
    else
        echo -e "${RED}✗ Custom Error Page: Not Installed${NC}"
    fi
    
    echo -e "\n${BLUE}Security Configuration:${NC}"
    echo -e "${YELLOW}• Hanya admin ID 1 yang bisa akses:${NC}"
    echo -e "  - Servers, Nodes, Nests, Locations"
    echo -e "${GREEN}• Semua admin bisa akses:${NC}"
    echo -e "  - Settings"
}

# Main menu
while true; do
    display_header
    echo -e "${BLUE}Pilih opsi:${NC}"
    echo -e "1. Install Security Panel"
    echo -e "2. Ganti Teks Error" 
    echo -e "3. Uninstall Security Panel"
    echo -e "4. Check Status"
    echo -e "5. Exit"
    echo -e "=========================================="
    read -p "Masukkan pilihan [1-5]: " choice

    case $choice in
        1)
            install_security
            ;;
        2)
            change_error_text
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
    
    echo -e "\n${YELLOW}Tekan Enter untuk melanjutkan...${NC}"
    read
done
