#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error message
ERROR_MSG="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Paths
PANEL_PATH="/var/www/pterodactyl"
BACKUP_DIR="/root/pterodactyl_backup"

# Function to display header
display_header() {
    clear
    echo -e "${BLUE}"
    echo "================================================"
    echo "    Pterodactyl Panel Security Installer"
    echo "    By @ginaabaikhati"
    echo "================================================"
    echo -e "${NC}"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: Script harus dijalankan sebagai root!${NC}"
        exit 1
    fi
}

# Function to check if Pterodactyl is installed
check_pterodactyl() {
    if [[ ! -d "$PANEL_PATH" ]]; then
        echo -e "${RED}Error: Pterodactyl panel tidak ditemukan di $PANEL_PATH${NC}"
        exit 1
    fi
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup...${NC}"
    mkdir -p "$BACKUP_DIR"
    cp -r "$PANEL_PATH/app/Http/Controllers" "$BACKUP_DIR/" 2>/dev/null || true
    echo -e "${GREEN}Backup berhasil dibuat di $BACKUP_DIR${NC}"
}

# Function to restore backup
restore_backup() {
    if [[ -d "$BACKUP_DIR" ]]; then
        echo -e "${YELLOW}Memulihkan dari backup...${NC}"
        cp -r "$BACKUP_DIR/Controllers" "$PANEL_PATH/app/Http/" 2>/dev/null || true
        echo -e "${GREEN}Backup berhasil dipulihkan${NC}"
    else
        echo -e "${RED}Backup tidak ditemukan!${NC}"
    fi
}

# Function to install security
install_security() {
    display_header
    echo -e "${YELLOW}Menginstall Security Panel...${NC}"
    
    check_root
    check_pterodactyl
    create_backup
    
    # Create modified controllers
    cd "$PANEL_PATH"
    
    # 1. Modify AdminController untuk settings
    cat > app/Http/Controllers/Admin/AdminController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Http\Requests\Admin\AdminSettingsFormRequest;

class AdminController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    private $alert;

    /**
     * AdminController constructor.
     * @param AlertsMessageBag $alert
     */
    public function __construct(AlertsMessageBag $alert)
    {
        $this->alert = $alert;
    }

    /**
     * Render the Panel settings page.
     *
     * @return \Illuminate\View\View
     */
    public function index(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.settings', [
            'name' => config('app.name', 'Pterodactyl'),
        ]);
    }

    /**
     * Handle settings update.
     *
     * @param AdminSettingsFormRequest $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function update(AdminSettingsFormRequest $request): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        foreach ($request->normalize() as $key => $value) {
            $this->settings->set('settings::' . $key, $value);
        }

        $this->alert->success('Panel settings have been updated successfully.')->flash();

        return redirect()->route('admin.settings');
    }
}
EOF

    # 2. Modify NodeController
    cat > app/Http/Controllers/Admin/NodeController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Eloquent\NodeRepository;
use Pterodactyl\Http\Requests\Admin\NodeFormRequest;

class NodeController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    private $alert;

    /**
     * @var \Pterodactyl\Repositories\Eloquent\NodeRepository
     */
    private $repository;

    /**
     * NodeController constructor.
     * @param AlertsMessageBag $alert
     * @param NodeRepository $repository
     */
    public function __construct(AlertsMessageBag $alert, NodeRepository $repository)
    {
        $this->alert = $alert;
        $this->repository = $repository;
    }

    /**
     * List nodes index.
     *
     * @return \Illuminate\View\View
     */
    public function index(): View
    {
        return view('admin.nodes.index', [
            'nodes' => $this->repository->all(),
        ]);
    }

    /**
     * Node create page.
     *
     * @return \Illuminate\View\View
     */
    public function create(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.nodes.new');
    }

    /**
     * Handle node creation.
     *
     * @param NodeFormRequest $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function store(NodeFormRequest $request): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $node = $this->repository->create($request->validated());

        $this->alert->success(trans('admin/node.notices.node_created'))->flash();

        return redirect()->route('admin.nodes.view.configuration', $node->id);
    }

    /**
     * Update a node.
     *
     * @param NodeFormRequest $request
     * @param int $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function update(NodeFormRequest $request, int $id): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->repository->update($id, $request->validated());

        $this->alert->success(trans('admin/node.notices.node_updated'))->flash();

        return redirect()->route('admin.nodes.view.settings', $id);
    }

    /**
     * Delete a node.
     *
     * @param int $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function destroy(int $id): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->repository->delete($id);

        $this->alert->success(trans('admin/node.notices.node_deleted'))->flash();

        return redirect()->route('admin.nodes');
    }
}
EOF

    # 3. Modify LocationController
    cat > app/Http/Controllers/Admin/LocationController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Eloquent\LocationRepository;
use Pterodactyl\Http\Requests\Admin\LocationFormRequest;

class LocationController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    private $alert;

    /**
     * @var \Pterodactyl\Repositories\Eloquent\LocationRepository
     */
    private $repository;

    /**
     * LocationController constructor.
     * @param AlertsMessageBag $alert
     * @param LocationRepository $repository
     */
    public function __construct(AlertsMessageBag $alert, LocationRepository $repository)
    {
        $this->alert = $alert;
        $this->repository = $repository;
    }

    /**
     * Return the location overview page.
     *
     * @return \Illuminate\View\View
     */
    public function index(): View
    {
        return view('admin.locations.index', [
            'locations' => $this->repository->all(),
        ]);
    }

    /**
     * Return the location creation page.
     *
     * @return \Illuminate\View\View
     */
    public function create(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.locations.new');
    }

    /**
     * Handle creation of a new location.
     *
     * @param LocationFormRequest $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function store(LocationFormRequest $request): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $location = $this->repository->create($request->validated());

        $this->alert->success(trans('admin/location.notices.location_created'))->flash();

        return redirect()->route('admin.locations');
    }

    /**
     * Return the location update page.
     *
     * @param int $id
     * @return \Illuminate\View\View
     */
    public function update(int $id): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.locations.update', [
            'location' => $this->repository->find($id),
        ]);
    }

    /**
     * Handle updating of specified location.
     *
     * @param LocationFormRequest $request
     * @param int $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function updateLocation(LocationFormRequest $request, int $id): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->repository->update($id, $request->validated());

        $this->alert->success(trans('admin/location.notices.location_updated'))->flash();

        return redirect()->route('admin.locations');
    }

    /**
     * Delete a specified location.
     *
     * @param int $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function destroy(int $id): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->repository->delete($id);

        $this->alert->success(trans('admin/location.notices.location_deleted'))->flash();

        return redirect()->route('admin.locations');
    }
}
EOF

    # 4. Modify NestsController
    cat > app/Http/Controllers/Admin/NestsController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Eloquent\NestRepository;
use Pterodactyl\Http\Requests\Admin\NestFormRequest;

class NestsController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    private $alert;

    /**
     * @var \Pterodactyl\Repositories\Eloquent\NestRepository
     */
    private $repository;

    /**
     * NestsController constructor.
     * @param AlertsMessageBag $alert
     * @param NestRepository $repository
     */
    public function __construct(AlertsMessageBag $alert, NestRepository $repository)
    {
        $this->alert = $alert;
        $this->repository = $repository;
    }

    /**
     * Return the nest overview page.
     *
     * @return \Illuminate\View\View
     */
    public function index(): View
    {
        return view('admin.nests.index', [
            'nests' => $this->repository->all(),
        ]);
    }

    /**
     * Return the nest creation page.
     *
     * @return \Illuminate\View\View
     */
    public function create(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.nests.new');
    }

    /**
     * Handle creation of a new nest.
     *
     * @param NestFormRequest $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function store(NestFormRequest $request): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $nest = $this->repository->create($request->validated());

        $this->alert->success(trans('admin/nest.notices.nest_created'))->flash();

        return redirect()->route('admin.nests.view', $nest->id);
    }

    /**
     * Handle updating of a nest.
     *
     * @param NestFormRequest $request
     * @param int $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function update(NestFormRequest $request, int $id): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->repository->update($id, $request->validated());

        $this->alert->success(trans('admin/nest.notices.nest_updated'))->flash();

        return redirect()->route('admin.nests.view', $id);
    }

    /**
     * Delete a nest.
     *
     * @param int $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function destroy(int $id): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->repository->delete($id);

        $this->alert->success(trans('admin/nest.notices.nest_deleted'))->flash();

        return redirect()->route('admin.nests');
    }
}
EOF

    # 5. Modify UserController untuk mencegah edit/delete user lain
    cat > app/Http/Controllers/Admin/UserController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Eloquent\UserRepository;
use Pterodactyl\Http\Requests\Admin\UserFormRequest;

class UserController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    private $alert;

    /**
     * @var \Pterodactyl\Repositories\Eloquent\UserRepository
     */
    private $repository;

    /**
     * UserController constructor.
     * @param AlertsMessageBag $alert
     * @param UserRepository $repository
     */
    public function __construct(AlertsMessageBag $alert, UserRepository $repository)
    {
        $this->alert = $alert;
        $this->repository = $repository;
    }

    /**
     * Display user index page.
     *
     * @return \Illuminate\View\View
     */
    public function index(): View
    {
        return view('admin.users.index', [
            'users' => $this->repository->setSearchTerm(request()->input('query'))->getPaginated(50),
        ]);
    }

    /**
     * Display user view page.
     *
     * @param int $id
     * @return \Illuminate\View\View
     */
    public function view(int $id): View
    {
        $user = $this->repository->find($id);
        
        // Allow view, but prevent modifications if not user ID 1
        if (auth()->user()->id !== 1 && $id !== auth()->user()->id) {
            // Only show view, modifications will be blocked in update/delete methods
        }
        
        return view('admin.users.view', [
            'user' => $user,
            'servers' => $user->servers()->paginate(25),
        ]);
    }

    /**
     * Display user creation page.
     *
     * @return \Illuminate\View\View
     */
    public function create(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.users.new');
    }

    /**
     * Handle user creation.
     *
     * @param UserFormRequest $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function store(UserFormRequest $request): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $user = $this->repository->create($request->validated());

        $this->alert->success(trans('admin/user.notices.user_created'))->flash();

        return redirect()->route('admin.users.view', $user->id);
    }

    /**
     * Handle user update.
     *
     * @param UserFormRequest $request
     * @param int $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function update(UserFormRequest $request, int $id): RedirectResponse
    {
        if (auth()->user()->id !== 1 && $id !== auth()->user()->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->repository->update($id, $request->validated());

        $this->alert->success(trans('admin/user.notices.user_updated'))->flash();

        return redirect()->route('admin.users.view', $id);
    }

    /**
     * Delete a user.
     *
     * @param int $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function destroy(int $id): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->repository->delete($id);

        $this->alert->success(trans('admin/user.notices.user_deleted'))->flash();

        return redirect()->route('admin.users');
    }
}
EOF

    # 6. Modify ServerController untuk mencegah akses server user lain
    cat > app/Http/Controllers/Admin/ServersController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Eloquent\ServerRepository;
use Pterodactyl\Http\Requests\Admin\ServerFormRequest;

class ServersController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    private $alert;

    /**
     * @var \Pterodactyl\Repositories\Eloquent\ServerRepository
     */
    private $repository;

    /**
     * ServersController constructor.
     * @param AlertsMessageBag $alert
     * @param ServerRepository $repository
     */
    public function __construct(AlertsMessageBag $alert, ServerRepository $repository)
    {
        $this->alert = $alert;
        $this->repository = $repository;
    }

    /**
     * Display server index page.
     *
     * @return \Illuminate\View\View
     */
    public function index(): View
    {
        return view('admin.servers.index', [
            'servers' => $this->repository->setSearchTerm(request()->input('query'))->getPaginated(50),
        ]);
    }

    /**
     * Display server creation page.
     *
     * @return \Illuminate\View\View
     */
    public function create(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.servers.new');
    }

    /**
     * Handle server creation.
     *
     * @param ServerFormRequest $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function store(ServerFormRequest $request): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $server = $this->repository->create($request->validated());

        $this->alert->success(trans('admin/server.notices.server_created'))->flash();

        return redirect()->route('admin.servers.view', $server->id);
    }

    /**
     * Display server view page.
     *
     * @param int $id
     * @return \Illuminate\View\View
     */
    public function view(int $id): View
    {
        $server = $this->repository->find($id);
        
        // Allow view, but prevent modifications if not user ID 1
        if (auth()->user()->id !== 1 && $server->owner_id !== auth()->user()->id) {
            // Only show view, modifications will be blocked in update/delete methods
        }
        
        return view('admin.servers.view', [
            'server' => $server,
            'actions' => $server->actions,
        ]);
    }

    /**
     * Handle server update.
     *
     * @param ServerFormRequest $request
     * @param int $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function update(ServerFormRequest $request, int $id): RedirectResponse
    {
        $server = $this->repository->find($id);
        
        if (auth()->user()->id !== 1 && $server->owner_id !== auth()->user()->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->repository->update($id, $request->validated());

        $this->alert->success(trans('admin/server.notices.server_updated'))->flash();

        return redirect()->route('admin.servers.view', $id);
    }

    /**
     * Delete a server.
     *
     * @param int $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function destroy(int $id): RedirectResponse
    {
        $server = $this->repository->find($id);
        
        if (auth()->user()->id !== 1 && $server->owner_id !== auth()->user()->id) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->repository->delete($id);

        $this->alert->success(trans('admin/server.notices.server_deleted'))->flash();

        return redirect()->route('admin.servers');
    }
}
EOF

    # Clear cache and optimize
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    php artisan cache:clear
    php artisan view:clear
    php artisan config:clear

    echo -e "${GREEN}Security Panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Hanya user dengan ID 1 yang dapat melakukan modifikasi pada settings, nodes, locations, nests, dan user/server lain.${NC}"
    read -p "Tekan Enter untuk melanjutkan..."
}

# Function to change error text
change_error_text() {
    display_header
    echo -e "${YELLOW}Mengubah Teks Error...${NC}"
    
    read -p "Masukkan teks error baru: " new_error
    
    if [[ -z "$new_error" ]]; then
        echo -e "${RED}Teks error tidak boleh kosong!${NC}"
        return 1
    fi
    
    # Update all controllers with new error message
    find "$PANEL_PATH/app/Http/Controllers/Admin" -name "*.php" -type f -exec sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_error}/g" {} \;
    
    echo -e "${GREEN}Teks error berhasil diubah!${NC}"
    echo -e "${BLUE}Teks error baru: ${new_error}${NC}"
    read -p "Tekan Enter untuk melanjutkan..."
}

# Function to uninstall security
uninstall_security() {
    display_header
    echo -e "${YELLOW}Uninstall Security Panel...${NC}"
    
    restore_backup
    
    # Clear cache and optimize
    php artisan cache:clear
    php artisan view:clear
    php artisan config:clear
    
    echo -e "${GREEN}Security Panel berhasil diuninstall!${NC}"
    echo -e "${YELLOW}Panel telah dikembalikan ke keadaan semula.${NC}"
    read -p "Tekan Enter untuk melanjutkan..."
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${GREEN}Pilih opsi:${NC}"
        echo -e "1. Install Security Panel"
        echo -e "2. Ubah Teks Error" 
        echo -e "3. Uninstall Security Panel"
        echo -e "4. Exit"
        echo
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
                echo -e "${GREEN}Keluar...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Pilihan tidak valid!${NC}"
                sleep 2
                ;;
        esac
    done
}

# Check if Pterodactyl path exists, if not ask for path
if [[ ! -d "$PANEL_PATH" ]]; then
    echo -e "${YELLOW}Pterodactyl panel tidak ditemukan di path default.${NC}"
    read -p "Masukkan path panel Pterodactyl (contoh: /var/www/pterodactyl): " custom_path
    if [[ -d "$custom_path" ]]; then
        PANEL_PATH="$custom_path"
    else
        echo -e "${RED}Path panel Pterodactyl tidak valid!${NC}"
        exit 1
    fi
fi

# Run main menu
main_menu
