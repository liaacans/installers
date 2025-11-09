#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesViewController.php"
BACKUP_PATTERN="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesViewController.php.bak_*"

echo "🗑️ Menghapus proteksi Security Panel Admin Nodes View..."

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ Backup berhasil dikembalikan: $LATEST_BACKUP"
else
    echo "⚠️ Tidak ada backup ditemukan, membuat file baru..."
    
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
}
?>
EOF
fi

# Kembalikan view template
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view.blade.php"
VIEW_BACKUP_PATTERN="/var/www/pterodactyl/resources/views/admin/nodes/view.blade.php.bak_*"

LATEST_VIEW_BACKUP=$(ls -t $VIEW_BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_VIEW_BACKUP" ]; then
    mv "$LATEST_VIEW_BACKUP" "$VIEW_PATH"
    echo "✅ View template berhasil dikembalikan: $LATEST_VIEW_BACKUP"
else
    # Hapus security code dari view template jika ada
    if [ -f "$VIEW_PATH" ]; then
        sed -i '/@if(auth()->check() && auth()->user()->id !== 1 && \$node->id == 1)/d' "$VIEW_PATH"
        sed -i '/security-overlay/d' "$VIEW_PATH"
        sed -i '/security-panel-view/d' "$VIEW_PATH"
        sed -i '/SECURITY RESTRICTION/d' "$VIEW_PATH"
        sed -i '/Akses ditolak, protect by @naaofficiall/d' "$VIEW_PATH"
        echo "✅ Security code di view template telah dihapus"
    fi
fi

chmod 644 "$REMOTE_PATH"

# Clear cache
cd /var/www/pterodactyl
php artisan cache:clear
php artisan view:clear

echo "✅ Proteksi Security Panel berhasil dihapus!"
echo "🔓 Semua admin sekarang bisa mengakses semua nodes"
echo "🔄 Cache telah dibersihkan"
