#!/bin/bash

# Security Panel Pterodactyl - By @ginaabaikhati
# Hanya admin ID 1 yang bisa mengakses semua fitur

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Security configuration
SECURITY_DIR="/var/www/pterodactyl-security"
BACKUP_DIR="/var/www/pterodactyl-backups"
PANEL_DIR="/var/www/pterodactyl"

# Error message
ERROR_MSG="Ngapain sih? mau nyolong sc org? - By @ginaabaikhati"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Script harus dijalankan sebagai root${NC}"
   exit 1
fi

# Function to display header
display_header() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║           Pterodactyl Security Panel         ║"
    echo "║            By @ginaabaikhati                 ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to check if Pterodactyl is installed
check_pterodactyl() {
    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "${RED}Error: Directory Pterodactyl tidak ditemukan di $PANEL_DIR${NC}"
        exit 1
    fi
    
    if [ ! -f "$PANEL_DIR/app/Http/Controllers/Admin/AdminController.php" ]; then
        echo -e "${RED}Error: File controller admin tidak ditemukan${NC}"
        exit 1
    fi
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup panel...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi
    
    BACKUP_FILE="$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar -czf "$BACKUP_FILE" -C /var/www/pterodactyl . 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Backup berhasil dibuat: $BACKUP_FILE${NC}"
    else
        echo -e "${RED}Warning: Gagal membuat backup${NC}"
    fi
}

# Function to install security
install_security() {
    display_header
    echo -e "${YELLOW}[1] Memulai instalasi security panel...${NC}"
    
    check_pterodactyl
    create_backup
    
    # Create security directory
    mkdir -p "$SECURITY_DIR"
    
    echo -e "${YELLOW}Mengimplementasikan security restrictions...${NC}"
    
    # Backup original files
    cp "$PANEL_DIR/app/Http/Controllers/Admin/AdminController.php" "$SECURITY_DIR/AdminController.backup"
    cp "$PANEL_DIR/app/Http/Controllers/Admin/ServersController.php" "$SECURITY_DIR/ServersController.backup"
    cp "$PANEL_DIR/app/Http/Controllers/Admin/NodesController.php" "$SECURITY_DIR/NodesController.backup"
    cp "$PANEL_DIR/app/Http/Controllers/Admin/NestsController.php" "$SECURITY_DIR/NestsController.backup"
    cp "$PANEL_DIR/app/Http/Controllers/Admin/LocationsController.php" "$SECURITY_DIR/LocationsController.backup"
    cp "$PANEL_DIR/app/Http/Controllers/Admin/SettingsController.php" "$SECURITY_DIR/SettingsController.backup"
    
    # 1. Modify AdminController untuk general admin access
    cat > "$PANEL_DIR/app/Http/Controllers/Admin/AdminController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Pterodactyl\Exceptions\DisplayException;

class AdminController extends Controller
{
    /**
     * AdminController constructor.
     */
    public function __construct()
    {
        //
    }

    /**
     * Return the admin index view.
     */
    public function index(): View
    {
        // Security check - hanya admin ID 1 yang bisa akses
        if (auth()->user()->id !== 1) {
            throw new DisplayException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
        
        return view('admin.index');
    }
    
    /**
     * Handle other admin methods
     */
    public function __call($method, $parameters)
    {
        // Security check - hanya admin ID 1 yang bisa akses
        if (auth()->user()->id !== 1) {
            throw new DisplayException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
        
        return parent::__call($method, $parameters);
    }
}
EOF

    # 2. Modify ServersController untuk server access
    cat > "$PANEL_DIR/app/Http/Controllers/Admin/ServersController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Exceptions\DisplayException;

class ServersController extends Controller
{
    /**
     * ServersController constructor.
     */
    public function __construct()
    {
        //
    }

    /**
     * Return the servers index view.
     */
    public function index(): View
    {
        // Security check - hanya admin ID 1 yang bisa akses
        if (auth()->user()->id !== 1) {
            throw new DisplayException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
        
        return view('admin.servers.index');
    }
    
    /**
     * Handle server views
     */
    public function view($id): View
    {
        // Security check - hanya admin ID 1 yang bisa akses
        if (auth()->user()->id !== 1) {
            throw new DisplayException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
        
        return view('admin.servers.view', compact('id'));
    }
    
    /**
     * Handle other server methods
     */
    public function __call($method, $parameters)
    {
        // Security check - hanya admin ID 1 yang bisa akses
        if (auth()->user()->id !== 1) {
            throw new DisplayException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
        
        return parent::__call($method, $parameters);
    }
}
EOF

    # 3. Modify NodesController untuk nodes access
    cat > "$PANEL_DIR/app/Http/Controllers/Admin/NodesController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Exceptions\DisplayException;

class NodesController extends Controller
{
    /**
     * NodesController constructor.
     */
    public function __construct()
    {
        //
    }

    /**
     * Return the nodes index view.
     */
    public function index(): View
    {
        // Security check - hanya admin ID 1 yang bisa akses
        if (auth()->user()->id !== 1) {
            throw new DisplayException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
        
        return view('admin.nodes.index');
    }
    
    /**
     * Handle node views
     */
    public function view($id): View
    {
        // Security check - hanya admin ID 1 yang bisa akses
        if (auth()->user()->id !== 1) {
            throw new DisplayException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
        
        return view('admin.nodes.view', compact('id'));
    }
    
    /**
     * Handle other node methods
     */
    public function __call($method, $parameters)
    {
        // Security check - hanya admin ID 1 yang bisa akses
        if (auth()->user()->id !== 1) {
            throw new DisplayException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
        
        return parent::__call($method, $parameters);
    }
}
EOF

    # 4. Modify NestsController untuk nests access
    cat > "$PANEL_DIR/app/Http/Controllers/Admin/NestsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Exceptions\DisplayException;

class NestsController extends Controller
{
    /**
     * NestsController constructor.
     */
    public function __construct()
    {
        //
    }

    /**
     * Return the nests index view.
     */
    public function index(): View
    {
        // Security check - hanya admin ID 1 yang bisa akses
        if (auth()->user()->id !== 1) {
            throw new DisplayException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
        
        return view('admin.nests.index');
    }
    
    /**
     * Handle nest views
     */
    public function view($id): View
    {
        // Security check - hanya admin ID 1 yang bisa akses
        if (auth()->user()->id !== 1) {
            throw new DisplayException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
        
        return view('admin.nests.view', compact('id'));
    }
    
    /**
     * Handle other nest methods
     */
    public function __call($method, $parameters)
    {
        // Security check - hanya admin ID 1 yang bisa akses
        if (auth()->user()->id !== 1) {
            throw new DisplayException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
        
        return parent::__call($method, $parameters);
    }
}
EOF

    # 5. Modify LocationsController untuk locations access
    cat > "$PANEL_DIR/app/Http/Controllers/Admin/LocationsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Exceptions\DisplayException;

class LocationsController extends Controller
{
    /**
     * LocationsController constructor.
     */
    public function __construct()
    {
        //
    }

    /**
     * Return the locations index view.
     */
    public function index(): View
    {
        // Security check - hanya admin ID 1 yang bisa akses
        if (auth()->user()->id !== 1) {
            throw new DisplayException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
        
        return view('admin.locations.index');
    }
    
    /**
     * Handle location views
     */
    public function view($id): View
    {
        // Security check - hanya admin ID 1 yang bisa akses
        if (auth()->user()->id !== 1) {
            throw new DisplayException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
        
        return view('admin.locations.view', compact('id'));
    }
    
    /**
     * Handle other location methods
     */
    public function __call($method, $parameters)
    {
        // Security check - hanya admin ID 1 yang bisa akses
        if (auth()->user()->id !== 1) {
            throw new DisplayException('Ngapain sih? mau nyolong sc org? - By @ginaabaikhati');
        }
        
        return parent::__call($method, $parameters);
    }
}
EOF

    # 6. Modify SettingsController - allow access for all admins
    cat > "$PANEL_DIR/app/Http/Controllers/Admin/SettingsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Pterodactyl\Http\Controllers\Controller;

class SettingsController extends Controller
{
    /**
     * SettingsController constructor.
     */
    public function __construct()
    {
        //
    }

    /**
     * Return the settings index view.
     */
    public function index(): View
    {
        // Settings bisa diakses semua admin
        return view('admin.settings.index');
    }
    
    /**
     * Handle other settings methods
     */
    public function __call($method, $parameters)
    {
        return parent::__call($method, $parameters);
    }
}
EOF

    # Clear view cache
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    cd "$PANEL_DIR" && php artisan view:clear > /dev/null 2>&1
    cd "$PANEL_DIR" && php artisan cache:clear > /dev/null 2>&1
    
    # Set permissions
    chown -R www-data:www-data "$PANEL_DIR"
    chmod -R 755 "$PANEL_DIR"
    
    echo -e "${GREEN}✓ Security panel berhasil diinstall!${NC}"
    echo -e "${GREEN}✓ Hanya admin ID 1 yang bisa mengakses:${NC}"
    echo -e "${GREEN}  - Servers, Nodes, Nests, Locations${NC}"
    echo -e "${GREEN}✓ Settings bisa diakses semua admin${NC}"
    echo -e "${GREEN}✓ Error message diterapkan: '$ERROR_MSG'${NC}"
    
    sleep 3
}

# Function to change error text
change_error_text() {
    display_header
    echo -e "${YELLOW}[2] Mengganti teks error...${NC}"
    
    read -p "Masukkan teks error baru: " NEW_ERROR
    
    if [ -z "$NEW_ERROR" ]; then
        echo -e "${RED}Error: Teks tidak boleh kosong${NC}"
        return 1
    fi
    
    # Update error message in all controller files
    for file in "$PANEL_DIR/app/Http/Controllers/Admin/"*Controller.php; do
        if [ -f "$file" ]; then
            sed -i "s/'Ngapain sih? mau nyolong sc org? - By @ginaabaikhati'/'$NEW_ERROR'/g" "$file"
        fi
    done
    
    # Clear cache
    cd "$PANEL_DIR" && php artisan view:clear > /dev/null 2>&1
    cd "$PANEL_DIR" && php artisan cache:clear > /dev/null 2>&1
    
    echo -e "${GREEN}✓ Teks error berhasil diganti menjadi: '$NEW_ERROR'${NC}"
    sleep 2
}

# Function to uninstall security
uninstall_security() {
    display_header
    echo -e "${YELLOW}[3] Uninstall security panel...${NC}"
    
    if [ ! -d "$SECURITY_DIR" ]; then
        echo -e "${RED}Error: Security panel belum diinstall${NC}"
        sleep 2
        return 1
    fi
    
    # Restore backup files
    echo -e "${YELLOW}Memulihkan file original...${NC}"
    
    if [ -f "$SECURITY_DIR/AdminController.backup" ]; then
        cp "$SECURITY_DIR/AdminController.backup" "$PANEL_DIR/app/Http/Controllers/Admin/AdminController.php"
    fi
    
    if [ -f "$SECURITY_DIR/ServersController.backup" ]; then
        cp "$SECURITY_DIR/ServersController.backup" "$PANEL_DIR/app/Http/Controllers/Admin/ServersController.php"
    fi
    
    if [ -f "$SECURITY_DIR/NodesController.backup" ]; then
        cp "$SECURITY_DIR/NodesController.backup" "$PANEL_DIR/app/Http/Controllers/Admin/NodesController.php"
    fi
    
    if [ -f "$SECURITY_DIR/NestsController.backup" ]; then
        cp "$SECURITY_DIR/NestsController.backup" "$PANEL_DIR/app/Http/Controllers/Admin/NestsController.php"
    fi
    
    if [ -f "$SECURITY_DIR/LocationsController.backup" ]; then
        cp "$SECURITY_DIR/LocationsController.backup" "$PANEL_DIR/app/Http/Controllers/Admin/LocationsController.php"
    fi
    
    if [ -f "$SECURITY_DIR/SettingsController.backup" ]; then
        cp "$SECURITY_DIR/SettingsController.backup" "$PANEL_DIR/app/Http/Controllers/Admin/SettingsController.php"
    fi
    
    # Clear cache
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    cd "$PANEL_DIR" && php artisan view:clear > /dev/null 2>&1
    cd "$PANEL_DIR" && php artisan cache:clear > /dev/null 2>&1
    
    # Remove security directory
    rm -rf "$SECURITY_DIR"
    
    echo -e "${GREEN}✓ Security panel berhasil diuninstall!${NC}"
    echo -e "${GREEN}✓ Semua restrictions telah dihapus${NC}"
    
    sleep 3
}

# Function to show menu
show_menu() {
    while true; do
        display_header
        echo -e "${GREEN}Pilihan Menu:${NC}"
        echo -e "  ${YELLOW}[1]${NC} Install Security Panel"
        echo -e "  ${YELLOW}[2]${NC} Ganti Teks Error" 
        echo -e "  ${YELLOW}[3]${NC} Uninstall Security Panel"
        echo -e "  ${YELLOW}[4]${NC} Exit Security Panel"
        echo ""
        read -p "Pilih opsi [1-4]: " choice
        
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
                echo -e "${GREEN}Terima kasih! - By @ginaabaikhati${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Pilihan tidak valid!${NC}"
                sleep 2
                ;;
        esac
    done
}

# Main execution
if [ "$1" = "install" ]; then
    install_security
elif [ "$1" = "uninstall" ]; then
    uninstall_security
elif [ "$1" = "change-error" ]; then
    change_error_text
else
    show_menu
fi
