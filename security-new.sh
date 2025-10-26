#!/bin/bash

# Security Panel Pterodactyl
# By: @ginaabaikhati
# Description: Security script to restrict access to admin ID 1 only

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Security configuration
SECURITY_DIR="/var/www/pterodactyl-security"
BACKUP_DIR="$SECURITY_DIR/backups"
LOG_FILE="$SECURITY_DIR/security.log"
ERROR_MESSAGE="Ngapain sih? mau nyolong sc org? - By @ginaabaikhati"

# Pterodactyl paths (adjust if needed)
PTERODACTYL_DIR="/var/www/pterodactyl"
CONTROLLERS_DIR="$PTERODACTYL_DIR/app/Http/Controllers"
MIDDLEWARE_DIR="$PTERODACTYL_DIR/app/Http/Middleware"
ROUTES_DIR="$PTERODACTYL_DIR/routes"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to show error
show_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log_action "ERROR: $1"
}

# Function to show success
show_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log_action "SUCCESS: $1"
}

# Function to show warning
show_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log_action "WARNING: $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        show_warning "Running as root user"
        return 0
    else
        show_error "This script requires root privileges. Please run with sudo."
        exit 1
    fi
}

# Function to check Pterodactyl installation
check_pterodactyl() {
    if [ ! -d "$PTERODACTYL_DIR" ]; then
        show_error "Pterodactyl directory not found at $PTERODACTYL_DIR"
        exit 1
    fi
    
    if [ ! -d "$CONTROLLERS_DIR" ]; then
        show_error "Controllers directory not found at $CONTROLLERS_DIR"
        exit 1
    fi
    
    show_success "Pterodactyl installation verified"
}

# Function to create security directory
create_security_dir() {
    mkdir -p "$SECURITY_DIR" "$BACKUP_DIR"
    chmod 700 "$SECURITY_DIR"
    show_success "Security directory created"
}

# Function to backup original files
backup_files() {
    local files=(
        "$CONTROLLERS_DIR/Admin"
        "$MIDDLEWARE_DIR/AdminAuthenticate.php"
        "$ROUTES_DIR/admin.php"
    )
    
    for file in "${files[@]}"; do
        if [ -e "$file" ]; then
            local backup_name=$(basename "$file")-$(date +%Y%m%d%H%M%S)
            cp -r "$file" "$BACKUP_DIR/$backup_name"
            show_success "Backed up: $file"
        fi
    done
}

# Function to create custom middleware
create_custom_middleware() {
    cat > "$MIDDLEWARE_DIR/AdminSecurityMiddleware.php" << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminSecurityMiddleware
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
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        // Get current user
        $user = auth()->user();
        $currentRoute = $request->route()->getName();

        // Define restricted routes for non-admin-id-1 users
        $restrictedRoutes = [
            'admin.servers',
            'admin.nodes', 
            'admin.nests',
            'admin.locations',
            'admin.settings'
        ];

        // Check if current route is in restricted list and user is not admin ID 1
        if (in_array($currentRoute, $restrictedRoutes) && $user->id !== 1) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        return $next($request);
    }
}
EOF
    show_success "Custom middleware created"
}

# Function to modify AdminAuthenticate middleware
modify_admin_middleware() {
    if [ -f "$MIDDLEWARE_DIR/AdminAuthenticate.php" ]; then
        # Backup original
        cp "$MIDDLEWARE_DIR/AdminAuthenticate.php" "$BACKUP_DIR/AdminAuthenticate.php.backup"
        
        # Create modified version
        cat > "$MIDDLEWARE_DIR/AdminAuthenticate.php" << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Contracts\Auth\Factory as Auth;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminAuthenticate
{
    /**
     * The authentication factory instance.
     */
    protected Auth $auth;

    /**
     * Create a new middleware instance.
     */
    public function __construct(Auth $auth)
    {
        $this->auth = $auth;
    }

    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Check if user is authenticated
        if (!$this->auth->guard()->check()) {
            abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }

        $user = $this->auth->guard()->user();
        $currentRoute = $request->route()->getName();

        // Define admin-only routes
        $adminRoutes = [
            'admin.*',
            'api.admin.*'
        ];

        // Check if user is trying to access admin routes
        $isAdminRoute = false;
        foreach ($adminRoutes as $pattern) {
            if (\Illuminate\Support\Str::is($pattern, $currentRoute)) {
                $isAdminRoute = true;
                break;
            }
        }

        if ($isAdminRoute) {
            // Define restricted admin sections for non-admin-id-1 users
            $restrictedSections = [
                'admin.servers',
                'admin.nodes',
                'admin.nests', 
                'admin.locations',
                'admin.settings'
            ];

            // Check if current route matches restricted sections and user is not admin ID 1
            foreach ($restrictedSections as $section) {
                if (\Illuminate\Support\Str::is($section . '.*', $currentRoute) && $user->id !== 1) {
                    abort(403, 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
                }
            }
        }

        return $next($request);
    }
}
EOF
        show_success "AdminAuthenticate middleware modified"
    else
        show_warning "AdminAuthenticate.php not found, skipping modification"
    fi
}

# Function to modify controllers
modify_controllers() {
    # Modify AdminController if exists
    if [ -f "$CONTROLLERS_DIR/Admin/AdminController.php" ]; then
        cp "$CONTROLLERS_DIR/Admin/AdminController.php" "$BACKUP_DIR/AdminController.php.backup"
        
        # Add security check to AdminController constructor
        sed -i '/public function __construct()/a\        if (auth()->check() && auth()->user()->id !== 1) {\n            abort(403, "Ngapain sih? mau nyolong sc org? - By @ginaabaikhati");\n        }' "$CONTROLLERS_DIR/Admin/AdminController.php"
        
        show_success "AdminController modified"
    fi

    # Modify specific admin controllers
    local controllers=("ServerController" "NodeController" "NestController" "LocationController" "SettingsController")
    
    for controller in "${controllers[@]}"; do
        local controller_path="$CONTROLLERS_DIR/Admin/${controller}.php"
        if [ -f "$controller_path" ]; then
            cp "$controller_path" "$BACKUP_DIR/${controller}.php.backup"
            
            # Check if constructor already exists
            if grep -q "public function __construct()" "$controller_path"; then
                # Add security check to existing constructor
                sed -i '/public function __construct()/{n;a\        if (auth()->check() && auth()->user()->id !== 1) {\n            abort(403, "Ngapain sih? mau nyolong sc org? - By @ginaabaikhati");\n        }' "$controller_path"
            else
                # Add new constructor with security check
                sed -i "/class [a-zA-Z]*Controller extends Controller/a\    public function __construct()\n    {\n        parent::__construct();\n        if (auth()->check() && auth()->user()->id !== 1) {\n            abort(403, \"Ngapain sih? mau nyolong sc org? - By @ginaabaikhati\");\n        }\n    }" "$controller_path"
            fi
            
            show_success "${controller} modified"
        else
            show_warning "${controller} not found, skipping"
        fi
    done
}

# Function to update routes safely
update_routes() {
    local routes_file="$ROUTES_DIR/admin.php"
    
    if [ -f "$routes_file" ]; then
        cp "$routes_file" "$BACKUP_DIR/admin_routes.php.backup"
        
        # Check if the file already has PHP opening tag
        if ! head -n 1 "$routes_file" | grep -q "<?php"; then
            show_error "Routes file doesn't start with PHP tag. Fixing..."
            # Add PHP opening tag
            echo "<?php" > "$routes_file.tmp"
            cat "$BACKUP_DIR/admin_routes.php.backup" >> "$routes_file.tmp"
            mv "$routes_file.tmp" "$routes_file"
        fi
        
        # Create a temporary file with the security wrapper
        cat > "$routes_file.tmp" << 'EOF'
<?php

// =========================================
// Security Wrapper - Admin ID 1 Only
// By: @ginaabaikhati
// =========================================

use Illuminate\Support\Facades\Route;

Route::group(['middleware' => ['auth', 'admin']], function () {
EOF

        # Add the original content (without opening PHP tag)
        grep -v "<?php" "$BACKUP_DIR/admin_routes.php.backup" >> "$routes_file.tmp"
        
        # Close the route group
        echo -e "\n}); // End Security Wrapper" >> "$routes_file.tmp"
        
        # Replace the original file
        mv "$routes_file.tmp" "$routes_file"
        
        show_success "Routes file updated with security wrapper"
    else
        show_warning "Admin routes file not found at $routes_file"
    fi
}

# Function to create kernel modification
modify_kernel() {
    local kernel_file="$PTERODACTYL_DIR/app/Http/Kernel.php"
    
    if [ -f "$kernel_file" ]; then
        cp "$kernel_file" "$BACKUP_DIR/Kernel.php.backup"
        
        # Add the custom middleware to kernel
        if ! grep -q "AdminSecurityMiddleware" "$kernel_file"; then
            sed -i "/protected \$routeMiddleware = \[/a\        'admin.security' => \\App\\Http\\Middleware\\AdminSecurityMiddleware::class," "$kernel_file"
            show_success "Kernel updated with custom middleware"
        else
            show_warning "AdminSecurityMiddleware already exists in kernel"
        fi
    else
        show_warning "Kernel file not found, skipping kernel modification"
    fi
}

# Function to clear cache
clear_cache() {
    cd "$PTERODACTYL_DIR"
    php artisan config:clear
    php artisan route:clear
    php artisan view:clear
    php artisan cache:clear
    show_success "Application cache cleared"
}

# Function to fix route file syntax
fix_route_syntax() {
    local routes_file="$ROUTES_DIR/admin.php"
    
    if [ -f "$routes_file" ]; then
        # Check for syntax errors
        if ! php -l "$routes_file" > /dev/null 2>&1; then
            show_warning "Syntax error detected in routes file. Fixing..."
            
            # Restore from backup and apply safe modification
            if [ -f "$BACKUP_DIR/admin_routes.php.backup" ]; then
                cp "$BACKUP_DIR/admin_routes.php.backup" "$routes_file"
                
                # Apply safe route modification
                update_routes
                
                # Verify the fix
                if php -l "$routes_file" > /dev/null 2>&1; then
                    show_success "Route syntax fixed successfully"
                else
                    show_error "Failed to fix route syntax. Restoring original..."
                    cp "$BACKUP_DIR/admin_routes.php.backup" "$routes_file"
                fi
            else
                show_error "No backup found for routes file. Cannot fix automatically."
            fi
        else
            show_success "Route file syntax is valid"
        fi
    fi
}

# Function to install security
install_security() {
    log_action "Starting security installation"
    
    check_root
    check_pterodactyl
    create_security_dir
    backup_files
    create_custom_middleware
    modify_admin_middleware
    modify_controllers
    modify_kernel
    update_routes
    fix_route_syntax
    clear_cache
    
    show_success "Security panel installed successfully!"
    show_warning "Only Admin ID 1 can access servers, nodes, nests, locations, and settings"
    show_warning "Other admins will see the security error message"
}

# Function to change error text
change_error_text() {
    read -p "Enter new error text: " new_error_text
    
    if [ -z "$new_error_text" ]; then
        show_error "Error text cannot be empty"
        return 1
    fi
    
    # Update error message in all modified files
    local files=(
        "$MIDDLEWARE_DIR/AdminAuthenticate.php"
        "$MIDDLEWARE_DIR/AdminSecurityMiddleware.php"
        "$CONTROLLERS_DIR/Admin/AdminController.php"
        "$CONTROLLERS_DIR/Admin/ServerController.php"
        "$CONTROLLERS_DIR/Admin/NodeController.php"
        "$CONTROLLERS_DIR/Admin/NestController.php"
        "$CONTROLLERS_DIR/Admin/LocationController.php"
        "$CONTROLLERS_DIR/Admin/SettingsController.php"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            sed -i "s/Ngapain sih? mau nyolong sc org? - By @ginaabaikhati/$(echo "$new_error_text" | sed 's/\//\\\//g')/g" "$file"
            show_success "Updated: $(basename "$file")"
        fi
    done
    
    ERROR_MESSAGE="$new_error_text"
    clear_cache
    
    show_success "Error text changed successfully to: $new_error_text"
    log_action "Error text changed to: $new_error_text"
}

# Function to uninstall security
uninstall_security() {
    log_action "Starting security uninstallation"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        show_error "Backup directory not found. Cannot uninstall."
        exit 1
    fi
    
    # Restore backed up files
    show_warning "Restoring original files from backup..."
    
    # Restore routes file first
    if [ -f "$BACKUP_DIR/admin_routes.php.backup" ]; then
        cp "$BACKUP_DIR/admin_routes.php.backup" "$ROUTES_DIR/admin.php"
        show_success "Restored routes file"
    fi
    
    # Restore middleware
    if [ -f "$BACKUP_DIR/AdminAuthenticate.php.backup" ]; then
        cp "$BACKUP_DIR/AdminAuthenticate.php.backup" "$MIDDLEWARE_DIR/AdminAuthenticate.php"
        show_success "Restored AdminAuthenticate middleware"
    fi
    
    # Restore kernel
    if [ -f "$BACKUP_DIR/Kernel.php.backup" ]; then
        cp "$BACKUP_DIR/Kernel.php.backup" "$PTERODACTYL_DIR/app/Http/Kernel.php"
        show_success "Restored Kernel"
    fi
    
    # Restore controllers
    local controllers=("AdminController" "ServerController" "NodeController" "NestController" "LocationController" "SettingsController")
    for controller in "${controllers[@]}"; do
        if [ -f "$BACKUP_DIR/${controller}.php.backup" ]; then
            cp "$BACKUP_DIR/${controller}.php.backup" "$CONTROLLERS_DIR/Admin/${controller}.php"
            show_success "Restored ${controller}"
        fi
    done
    
    # Remove custom middleware
    if [ -f "$MIDDLEWARE_DIR/AdminSecurityMiddleware.php" ]; then
        rm "$MIDDLEWARE_DIR/AdminSecurityMiddleware.php"
        show_success "Removed custom middleware"
    fi
    
    clear_cache
    
    show_success "Security panel uninstalled successfully!"
    show_warning "All restrictions have been removed"
}

# Function to show menu
show_menu() {
    echo -e "\n${BLUE}=========================================${NC}"
    echo -e "${BLUE}    Pterodactyl Security Panel${NC}"
    echo -e "${BLUE}    By: @ginaabaikhati${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${GREEN}1.${NC} Install Security Panel"
    echo -e "${GREEN}2.${NC} Ganti Teks Error" 
    echo -e "${GREEN}3.${NC} Uninstall Security Panel"
    echo -e "${GREEN}4.${NC} Exit Security Panel"
    echo -e "${BLUE}=========================================${NC}"
    echo -n "Pilih opsi [1-4]: "
}

# Function to verify installation
verify_installation() {
    echo -e "\n${BLUE}Verifying installation...${NC}"
    
    # Check if middleware files exist
    if [ -f "$MIDDLEWARE_DIR/AdminSecurityMiddleware.php" ]; then
        show_success "Custom middleware installed"
    else
        show_error "Custom middleware missing"
    fi
    
    # Check if routes file is syntactically correct
    if [ -f "$ROUTES_DIR/admin.php" ]; then
        if php -l "$ROUTES_DIR/admin.php" > /dev/null 2>&1; then
            show_success "Routes file syntax is valid"
        else
            show_error "Routes file has syntax errors"
        fi
    fi
    
    # Check if controllers are modified
    local modified_count=0
    local controllers=("AdminController" "ServerController" "NodeController" "NestController" "LocationController" "SettingsController")
    for controller in "${controllers[@]}"; do
        if [ -f "$CONTROLLERS_DIR/Admin/${controller}.php" ] && grep -q "abort(403" "$CONTROLLERS_DIR/Admin/${controller}.php"; then
            ((modified_count++))
        fi
    done
    
    if [ $modified_count -gt 0 ]; then
        show_success "$modified_count controllers secured"
    else
        show_warning "No controllers modified yet"
    fi
}

# Main script
main() {
    # Check if security directory exists for persistence
    if [ ! -d "$SECURITY_DIR" ]; then
        mkdir -p "$SECURITY_DIR"
    fi
    
    while true; do
        show_menu
        read choice
        
        case $choice in
            1)
                install_security
                verify_installation
                ;;
            2)
                change_error_text
                ;;
            3)
                uninstall_security
                ;;
            4)
                echo -e "${GREEN}Terima kasih telah menggunakan Security Panel!${NC}"
                log_action "User exited security panel"
                exit 0
                ;;
            *)
                show_error "Pilihan tidak valid. Silakan pilih 1-4."
                ;;
        esac
        
        echo
        read -p "Tekan Enter untuk melanjutkan..."
    done
}

# Check if script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    case "${1:-}" in
        "install")
            install_security
            verify_installation
            ;;
        "uninstall")
            uninstall_security
            ;;
        "change-text")
            change_error_text
            ;;
        "verify")
            verify_installation
            ;;
        *)
            main
            ;;
    esac
fi
