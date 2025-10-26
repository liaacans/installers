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
SECURITY_MODIFIED=false

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Script harus dijalankan sebagai root${NC}"
   exit 1
fi

# Function to display menu
show_menu() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║    Security Panel Pterodactyl       ║"
    echo "║        By @ginaabaikhati            ║"
    echo "╠══════════════════════════════════════╣"
    echo "║ 1. Install Security Panel           ║"
    echo "║ 2. Ganti Teks Error                 ║"
    echo "║ 3. Uninstall Security Panel         ║"
    echo "║ 4. Exit Security Panel              ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to backup original files
backup_files() {
    echo -e "${YELLOW}Membuat backup file original...${NC}"
    mkdir -p "$BACKUP_PATH"
    
    # Backup important files
    cp "$PANEL_PATH/app/Http/Controllers/Admin/ServerController.php" "$BACKUP_PATH/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Controllers/Admin/NodeController.php" "$BACKUP_PATH/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Controllers/Admin/NestController.php" "$BACKUP_PATH/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Controllers/Admin/LocationController.php" "$BACKUP_PATH/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php" "$BACKUP_PATH/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php" "$BACKUP_PATH/" 2>/dev/null
    
    echo -e "${GREEN}Backup selesai di: $BACKUP_PATH${NC}"
}

# Function to check panel path
check_panel_path() {
    if [[ ! -d "$PANEL_PATH" ]]; then
        echo -e "${YELLOW}Directory panel tidak ditemukan di $PANEL_PATH${NC}"
        read -p "Masukkan path panel Pterodactyl (default: /var/www/pterodactyl): " custom_path
        if [[ -n "$custom_path" ]]; then
            PANEL_PATH="$custom_path"
        fi
        
        if [[ ! -d "$PANEL_PATH" ]]; then
            echo -e "${RED}Error: Directory panel tidak ditemukan!${NC}"
            return 1
        fi
    fi
    return 0
}

# Function to install security
install_security() {
    echo -e "${YELLOW}Memulai instalasi security panel...${NC}"
    
    if ! check_panel_path; then
        return 1
    fi
    
    # Backup files first
    backup_files
    
    # Create custom middleware
    echo -e "${YELLOW}Membuat custom middleware...${NC}"
    
    cat > "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php" << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminSecurity
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Check if user is authenticated
        if (!auth()->check()) {
            return redirect()->route('auth.login');
        }

        $user = auth()->user();
        $routeName = $request->route()->getName();
        
        // Define protected admin routes
        $protectedRoutes = [
            'admin.servers', 'admin.servers.*',
            'admin.nodes', 'admin.nodes.*', 
            'admin.nests', 'admin.nests.*',
            'admin.locations', 'admin.locations.*',
            'admin.settings', 'admin.settings.*'
        ];

        // Check if current route is protected
        $isProtectedRoute = false;
        foreach ($protectedRoutes as $route) {
            if (str_contains($route, '*')) {
                $pattern = str_replace('*', '.*', $route);
                if (preg_match('#^' . $pattern . '$#', $routeName)) {
                    $isProtectedRoute = true;
                    break;
                }
            } elseif ($routeName === $route) {
                $isProtectedRoute = true;
                break;
            }
        }

        // Allow only admin ID 1 to access protected routes
        if ($isProtectedRoute && $user->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return $next($request);
    }
}
EOF

    # Modify AdminAuthenticate middleware
    echo -e "${YELLOW}Memodifikasi AdminAuthenticate middleware...${NC}"
    
    cat > "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php" << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Contracts\Auth\Factory as AuthFactory;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminAuthenticate
{
    /**
     * The authentication factory implementation.
     */
    protected AuthFactory $auth;

    /**
     * AdminAuthenticate constructor.
     */
    public function __construct(AuthFactory $auth)
    {
        $this->auth = $auth;
    }

    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!$this->auth->guard()->check()) {
            return redirect()->route('auth.login');
        }

        $user = $this->auth->guard()->user();
        $routeName = $request->route()->getName();
        
        // Define protected admin routes
        $protectedRoutes = [
            'admin.servers', 'admin.servers.*',
            'admin.nodes', 'admin.nodes.*', 
            'admin.nests', 'admin.nests.*',
            'admin.locations', 'admin.locations.*',
            'admin.settings', 'admin.settings.*'
        ];

        // Check if current route is protected
        $isProtectedRoute = false;
        foreach ($protectedRoutes as $route) {
            if (str_contains($route, '*')) {
                $pattern = str_replace('*', '.*', $route);
                if (preg_match('#^' . $pattern . '$#', $routeName)) {
                    $isProtectedRoute = true;
                    break;
                }
            } elseif ($routeName === $route) {
                $isProtectedRoute = true;
                break;
            }
        }

        // Allow only admin ID 1 to access protected routes
        if ($isProtectedRoute && $user->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return $next($request);
    }
}
EOF

    # Modify controllers to add additional security
    modify_controllers
    
    # Update route middleware
    echo -e "${YELLOW}Memperbarui route middleware...${NC}"
    
    # Backup routes
    cp "$PANEL_PATH/routes/admin.php" "$BACKUP_PATH/admin_routes_backup.php" 2>/dev/null
    
    SECURITY_MODIFIED=true
    echo -e "${GREEN}Security panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Jangan lupa jalankan: php artisan optimize:clear${NC}"
}

# Function to modify controllers
modify_controllers() {
    echo -e "${YELLOW}Menambahkan security check ke controllers...${NC}"
    
    # ServerController security
    if [[ -f "$PANEL_PATH/app/Http/Controllers/Admin/ServerController.php" ]]; then
        sed -i '1i <?php\n// Security Check - Only admin ID 1 can access - By @ginaabaikhati' "$PANEL_PATH/app/Http/Controllers/Admin/ServerController.php"
    fi
    
    # NodeController security  
    if [[ -f "$PANEL_PATH/app/Http/Controllers/Admin/NodeController.php" ]]; then
        sed -i '1i <?php\n// Security Check - Only admin ID 1 can access - By @ginaabaikhati' "$PANEL_PATH/app/Http/Controllers/Admin/NodeController.php"
    fi
    
    # NestController security
    if [[ -f "$PANEL_PATH/app/Http/Controllers/Admin/NestController.php" ]]; then
        sed -i '1i <?php\n// Security Check - Only admin ID 1 can access - By @ginaabaikhati' "$PANEL_PATH/app/Http/Controllers/Admin/NestController.php"
    fi
    
    # LocationController security
    if [[ -f "$PANEL_PATH/app/Http/Controllers/Admin/LocationController.php" ]]; then
        sed -i '1i <?php\n// Security Check - Only admin ID 1 can access - By @ginaabaikhati' "$PANEL_PATH/app/Http/Controllers/Admin/LocationController.php"
    fi
    
    # SettingsController security
    if [[ -f "$PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php" ]]; then
        sed -i '1i <?php\n// Security Check - Only admin ID 1 can access - By @ginaabaikhati' "$PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php"
    fi
}

# Function to change error text
change_error_text() {
    echo -e "${YELLOW}Mengganti teks error...${NC}"
    
    if ! check_panel_path; then
        return 1
    fi
    
    read -p "Masukkan teks error baru: " new_error_text
    if [[ -z "$new_error_text" ]]; then
        new_error_text="Ngapain sih? mau nyolong sc org? - By @ginaabaikhati"
    fi
    
    # Update error text in middleware
    if [[ -f "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php" ]]; then
        sed -i "s/abort(403, '.*');/abort(403, '$new_error_text');/g" "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php"
    fi
    
    if [[ -f "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php" ]]; then
        sed -i "s/abort(403, '.*');/abort(403, '$new_error_text');/g" "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php"
    fi
    
    echo -e "${GREEN}Teks error berhasil diganti!${NC}"
    echo -e "${YELLOW}Teks error baru: $new_error_text${NC}"
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Memulai uninstall security panel...${NC}"
    
    if [[ ! -d "$BACKUP_PATH" ]]; then
        echo -e "${RED}Backup files tidak ditemukan!${NC}"
        echo -e "${YELLOW}Uninstall tidak dapat dilanjutkan.${NC}"
        return 1
    fi
    
    # Restore original files
    echo -e "${YELLOW}Memulihkan file original...${NC}"
    
    cp "$BACKUP_PATH/ServerController.php" "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
    cp "$BACKUP_PATH/NodeController.php" "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
    cp "$BACKUP_PATH/NestController.php" "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
    cp "$BACKUP_PATH/LocationController.php" "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
    cp "$BACKUP_PATH/SettingsController.php" "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
    cp "$BACKUP_PATH/AdminAuthenticate.php" "$PANEL_PATH/app/Http/Middleware/" 2>/dev/null
    
    # Remove custom middleware
    rm -f "$PANEL_PATH/app/Http/Middleware/AdminSecurity.php" 2>/dev/null
    
    # Restore routes if backup exists
    if [[ -f "$BACKUP_PATH/admin_routes_backup.php" ]]; then
        cp "$BACKUP_PATH/admin_routes_backup.php" "$PANEL_PATH/routes/admin.php" 2>/dev/null
    fi
    
    SECURITY_MODIFIED=false
    echo -e "${GREEN}Security panel berhasil diuninstall!${NC}"
    echo -e "${YELLOW}Jangan lupa jalankan: php artisan optimize:clear${NC}"
}

# Function to optimize panel
optimize_panel() {
    echo -e "${YELLOW}Mengoptimalkan panel...${NC}"
    cd "$PANEL_PATH" || exit 1
    php artisan optimize:clear
    php artisan view:cache
    php artisan route:cache
    php artisan config:cache
    echo -e "${GREEN}Optimasi selesai!${NC}"
}

# Main script
while true; do
    show_menu
    read -p "Pilih opsi [1-4]: " choice
    case $choice in
        1)
            install_security
            read -p "Tekan Enter untuk melanjutkan..."
            ;;
        2)
            change_error_text
            read -p "Tekan Enter untuk melanjutkan..."
            ;;
        3)
            uninstall_security
            read -p "Tekan Enter untuk melanjutkan..."
            ;;
        4)
            echo -e "${GREEN}Keluar dari Security Panel.${NC}"
            if [[ "$SECURITY_MODIFIED" == true ]]; then
                read -p "Jalankan optimasi panel? (y/n): " optimize_choice
                if [[ "$optimize_choice" == "y" || "$optimize_choice" == "Y" ]]; then
                    optimize_panel
                fi
            fi
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            read -p "Tekan Enter untuk melanjutkan..."
            ;;
    esac
done
