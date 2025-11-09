#!/bin/bash

echo "🗑️ Menghapus proteksi Security Panel Admin Nodes View..."

# File utama
REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesViewController.php"
BACKUP_PATTERN="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesViewController.php.bak_*"

# View templates patterns
VIEW_PATTERNS=(
    "/var/www/pterodactyl/resources/views/admin/nodes/index.blade.php.bak_*"
    "/var/www/pterodactyl/resources/views/admin/nodes/view.blade.php.bak_*"
    "/var/www/pterodactyl/resources/views/admin/nodes/settings.blade.php.bak_*"
    "/var/www/pterodactyl/resources/views/admin/nodes/configuration.blade.php.bak_*"
    "/var/www/pterodactyl/resources/views/admin/nodes/allocation.blade.php.bak_*"
    "/var/www/pterodactyl/resources/views/admin/nodes/servers.blade.php.bak_*"
    "/var/www/pterodactyl/resources/views/admin/nodes/about.blade.php.bak_*"
)

# Routes backup
ROUTES_PATTERN="/var/www/pterodactyl/routes/web.php.bak_*"

# ==================== RESTORE FILE UTAMA ====================
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ Backup utama dikembalikan: $LATEST_BACKUP"
else
    echo "⚠️ Tidak ada backup utama ditemukan, membuat file default..."
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

    public function allocation(Request $request, Node $node)
    {
        return view('admin.nodes.allocation', [
            'node' => $node,
        ]);
    }

    public function configuration(Request $request, Node $node)
    {
        return view('admin.nodes.configuration', [
            'node' => $node,
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

# ==================== RESTORE VIEW TEMPLATES ====================
for PATTERN in "${VIEW_PATTERNS[@]}"; do
    for BACKUP_FILE in $PATTERN; do
        if [ -f "$BACKUP_FILE" ]; then
            ORIGINAL_FILE="${BACKUP_FILE%.bak_*}"
            mv "$BACKUP_FILE" "$ORIGINAL_FILE"
            echo "✅ View template dikembalikan: $(basename $BACKUP_FILE)"
        fi
    done
done

# ==================== RESTORE ROUTES ====================
LATEST_ROUTES_BACKUP=$(ls -t $ROUTES_PATTERN 2>/dev/null | head -n1)
if [ -n "$LATEST_ROUTES_BACKUP" ]; then
    mv "$LATEST_ROUTES_BACKUP" "/var/www/pterodactyl/routes/web.php"
    echo "✅ Routes web dikembalikan: $LATEST_ROUTES_BACKUP"
fi

# ==================== CLEANUP VIEW TEMPLATES ====================
VIEW_PATHS=(
    "/var/www/pterodactyl/resources/views/admin/nodes/index.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/view.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/settings.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/configuration.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/allocation.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/servers.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/about.blade.php"
)

for VIEW_PATH in "${VIEW_PATHS[@]}"; do
    if [ -f "$VIEW_PATH" ]; then
        # Hapus security code dari awal file
        sed -i '/@if(auth()->check() && auth()->user()->id !== 1)/,/@endif/d' "$VIEW_PATH"
        sed -i '/Akses ditolak, hanya admin id 1 yang bisa melihat/d' "$VIEW_PATH"
        sed -i '/protect by @andinofficial/d' "$VIEW_PATH"
        echo "✅ Security code dihapus dari: $(basename $VIEW_PATH)"
    fi
done

# ==================== CLEAR CACHE ====================
cd /var/www/pterodactyl
php artisan cache:clear
php artisan view:clear
php artisan config:clear
php artisan route:clear

echo ""
echo "✅ ==========================================="
echo "✅ PROTEKSI BERHASIL DIHAPUS!"
echo "✅ ==========================================="
echo "🔓 Semua admin sekarang bisa mengakses nodes"
echo "🗑️ Semua file backup telah dikembalikan"
echo "🔄 Cache telah dibersihkan"
echo ""
echo "📋 STATUS:"
echo "   • Controller: ✅ Dikembalikan"
echo "   • View Templates: ✅ Dikembalikan" 
echo "   • Routes: ✅ Dikembalikan"
echo "   • Security Code: ✅ Dihapus"
echo ""
echo "🎯 Sistem kembali ke mode akses normal"
