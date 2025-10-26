#!/bin/bash

# security.sh - Security Panel Pterodactyl
# Script untuk mengamankan panel Pterodactyl
# By @ginaabaikhati

PANEL_PATH="/var/www/pterodactyl"
BACKUP_PATH="/root/pterodactyl_backup"

# Fungsi untuk menampilkan header
show_header() {
    clear
    echo "================================================"
    echo "    Pterodactyl Panel Security Installer"
    echo "          By @ginaabaikhati"
    echo "================================================"
    echo ""
}

# Fungsi untuk membuat backup
create_backup() {
    echo "Membuat backup file original..."
    mkdir -p $BACKUP_PATH
    
    # Backup file yang akan dimodifikasi
    cp $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php $BACKUP_PATH/ServerController.php.backup 2>/dev/null
    cp $PANEL_PATH/app/Http/Controllers/Admin/*.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php $BACKUP_PATH/AdminAuthenticate.php.backup 2>/dev/null
    cp $PANEL_PATH/routes/api.php $BACKUP_PATH/api.php.backup 2>/dev/null
    cp $PANEL_PATH/app/Http/Controllers/Api/Client/ClientApiController.php $BACKUP_PATH/ClientApiController.php.backup 2>/dev/null
    
    echo "Backup berhasil dibuat di: $BACKUP_PATH"
}

# Fungsi untuk restore backup
restore_backup() {
    echo "Memulihkan file dari backup..."
    
    if [ ! -d "$BACKUP_PATH" ]; then
        echo "Error: Backup tidak ditemukan!"
        return 1
    fi
    
    # Restore file yang dimodifikasi
    cp $BACKUP_PATH/ServerController.php.backup $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php 2>/dev/null
    cp $BACKUP_PATH/*.php $PANEL_PATH/app/Http/Controllers/Admin/ 2>/dev/null
    cp $BACKUP_PATH/AdminAuthenticate.php.backup $PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php 2>/dev/null
    cp $BACKUP_PATH/api.php.backup $PANEL_PATH/routes/api.php 2>/dev/null
    cp $BACKUP_PATH/ClientApiController.php.backup $PANEL_PATH/app/Http/Controllers/Api/Client/ClientApiController.php 2>/dev/null
    
    echo "Menjalankan optimasi panel..."
    cd $PANEL_PATH
    php artisan cache:clear
    php artisan view:clear
    
    echo "Restore berhasil!"
}

# Fungsi untuk mengecek user ID
check_user_id() {
    local user_id=$1
    if [ "$user_id" != "1" ]; then
        echo "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"
        return 1
    fi
    return 0
}

# Fungsi untuk install security
install_security() {
    show_header
    echo "Menginstall Security Panel..."
    
    # Buat backup terlebih dahulu
    create_backup
    
    # Modifikasi Admin Controller untuk proteksi settings, nodes, locations, nests
    cat > $PANEL_PATH/app/Http/Controllers/Admin/SecurityController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;

class SecurityController
{
    public function checkAccess($user_id, $action = null)
    {
        if ($user_id != 1) {
            return response()->json([
                'error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'
            ], 403);
        }
        return null;
    }
}
EOF

    # Modifikasi AdminAuthenticate middleware
    cat > $PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminAuthenticate
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        
        if (!$user || !$user->root_admin) {
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'
                ], 403);
            }
            
            return redirect('/');
        }

        // Cek akses untuk routes tertentu
        $route = $request->route();
        $user_id = $user->id;
        
        // Blokir akses ke settings, nodes, locations, nests untuk user selain ID 1
        if ($user_id != 1) {
            $blocked_paths = ['settings', 'nodes', 'locations', 'nests', 'users'];
            $current_path = $request->path();
            
            foreach ($blocked_paths as $path) {
                if (strpos($current_path, "admin/{$path}") !== false) {
                    if ($request->expectsJson()) {
                        return response()->json([
                            'error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'
                        ], 403);
                    }
                    abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
                }
            }
        }

        return $next($request);
    }
}
EOF

    # Modifikasi ServerController untuk proteksi server user lain
    cat > $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Client\Servers;

use App\Http\Controllers\Controller;
use App\Models\Server;
use App\Repositories\Proxmox\Server\ProxmoxPowerRepository;
use App\Services\Servers\DetailsService;
use Illuminate\Http\Request;

class ServerController extends Controller
{
    public function __construct(
        private DetailsService $detailsService,
        private ProxmoxPowerRepository $powerRepository
    ) {}

    public function details(Request $request, Server $server)
    {
        // Cek ownership server
        if ($request->user()->id !== $server->user_id && $request->user()->id != 1) {
            return response()->json([
                'error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'
            ], 403);
        }

        return $this->detailsService->setServer($server)->getDetails();
    }

    public function resources(Request $request, Server $server)
    {
        if ($request->user()->id !== $server->user_id && $request->user()->id != 1) {
            return response()->json([
                'error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'
            ], 403);
        }

        return $this->detailsService->setServer($server)->getResources();
    }

    public function power(Request $request, Server $server, string $action)
    {
        if ($request->user()->id !== $server->user_id && $request->user()->id != 1) {
            return response()->json([
                'error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'
            ], 403);
        }

        return $this->powerRepository->setServer($server)->send($action);
    }
}
EOF

    # Modifikasi ClientApiController untuk proteksi API
    cat > $PANEL_PATH/app/Http/Controllers/Api/Client/ClientApiController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Client;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ClientApiController extends Controller
{
    protected function checkAccess(Request $request, $server = null)
    {
        $user = $request->user();
        
        // Jika ada server, cek ownership
        if ($server && $server->user_id !== $user->id && $user->id != 1) {
            return response()->json([
                'error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'
            ], 403);
        }

        // Cek akses untuk admin functions
        if ($user->id != 1) {
            $path = $request->path();
            $blocked_paths = ['settings', 'nodes', 'locations', 'nests', 'users'];
            
            foreach ($blocked_paths as $blocked) {
                if (strpos($path, $blocked) !== false) {
                    return response()->json([
                        'error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'
                    ], 403);
                }
            }
        }

        return null;
    }
}
EOF

    # Update routes untuk menambahkan security check
    if [ -f "$PANEL_PATH/routes/api.php" ]; then
        # Backup routes original
        cp $PANEL_PATH/routes/api.php $BACKUP_PATH/api.php.original
        
        # Tambahkan security middleware ke routes
        sed -i '1i <?php\n\n// Security Protection By @ginaabaikhati\nuse Illuminate\\Support\\Facades\\Route;\n' $PANEL_PATH/routes/api.php
    fi

    echo "Menjalankan optimasi panel..."
    cd $PANEL_PATH
    php artisan cache:clear
    php artisan view:clear
    php artisan route:clear

    echo ""
    echo "================================================"
    echo "Security Panel berhasil diinstall!"
    echo "Fitur yang diamankan:"
    echo "- Settings Panel (Hanya ID 1)"
    echo "- Nodes (Hanya ID 1)" 
    echo "- Locations (Hanya ID 1)"
    echo "- Nests (Hanya ID 1)"
    echo "- User Management (Hanya ID 1)"
    echo "- Server user lain (Tidak bisa diakses)"
    echo ""
    echo "Pesan Error: 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'"
    echo "================================================"
    echo ""
    read -p "Tekan Enter untuk kembali ke menu..."
}

# Fungsi untuk mengubah teks error
change_error_text() {
    show_header
    echo "Mengubah Teks Error Security"
    echo "=============================="
    echo ""
    read -p "Masukkan teks error baru: " new_text
    
    if [ -z "$new_text" ]; then
        echo "Teks tidak boleh kosong!"
        read -p "Tekan Enter untuk kembali..."
        return
    fi
    
    # Escape special characters for sed
    escaped_text=$(printf '%s\n' "$new_text" | sed 's/[[\.*^$/]/\\&/g')
    
    # Update teks di semua file
    find $PANEL_PATH -name "*.php" -type f -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/$escaped_text/g" {} \; 2>/dev/null
    
    echo "Teks error berhasil diubah!"
    echo "Teks baru: $new_text"
    echo ""
    read -p "Tekan Enter untuk kembali ke menu..."
}

# Fungsi uninstall security
uninstall_security() {
    show_header
    echo "Uninstall Security Panel"
    echo "========================"
    echo ""
    echo "Perhatian: Tindakan ini akan mengembalikan panel ke state semula!"
    echo ""
    read -p "Apakah Anda yakin? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        restore_backup
        echo ""
        echo "Security panel berhasil diuninstall!"
        echo "Panel telah dikembalikan ke state semula."
    else
        echo "Uninstall dibatalkan."
    fi
    
    echo ""
    read -p "Tekan Enter untuk kembali ke menu..."
}

# Main menu
while true; do
    show_header
    echo "Menu Utama:"
    echo "1. Install Security Panel"
    echo "2. Ubah Teks Error" 
    echo "3. Uninstall Security Panel"
    echo "4. Exit"
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
            echo "Terima kasih telah menggunakan script security!"
            echo "By @ginaabaikhati"
            exit 0
            ;;
        *)
            echo "Pilihan tidak valid!"
            sleep 2
            ;;
    esac
done
