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
SECURITY_MODIFIED=false

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
        echo -e "${RED}Error: Script must be run as root${NC}"
        exit 1
    fi
}

# Function to check if Pterodactyl panel exists
check_panel() {
    if [[ ! -d "$PANEL_PATH" ]]; then
        echo -e "${RED}Error: Pterodactyl panel not found at $PANEL_PATH${NC}"
        echo -e "${YELLOW}Please update PANEL_PATH variable in the script${NC}"
        exit 1
    fi
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Creating backup...${NC}"
    mkdir -p "$BACKUP_DIR"
    cp -r "$PANEL_PATH/app" "$BACKUP_DIR/app_backup_$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}Backup created successfully${NC}"
}

# Function to restore backup
restore_backup() {
    local latest_backup=$(ls -td "$BACKUP_DIR"/app_backup_* | head -1)
    if [[ -n "$latest_backup" ]]; then
        echo -e "${YELLOW}Restoring from backup: $latest_backup${NC}"
        rm -rf "$PANEL_PATH/app"
        cp -r "$latest_backup" "$PANEL_PATH/app"
        echo -e "${GREEN}Backup restored successfully${NC}"
    else
        echo -e "${RED}No backup found to restore${NC}"
    fi
}

# Function to install security
install_security() {
    display_header
    echo -e "${YELLOW}Installing Security Panel...${NC}"
    
    check_root
    check_panel
    create_backup
    
    # Modify middleware to restrict access
    modify_middleware
    
    # Modify controllers to restrict access
    modify_controllers
    
    # Modify error messages
    modify_error_messages
    
    # Clear cache
    clear_cache
    
    SECURITY_MODIFIED=true
    echo -e "${GREEN}Security Panel installed successfully!${NC}"
    echo -e "${YELLOW}Only admin with ID 1 can access servers, nodes, nests, locations, and settings.${NC}"
}

# Function to modify middleware
modify_middleware() {
    echo -e "${YELLOW}Modifying middleware...${NC}"
    
    # Admin middleware
    local admin_middleware="$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php"
    if [[ -f "$admin_middleware" ]]; then
        # Backup original
        cp "$admin_middleware" "$admin_middleware.backup"
        
        # Add admin ID check
        cat > "$admin_middleware" << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class AdminAuthenticate
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
        $user = $request->user();
        
        // Security restriction: Only admin with ID 1 can access
        if (is_null($user) || !$user->root_admin || $user->id !== 1) {
            $path = $request->path();
            
            // Check if trying to access restricted areas
            if (strpos($path, 'admin/servers') !== false || 
                strpos($path, 'admin/nodes') !== false ||
                strpos($path, 'admin/nests') !== false ||
                strpos($path, 'admin/locations') !== false ||
                strpos($path, 'admin/settings') !== false) {
                throw new AccessDeniedHttpException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
            }
        }

        return $next($request);
    }
}
EOF
        echo -e "${GREEN}Admin middleware modified${NC}"
    fi
}

# Function to modify controllers
modify_controllers() {
    echo -e "${YELLOW}Modifying controllers...${NC}"
    
    # Array of controller files to modify
    local controllers=(
        "ServerController"
        "NodeController" 
        "NestController"
        "LocationController"
        "SettingsController"
    )
    
    for controller in "${controllers[@]}"; do
        local controller_file="$PANEL_PATH/app/Http/Controllers/Admin/$controller.php"
        local controller_path=$(find "$PANEL_PATH" -name "$controller.php" -type f | head -1)
        
        if [[ -n "$controller_path" ]]; then
            # Backup original
            cp "$controller_path" "$controller_path.backup"
            
            # Add security check to constructor
            if grep -q "public function __construct" "$controller_path"; then
                # Insert security check after constructor
                sed -i '/public function __construct/,/^    \}/{/^    \}/a\
    \    /**\
    \     * Security restriction: Only admin with ID 1 can access\
    \     */\
    \    public function checkAdminAccess()\
    \    {\
    \        if (auth()->user()->id !== 1) {\
    \            throw new \\Symfony\\Component\\HttpKernel\\Exception\\AccessDeniedHttpException(\"Ngapain sih? mau nyolong sc org? - By @ginaabaikhati\");\
    \        }\
    \    }\
    \
    \    public function __construct()\
    \    {\
    \        $this->checkAdminAccess();\
    \    }' "$controller_path"
            else
                # Add constructor with security check
                sed -i "s/<?php/<?php\n\nuse Symfony\\Component\\HttpKernel\\Exception\\AccessDeniedHttpException;/" "$controller_path"
                sed -i "/class $controller/a\\\n    /**\n     * Security restriction: Only admin with ID 1 can access\n     */\n    public function __construct()\n    {\n        if (auth()->check() && auth()->user()->id !== 1) {\n            throw new AccessDeniedHttpException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');\n        }\n    }" "$controller_path"
            fi
            
            echo -e "${GREEN}Modified $controller${NC}"
        fi
    done
}

# Function to modify error messages
modify_error_messages() {
    echo -e "${YELLOW}Modifying error messages...${NC}"
    
    # Modify exception handler
    local exception_handler="$PANEL_PATH/app/Exceptions/Handler.php"
    if [[ -f "$exception_handler" ]]; then
        cp "$exception_handler" "$exception_handler.backup"
        
        # Replace 403 error message
        sed -i "s/return response()->view('errors\.403', \[\], 403)/return response()->view('errors.403', ['message' => 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'], 403)/g" "$exception_handler"
        
        # Replace 404 error message  
        sed -i "s/return response()->view('errors\.404', \[\], 404)/return response()->view('errors.404', ['message' => 'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'], 404)/g" "$exception_handler"
        
        echo -e "${GREEN}Error messages modified${NC}"
    fi
    
    # Modify error views
    local error_403="$PANEL_PATH/resources/views/errors/403.blade.php"
    if [[ -f "$error_403" ]]; then
        cp "$error_403" "$error_403.backup"
        cat > "$error_403" << 'EOF'
@extends('layouts.error')

@section('title', 'Forbidden')

@section('content')
    <div class="flex flex-col justify-center text-center h-full">
        <h1 class="text-4xl font-bold text-white mb-4">403</h1>
        <h2 class="text-2xl font-light text-white mb-10">
            <i class="fa fa-exclamation-triangle mr-2 text-warning"></i>Forbidden
        </h2>
        <p class="text-lg text-white mb-4">
            Ngapain sih? mau nyolong sc org? - By @ginaabaikhati
        </p>
        <a href="/" class="text-blue-400 hover:text-blue-300 underline">Return to Home</a>
    </div>
@endsection
EOF
        echo -e "${GREEN}403 error page modified${NC}"
    fi
    
    local error_404="$PANEL_PATH/resources/views/errors/404.blade.php"
    if [[ -f "$error_404" ]]; then
        cp "$error_404" "$error_404.backup"
        cat > "$error_404" << 'EOF'
@extends('layouts.error')

@section('title', 'Not Found')

@section('content')
    <div class="flex flex-col justify-center text-center h-full">
        <h1 class="text-4xl font-bold text-white mb-4">404</h1>
        <h2 class="text-2xl font-light text-white mb-10">
            <i class="fa fa-question-circle mr-2 text-warning"></i>Not Found
        </h2>
        <p class="text-lg text-white mb-4">
            Ngapain sih? mau nyolong sc org? - By @ginaabaikhati
        </p>
        <a href="/" class="text-blue-400 hover:text-blue-300 underline">Return to Home</a>
    </div>
@endsection
EOF
        echo -e "${GREEN}404 error page modified${NC}"
    fi
}

# Function to clear cache
clear_cache() {
    echo -e "${YELLOW}Clearing cache...${NC}"
    cd "$PANEL_PATH"
    php artisan cache:clear
    php artisan view:clear
    php artisan config:clear
    echo -e "${GREEN}Cache cleared${NC}"
}

# Function to uninstall security
uninstall_security() {
    display_header
    echo -e "${YELLOW}Uninstalling Security Panel...${NC}"
    
    check_root
    check_panel
    
    # Restore from backup
    restore_backup
    
    # Clear cache
    clear_cache
    
    SECURITY_MODIFIED=false
    echo -e "${GREEN}Security Panel uninstalled successfully!${NC}"
}

# Function to show menu
show_menu() {
    display_header
    echo -e "${YELLOW}Select an option:${NC}"
    echo -e "1. Install Security Panel"
    echo -e "2. Ganti Teks Error" 
    echo -e "3. Uninstall Security Panel"
    echo -e "4. Exit Security Panel"
    echo
    echo -n "Enter your choice [1-4]: "
}

# Function to change error text
change_error_text() {
    display_header
    echo -e "${YELLOW}Changing error text...${NC}"
    
    check_root
    check_panel
    
    # Modify error messages
    modify_error_messages
    
    # Clear cache
    clear_cache
    
    echo -e "${GREEN}Error text changed successfully!${NC}"
}

# Main script execution
main() {
    while true; do
        show_menu
        read choice
        
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
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
        
        echo
        echo -e "${YELLOW}Press any key to continue...${NC}"
        read -n 1
    done
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
