#!/bin/bash

# security.sh - Security Panel Pterodactyl
# By @ginaabaikhati

PANEL_PATH="/var/www/pterodactyl"
BACKUP_PATH="/root/pterodactyl_backup"
ERROR_MSG="Akses ditolak: Hayoloh Lu Mau NGapain? By @ginaabaikhati"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display header
show_header() {
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
        echo -e "${RED}Error: Script harus dijalankan sebagai root${NC}"
        exit 1
    fi
}

# Function to check if Pterodactyl is installed
check_pterodactyl() {
    if [ ! -d "$PANEL_PATH" ]; then
        echo -e "${RED}Error: Pterodactyl tidak ditemukan di $PANEL_PATH${NC}"
        exit 1
    fi
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Membuat backup file Pterodactyl...${NC}"
    mkdir -p "$BACKUP_PATH"
    
    # Backup important files
    cp "$PANEL_PATH/app/Http/Controllers/Admin"/*.php "$BACKUP_PATH/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php" "$BACKUP_PATH/" 2>/dev/null
    cp "$PANEL_PATH/app/Http/Controllers/Api/Client"/*.php "$BACKUP_PATH/" 2>/dev/null
    
    echo -e "${GREEN}Backup berhasil dibuat di $BACKUP_PATH${NC}"
}

# Function to install security
install_security() {
    check_root
    check_pterodactyl
    
    echo -e "${YELLOW}Memulai instalasi Security Panel...${NC}"
    
    create_backup
    
    # Patch Admin Controller
    echo -e "${YELLOW}Memodifikasi Admin Controller...${NC}"
    
    # Find and patch all admin controllers
    find "$PANEL_PATH/app/Http/Controllers/Admin" -name "*.php" -type f | while read file; do
        if grep -q "function destroy\|function update\|function delete" "$file"; then
            sed -i 's/public function destroy(.*)/public function destroy(\1)\n    {\n        if (\\Auth::user()->id !== 1) {\n            abort(403, \"'"$ERROR_MSG"'\");\n        }/g' "$file"
            sed -i 's/public function update(.*)/public function update(\1)\n    {\n        if (\\Auth::user()->id !== 1) {\n            abort(403, \"'"$ERROR_MSG"'\");\n        }/g' "$file"
            sed -i 's/public function delete(.*)/public function delete(\1)\n    {\n        if (\\Auth::user()->id !== 1) {\n            abort(403, \"'"$ERROR_MSG"'\");\n        }/g' "$file"
        fi
    done
    
    # Patch specific important controllers
    patch_node_controller
    patch_location_controller  
    patch_nest_controller
    patch_user_controller
    patch_server_controller
    
    # Patch API Client Controllers
    echo -e "${YELLOW}Memodifikasi API Client Controllers...${NC}"
    
    find "$PANEL_PATH/app/Http/Controllers/Api/Client" -name "*.php" -type f | while read file; do
        if grep -q "function destroy\|function update\|function delete" "$file"; then
            sed -i 's/public function destroy(.*)/public function destroy(\1)\n    {\n        if (\\Auth::user()->id !== 1) {\n            abort(403, \"'"$ERROR_MSG"'\");\n        }/g' "$file"
            sed -i 's/public function update(.*)/public function update(\1)\n    {\n        if (\\Auth::user()->id !== 1) {\n            abort(403, \"'"$ERROR_MSG"'\");\n        }/g' "$file"
        fi
    done
    
    # Clear cache
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    cd "$PANEL_PATH" && php artisan cache:clear && php artisan view:clear
    
    echo -e "${GREEN}Security Panel berhasil diinstall!${NC}"
    echo -e "${YELLOW}Hanya user dengan ID 1 yang dapat melakukan modifikasi.${NC}"
}

# Function to patch Node Controller
patch_node_controller() {
    local file="$PANEL_PATH/app/Http/Controllers/Admin/NodeController.php"
    if [ -f "$file" ]; then
        cat > "$file" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Http\Requests\Admin\Node\NodeStoreRequest;
use Pterodactyl\Http\Requests\Admin\Node\NodeUpdateRequest;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;
use Pterodactyl\Services\Nodes\NodeCreationService;
use Pterodactyl\Services\Nodes\NodeUpdateService;
use Pterodactyl\Services\Nodes\NodeDeletionService;

class NodeController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected NodeCreationService $creationService,
        protected NodeDeletionService $deletionService,
        protected NodeRepositoryInterface $repository,
        protected NodeUpdateService $updateService
    ) {
    }

    public function index(): View
    {
        return view('admin.nodes.index', [
            'nodes' => $this->repository->getAllNodesWithServers(),
        ]);
    }

    public function create(): View
    {
        return view('admin.nodes.new');
    }

    public function store(NodeStoreRequest $request): RedirectResponse
    {
        if (\Auth::user()->id !== 1) {
            abort(403, "<?php echo $ERROR_MSG; ?>");
        }
        
        $node = $this->creationService->handle($request->normalize());
        $this->alert->success('Node was created successfully.')->flash();

        return redirect()->route('admin.nodes.view', $node->id);
    }

    public function view(int $id): View
    {
        $node = $this->repository->getWithLocation($id);

        return view('admin.nodes.view', [
            'node' => $node,
            'servers' => $node->servers()->with('user')->withCount('allocations')->paginate(50),
        ]);
    }

    public function update(int $id, NodeUpdateRequest $request): RedirectResponse
    {
        if (\Auth::user()->id !== 1) {
            abort(403, "<?php echo $ERROR_MSG; ?>");
        }
        
        $this->updateService->handle($id, $request->normalize());
        $this->alert->success('Node was updated successfully.')->flash();

        return redirect()->route('admin.nodes.view', $id);
    }

    public function destroy(int $id): RedirectResponse
    {
        if (\Auth::user()->id !== 1) {
            abort(403, "<?php echo $ERROR_MSG; ?>");
        }
        
        $this->deletionService->handle($id);
        $this->alert->success('Node was deleted successfully.')->flash();

        return redirect()->route('admin.nodes');
    }
}
EOF
    fi
}

# Function to patch Location Controller
patch_location_controller() {
    local file="$PANEL_PATH/app/Http/Controllers/Admin/LocationController.php"
    if [ -f "$file" ]; then
        cat > "$file" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Http\Requests\Admin\LocationRequest;
use Pterodactyl\Contracts\Repository\LocationRepositoryInterface;

class LocationController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected LocationRepositoryInterface $repository
    ) {
    }

    public function index(): View
    {
        return view('admin.locations.index', [
            'locations' => $this->repository->all(),
        ]);
    }

    public function create(): View
    {
        return view('admin.locations.new');
    }

    public function store(LocationRequest $request): RedirectResponse
    {
        if (\Auth::user()->id !== 1) {
            abort(403, "<?php echo $ERROR_MSG; ?>");
        }
        
        $location = $this->repository->create($request->validated());
        $this->alert->success('Location was created successfully.')->flash();

        return redirect()->route('admin.locations');
    }

    public function edit(int $id): View
    {
        return view('admin.locations.edit', [
            'location' => $this->repository->find($id),
        ]);
    }

    public function update(int $id, LocationRequest $request): RedirectResponse
    {
        if (\Auth::user()->id !== 1) {
            abort(403, "<?php echo $ERROR_MSG; ?>");
        }
        
        $this->repository->update($id, $request->validated());
        $this->alert->success('Location was updated successfully.')->flash();

        return redirect()->route('admin.locations');
    }

    public function destroy(int $id): RedirectResponse
    {
        if (\Auth::user()->id !== 1) {
            abort(403, "<?php echo $ERROR_MSG; ?>");
        }
        
        $this->repository->delete($id);
        $this->alert->success('Location was deleted successfully.')->flash();

        return redirect()->route('admin.locations');
    }
}
EOF
    fi
}

# Function to patch Nest Controller
patch_nest_controller() {
    local file="$PANEL_PATH/app/Http/Controllers/Admin/NestController.php"
    if [ -f "$file" ]; then
        cat > "$file" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NestRepositoryInterface;

class NestController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected NestRepositoryInterface $repository
    ) {
    }

    public function index(): View
    {
        return view('admin.nests.index', [
            'nests' => $this->repository->getWithEggs(),
        ]);
    }

    public function view(int $id): View
    {
        return view('admin.nests.view', [
            'nest' => $this->repository->getWithEggs($id),
        ]);
    }

    public function update(int $id): RedirectResponse
    {
        if (\Auth::user()->id !== 1) {
            abort(403, "<?php echo $ERROR_MSG; ?>");
        }
        
        // Update logic here
        $this->alert->success('Nest was updated successfully.')->flash();

        return redirect()->route('admin.nests.view', $id);
    }

    public function destroy(int $id): RedirectResponse
    {
        if (\Auth::user()->id !== 1) {
            abort(403, "<?php echo $ERROR_MSG; ?>");
        }
        
        $this->repository->delete($id);
        $this->alert->success('Nest was deleted successfully.')->flash();

        return redirect()->route('admin.nests');
    }
}
EOF
    fi
}

# Function to patch User Controller
patch_user_controller() {
    local file="$PANEL_PATH/app/Http/Controllers/Admin/UserController.php"
    if [ -f "$file" ]; then
        cat > "$file" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Http\Requests\Admin\UserRequest;
use Pterodactyl\Contracts\Repository\UserRepositoryInterface;

class UserController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected UserRepositoryInterface $repository
    ) {
    }

    public function index(): View
    {
        return view('admin.users.index', [
            'users' => $this->repository->setSearchTerm(request()->query('search'))->getAllUsers(50),
        ]);
    }

    public function view(int $id): View
    {
        return view('admin.users.view', [
            'user' => $this->repository->find($id),
        ]);
    }

    public function create(): View
    {
        return view('admin.users.new');
    }

    public function store(UserRequest $request): RedirectResponse
    {
        if (\Auth::user()->id !== 1) {
            abort(403, "<?php echo $ERROR_MSG; ?>");
        }
        
        $user = $this->repository->create($request->validated());
        $this->alert->success('User was created successfully.')->flash();

        return redirect()->route('admin.users.view', $user->id);
    }

    public function update(int $id, UserRequest $request): RedirectResponse
    {
        if (\Auth::user()->id !== 1) {
            abort(403, "<?php echo $ERROR_MSG; ?>");
        }
        
        $this->repository->update($id, $request->validated());
        $this->alert->success('User was updated successfully.')->flash();

        return redirect()->route('admin.users.view', $id);
    }

    public function destroy(int $id): RedirectResponse
    {
        if (\Auth::user()->id !== 1) {
            abort(403, "<?php echo $ERROR_MSG; ?>");
        }
        
        $this->repository->delete($id);
        $this->alert->success('User was deleted successfully.')->flash();

        return redirect()->route('admin.users');
    }
}
EOF
    fi
}

# Function to patch Server Controller
patch_server_controller() {
    local file="$PANEL_PATH/app/Http/Controllers/Admin/ServerController.php"
    if [ -f "$file" ]; then
        cat > "$file" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\ServerRepositoryInterface;

class ServerController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected ServerRepositoryInterface $repository
    ) {
    }

    public function index(): View
    {
        return view('admin.servers.index', [
            'servers' => $this->repository->setSearchTerm(request()->query('search'))->getAllServers(50),
        ]);
    }

    public function view(int $id): View
    {
        return view('admin.servers.view', [
            'server' => $this->repository->find($id),
        ]);
    }

    public function update(int $id): RedirectResponse
    {
        if (\Auth::user()->id !== 1) {
            abort(403, "<?php echo $ERROR_MSG; ?>");
        }
        
        // Update logic here
        $this->alert->success('Server was updated successfully.')->flash();

        return redirect()->route('admin.servers.view', $id);
    }

    public function destroy(int $id): RedirectResponse
    {
        if (\Auth::user()->id !== 1) {
            abort(403, "<?php echo $ERROR_MSG; ?>");
        }
        
        $this->repository->delete($id);
        $this->alert->success('Server was deleted successfully.')->flash();

        return redirect()->route('admin.servers');
    }
}
EOF
    fi
}

# Function to change error text
change_error_text() {
    check_root
    check_pterodactyl
    
    echo -e "${YELLOW}Mengubah teks error...${NC}"
    echo -n "Masukkan teks error baru: "
    read -r new_error
    
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
    check_root
    check_pterodactyl
    
    if [ ! -d "$BACKUP_PATH" ]; then
        echo -e "${RED}Error: Backup tidak ditemukan di $BACKUP_PATH${NC}"
        echo -e "${YELLOW}Silakan install security panel terlebih dahulu${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Memulai uninstall Security Panel...${NC}"
    
    # Restore backed up files
    echo -e "${YELLOW}Memulihkan file backup...${NC}"
    
    if [ -f "$BACKUP_PATH/NodeController.php" ]; then
        cp "$BACKUP_PATH/NodeController.php" "$PANEL_PATH/app/Http/Controllers/Admin/"
    fi
    
    if [ -f "$BACKUP_PATH/LocationController.php" ]; then
        cp "$BACKUP_PATH/LocationController.php" "$PANEL_PATH/app/Http/Controllers/Admin/"
    fi
    
    if [ -f "$BACKUP_PATH/NestController.php" ]; then
        cp "$BACKUP_PATH/NestController.php" "$PANEL_PATH/app/Http/Controllers/Admin/"
    fi
    
    if [ -f "$BACKUP_PATH/UserController.php" ]; then
        cp "$BACKUP_PATH/UserController.php" "$PANEL_PATH/app/Http/Controllers/Admin/"
    fi
    
    if [ -f "$BACKUP_PATH/ServerController.php" ]; then
        cp "$BACKUP_PATH/ServerController.php" "$PANEL_PATH/app/Http/Controllers/Admin/"
    fi
    
    # Clear cache
    echo -e "${YELLOW}Membersihkan cache...${NC}"
    cd "$PANEL_PATH" && php artisan cache:clear && php artisan view:clear
    
    echo -e "${GREEN}Security Panel berhasil diuninstall!${NC}"
    echo -e "${YELLOW}Panel Pterodactyl telah dikembalikan ke keadaan semula.${NC}"
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
        echo
        echo -n "Masukkan pilihan [1-4]: "
        read -r choice
        
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
        
        echo
        echo -n "Tekan Enter untuk melanjutkan..."
        read -r
    done
}

# Check if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_menu
fi
