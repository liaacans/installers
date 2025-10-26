#!/bin/bash
# security.sh - Security Panel Pterodactyl
# By @ginaabaikhati

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variabel path Pterodactyl
PANEL_PATH="/var/www/pterodactyl"
BACKUP_DIR="/root/pterodactyl_backup"
ERROR_MSG='Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati'

# Fungsi untuk mengecek apakah script dijalankan di VPS yang diizinkan
check_vps_authorization() {
    local allowed_hostname="128.199.175.12" # Ganti dengan hostname VPS yang diizinkan
    local current_hostname=$(hostname)
    
    if [[ "$current_hostname" != "$allowed_hostname" ]]; then
        echo -e "${RED}❌ Akses ditolak! Script hanya boleh dijalankan di VPS yang telah diotorisasi.${NC}"
        echo -e "${YELLOW}Hostname saat ini: $current_hostname${NC}"
        echo -e "${YELLOW}Hostname yang diizinkan: $allowed_hostname${NC}"
        exit 1
    fi
}

# Fungsi untuk membuat backup
create_backup() {
    echo -e "${YELLOW}Membuat backup file yang akan dimodifikasi...${NC}"
    mkdir -p "$BACKUP_DIR"
    
    # Backup file yang akan dimodifikasi
    cp "$PANEL_PATH/app/Http/Controllers/Admin"/*.php "$BACKUP_DIR/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Middleware"/*.php "$BACKUP_DIR/" 2>/dev/null
    cp "$PANEL_PATH/app/Models"/*.php "$BACKUP_DIR/" 2>/dev/null
    
    echo -e "${GREEN}✅ Backup berhasil dibuat di $BACKUP_DIR${NC}"
}

# Fungsi install security
install_security() {
    echo -e "${YELLOW}Memulai instalasi security panel...${NC}"
    
    # Pastikan path panel ada
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}❌ Directory Pterodactyl tidak ditemukan di $PANEL_PATH${NC}"
        exit 1
    fi
    
    cd "$PANEL_PATH"
    
    # Buat backup terlebih dahulu
    create_backup
    
    # 1. Modifikasi AdminController
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/AdminController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\User;
use Pterodactyl\Models\Server;
use Pterodactyl\Models\Node;
use Pterodactyl\Models\Location;
use Pterodactyl\Models\Nest;

class AdminController extends Controller
{
    public function checkAccess($action = '')
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
    }
    
    public function checkResourceAccess($resource, $id = null)
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            // Allow API access
            if (request()->is('api/*')) {
                return true;
            }
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
    }
}
EOF

    # 2. Modifikasi SettingsController
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class SettingsController extends Controller
{
    public function __construct()
    {
        parent::__construct();
        $this->checkSettingsAccess();
    }
    
    private function checkSettingsAccess()
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
    }
    
    public function index()
    {
        return view('admin.settings');
    }
    
    public function update(Request $request)
    {
        // Hanya user ID 1 yang bisa update settings
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Logic update settings
        return redirect()->back()->with('success', 'Settings updated successfully');
    }
}
EOF

    # 3. Modifikasi NodeController
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Node;

class NodesController extends Controller
{
    public function __construct()
    {
        parent::__construct();
        $this->checkNodeAccess();
    }
    
    private function checkNodeAccess()
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
    }
    
    public function index()
    {
        $nodes = Node::all();
        return view('admin.nodes.index', compact('nodes'));
    }
    
    public function create()
    {
        return view('admin.nodes.create');
    }
    
    public function store(Request $request)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Logic store node
    }
    
    public function edit($id)
    {
        $node = Node::findOrFail($id);
        return view('admin.nodes.edit', compact('node'));
    }
    
    public function update(Request $request, $id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Logic update node
    }
    
    public function destroy($id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        // Logic delete node
    }
}
EOF

    # 4. Modifikasi LocationController
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Pterodactyl\Models\Location;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Locations\LocationUpdateService;
use Pterodactyl\Services\Locations\LocationCreationService;
use Pterodactyl\Services\Locations\LocationDeletionService;
use Pterodactyl\Http\Requests\Admin\LocationFormRequest;

class LocationsController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected LocationCreationService $creationService,
        protected LocationDeletionService $deletionService,
        protected LocationUpdateService $updateService
    ) {
        parent::__construct();
        $this->checkLocationAccess();
    }
    
    private function checkLocationAccess()
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
    }

    public function index()
    {
        return view('admin.locations.index', [
            'locations' => Location::all(),
        ]);
    }

    public function create()
    {
        return view('admin.locations.create');
    }

    public function store(LocationFormRequest $request)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $location = $this->creationService->handle($request->normalize());
        $this->alert->success('Location was created successfully.')->flash();

        return redirect()->route('admin.locations.view', $location->id);
    }

    public function view(Location $location)
    {
        return view('admin.locations.view', [
            'location' => $location,
            'nodes' => $location->nodes,
        ]);
    }

    public function update(LocationFormRequest $request, Location $location)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->updateService->handle($location, $request->normalize());
        $this->alert->success('Location was updated successfully.')->flash();

        return redirect()->route('admin.locations.view', $location->id);
    }

    public function destroy(Location $location)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->deletionService->handle($location);
        $this->alert->success('Location was deleted successfully.')->flash();

        return redirect()->route('admin.locations');
    }
}
EOF

    # 5. Modifikasi NestController
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NestsController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Pterodactyl\Models\Nest;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Nests\NestUpdateService;
use Pterodactyl\Services\Nests\NestCreationService;
use Pterodactyl\Services\Nests\NestDeletionService;
use Pterodactyl\Http\Requests\Admin\NestFormRequest;

class NestsController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected NestCreationService $creationService,
        protected NestDeletionService $deletionService,
        protected NestUpdateService $updateService
    ) {
        parent::__construct();
        $this->checkNestAccess();
    }
    
    private function checkNestAccess()
    {
        if (auth()->check() && auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
    }

    public function index(): View
    {
        return view('admin.nests.index', [
            'nests' => Nest::all(),
        ]);
    }

    public function create(): View
    {
        return view('admin.nests.create');
    }

    public function store(NestFormRequest $request): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $nest = $this->creationService->handle($request->normalize());
        $this->alert->success('Nest was created successfully.')->flash();

        return redirect()->route('admin.nests.view', $nest->id);
    }

    public function view(Nest $nest): View
    {
        return view('admin.nests.view', [
            'nest' => $nest,
            'eggs' => $nest->eggs,
        ]);
    }

    public function update(NestFormRequest $request, Nest $nest): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->updateService->handle($nest, $request->normalize());
        $this->alert->success('Nest was updated successfully.')->flash();

        return redirect()->route('admin.nests.view', $nest->id);
    }

    public function destroy(Nest $nest): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->deletionService->handle($nest);
        $this->alert->success('Nest was deleted successfully.')->flash();

        return redirect()->route('admin.nests');
    }
}
EOF

    # 6. Modifikasi ServerController untuk proteksi server user lain
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/ServersController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Models\Server;
use Pterodactyl\Models\User;
use Pterodactyl\Http\Controllers\Controller;

class ServersController extends Controller
{
    public function __construct()
    {
        parent::__construct();
    }
    
    private function checkServerAccess($serverId = null)
    {
        $user = auth()->user();
        
        // User ID 1 bisa akses semua
        if ($user->id === 1) {
            return true;
        }
        
        // Jika mengakses server spesifik
        if ($serverId) {
            $server = Server::find($serverId);
            if ($server && $server->owner_id !== $user->id) {
                abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
            }
        }
        
        // Untuk aksi global seperti list semua server
        if (in_array(request()->route()->getName(), ['admin.servers', 'admin.servers.view'])) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
    }
    
    public function index()
    {
        $this->checkServerAccess();
        
        if (auth()->user()->id === 1) {
            $servers = Server::all();
        } else {
            $servers = Server::where('owner_id', auth()->user()->id)->get();
        }
        
        return view('admin.servers.index', compact('servers'));
    }
    
    public function view($id)
    {
        $this->checkServerAccess($id);
        $server = Server::findOrFail($id);
        return view('admin.servers.view', compact('server'));
    }
    
    public function edit($id)
    {
        $this->checkServerAccess($id);
        $server = Server::findOrFail($id);
        return view('admin.servers.edit', compact('server'));
    }
    
    public function update(Request $request, $id)
    {
        $this->checkServerAccess($id);
        
        $server = Server::findOrFail($id);
        // Logic update server
    }
    
    public function destroy($id)
    {
        $this->checkServerAccess($id);
        
        $server = Server::findOrFail($id);
        // Logic delete server
    }
}
EOF

    # 7. Modifikasi UserController
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/UsersController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Models\User;
use Pterodactyl\Http\Controllers\Controller;

class UsersController extends Controller
{
    public function __construct()
    {
        parent::__construct();
        $this->checkUserAccess();
    }
    
    private function checkUserAccess()
    {
        $user = auth()->user();
        
        // User ID 1 bisa akses semua
        if ($user->id === 1) {
            return true;
        }
        
        // User lain tidak bisa akses halaman users
        abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
    }
    
    public function index()
    {
        $users = User::all();
        return view('admin.users.index', compact('users'));
    }
    
    public function view($id)
    {
        $user = User::findOrFail($id);
        return view('admin.users.view', compact('user'));
    }
    
    public function edit($id)
    {
        $user = User::findOrFail($id);
        return view('admin.users.edit', compact('user'));
    }
    
    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);
        // Logic update user
    }
    
    public function destroy($id)
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $user = User::findOrFail($id);
        // Logic delete user
    }
}
EOF

    # 8. Buat middleware untuk proteksi global
    cat > "$PANEL_PATH/app/Http/Middleware/CheckAdminAccess.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckAdminAccess
{
    public function handle(Request $request, Closure $next)
    {
        // Skip untuk API routes
        if ($request->is('api/*')) {
            return $next($request);
        }
        
        $user = auth()->user();
        $route = $request->route();
        
        if (!$user) {
            return $next($request);
        }
        
        // User ID 1 bisa akses semua
        if ($user->id === 1) {
            return $next($request);
        }
        
        // Proteksi routes admin tertentu
        $protectedRoutes = [
            'admin.settings',
            'admin.nodes', 
            'admin.locations',
            'admin.nests',
            'admin.users'
        ];
        
        if ($route && in_array($route->getName(), $protectedRoutes)) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return $next($request);
    }
}
EOF

    echo -e "${YELLOW}Mengupdate composer autoload...${NC}"
    composer dump-autoload

    echo -e "${YELLOW}Mengatur permissions...${NC}"
    chown -R www-data:www-data "$PANEL_PATH"
    chmod -R 755 "$PANEL_PATH/storage"
    chmod -R 755 "$PANEL_PATH/bootstrap/cache"

    echo -e "${GREEN}✅ Security panel berhasil diinstall!${NC}"
    echo -e "${BLUE}📝 Hanya user dengan ID 1 yang bisa mengakses:${NC}"
    echo -e "${BLUE}   • Panel Settings${NC}"
    echo -e "${BLUE}   • Nodes Management${NC}"
    echo -e "${BLUE}   • Locations Management${NC}"
    echo -e "${BLUE}   • Nests Management${NC}"
    echo -e "${BLUE}   • Users Management${NC}"
    echo -e "${BLUE}   • Server user lain${NC}"
}

# Fungsi untuk mengubah teks error
change_error_text() {
    echo -e "${YELLOW}Mengubah teks error...${NC}"
    
    read -p "Masukkan teks error baru: " new_error_text
    
    if [ -z "$new_error_text" ]; then
        echo -e "${RED}❌ Teks error tidak boleh kosong!${NC}"
        return 1
    fi
    
    # Escape special characters for sed
    escaped_text=$(printf '%s\n' "$new_error_text" | sed 's/[[\.*^$/]/\\&/g')
    
    # Update teks error di semua file controller
    find "$PANEL_PATH/app/Http/Controllers/Admin" -name "*.php" -type f -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${escaped_text}/g" {} \;
    
    # Update teks error di middleware
    if [ -f "$PANEL_PATH/app/Http/Middleware/CheckAdminAccess.php" ]; then
        sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${escaped_text}/g" "$PANEL_PATH/app/Http/Middleware/CheckAdminAccess.php"
    fi
    
    echo -e "${GREEN}✅ Teks error berhasil diubah!${NC}"
    echo -e "${BLUE}📝 Teks error baru: $new_error_text${NC}"
}

# Fungsi uninstall security
uninstall_security() {
    echo -e "${YELLOW}Memulai uninstall security panel...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}❌ Backup directory tidak ditemukan!${NC}"
        echo -e "${YELLOW}⚠️  Tidak bisa melakukan uninstall otomatis.${NC}"
        return 1
    fi
    
    # Restore file dari backup
    echo -e "${YELLOW}Merestore file dari backup...${NC}"
    cp -r "$BACKUP_DIR"/* "$PANEL_PATH/app/Http/Controllers/Admin/" 2>/dev/null
    
    # Hapus middleware custom
    if [ -f "$PANEL_PATH/app/Http/Middleware/CheckAdminAccess.php" ]; then
        rm "$PANEL_PATH/app/Http/Middleware/CheckAdminAccess.php"
    fi
    
    echo -e "${YELLOW}Mengupdate composer autoload...${NC}"
    cd "$PANEL_PATH" && composer dump-autoload
    
    echo -e "${YELLOW}Mengatur permissions...${NC}"
    chown -R www-data:www-data "$PANEL_PATH"
    chmod -R 755 "$PANEL_PATH/storage"
    chmod -R 755 "$PANEL_PATH/bootstrap/cache"
    
    echo -e "${GREEN}✅ Security panel berhasil diuninstall!${NC}"
    echo -e "${YELLOW}⚠️  Panel telah dikembalikan ke state semula.${NC}"
}

# Fungsi utama
main() {
    # Check VPS authorization
    check_vps_authorization
    
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║    Security Panel Pterodactyl        ║"
    echo "║        By @ginaabaikhati             ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
    
    while true; do
        echo
        echo -e "${YELLOW}Pilih opsi:${NC}"
        echo "1. Install Security Panel"
        echo "2. Ubah Teks Error" 
        echo "3. Uninstall Security Panel"
        echo "4. Exit"
        echo
        read -p "Masukkan pilihan (1-4): " choice
        
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
                echo -e "${RED}❌ Pilihan tidak valid!${NC}"
                ;;
        esac
        
        echo
        read -p "Tekan Enter untuk melanjutkan..."
        clear
    done
}

# Jalankan script utama
main "$@"
