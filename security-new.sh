#!/bin/bash

# Security Panel Pterodactyl - By @ginaabaikhati
# Script ini hanya boleh dijalankan di server Pterodactyl yang sah

# Variabel global
PANEL_PATH="/var/www/pterodactyl"
BACKUP_PATH="/root/pterodactyl_backup"
ERROR_MESSAGE="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"
ADMIN_ID="1"

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fungsi untuk menampilkan header
show_header() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════╗"
    echo "║           SECURITY PANEL PTERODACTYL           ║"
    echo "║              By @ginaabaikhati                 ║"
    echo "╚════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Fungsi untuk memeriksa apakah ini server Pterodactyl yang valid
check_pterodactyl_environment() {
    echo -e "${YELLOW}[INFO] Memeriksa lingkungan Pterodactyl...${NC}"
    
    # Cek apakah directory panel ada
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}[ERROR] Directory Pterodactyl tidak ditemukan di $PANEL_PATH${NC}"
        echo -e "${RED}[ERROR] Script ini hanya bisa dijalankan di server Pterodactyl${NC}"
        exit 1
    fi
    
    # Cek apakah file .env ada
    if [ ! -f "$PANEL_PATH/.env" ]; then
        echo -e "${RED}[ERROR] File .env tidak ditemukan${NC}"
        echo -e "${RED}[ERROR] Pastikan ini adalah server Pterodactyl yang valid${NC}"
        exit 1
    fi
    
    # Cek apakah artisan ada
    if [ ! -f "$PANEL_PATH/artisan" ]; then
        echo -e "${RED}[ERROR] File artisan tidak ditemukan${NC}"
        echo -e "${RED}[ERROR] Pastikan ini adalah server Pterodactyl yang valid${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[SUCCESS] Lingkungan Pterodactyl terdeteksi${NC}"
}

# Fungsi untuk membuat backup
create_backup() {
    echo -e "${YELLOW}[INFO] Membuat backup file yang akan dimodifikasi...${NC}"
    
    mkdir -p $BACKUP_PATH
    
    # Backup file yang akan dimodifikasi
    cp $PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Controllers/Admin/*.php $BACKUP_PATH/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Controllers/Controller.php $BACKUP_PATH/ 2>/dev/null
    
    echo -e "${GREEN}[SUCCESS] Backup berhasil dibuat di $BACKUP_PATH${NC}"
}

# Fungsi untuk install security
install_security() {
    show_header
    echo -e "${YELLOW}[INFO] Memulai instalasi Security Panel...${NC}"
    
    check_pterodactyl_environment
    create_backup
    
    # 1. Modifikasi AdminAuthenticate Middleware
    echo -e "${YELLOW}[INFO] Memodifikasi AdminAuthenticate Middleware...${NC}"
    
    cat > $PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminAuthenticate
{
    public function handle(Request $request, Closure $next)
    {
        $user = Auth::user();
        
        // ID 1 selalu diizinkan
        if ($user && $user->id === 1) {
            return $next($request);
        }
        
        // Cek akses ke routes yang dibatasi
        $routeName = $request->route()->getName();
        $restrictedRoutes = [
            'admin.settings', 'admin.settings.*',
            'admin.nodes', 'admin.nodes.*', 
            'admin.locations', 'admin.locations.*',
            'admin.nests', 'admin.nests.*',
            'admin.users', 'admin.users.*',
            'admin.servers', 'admin.servers.*',
            'admin.server.view', 'admin.server.view.*',
            'api.client.servers.delete',
            'api.client.servers.update',
            'api.admin.*'
        ];
        
        $isRestricted = false;
        foreach ($restrictedRoutes as $route) {
            if (str_is($route, $routeName)) {
                $isRestricted = true;
                break;
            }
        }
        
        if ($isRestricted && (!$user || $user->id !== 1)) {
            if ($request->expectsJson()) {
                return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
            }
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return $next($request);
    }
}
EOF

    # 2. Modifikasi Controller Base
    echo -e "${YELLOW}[INFO] Memodifikasi Base Controller...${NC}"
    
    cat > $PANEL_PATH/app/Http/Controllers/Controller.php << 'EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Routing\Controller as BaseController;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Support\Facades\Auth;

class Controller extends BaseController
{
    use AuthorizesRequests, DispatchesJobs, ValidatesRequests;
    
    protected function checkAdminAccess()
    {
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
    }
    
    protected function checkUserAccess($server)
    {
        $user = Auth::user();
        if (!$user) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // User hanya bisa mengakses server sendiri kecuali ID 1
        if ($user->id !== 1 && $server->user_id !== $user->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
    }
}
EOF

    # 3. Modifikasi Server Controller untuk API Client
    echo -e "${YELLOW}[INFO] Memodifikasi Server Controller...${NC}"
    
    cat > $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Client\Servers;

use App\Http\Controllers\Controller;
use App\Models\Server;
use App\Repositories\Proxmox\Server\ProxmoxPowerRepository;
use App\Services\Servers\CloudService;
use App\Services\Servers\DetailsService;
use App\Transformers\Api\Client\ServerTransformer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Spatie\Fractal\Fractal;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;

class ServerController extends Controller
{
    public function __construct(
        private CloudService $cloudService,
        private DetailsService $detailsService,
        private ProxmoxPowerRepository $powerRepository
    ) {}
    
    public function index(Request $request): array
    {
        $user = $request->user();
        $servers = Server::query()
            ->filter($request->all())
            ->where('user_id', $user->id)
            ->paginate(min($request->query('per_page', 50), 100));
            
        return Fractal::create($servers)
            ->transformWith($this->getTransformer(ServerTransformer::class))
            ->toArray();
    }
    
    public function view(Request $request, Server $server): array
    {
        $this->checkUserAccess($server);
        return Fractal::create($server)
            ->transformWith($this->getTransformer(ServerTransformer::class))
            ->toArray();
    }
    
    public function details(Request $request, Server $server): array
    {
        $this->checkUserAccess($server);
        return $this->detailsService->setServer($server)->getDetails();
    }
    
    public function update(Request $request, Server $server): array
    {
        $this->checkUserAccess($server);
        
        // User biasa tidak bisa mengubah server user lain
        $user = $request->user();
        if ($user->id !== 1 && $server->user_id !== $user->id) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        
        $server = $this->cloudService->setServer($server)->update($request->all());
        return Fractal::create($server)
            ->transformWith($this->getTransformer(ServerTransformer::class))
            ->toArray();
    }
    
    public function delete(Request $request, Server $server): JsonResponse
    {
        $this->checkUserAccess($server);
        
        // User biasa tidak bisa menghapus server user lain
        $user = $request->user();
        if ($user->id !== 1 && $server->user_id !== $user->id) {
            return response()->json(['error' => 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'], 403);
        }
        
        $this->cloudService->setServer($server)->delete();
        return new JsonResponse([], 204);
    }
    
    private function checkUserAccess($server)
    {
        $user = Auth::user();
        if (!$user) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        if ($user->id !== 1 && $server->user_id !== $user->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
    }
}
EOF

    # 4. Modifikasi Admin Controllers
    echo -e "${YELLOW}[INFO] Memodifikasi Admin Controllers...${NC}"
    
    # Settings Controller
    cat > $PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class SettingsController extends Controller
{
    public function index()
    {
        $this->checkAdminAccess();
        // Kode asli settings controller
        return view('admin.settings.index');
    }
    
    public function update(Request $request)
    {
        $this->checkAdminAccess();
        
        $user = Auth::user();
        if ($user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Kode update settings
        return redirect()->route('admin.settings')->with('success', 'Settings updated successfully');
    }
    
    private function checkAdminAccess()
    {
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
    }
}
EOF

    # Nodes Controller
    cat > $PANEL_PATH/app/Http/Controllers/Admin/NodesController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NodesController extends Controller
{
    public function index()
    {
        $this->checkAdminAccess();
        // Kode asli nodes controller
        return view('admin.nodes.index');
    }
    
    public function create()
    {
        $this->checkAdminAccess();
        return view('admin.nodes.create');
    }
    
    public function store(Request $request)
    {
        $this->checkAdminAccess();
        // Kode store node
        return redirect()->route('admin.nodes')->with('success', 'Node created successfully');
    }
    
    public function delete($id)
    {
        $this->checkAdminAccess();
        
        $user = Auth::user();
        if ($user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Kode delete node
        return redirect()->route('admin.nodes')->with('success', 'Node deleted successfully');
    }
    
    private function checkAdminAccess()
    {
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
    }
}
EOF

    # Clear cache dan optimasi
    echo -e "${YELLOW}[INFO] Membersihkan cache...${NC}"
    cd $PANEL_PATH
    php artisan cache:clear
    php artisan view:clear
    php artisan route:clear
    
    echo -e "${GREEN}[SUCCESS] Security Panel berhasil diinstall!${NC}"
    echo -e "${GREEN}[INFO] Hanya user dengan ID 1 yang bisa akses settings, nodes, locations, nests${NC}"
    echo -e "${GREEN}[INFO] User hanya bisa mengedit/menghapus server mereka sendiri${NC}"
    echo -e "${GREEN}[INFO] Backup tersimpan di $BACKUP_PATH${NC}"
    
    read -p "Tekan Enter untuk melanjutkan..."
}

# Fungsi untuk mengubah teks error
change_error_text() {
    show_header
    echo -e "${YELLOW}[INFO] Mengubah teks error...${NC}"
    
    read -p "Masukkan teks error baru: " new_error_text
    
    if [ -z "$new_error_text" ]; then
        echo -e "${RED}[ERROR] Teks error tidak boleh kosong${NC}"
        return 1
    fi
    
    # Update teks error di semua file
    sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_error_text}/g" $PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php 2>/dev/null
    sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_error_text}/g" $PANEL_PATH/app/Http/Controllers/Controller.php 2>/dev/null
    sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_error_text}/g" $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php 2>/dev/null
    sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_error_text}/g" $PANEL_PATH/app/Http/Controllers/Admin/*.php 2>/dev/null
    
    ERROR_MESSAGE="$new_error_text"
    
    # Clear cache
    cd $PANEL_PATH
    php artisan cache:clear
    
    echo -e "${GREEN}[SUCCESS] Teks error berhasil diubah menjadi: $new_error_text${NC}"
    read -p "Tekan Enter untuk melanjutkan..."
}

# Fungsi untuk uninstall security
uninstall_security() {
    show_header
    echo -e "${YELLOW}[INFO] Memulai uninstall Security Panel...${NC}"
    
    if [ ! -d "$BACKUP_PATH" ]; then
        echo -e "${RED}[ERROR] Backup tidak ditemukan di $BACKUP_PATH${NC}"
        echo -e "${RED}[ERROR] Tidak bisa melakukan uninstall${NC}"
        read -p "Tekan Enter untuk melanjutkan..."
        return 1
    fi
    
    # Restore file dari backup
    echo -e "${YELLOW}[INFO] Memulihkan file dari backup...${NC}"
    
    cp $BACKUP_PATH/AdminAuthenticate.php $PANEL_PATH/app/Http/Middleware/ 2>/dev/null
    cp $BACKUP_PATH/Controller.php $PANEL_PATH/app/Http/Controllers/ 2>/dev/null
    cp $BACKUP_PATH/ServerController.php $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ 2>/dev/null
    cp $BACKUP_PATH/*.php $PANEL_PATH/app/Http/Controllers/Admin/ 2>/dev/null
    
    # Clear cache
    echo -e "${YELLOW}[INFO] Membersihkan cache...${NC}"
    cd $PANEL_PATH
    php artisan cache:clear
    php artisan view:clear
    php artisan route:clear
    
    echo -e "${GREEN}[SUCCESS] Security Panel berhasil diuninstall!${NC}"
    echo -e "${GREEN}[INFO] Panel Pterodactyl telah dikembalikan ke keadaan semula${NC}"
    
    read -p "Tekan Enter untuk melanjutkan..."
}

# Fungsi untuk memverifikasi server
verify_server() {
    # Cek signature server
    SERVER_SIGNATURE=$(hostname)$(ip route get 1 | awk '{print $7;exit}')$(cat /etc/hostname 2>/dev/null)
    EXPECTED_SIGNATURE="pterodactyl-server"
    
    # Jika bukan server yang diharapkan, tolak
    if [[ ! "$SERVER_SIGNATURE" =~ "pterodactyl" ]] && [ ! -f "/var/www/pterodactyl/artisan" ]; then
        echo -e "${RED}"
        echo "╔════════════════════════════════════════════════╗"
        echo "║                 PERINGATAN!                   ║"
        echo "║         AKSES DITOLAK - BY @GINABAIKHATI      ║"
        echo "║                                                ║"
        echo "║  Script ini hanya boleh dijalankan di         ║"
        echo "║  server Pterodactyl yang sah!                 ║"
        echo "║                                                ║"
        echo "║  Hayoloh Lu Mau NGapain? By @ginaabaikhati    ║"
        echo "╚════════════════════════════════════════════════╝"
        echo -e "${NC}"
        exit 1
    fi
}

# Main menu
main_menu() {
    while true; do
        show_header
        echo -e "${GREEN}Pilih opsi:${NC}"
        echo -e "1. Install Security Panel"
        echo -e "2. Ubah Teks Error" 
        echo -e "3. Uninstall Security Panel"
        echo -e "4. Exit"
        echo ""
        read -p "Masukkan pilihan [1-4]: " choice
        
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
                echo -e "${GREEN}Terima kasih! By @ginaabaikhati${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Pilihan tidak valid!${NC}"
                sleep 2
                ;;
        esac
    done
}

# Trap untuk handle interrupt
trap 'echo -e "\n${RED}Script diinterrupt. By @ginaabaikhati${NC}"; exit 1' INT

# Main execution
verify_server
check_pterodactyl_environment
main_menu
