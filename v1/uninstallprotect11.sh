#!/bin/bash

echo "🗑️ Menghapus proteksi Specific Routes Admin Nodes View..."

# File utama
REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesViewController.php"
BACKUP_PATTERN="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesViewController.php.bak_*"

# View templates patterns
VIEW_PATTERNS=(
    "/var/www/pterodactyl/resources/views/admin/nodes/settings.blade.php.bak_*"
    "/var/www/pterodactyl/resources/views/admin/nodes/configuration.blade.php.bak_*"
    "/var/www/pterodactyl/resources/views/admin/nodes/allocations.blade.php.bak_*"
    "/var/www/pterodactyl/resources/views/admin/nodes/servers.blade.php.bak_*"
)

# API routes backup
API_BACKUP_PATTERN="/var/www/pterodactyl/routes/api.php.bak_*"

# Restore file controller utama
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ Backup controller utama dikembalikan: $LATEST_BACKUP"
else
    echo "⚠️ Tidak ada backup controller utama ditemukan"
    echo "📝 Membuat controller default..."
    
    cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Models\Node;
use Pterodactyl\Models\User;
use Illuminate\Http\JsonResponse;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Wings\DaemonServerRepository;
use Pterodactyl\Services\Nodes\NodeUpdateService;
use Pterodactyl\Services\Nodes\NodeCreationService;
use Pterodactyl\Services\Nodes\NodeDeletionService;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\Node\NodeFormRequest;
use Pterodactyl\Http\Requests\Admin\Node\AllocationFormRequest;

class NodesViewController extends Controller
{
    public function __construct(
        protected NodeRepositoryInterface $repository,
        protected NodeCreationService $creationService,
        protected NodeUpdateService $updateService,
        protected NodeDeletionService $deletionService,
        protected DaemonServerRepository $serverRepository
    ) {}

    public function index(Request $request)
    {
        $nodes = $this->repository->getAllNodesWithServers();

        return view('admin.nodes.index', [
            'nodes' => $nodes,
        ]);
    }

    public function view(Request $request, Node $node)
    {
        $allocations = $node->allocations()->with('server')->get();
        $servers = $node->servers;

        return view('admin.nodes.view', [
            'node' => $node,
            'allocations' => $allocations,
            'servers' => $servers,
        ]);
    }

    public function update(NodeFormRequest $request, Node $node)
    {
        $this->updateService->handle($node, $request->validated());

        return redirect()->route('admin.nodes.view', $node->id)
            ->with('success', 'Node berhasil diperbarui');
    }

    public function create()
    {
        return view('admin.nodes.create');
    }

    public function store(NodeFormRequest $request)
    {
        $node = $this->creationService->handle($request->validated());

        return redirect()->route('admin.nodes.view', $node->id)
            ->with('success', 'Node berhasil dibuat');
    }

    public function delete(Request $request, Node $node)
    {
        $this->deletionService->handle($node);

        return redirect()->route('admin.nodes')
            ->with('success', 'Node berhasil dihapus');
    }

    public function allocation(AllocationFormRequest $request, Node $node)
    {
        $this->updateService->handle($node, $request->validated());

        return redirect()->route('admin.nodes.view', $node->id)
            ->with('success', 'Alokasi berhasil diperbarui');
    }

    public function configuration(Request $request, Node $node)
    {
        return response()->json([
            'config' => $node->getConfiguration(),
        ]);
    }

    public function settings(Request $request, Node $node)
    {
        return view('admin.nodes.settings', [
            'node' => $node,
        ]);
    }

    public function servers(Request $request, Node $node)
    {
        $servers = $node->servers()->with('user')->get();

        return view('admin.nodes.servers', [
            'node' => $node,
            'servers' => $servers,
        ]);
    }

    public function about(Request $request, Node $node)
    {
        return view('admin.nodes.about', [
            'node' => $node,
        ]);
    }
}
?>
EOF
fi

# Restore view templates
for PATTERN in "${VIEW_PATTERNS[@]}"; do
    for BACKUP_FILE in $PATTERN; do
        if [ -f "$BACKUP_FILE" ]; then
            ORIGINAL_FILE="${BACKUP_FILE%.bak_*}"
            mv "$BACKUP_FILE" "$ORIGINAL_FILE"
            echo "✅ Backup view dikembalikan: $BACKUP_FILE"
        fi
    done
done

# Restore API routes
for BACKUP_FILE in $API_BACKUP_PATTERN; do
    if [ -f "$BACKUP_FILE" ]; then
        ORIGINAL_FILE="${BACKUP_FILE%.bak_*}"
        mv "$BACKUP_FILE" "$ORIGINAL_FILE"
        echo "✅ Backup API routes dikembalikan: $BACKUP_FILE"
    fi
done

# Clear cache
cd /var/www/pterodactyl
php artisan cache:clear
php artisan view:clear
php artisan config:clear
php artisan route:clear

echo "✅ Proteksi Specific Routes berhasil dihapus!"
echo "🔓 Semua route sekarang dapat diakses oleh semua admin"
echo "🔄 Cache dan routes telah dibersihkan"
echo "📋 Semua file telah dikembalikan ke versi original"
