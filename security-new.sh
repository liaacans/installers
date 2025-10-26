#!/bin/bash

# Security Panel Pterodactyl - By @ginaabaikhati
# Script untuk mengamankan panel Pterodactyl

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Security message
SECURITY_MSG="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Path to Pterodactyl files (adjust according to your installation)
PANEL_PATH="/var/www/pterodactyl"
BACKUP_DIR="/root/pterodactyl_backup"

# Function to display header
display_header() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║               PTERODACTYL SECURITY PANEL                ║"
    echo "║                  By @ginaabaikhati                      ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup file Pterodactyl...${NC}"
    mkdir -p $BACKUP_DIR
    
    # Backup important files
    cp $PANEL_PATH/app/Http/Controllers/Admin/*.php $BACKUP_DIR/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php $BACKUP_DIR/ 2>/dev/null
    cp $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/*.php $BACKUP_DIR/ 2>/dev/null
    
    echo -e "${GREEN}Backup berhasil dibuat di: $BACKUP_DIR${NC}"
}

# Function to restore backup
restore_backup() {
    echo -e "${YELLOW}Mengembalikan dari backup...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}Backup directory tidak ditemukan!${NC}"
        return 1
    fi
    
    # Restore files
    cp $BACKUP_DIR/*.php $PANEL_PATH/app/Http/Controllers/Admin/ 2>/dev/null
    cp $BACKUP_DIR/AdminAuthenticate.php $PANEL_PATH/app/Http/Middleware/ 2>/dev/null
    cp $BACKUP_DIR/*.php $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ 2>/dev/null
    
    echo -e "${GREEN}Restore berhasil!${NC}"
}

# Function to install security
install_security() {
    echo -e "${YELLOW}Menginstall Security Panel...${NC}"
    
    # Create backup first
    create_backup
    
    # Security for Admin Settings Controller
    cat > $PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\Settings\BaseSettingsFormRequest;

class SettingsController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    private $alert;

    /**
     * @var \Pterodactyl\Contracts\Repository\SettingsRepositoryInterface
     */
    private $settings;

    /**
     * SettingsController constructor.
     */
    public function __construct(
        AlertsMessageBag $alert,
        SettingsRepositoryInterface $settings
    ) {
        $this->alert = $alert;
        $this->settings = $settings;
    }

    /**
     * Render the UI for basic panel settings.
     */
    public function index(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.settings.index', [
            'name' => config('app.name', 'Pterodactyl'),
        ]);
    }

    /**
     * Handle settings update.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     * @throws \Pterodactyl\Exceptions\Repository\RecordNotFoundException
     */
    public function update(BaseSettingsFormRequest $request): RedirectResponse
    {
        // Security check - only user ID 1 can access
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

    # Security for Nodes Controller
    cat > $PANEL_PATH/app/Http/Controllers/Admin/NodesController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Nodes\NodeUpdateService;
use Pterodactyl\Services\Nodes\NodeCreationService;
use Pterodactyl\Services\Nodes\NodeDeletionService;
use Pterodactyl\Http\Requests\Admin\NodeFormRequest;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;

class NodesController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    private $alert;

    /**
     * @var \Pterodactyl\Services\Nodes\NodeCreationService
     */
    private $creationService;

    /**
     * @var \Pterodactyl\Services\Nodes\NodeDeletionService
     */
    private $deletionService;

    /**
     * @var \Pterodactyl\Contracts\Repository\NodeRepositoryInterface
     */
    private $repository;

    /**
     * @var \Pterodactyl\Services\Nodes\NodeUpdateService
     */
    private $updateService;

    /**
     * NodesController constructor.
     */
    public function __construct(
        AlertsMessageBag $alert,
        NodeCreationService $creationService,
        NodeDeletionService $deletionService,
        NodeRepositoryInterface $repository,
        NodeUpdateService $updateService
    ) {
        $this->alert = $alert;
        $this->creationService = $creationService;
        $this->deletionService = $deletionService;
        $this->repository = $repository;
        $this->updateService = $updateService;
    }

    /**
     * Returns a listing of all nodes on the system.
     */
    public function index(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.nodes.index', [
            'nodes' => $this->repository->all(),
        ]);
    }

    /**
     * Returns the new node creation page.
     */
    public function create(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.nodes.new');
    }

    /**
     * Creates a new node.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     */
    public function store(NodeFormRequest $request): RedirectResponse
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $node = $this->creationService->handle($request->normalize());
        $this->alert->success(trans('admin/node.notices.node_created'))->flash();

        return redirect()->route('admin.nodes.view', $node->id);
    }

    /**
     * Returns node view page.
     */
    public function view(int $id): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.nodes.view', [
            'node' => $this->repository->find($id),
        ]);
    }

    /**
     * Updates a node.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     * @throws \Pterodactyl\Exceptions\Repository\RecordNotFoundException
     */
    public function update(NodeFormRequest $request, int $id): RedirectResponse
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->updateService->handle($id, $request->normalize());
        $this->alert->success(trans('admin/node.notices.node_updated'))->flash();

        return redirect()->route('admin.nodes.view', $id);
    }

    /**
     * Deletes a node.
     *
     * @throws \Pterodactyl\Exceptions\Service\HasActiveServersException
     */
    public function destroy(int $id): RedirectResponse
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->deletionService->handle($id);
        $this->alert->success(trans('admin/node.notices.node_deleted'))->flash();

        return redirect()->route('admin.nodes');
    }
}
EOF

    # Security for Locations Controller
    cat > $PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Locations\LocationUpdateService;
use Pterodactyl\Services\Locations\LocationCreationService;
use Pterodactyl\Services\Locations\LocationDeletionService;
use Pterodactyl\Http\Requests\Admin\LocationFormRequest;
use Pterodactyl\Contracts\Repository\LocationRepositoryInterface;

class LocationsController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    private $alert;

    /**
     * @var \Pterodactyl\Services\Locations\LocationCreationService
     */
    private $creationService;

    /**
     * @var \Pterodactyl\Services\Locations\LocationDeletionService
     */
    private $deletionService;

    /**
     * @var \Pterodactyl\Contracts\Repository\LocationRepositoryInterface
     */
    private $repository;

    /**
     * @var \Pterodactyl\Services\Locations\LocationUpdateService
     */
    private $updateService;

    /**
     * LocationsController constructor.
     */
    public function __construct(
        AlertsMessageBag $alert,
        LocationCreationService $creationService,
        LocationDeletionService $deletionService,
        LocationRepositoryInterface $repository,
        LocationUpdateService $updateService
    ) {
        $this->alert = $alert;
        $this->creationService = $creationService;
        $this->deletionService = $deletionService;
        $this->repository = $repository;
        $this->updateService = $updateService;
    }

    /**
     * Return the location overview page.
     */
    public function index(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.locations.index', [
            'locations' => $this->repository->all(),
        ]);
    }

    /**
     * Return the location creation page.
     */
    public function create(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.locations.new');
    }

    /**
     * Return the location update page.
     */
    public function update(int $id): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.locations.update', [
            'location' => $this->repository->find($id),
        ]);
    }

    /**
     * Create a new location.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     */
    public function store(LocationFormRequest $request): RedirectResponse
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $location = $this->creationService->handle($request->normalize());
        $this->alert->success(trans('admin/location.notices.location_created'))->flash();

        return redirect()->route('admin.locations');
    }

    /**
     * Update an existing location.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     * @throws \Pterodactyl\Exceptions\Repository\RecordNotFoundException
     */
    public function edit(LocationFormRequest $request, int $id): RedirectResponse
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->updateService->handle($id, $request->normalize());
        $this->alert->success(trans('admin/location.notices.location_updated'))->flash();

        return redirect()->route('admin.locations.update', $id);
    }

    /**
     * Delete a location from the system.
     */
    public function destroy(int $id): RedirectResponse
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->deletionService->handle($id);
        $this->alert->success(trans('admin/location.notices.location_deleted'))->flash();

        return redirect()->route('admin.locations');
    }
}
EOF

    # Security for Nests Controller
    cat > $PANEL_PATH/app/Http/Controllers/Admin/NestsController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Nests\NestUpdateService;
use Pterodactyl\Services\Nests\NestCreationService;
use Pterodactyl\Services\Nests\NestDeletionService;
use Pterodactyl\Http\Requests\Admin\NestFormRequest;
use Pterodactyl\Contracts\Repository\NestRepositoryInterface;

class NestsController extends Controller
{
    /**
     * @var \Prologue\Alerts\AlertsMessageBag
     */
    private $alert;

    /**
     * @var \Pterodactyl\Services\Nests\NestCreationService
     */
    private $creationService;

    /**
     * @var \Pterodactyl\Services\Nests\NestDeletionService
     */
    private $deletionService;

    /**
     * @var \Pterodactyl\Contracts\Repository\NestRepositoryInterface
     */
    private $repository;

    /**
     * @var \Pterodactyl\Services\Nests\NestUpdateService
     */
    private $updateService;

    /**
     * NestsController constructor.
     */
    public function __construct(
        AlertsMessageBag $alert,
        NestCreationService $creationService,
        NestDeletionService $deletionService,
        NestRepositoryInterface $repository,
        NestUpdateService $updateService
    ) {
        $this->alert = $alert;
        $this->creationService = $creationService;
        $this->deletionService = $deletionService;
        $this->repository = $repository;
        $this->updateService = $updateService;
    }

    /**
     * Return the nest overview page.
     */
    public function index(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.nests.index', [
            'nests' => $this->repository->all(),
        ]);
    }

    /**
     * Return the nest creation page.
     */
    public function create(): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.nests.new');
    }

    /**
     * Return the nest update page.
     */
    public function update(int $id): View
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        return view('admin.nests.update', [
            'nest' => $this->repository->getWithEggs($id),
        ]);
    }

    /**
     * Create a new nest.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     */
    public function store(NestFormRequest $request): RedirectResponse
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $nest = $this->creationService->handle($request->normalize());
        $this->alert->success(trans('admin/nest.notices.nest_created'))->flash();

        return redirect()->route('admin.nests.view', $nest->id);
    }

    /**
     * Update an existing nest.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     * @throws \Pterodactyl\Exceptions\Repository\RecordNotFoundException
     */
    public function edit(NestFormRequest $request, int $id): RedirectResponse
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->updateService->handle($id, $request->normalize());
        $this->alert->success(trans('admin/nest.notices.nest_updated'))->flash();

        return redirect()->route('admin.nests.view', $id);
    }

    /**
     * Delete a nest from the system.
     */
    public function destroy(int $id): RedirectResponse
    {
        // Security check - only user ID 1 can access
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->deletionService->handle($id);
        $this->alert->success(trans('admin/nest.notices.nest_deleted'))->flash();

        return redirect()->route('admin.nests');
    }
}
EOF

    # Security for Server Controller (prevent users from modifying other users' servers)
    cat > $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Illuminate\Http\Response;
use Pterodactyl\Models\Server;
use Pterodactyl\Repositories\Eloquent\ServerRepository;
use Pterodactyl\Services\Servers\ServerDeletionService;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Http\Requests\Api\Client\Servers\DeleteServerRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\UpdateServerRequest;

class ServerController extends ClientApiController
{
    /**
     * @var \Pterodactyl\Repositories\Eloquent\ServerRepository
     */
    private $repository;

    /**
     * @var \Pterodactyl\Services\Servers\ServerDeletionService
     */
    private $deletionService;

    /**
     * ServerController constructor.
     */
    public function __construct(ServerRepository $repository, ServerDeletionService $deletionService)
    {
        parent::__construct();

        $this->repository = $repository;
        $this->deletionService = $deletionService;
    }

    /**
     * Update the details of a server.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     * @throws \Pterodactyl\Exceptions\Repository\RecordNotFoundException
     */
    public function update(UpdateServerRequest $request, Server $server): array
    {
        // Security check - prevent users from modifying other users' servers
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->repository->update($server->id, $request->validated());

        return $this->fractal->item($server->refresh())
            ->transformWith($this->getTransformer(ServerTransformer::class))
            ->toArray();
    }

    /**
     * Delete a server from the panel.
     *
     * @throws \Throwable
     */
    public function delete(DeleteServerRequest $request, Server $server): Response
    {
        // Security check - prevent users from deleting other users' servers
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        $this->deletionService->handle($server);

        return $this->returnNoContent();
    }
}
EOF

    # Update Admin Authenticate Middleware for additional security
    cat > $PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Pterodactyl\Contracts\Repository\ApiKeyRepositoryInterface;

class AdminAuthenticate
{
    /**
     * @var \Pterodactyl\Contracts\Repository\ApiKeyRepositoryInterface
     */
    private $repository;

    public function __construct(ApiKeyRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    /**
     * Check if a user is an admin, or if an API key is being used with admin permissions.
     *
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        // Security check - only user ID 1 can access admin areas
        if ($request->user() && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }
        
        if ($request->user()) {
            if (! $request->user()->root_admin) {
                abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
            }

            return $next($request);
        }

        // Check if this is an API key that is an administrative key.
        if ($request->apiKey) {
            $model = $this->repository->find($request->apiKey);
            if (! $model->admin) {
                abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
            }

            return $next($request);
        }

        abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
    }
}
EOF

    echo -e "${GREEN}Security Panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Hanya user dengan ID 1 yang dapat mengakses settings, nodes, locations, nests${NC}"
    echo -e "${YELLOW}User lain tidak dapat menghapus/mengubah server user lain${NC}"
    
    # Clear cache
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    cd $PANEL_PATH
    php artisan cache:clear
    php artisan view:clear
    
    echo -e "${GREEN}Installasi selesai!${NC}"
}

# Function to change error text
change_error_text() {
    echo -e "${YELLOW}Mengubah teks error...${NC}"
    
    read -p "Masukkan teks error baru: " new_text
    
    if [ -z "$new_text" ]; then
        echo -e "${RED}Teks tidak boleh kosong!${NC}"
        return 1
    fi
    
    # Update all files with new text
    sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_text}/g" $PANEL_PATH/app/Http/Controllers/Admin/*.php 2>/dev/null
    sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_text}/g" $PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php 2>/dev/null
    sed -i "s/Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati/${new_text}/g" $PANEL_PATH/app/Http/Controllers/Api/Client/Servers/*.php 2>/dev/null
    
    SECURITY_MSG="$new_text"
    
    echo -e "${GREEN}Teks error berhasil diubah!${NC}"
    echo -e "${BLUE}Teks baru: $new_text${NC}"
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Uninstall Security Panel...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}Backup directory tidak ditemukan!${NC}"
        echo -e "${YELLOW}Mencoba restore dari original Pterodactyl...${NC}"
        
        # You might need to reinstall or restore from git
        echo -e "${YELLOW}Silakan restore Pterodactyl dari backup original atau git repository${NC}"
        return 1
    fi
    
    restore_backup
    
    echo -e "${GREEN}Security Panel berhasil diuninstall!${NC}"
    echo -e "${YELLOW}Panel kembali ke pengaturan semula${NC}"
}

# Main menu
while true; do
    display_header
    echo -e "${GREEN}Pilih opsi:${NC}"
    echo -e "1. Install Security Panel"
    echo -e "2. Ubah Teks Error" 
    echo -e "3. Uninstall Security Panel"
    echo -e "4. Exit"
    echo ""
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
            echo -e "${GREEN}Keluar...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            ;;
    esac
    
    echo ""
    read -p "Tekan Enter untuk melanjutkan..."
done
