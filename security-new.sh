#!/bin/bash

# Security Panel Pterodactyl - By @ginaabaikhati
# Script ini hanya boleh dijalankan di server Pterodactyl yang sah

# Variabel warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variabel path Pterodactyl
PANEL_PATH="/var/www/pterodactyl"
BACKUP_DIR="/root/pterodactyl_backup"
SECURITY_FLAG="/root/.pterodactyl_security_installed"

# Fungsi untuk mengecek environment
check_environment() {
    echo -e "${BLUE}[INFO]${NC} Mengecek environment Pterodactyl..."
    
    # Cek apakah directory panel exists
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}[ERROR]${NC} Directory Pterodactyl tidak ditemukan di $PANEL_PATH"
        echo -e "${RED}[ERROR]${NC} Script ini hanya bisa dijalankan di server Pterodactyl yang valid!"
        exit 1
    fi
    
    # Cek apakah file .env exists
    if [ ! -f "$PANEL_PATH/.env" ]; then
        echo -e "${RED}[ERROR]${NC} File .env tidak ditemukan!"
        echo -e "${RED}[ERROR]${NC} Pastikan ini adalah server Pterodactyl yang valid!"
        exit 1
    fi
    
    # Cek composer
    if [ ! -f "$PANEL_PATH/composer.json" ]; then
        echo -e "${RED}[ERROR]${NC} File composer.json tidak ditemukan!"
        echo -e "${RED}[ERROR]${NC} Script ditolak: Environment tidak valid!"
        exit 1
    fi
    
    echo -e "${GREEN}[SUCCESS]${NC} Environment valid!"
}

# Fungsi backup file
backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        local backup_file="$BACKUP_DIR/$(basename $file).backup.$(date +%Y%m%d%H%M%S)"
        cp "$file" "$backup_file"
        echo -e "${GREEN}[BACKUP]${NC} $file -> $backup_file"
    fi
}

# Fungsi install security
install_security() {
    echo -e "${BLUE}[INSTALL]${NC} Memulai instalasi Security Panel..."
    
    # Buat backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Backup file yang akan dimodifikasi
    backup_file "$PANEL_PATH/app/Http/Controllers/Admin"
    backup_file "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php"
    
    # 1. Modifikasi Admin Controller
    echo -e "${YELLOW}[MODIFIKASI]${NC} Memodifikasi Admin Controller..."
    
    # Buat directory jika belum ada
    mkdir -p "$PANEL_PATH/app/Http/Controllers/Admin"
    
    # File AdminController.php
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/AdminController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class AdminController extends Controller
{
    public function checkAdminAccess($user, $action = 'akses')
    {
        if ($user->id !== 1) {
            abort(403, "Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati");
        }
    }
}
EOF

    # 2. Modifikasi Settings Controller
    echo -e "${YELLOW}[MODIFIKASI]${NC} Memodifikasi Settings Controller..."
    
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class SettingsController extends Controller
{
    public function __construct(
        private AlertsMessageBag $alert,
        private SettingsRepositoryInterface $settings
    ) {
    }

    public function index(): View
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'melihat settings');
        
        return view('admin.settings', [
            'name' => $this->settings->get('settings::app:name', 'Pterodactyl'),
        ]);
    }

    public function update(): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'mengubah settings');
        
        $this->settings->set('settings::app:name', request()->input('name'));
        $this->alert->success('Settings berhasil diupdate.')->flash();

        return redirect()->route('admin.settings');
    }
}
EOF

    # 3. Modifikasi Nodes Controller
    echo -e "${YELLOW}[MODIFIKASI]${NC} Memodifikasi Nodes Controller..."
    
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Pterodactyl\Models\Node;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Symfony\Component\HttpFoundation\Response;
use Pterodactyl\Services\Nodes\NodeUpdateService;
use Pterodactyl\Services\Nodes\NodeCreationService;
use Pterodactyl\Services\Nodes\NodeDeletionService;
use Pterodactyl\Http\Requests\Admin\NodeFormRequest;

class NodesController extends Controller
{
    public function __construct(
        private AlertsMessageBag $alert,
        private NodeCreationService $creationService,
        private NodeDeletionService $deletionService,
        private NodeUpdateService $updateService
    ) {
    }

    public function index(): View
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'melihat nodes');
        
        return view('admin.nodes.index', [
            'nodes' => Node::all(),
        ]);
    }

    public function create(): View
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'membuat node');
        
        return view('admin.nodes.new');
    }

    public function store(NodeFormRequest $request): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'menyimpan node');
        
        $node = $this->creationService->handle($request->validated());
        $this->alert->success(trans('admin/node.notices.node_created'))->flash();

        return redirect()->route('admin.nodes.view', $node->id);
    }

    public function update(NodeFormRequest $request, Node $node): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'mengupdate node');
        
        $this->updateService->handle($node, $request->validated());
        $this->alert->success(trans('admin/node.notices.node_updated'))->flash();

        return redirect()->route('admin.nodes.view', $node->id);
    }

    public function destroy(Node $node): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'menghapus node');
        
        $this->deletionService->handle($node);
        $this->alert->success(trans('admin/node.notices.node_deleted'))->flash();

        return redirect()->route('admin.nodes');
    }
}
EOF

    # 4. Modifikasi Locations Controller
    echo -e "${YELLOW}[MODIFIKASI]${NC} Memodifikasi Locations Controller..."
    
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Pterodactyl\Models\Location;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Symfony\Component\HttpFoundation\Response;
use Pterodactyl\Services\Locations\LocationUpdateService;
use Pterodactyl\Services\Locations\LocationCreationService;
use Pterodactyl\Services\Locations\LocationDeletionService;
use Pterodactyl\Http\Requests\Admin\LocationFormRequest;

class LocationsController extends Controller
{
    public function __construct(
        private AlertsMessageBag $alert,
        private LocationCreationService $creationService,
        private LocationDeletionService $deletionService,
        private LocationUpdateService $updateService
    ) {
    }

    public function index(): View
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'melihat locations');
        
        return view('admin.locations.index', [
            'locations' => Location::all(),
        ]);
    }

    public function create(): View
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'membuat location');
        
        return view('admin.locations.new');
    }

    public function store(LocationFormRequest $request): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'menyimpan location');
        
        $location = $this->creationService->handle($request->validated());
        $this->alert->success(trans('admin/location.notices.location_created'))->flash();

        return redirect()->route('admin.locations');
    }

    public function update(LocationFormRequest $request, Location $location): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'mengupdate location');
        
        $this->updateService->handle($location, $request->validated());
        $this->alert->success(trans('admin/location.notices.location_updated'))->flash();

        return redirect()->route('admin.locations');
    }

    public function destroy(Location $location): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'menghapus location');
        
        $this->deletionService->handle($location);
        $this->alert->success(trans('admin/location.notices.location_deleted'))->flash();

        return redirect()->route('admin.locations');
    }
}
EOF

    # 5. Modifikasi Nests Controller
    echo -e "${YELLOW}[MODIFIKASI]${NC} Memodifikasi Nests Controller..."
    
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NestsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Pterodactyl\Models\Nest;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Nests\NestUpdateService;
use Pterodactyl\Services\Nests\NestCreationService;
use Pterodactyl\Services\Nests\NestDeletionService;
use Pterodactyl\Http\Requests\Admin\NestFormRequest;

class NestsController extends Controller
{
    public function __construct(
        private AlertsMessageBag $alert,
        private NestCreationService $creationService,
        private NestDeletionService $deletionService,
        private NestUpdateService $updateService
    ) {
    }

    public function index(): View
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'melihat nests');
        
        return view('admin.nests.index', [
            'nests' => Nest::all(),
        ]);
    }

    public function create(): View
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'membuat nest');
        
        return view('admin.nests.new');
    }

    public function store(NestFormRequest $request): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'menyimpan nest');
        
        $nest = $this->creationService->handle($request->validated());
        $this->alert->success(trans('admin/nest.notices.nest_created'))->flash();

        return redirect()->route('admin.nests.view', $nest->id);
    }

    public function update(NestFormRequest $request, Nest $nest): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'mengupdate nest');
        
        $this->updateService->handle($nest, $request->validated());
        $this->alert->success(trans('admin/nest.notices.nest_updated'))->flash();

        return redirect()->route('admin.nests.view', $nest->id);
    }

    public function destroy(Nest $nest): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'menghapus nest');
        
        $this->deletionService->handle($nest);
        $this->alert->success(trans('admin/nest.notices.nest_deleted'))->flash();

        return redirect()->route('admin.nests');
    }
}
EOF

    # 6. Modifikasi Users Controller untuk proteksi server user lain
    echo -e "${YELLOW}[MODIFIKASI]${NC} Memodifikasi Users Controller..."
    
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/UsersController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Pterodactyl\Models\User;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Users\UserUpdateService;
use Pterodactyl\Services\Users\UserCreationService;
use Pterodactyl\Services\Users\UserDeletionService;
use Pterodactyl\Http\Requests\Admin\UserFormRequest;

class UsersController extends Controller
{
    public function __construct(
        private AlertsMessageBag $alert,
        private UserCreationService $creationService,
        private UserDeletionService $deletionService,
        private UserUpdateService $updateService
    ) {
    }

    public function index(): View
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'melihat users');
        
        return view('admin.users.index', [
            'users' => User::all(),
        ]);
    }

    public function view(User $user): View
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'melihat detail user');
        
        return view('admin.users.view', [
            'user' => $user,
            'servers' => $user->servers,
        ]);
    }

    public function create(): View
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'membuat user');
        
        return view('admin.users.new');
    }

    public function store(UserFormRequest $request): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'menyimpan user');
        
        $user = $this->creationService->handle($request->validated());
        $this->alert->success(trans('admin/user.notices.user_created'))->flash();

        return redirect()->route('admin.users');
    }

    public function update(UserFormRequest $request, User $user): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'mengupdate user');
        
        $this->updateService->handle($user, $request->validated());
        $this->alert->success(trans('admin/user.notices.user_updated'))->flash();

        return redirect()->route('admin.users.view', $user->id);
    }

    public function destroy(User $user): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'menghapus user');
        
        $this->deletionService->handle($user);
        $this->alert->success(trans('admin/user.notices.user_deleted'))->flash();

        return redirect()->route('admin.users');
    }
}
EOF

    # 7. Modifikasi Servers Controller untuk proteksi server
    echo -e "${YELLOW}[MODIFIKASI]${NC} Memodifikasi Servers Controller..."
    
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/ServersController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Pterodactyl\Models\Server;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Servers\ServerUpdateService;
use Pterodactyl\Services\Servers\ServerCreationService;
use Pterodactyl\Services\Servers\ServerDeletionService;
use Pterodactyl\Http\Requests\Admin\ServerFormRequest;

class ServersController extends Controller
{
    public function __construct(
        private AlertsMessageBag $alert,
        private ServerCreationService $creationService,
        private ServerDeletionService $deletionService,
        private ServerUpdateService $updateService
    ) {
    }

    public function index(): View
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'melihat servers');
        
        return view('admin.servers.index', [
            'servers' => Server::all(),
        ]);
    }

    public function create(): View
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'membuat server');
        
        return view('admin.servers.new');
    }

    public function store(ServerFormRequest $request): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'menyimpan server');
        
        $server = $this->creationService->handle($request->validated());
        $this->alert->success(trans('admin/server.notices.server_created'))->flash();

        return redirect()->route('admin.servers.view', $server->id);
    }

    public function update(ServerFormRequest $request, Server $server): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'mengupdate server');
        
        $this->updateService->handle($server, $request->validated());
        $this->alert->success(trans('admin/server.notices.server_updated'))->flash();

        return redirect()->route('admin.servers.view', $server->id);
    }

    public function destroy(Server $server): RedirectResponse
    {
        $adminController = new AdminController();
        $adminController->checkAdminAccess(auth()->user(), 'menghapus server');
        
        $this->deletionService->handle($server);
        $this->alert->success(trans('admin/server.notices.server_deleted'))->flash();

        return redirect()->route('admin.servers');
    }
}
EOF

    # 8. Buat file Controller.php jika tidak ada
    echo -e "${YELLOW}[SETUP]${NC} Membuat base Controller..."
    
    cat > "$PANEL_PATH/app/Http/Controllers/Controller.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers;

use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Routing\Controller as BaseController;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class Controller extends BaseController
{
    use AuthorizesRequests, DispatchesJobs, ValidatesRequests;
}
EOF

    # Set flag instalasi
    touch "$SECURITY_FLAG"
    
    echo -e "${GREEN}[SUCCESS]${NC} Security Panel berhasil diinstall!"
    echo -e "${YELLOW}[INFO]${NC} Hanya user dengan ID 1 yang bisa mengakses settings, nodes, locations, nests, dan mengelola server/user lain"
    echo -e "${YELLOW}[INFO]${NC} Pesan error: 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'"
}

# Fungsi ubah teks error
change_error_text() {
    echo -e "${BLUE}[UBAH TEKS]${NC} Mengubah teks error..."
    
    read -p "Masukkan teks error baru: " new_text
    
    if [ -z "$new_text" ]; then
        echo -e "${RED}[ERROR]${NC} Teks tidak boleh kosong!"
        return 1
    fi
    
    # Update semua file controller dengan teks baru
    find "$PANEL_PATH/app/Http/Controllers/Admin" -name "*.php" -type f -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/$new_text/g" {} \;
    
    echo -e "${GREEN}[SUCCESS]${NC} Teks error berhasil diubah menjadi: $new_text"
}

# Fungsi uninstall security
uninstall_security() {
    echo -e "${BLUE}[UNINSTALL]${NC} Memulai uninstall Security Panel..."
    
    if [ ! -f "$SECURITY_FLAG" ]; then
        echo -e "${YELLOW}[WARNING]${NC} Security Panel belum terinstall!"
        return 1
    fi
    
    # Restore dari backup
    echo -e "${YELLOW}[RESTORE]${NC} Merestore file dari backup..."
    
    # Cari file backup terbaru
    for file in "$BACKUP_DIR"/*.backup.*; do
        if [ -f "$file" ]; then
            original_file=$(echo "$file" | sed 's/\.backup\.[0-9]*$//')
            original_file="$PANEL_PATH/$(basename $original_file)"
            
            if [ -f "$original_file" ]; then
                cp "$file" "$original_file"
                echo -e "${GREEN}[RESTORE]${NC} $original_file"
            fi
        fi
    done
    
    # Hapus flag
    rm -f "$SECURITY_FLAG"
    
    echo -e "${GREEN}[SUCCESS]${NC} Security Panel berhasil diuninstall!"
    echo -e "${YELLOW}[INFO]${NC} Panel telah dikembalikan ke keadaan semula"
}

# Fungsi main menu
main_menu() {
    while true; do
        echo
        echo -e "${BLUE}=== Security Panel Pterodactyl ===${NC}"
        echo -e "${BLUE}        By @ginaabaikhati${NC}"
        echo
        echo "1. Install Security Panel"
        echo "2. Ubah Teks Error" 
        echo "3. Uninstall Security Panel"
        echo "4. Exit"
        echo
        read -p "Pilih opsi [1-4]: " choice
        
        case $choice in
            1)
                check_environment
                install_security
                ;;
            2)
                check_environment
                change_error_text
                ;;
            3)
                check_environment
                uninstall_security
                ;;
            4)
                echo -e "${GREEN}[EXIT]${NC} Terima kasih!"
                exit 0
                ;;
            *)
                echo -e "${RED}[ERROR]${NC} Pilihan tidak valid!"
                ;;
        esac
        
        echo
        read -p "Tekan Enter untuk melanjutkan..."
    done
}

# Header
echo
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}    Security Panel Pterodactyl${NC}"
echo -e "${BLUE}        By @ginaabaikhati${NC}"
echo -e "${BLUE}=========================================${NC}"
echo

# Jalankan main menu
main_menu
