#!/bin/bash

# security.sh - Security Panel Pterodactyl
# By @ginaabaikhati

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default error message
ERROR_MSG="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Backup directory
BACKUP_DIR="/var/www/pterodactyl-backup"

# Function to display header
show_header() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════╗"
    echo "║           PTERODACTYL SECURITY PANEL            ║"
    echo "║              By @ginaabaikhati                  ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}Error: Jangan jalankan script ini sebagai root!${NC}"
        exit 1
    fi
}

# Function to check if in Pterodactyl directory
check_pterodactyl_dir() {
    if [[ ! -f "/var/www/pterodactyl/artisan" ]]; then
        echo -e "${RED}Error: Script harus dijalankan di directory Pterodactyl!${NC}"
        echo -e "${YELLOW}Pastikan Anda berada di /var/www/pterodactyl${NC}"
        exit 1
    fi
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup...${NC}"
    sudo mkdir -p "$BACKUP_DIR"
    sudo cp -r /var/www/pterodactyl/app "$BACKUP_DIR/app_backup_$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}Backup berhasil dibuat di $BACKUP_DIR${NC}"
}

# Function to restore backup
restore_backup() {
    local latest_backup=$(ls -dt "$BACKUP_DIR"/app_backup_* | head -1)
    
    if [[ -z "$latest_backup" ]]; then
        echo -e "${RED}Tidak ada backup yang ditemukan!${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Memulihkan dari backup: $latest_backup${NC}"
    sudo cp -r "$latest_backup"/* /var/www/pterodactyl/app/
    echo -e "${GREEN}Backup berhasil dipulihkan${NC}"
}

# Function to install security
install_security() {
    echo -e "${YELLOW}Menginstall Security Panel...${NC}"
    
    # Backup original files
    create_backup
    
    # 1. Patch AdminController - Settings Lock
    cat > /tmp/AdminController.patch << 'EOF'
--- original/AdminController.php
+++ modified/AdminController.php
@@ -1,6 +1,7 @@
 <?php
 
 namespace Pterodactyl\Http\Controllers\Admin;
+use Pterodactyl\Http\Controllers\Controller;
 
 class AdminController extends Controller
 {
@@ -8,6 +9,10 @@
      */
     public function index()
     {
+        if (auth()->user()->id !== 1) {
+            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
+        }
+        
         return view('admin.index');
     }
 }
EOF

    # 2. Patch NodeController - Nodes Lock
    cat > /tmp/NodeController.patch << 'EOF'
--- original/NodeController.php
+++ modified/NodeController.php
@@ -1,6 +1,7 @@
 <?php
 
 namespace Pterodactyl\Http\Controllers\Admin\Nodes;
+use Pterodactyl\Http\Controllers\Controller;
 
 class NodeController extends Controller
 {
@@ -8,6 +9,10 @@
      */
     public function index()
     {
+        if (auth()->user()->id !== 1) {
+            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
+        }
+        
         return view('admin.nodes.index');
     }
 
@@ -15,6 +20,10 @@
      */
     public function create()
     {
+        if (auth()->user()->id !== 1) {
+            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
+        }
+        
         return view('admin.nodes.new');
     }
 }
EOF

    # 3. Patch LocationController - Locations Lock
    cat > /tmp/LocationController.patch << 'EOF'
--- original/LocationController.php
+++ modified/LocationController.php
@@ -1,6 +1,7 @@
 <?php
 
 namespace Pterodactyl\Http\Controllers\Admin\Locations;
+use Pterodactyl\Http\Controllers\Controller;
 
 class LocationController extends Controller
 {
@@ -8,6 +9,10 @@
      */
     public function index()
     {
+        if (auth()->user()->id !== 1) {
+            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
+        }
+        
         return view('admin.locations.index');
     }
 
@@ -15,6 +20,10 @@
      */
     public function create()
     {
+        if (auth()->user()->id !== 1) {
+            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
+        }
+        
         return view('admin.locations.new');
     }
 }
EOF

    # 4. Patch NestController - Nests Lock
    cat > /tmp/NestController.patch << 'EOF'
--- original/NestController.php
+++ modified/NestController.php
@@ -1,6 +1,7 @@
 <?php
 
 namespace Pterodactyl\Http\Controllers\Admin\Nests;
+use Pterodactyl\Http\Controllers\Controller;
 
 class NestController extends Controller
 {
@@ -8,6 +9,10 @@
      */
     public function index()
     {
+        if (auth()->user()->id !== 1) {
+            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
+        }
+        
         return view('admin.nests.index');
     }
 }
EOF

    # 5. Patch UserController - User Management Lock
    cat > /tmp/UserController.patch << 'EOF'
--- original/UserController.php
+++ modified/UserController.php
@@ -1,6 +1,7 @@
 <?php
 
 namespace Pterodactyl\Http\Controllers\Admin\Users;
+use Pterodactyl\Http\Controllers\Controller;
 
 class UserController extends Controller
 {
@@ -8,6 +9,10 @@
      */
     public function index()
     {
+        if (auth()->user()->id !== 1) {
+            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
+        }
+        
         return view('admin.users.index');
     }
 
@@ -15,6 +20,10 @@
      */
     public function view($id)
     {
+        if (auth()->user()->id !== 1) {
+            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
+        }
+        
         return view('admin.users.view', ['id' => $id]);
     }
 
@@ -22,6 +31,10 @@
      */
     public function create()
     {
+        if (auth()->user()->id !== 1) {
+            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
+        }
+        
         return view('admin.users.new');
     }
 }
EOF

    # 6. Patch ServerController - Server View Lock
    cat > /tmp/ServerController.patch << 'EOF'
--- original/ServerController.php
+++ modified/ServerController.php
@@ -1,6 +1,7 @@
 <?php
 
 namespace Pterodactyl\Http\Controllers\Admin\Servers;
+use Pterodactyl\Http\Controllers\Controller;
 
 class ServerController extends Controller
 {
@@ -8,6 +9,10 @@
      */
     public function index()
     {
+        if (auth()->user()->id !== 1) {
+            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
+        }
+        
         return view('admin.servers.index');
     }
 
@@ -15,6 +20,10 @@
      */
     public function view($id)
     {
+        if (auth()->user()->id !== 1) {
+            abort(403, config('security.error_message', 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'));
+        }
+        
         return view('admin.servers.view', ['id' => $id]);
     }
 }
EOF

    # Apply patches
    echo -e "${YELLOW}Menerapkan security patches...${NC}"
    
    # Copy and patch files
    cd /var/www/pterodactyl
    
    # AdminController
    sudo cp app/Http/Controllers/Admin/AdminController.php app/Http/Controllers/Admin/AdminController.php.backup
    sudo patch -p1 app/Http/Controllers/Admin/AdminController.php < /tmp/AdminController.patch
    
    # NodeController  
    sudo cp app/Http/Controllers/Admin/Nodes/NodeController.php app/Http/Controllers/Admin/Nodes/NodeController.php.backup
    sudo patch -p2 app/Http/Controllers/Admin/Nodes/NodeController.php < /tmp/NodeController.patch
    
    # LocationController
    sudo cp app/Http/Controllers/Admin/Locations/LocationController.php app/Http/Controllers/Admin/Locations/LocationController.php.backup
    sudo patch -p2 app/Http/Controllers/Admin/Locations/LocationController.php < /tmp/LocationController.patch
    
    # NestController
    sudo cp app/Http/Controllers/Admin/Nests/NestController.php app/Http/Controllers/Admin/Nests/NestController.php.backup
    sudo patch -p2 app/Http/Controllers/Admin/Nests/NestController.php < /tmp/NestController.patch
    
    # UserController
    sudo cp app/Http/Controllers/Admin/Users/UserController.php app/Http/Controllers/Admin/Users/UserController.php.backup
    sudo patch -p2 app/Http/Controllers/Admin/Users/UserController.php < /tmp/UserController.patch
    
    # ServerController
    sudo cp app/Http/Controllers/Admin/Servers/ServerController.php app/Http/Controllers/Admin/Servers/ServerController.php.backup
    sudo patch -p2 app/Http/Controllers/Admin/Servers/ServerController.php < /tmp/ServerController.patch
    
    # Add security configuration
    sudo tee -a config/app.php > /dev/null << EOF
    
    /*
    |--------------------------------------------------------------------------
    | Security Configuration
    |--------------------------------------------------------------------------
    |
    | Security settings for Pterodactyl Panel
    | By @ginaabaikhati
    |
    */
    
    'security' => [
        'error_message' => '$ERROR_MSG',
        'restricted_areas' => [
            'admin_settings',
            'nodes', 
            'locations',
            'nests',
            'user_management',
            'server_management'
        ]
    ],
EOF

    # Clear cache and optimize
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    sudo php artisan config:clear
    sudo php artisan cache:clear
    sudo php artisan view:clear
    
    echo -e "${GREEN}Security Panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Hanya user dengan ID 1 yang dapat mengakses:${NC}"
    echo -e "${YELLOW}- Panel Settings${NC}"
    echo -e "${YELLOW}- Nodes Management${NC}" 
    echo -e "${YELLOW}- Locations Management${NC}"
    echo -e "${YELLOW}- Nests Management${NC}"
    echo -e "${YELLOW}- User Management${NC}"
    echo -e "${YELLOW}- Server View/Management${NC}"
}

# Function to change error text
change_error_text() {
    echo -e "${YELLOW}Mengubah teks error...${NC}"
    read -p "Masukkan teks error baru: " new_error
    
    if [[ -z "$new_error" ]]; then
        echo -e "${RED}Teks error tidak boleh kosong!${NC}"
        return 1
    fi
    
    # Update error message in config
    sudo sed -i "s/error_message' => '.*'/error_message' => '$new_error'/" /var/www/pterodactyl/config/app.php
    
    # Update all controller files with new error message
    sudo find /var/www/pterodactyl/app/Http/Controllers/Admin -name "*.php" -exec sed -i "s/abort(403, config('security.error_message', '.*')/abort(403, config('security.error_message', '$new_error')/" {} \;
    
    # Clear cache
    sudo php artisan config:clear
    sudo php artisan cache:clear
    
    echo -e "${GREEN}Teks error berhasil diubah!${NC}"
    echo -e "${YELLOW}Teks error baru: $new_error${NC}"
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Uninstall Security Panel...${NC}"
    
    # Restore from backup
    if restore_backup; then
        # Remove security config from app.php
        sudo sed -i '/Security Configuration/,/security/d' /var/www/pterodactyl/config/app.php
        
        # Clear cache
        sudo php artisan config:clear
        sudo php artisan cache:clear
        sudo php artisan view:clear
        
        echo -e "${GREEN}Security Panel berhasil diuninstall!${NC}"
        echo -e "${YELLOW}Panel telah kembali ke keadaan semula.${NC}"
    else
        echo -e "${RED}Gagal menguninstall security panel!${NC}"
    fi
}

# Function to show menu
show_menu() {
    show_header
    echo -e "${GREEN}Pilih opsi:${NC}"
    echo -e "1. Install Security Panel"
    echo -e "2. Ubah Teks Error" 
    echo -e "3. Uninstall Security Panel"
    echo -e "4. Exit"
    echo
    read -p "Masukkan pilihan [1-4]: " choice
}

# Main script
main() {
    check_root
    check_pterodactyl_dir
    
    while true; do
        show_menu
        
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
                echo -e "${GREEN}Terima kasih!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Pilihan tidak valid!${NC}"
                ;;
        esac
        
        echo
        read -p "Tekan Enter untuk melanjutkan..."
    done
}

# Check if script is sourced or directly executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
