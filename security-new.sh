#!/bin/bash

# security.sh - Security Panel Pterodactyl by @ginaabaikhati
# Script untuk mengamankan panel Pterodactyl dengan restriksi akses ketat

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default error message
ERROR_MSG="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Pterodactyl paths (adjust according to your installation)
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
    echo -e "${YELLOW}Membuat backup file panel...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi
    
    # Backup important files
    cp -r "$PANEL_PATH/app/Http" "$BACKUP_DIR/" 2>/dev/null
    cp -r "$PANEL_PATH/app/Models" "$BACKUP_DIR/" 2>/dev/null
    cp -r "$PANEL_PATH/routes" "$BACKUP_DIR/" 2>/dev/null
    cp -r "$PANEL_PATH/app" "$BACKUP_DIR/" 2>/dev/null
    
    echo -e "${GREEN}Backup berhasil dibuat di: $BACKUP_DIR${NC}"
}

# Function to restore backup
restore_backup() {
    echo -e "${YELLOW}Memulihkan panel dari backup...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}Backup tidak ditemukan!${NC}"
        return 1
    fi
    
    # Restore files
    cp -r "$BACKUP_DIR/Http" "$PANEL_PATH/app/" 2>/dev/null
    cp -r "$BACKUP_DIR/Models" "$PANEL_PATH/app/" 2>/dev/null
    cp -r "$BACKUP_DIR/routes" "$PANEL_PATH/" 2>/dev/null
    
    # Run panel commands
    cd "$PANEL_PATH"
    php artisan cache:clear
    php artisan view:clear
    
    echo -e "${GREEN}Panel berhasil dipulihkan!${NC}"
}

# Function to check if user is admin (ID 1)
check_admin_access() {
    echo '<?php
if (auth()->check()) {
    return auth()->user()->id === 1;
}
return false;
?>'
}

# Function to install security
install_security() {
    display_header
    echo -e "${YELLOW}Menginstal Security Panel Pterodactyl...${NC}"
    
    # Create backup first
    create_backup
    
    # Check if panel path exists
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}Path panel Pterodactyl tidak ditemukan!${NC}"
        echo -e "${YELLOW}Silakan sesuaikan PANEL_PATH dalam script.${NC}"
        return 1
    fi
    
    cd "$PANEL_PATH"
    
    # 1. Secure AdminController - Settings
    echo -e "${BLUE}Mengamankan Admin Settings...${NC}"
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/SettingsController.php" << 'EOF'
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
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.settings.index');
    }

    /**
     * Handle request to update basic panel settings.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     * @throws \Pterodactyl\Exceptions\Repository\RecordNotFoundException
     */
    public function update(BaseSettingsFormRequest $request): RedirectResponse
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

    # 2. Secure NodeController
    echo -e "${BLUE}Mengamankan Nodes...${NC}"
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NodeController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Pterodactyl\Models\Node;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Nodes\NodeUpdateService;
use Pterodactyl\Services\Nodes\NodeCreationService;
use Pterodactyl\Services\Nodes\NodeDeletionService;
use Pterodactyl\Http\Requests\Admin\Node\NodeFormRequest;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;

class NodeController extends Controller
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
     * NodeController constructor.
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
     * Display node index.
     */
    public function index(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.index', [
            'nodes' => $this->repository->all(),
        ]);
    }

    /**
     * Display node create page.
     */
    public function create(): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.create');
    }

    /**
     * Handle create node request.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     */
    public function store(NodeFormRequest $request): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $node = $this->creationService->handle($request->normalize());
        $this->alert->success(trans('admin/node.notices.node_created'))->flash();

        return redirect()->route('admin.nodes.view', $node->id);
    }

    /**
     * Display node update page.
     */
    public function view(int $id): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nodes.view', [
            'node' => $this->repository->find($id),
        ]);
    }

    /**
     * Handle node update.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     * @throws \Pterodactyl\Exceptions\Repository\RecordNotFoundException
     */
    public function update(NodeFormRequest $request, int $id): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $this->updateService->handle($id, $request->normalize());
        $this->alert->success(trans('admin/node.notices.node_updated'))->flash();

        return redirect()->route('admin.nodes.view', $id);
    }

    /**
     * Delete a node.
     *
     * @throws \Pterodactyl\Exceptions\Service\HasActiveServersException
     */
    public function destroy(int $id): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $this->deletionService->handle($id);
        $this->alert->success(trans('admin/node.notices.node_deleted'))->flash();

        return redirect()->route('admin.nodes');
    }
}
EOF

    # 3. Secure LocationController
    echo -e "${BLUE}Mengamankan Locations...${NC}"
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/LocationController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Pterodactyl\Models\Location;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Locations\LocationUpdateService;
use Pterodactyl\Services\Locations\LocationCreationService;
use Pterodactyl\Services\Locations\LocationDeletionService;
use Pterodactyl\Http\Requests\Admin\LocationFormRequest;
use Pterodactyl\Contracts\Repository\LocationRepositoryInterface;

class LocationController extends Controller
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
     * LocationController constructor.
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
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.index', [
            'locations' => $this->repository->all(),
        ]);
    }

    /**
     * Return the location view page.
     */
    public function view(int $id): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.locations.view', [
            'location' => $this->repository->find($id),
        ]);
    }

    /**
     * Handle request to create new location.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     */
    public function create(LocationFormRequest $request): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $location = $this->creationService->handle($request->normalize());
        $this->alert->success(trans('admin/location.notices.created'))->flash();

        return redirect()->route('admin.locations.view', $location->id);
    }

    /**
     * Handle request to update a location.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     * @throws \Pterodactyl\Exceptions\Repository\RecordNotFoundException
     */
    public function update(LocationFormRequest $request, int $id): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $this->updateService->handle($id, $request->normalize());
        $this->alert->success(trans('admin/location.notices.updated'))->flash();

        return redirect()->route('admin.locations.view', $id);
    }

    /**
     * Handle request to delete a location.
     */
    public function destroy(int $id): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $this->deletionService->handle($id);
        $this->alert->success(trans('admin/location.notices.deleted'))->flash();

        return redirect()->route('admin.locations');
    }
}
EOF

    # 4. Secure NestController
    echo -e "${BLUE}Mengamankan Nests...${NC}"
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NestController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Pterodactyl\Models\Nest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Nests\NestUpdateService;
use Pterodactyl\Services\Nests\NestCreationService;
use Pterodactyl\Services\Nests\NestDeletionService;
use Pterodactyl\Http\Requests\Admin\NestFormRequest;
use Pterodactyl\Contracts\Repository\NestRepositoryInterface;

class NestController extends Controller
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
     * NestController constructor.
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
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nests.index', [
            'nests' => $this->repository->getWithEggs(),
        ]);
    }

    /**
     * Return the nest view page.
     */
    public function view(int $id): View
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return view('admin.nests.view', [
            'nest' => $this->repository->getWithEggs($id),
        ]);
    }

    /**
     * Handle request to create new nest.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     */
    public function store(NestFormRequest $request): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $nest = $this->creationService->handle($request->normalize());
        $this->alert->success(trans('admin/nest.notices.created'))->flash();

        return redirect()->route('admin.nests.view', $nest->id);
    }

    /**
     * Handle request to update a nest.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     * @throws \Pterodactyl\Exceptions\Repository\RecordNotFoundException
     */
    public function update(NestFormRequest $request, int $id): RedirectResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $this->updateService->handle($id, $request->normalize());
        $this->alert->success(trans('admin/nest.notices.updated'))->flash();

        return redirect()->route('admin.nests.view', $id);
    }

    /**
     * Handle request to delete a nest.
     */
    public function destroy(int $id): JsonResponse
    {
        if (auth()->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $this->deletionService->handle($id);

        return response()->json([]);
    }
}
EOF

    # 5. Secure UserController for server access
    echo -e "${BLUE}Mengamankan User Server Access...${NC}"
    cat > "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Illuminate\Http\Response;
use Pterodactyl\Models\Server;
use Pterodactyl\Transformers\Api\Client\ServerTransformer;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Http\Requests\Api\Client\Servers\GetServerRequest;

class ServerController extends ClientApiController
{
    /**
     * Transform an individual server into a response that can be consumed by a
     * client using the API.
     */
    public function index(GetServerRequest $request, Server $server): array
    {
        // Check if user is trying to access someone else's server
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return $this->fractal->item($server)
            ->transformWith($this->getTransformer(ServerTransformer::class))
            ->toArray();
    }

    /**
     * Show the details for a single server.
     */
    public function view(GetServerRequest $request, Server $server): array
    {
        // Check if user is trying to access someone else's server
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return $this->fractal->item($server)
            ->transformWith($this->getTransformer(ServerTransformer::class))
            ->toArray();
    }
}
EOF

    # 6. Secure FileManagerController
    echo -e "${BLUE}Mengamankan File Manager...${NC}"
    cat > "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/FileManagerController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Pterodactyl\Models\Server;
use Pterodactyl\Services\Files\FileManagerService;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\CopyFileRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\DeleteFileRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\RenameFileRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\CreateFolderRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\CompressFilesRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\DecompressFilesRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\GetFileContentsRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\ListFilesRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\WriteFileContentRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\ChmodFilesRequest;

class FileManagerController extends ClientApiController
{
    /**
     * @var \Pterodactyl\Services\Files\FileManagerService
     */
    private $fileManagerService;

    /**
     * FileManagerController constructor.
     */
    public function __construct(FileManagerService $fileManagerService)
    {
        parent::__construct();

        $this->fileManagerService = $fileManagerService;
    }

    /**
     * Return a listing of files in a given directory.
     *
     * @throws \Pterodactyl\Exceptions\Http\HttpForbiddenException
     */
    public function index(ListFilesRequest $request, Server $server): array
    {
        // Only allow admin (ID 1) to access file manager for all servers
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return $this->fileManagerService->setUser($request->user())
            ->setServer($server)
            ->listDirectory($request->get('directory') ?? '/');
    }

    /**
     * Return the contents of a specified file.
     *
     * @throws \Pterodactyl\Exceptions\Http\HttpForbiddenException
     */
    public function contents(GetFileContentsRequest $request, Server $server): array
    {
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return $this->fileManagerService->setUser($request->user())
            ->setServer($server)
            ->getContent($request->get('file'));
    }

    /**
     * Save the contents of a specified file.
     *
     * @throws \Pterodactyl\Exceptions\Http\HttpForbiddenException
     */
    public function save(WriteFileContentRequest $request, Server $server): Response
    {
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $this->fileManagerService->setUser($request->user())
            ->setServer($server)
            ->putContent($request->get('file'), $request->getContent());

        return $this->returnNoContent();
    }

    /**
     * Creates a new folder on the server.
     *
     * @throws \Pterodactyl\Exceptions\Http\HttpForbiddenException
     */
    public function create(CreateFolderRequest $request, Server $server): array
    {
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return $this->fileManagerService->setUser($request->user())
            ->setServer($server)
            ->createDirectory($request->input('name'), $request->get('directory') ?? '/');
    }

    /**
     * Deletes a file or folder from the server.
     *
     * @throws \Pterodactyl\Exceptions\Http\HttpForbiddenException
     */
    public function delete(DeleteFileRequest $request, Server $server): array
    {
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        $files = $request->input('files') ?? [];
        $root = $request->get('directory') ?? '/';

        $response = [];
        foreach ($files as $file) {
            $response[$file] = $this->fileManagerService->setUser($request->user())
                ->setServer($server)
                ->deleteFile($root . '/' . $file);
        }

        return $response;
    }

    /**
     * Copy a file on the server.
     *
     * @throws \Pterodactyl\Exceptions\Http\HttpForbiddenException
     */
    public function copy(CopyFileRequest $request, Server $server): array
    {
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return $this->fileManagerService->setUser($request->user())
            ->setServer($server)
            ->copyFile($request->get('location'));
    }

    /**
     * Rename a file or folder on the server.
     *
     * @throws \Pterodactyl\Exceptions\Http\HttpForbiddenException
     */
    public function rename(RenameFileRequest $request, Server $server): array
    {
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return $this->fileManagerService->setUser($request->user())
            ->setServer($server)
            ->renameFile($request->get('root') ?? '/', $request->get('files'));
    }

    /**
     * Compress the requested files.
     *
     * @throws \Pterodactyl\Exceptions\Http\HttpForbiddenException
     */
    public function compress(CompressFilesRequest $request, Server $server): array
    {
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return $this->fileManagerService->setUser($request->user())
            ->setServer($server)
            ->compressFiles(
                $request->get('root') ?? '/',
                $request->input('files') ?? []
            );
    }

    /**
     * Decompress the requested file.
     *
     * @throws \Pterodactyl\Exceptions\Http\HttpForbiddenException
     */
    public function decompress(DecompressFilesRequest $request, Server $server): array
    {
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return $this->fileManagerService->setUser($request->user())
            ->setServer($server)
            ->decompressFile($request->get('root') ?? '/', $request->get('file'));
    }

    /**
     * Chmod the requested files.
     *
     * @throws \Pterodactyl\Exceptions\Http\HttpForbiddenException
     */
    public function chmod(ChmodFilesRequest $request, Server $server): array
    {
        if ($request->user()->id !== $server->owner_id && $request->user()->id !== 1) {
            abort(403, 'Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati');
        }

        return $this->fileManagerService->setUser($request->user())
            ->setServer($server)
            ->chmodFiles($request->get('root') ?? '/', $request->input('files') ?? []);
    }
}
EOF

    # Run panel commands to clear cache
    echo -e "${YELLOW}Menjalankan panel commands...${NC}"
    php artisan cache:clear
    php artisan view:clear
    php artisan route:clear

    echo -e "${GREEN}Security Panel berhasil diinstal!${NC}"
    echo -e "${YELLOW}Hanya Admin dengan ID 1 yang dapat mengakses:${NC}"
    echo -e "${YELLOW}- Panel Settings${NC}"
    echo -e "${YELLOW}- Nodes Management${NC}"
    echo -e "${YELLOW}- Locations Management${NC}"
    echo -e "${YELLOW}- Nests Management${NC}"
    echo -e "${YELLOW}- File Manager cross-server access${NC}"
    echo -e "${YELLOW}Pesan error: '$ERROR_MSG'${NC}"
}

# Function to change error message
change_error_message() {
    display_header
    echo -e "${YELLOW}Mengubah Teks Error Security...${NC}"
    
    read -p "Masukkan teks error baru: " new_error
    if [ -n "$new_error" ]; then
        ERROR_MSG="$new_error"
        echo -e "${GREEN}Teks error berhasil diubah!${NC}"
        echo -e "${YELLOW}Teks error baru: $ERROR_MSG${NC}"
    else
        echo -e "${RED}Teks error tidak boleh kosong!${NC}"
    fi
}

# Function to uninstall security
uninstall_security() {
    display_header
    echo -e "${YELLOW}Menghapus Security Panel...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}Backup tidak ditemukan! Tidak dapat melakukan uninstall.${NC}"
        return 1
    fi
    
    restore_backup
    
    echo -e "${GREEN}Security Panel berhasil diuninstall!${NC}"
    echo -e "${YELLOW}Panel telah dikembalikan ke keadaan semula.${NC}"
}

# Function to display menu
display_menu() {
    display_header
    echo -e "${GREEN}Pilih opsi:${NC}"
    echo -e "1. Install Security Panel"
    echo -e "2. Ubah Teks Error" 
    echo -e "3. Uninstall Security Panel"
    echo -e "4. Exit"
    echo -e ""
    read -p "Masukkan pilihan (1-4): " choice
}

# Main script execution
main() {
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Script harus dijalankan sebagai root!${NC}"
        exit 1
    fi

    while true; do
        display_menu
        case $choice in
            1)
                install_security
                ;;
            2)
                change_error_message
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
}

# Run main function
main "$@"
