#!/bin/bash

echo "🚀 Memasang proteksi Anti Akses Node Controller..."

# Backup timestamp
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

# Files yang perlu diproteksi
declare -A FILES=(
    ["NodeController"]="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php"
    ["NodeViewController"]="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeViewController.php"
    ["NodeSettingsController"]="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeSettingsController.php"
    ["NodeAllocationController"]="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeAllocationController.php"
)

# 1. Proteksi NodeController utama
if [ -f "${FILES[NodeController]}" ]; then
    BACKUP_PATH="${FILES[NodeController]}.bak_${TIMESTAMP}"
    cp "${FILES[NodeController]}" "$BACKUP_PATH"
    echo "📦 Backup NodeController: $BACKUP_PATH"
    
    # Buat file NodeController yang sudah diproteksi
    cat > "${FILES[NodeController]}" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\Node\NodeFormRequest;
use Pterodactyl\Models\Node;

class NodeController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected NodeRepositoryInterface $repository
    ) {
    }

    /**
     * 🔒 Fungsi tambahan: Cek akses admin untuk node.
     */
    private function checkAdminAccess()
    {
        $user = auth()->user();

        // Hanya admin ID 1 yang bisa akses penuh
        if ($user->id === 1) {
            return true;
        }

        // Admin lain ditolak dengan efek security
        abort(403, "𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅");
    }

    /**
     * Display node index page.
     */
    public function index(): View
    {
        $this->checkAdminAccess();
        
        return view('admin.nodes.index', [
            'nodes' => $this->repository->getAllWithDetails(),
        ]);
    }

    /**
     * Display node create page.
     */
    public function create(): View
    {
        $this->checkAdminAccess();
        
        return view('admin.nodes.view');
    }

    /**
     * Display node view page.
     */
    public function view(int $id, string $section = 'settings'): View
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->find($id);
        
        // Blur atau sembunyikan data sensitif untuk admin selain ID 1
        $user = auth()->user();
        if ($user->id !== 1) {
            // Data yang dibatasi untuk admin lain
            $limitedData = [
                'node' => $node,
                'isLimited' => true,
                'section' => $section,
            ];
            
            return view('admin.nodes.view-limited', $limitedData);
        }

        return view('admin.nodes.view', [
            'node' => $node,
            'section' => $section,
            'isLimited' => false,
        ]);
    }

    /**
     * Handle node creation.
     */
    public function store(NodeFormRequest $request): RedirectResponse
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->create($request->validated());

        $this->alert->success('Node was successfully created.')->flash();

        return redirect()->route('admin.nodes.view', $node->id);
    }

    /**
     * Handle node update.
     */
    public function update(NodeFormRequest $request, int $id): RedirectResponse
    {
        $this->checkAdminAccess();
        
        $this->repository->update($id, $request->validated());

        $this->alert->success('Node was successfully updated.')->flash();

        return redirect()->route('admin.nodes.view', $id)->withInput();
    }

    /**
     * Handle node deletion.
     */
    public function delete(int $id): RedirectResponse
    {
        $this->checkAdminAccess();
        
        $this->repository->delete($id);

        $this->alert->success('Node was successfully deleted.')->flash();

        return redirect()->route('admin.nodes');
    }

    /**
     * Get allocations for a specific node.
     */
    public function allocations(int $id): View
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->find($id);

        return view('admin.nodes.allocation', [
            'node' => $node,
            'allocations' => $node->allocations,
        ]);
    }

    /**
     * Get servers for a specific node.
     */
    public function servers(int $id): View
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->find($id);

        return view('admin.nodes.servers', [
            'node' => $node,
            'servers' => $node->servers,
        ]);
    }

    /**
     * Get configuration for a specific node.
     */
    public function configuration(int $id): View
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->find($id);

        return view('admin.nodes.configuration', [
            'node' => $node,
        ]);
    }
}
EOF
fi

# 2. Proteksi NodeViewController
if [ -f "${FILES[NodeViewController]}" ]; then
    BACKUP_PATH="${FILES[NodeViewController]}.bak_${TIMESTAMP}"
    cp "${FILES[NodeViewController]}" "$BACKUP_PATH"
    echo "📦 Backup NodeViewController: $BACKUP_PATH"
    
    # Ganti seluruh isi file dengan yang sudah diproteksi
    cat > "${FILES[NodeViewController]}" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\View\View;
use Pterodactyl\Models\Node;
use Pterodactyl\Http\Controllers\Controller;

class NodeViewController extends Controller
{
    /**
     * 🔒 Fungsi tambahan: Cek akses admin untuk node.
     */
    private function checkAdminAccess()
    {
        $user = auth()->user();

        // Hanya admin ID 1 yang bisa akses penuh
        if ($user->id === 1) {
            return true;
        }

        // Admin lain ditolak dengan efek security
        abort(403, "𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅");
    }

    /**
     * Render index page for a specific node.
     */
    public function index(Node $node): View
    {
        $this->checkAdminAccess();
        
        return view('admin.nodes.view', [
            'node' => $node,
        ]);
    }

    /**
     * Render settings page for a specific node.
     */
    public function settings(Node $node): View
    {
        $this->checkAdminAccess();
        
        return view('admin.nodes.settings', [
            'node' => $node,
        ]);
    }

    /**
     * Render configuration page for a specific node.
     */
    public function configuration(Node $node): View
    {
        $this->checkAdminAccess();
        
        return view('admin.nodes.configuration', [
            'node' => $node,
        ]);
    }

    /**
     * Render allocation management page for a specific node.
     */
    public function allocations(Node $node): View
    {
        $this->checkAdminAccess();
        
        return view('admin.nodes.allocation', [
            'node' => $node,
        ]);
    }

    /**
     * Render server listing for a specific node.
     */
    public function servers(Node $node): View
    {
        $this->checkAdminAccess();
        
        return view('admin.nodes.servers', [
            'node' => $node,
        ]);
    }
}
EOF
fi

# 3. Proteksi NodeSettingsController
if [ -f "${FILES[NodeSettingsController]}" ]; then
    BACKUP_PATH="${FILES[NodeSettingsController]}.bak_${TIMESTAMP}"
    cp "${FILES[NodeSettingsController]}" "$BACKUP_PATH"
    echo "📦 Backup NodeSettingsController: $BACKUP_PATH"
    
    # Ganti seluruh isi file
    cat > "${FILES[NodeSettingsController]}" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\Node\NodeFormRequest;
use Pterodactyl\Models\Node;

class NodeSettingsController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected NodeRepositoryInterface $repository
    ) {
    }

    /**
     * 🔒 Fungsi tambahan: Cek akses admin untuk node.
     */
    private function checkAdminAccess()
    {
        $user = auth()->user();

        // Hanya admin ID 1 yang bisa akses penuh
        if ($user->id === 1) {
            return true;
        }

        // Admin lain ditolak dengan efek security
        abort(403, "𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅");
    }

    /**
     * Update settings for a node.
     */
    public function settings(NodeFormRequest $request, Node $node): RedirectResponse
    {
        $this->checkAdminAccess();
        
        $this->repository->update($node->id, $request->validated());

        $this->alert->success('Node settings have been updated.')->flash();

        return redirect()->route('admin.nodes.view.settings', $node->id);
    }
}
EOF
fi

# 4. Proteksi NodeAllocationController
if [ -f "${FILES[NodeAllocationController]}" ]; then
    BACKUP_PATH="${FILES[NodeAllocationController]}.bak_${TIMESTAMP}"
    cp "${FILES[NodeAllocationController]}" "$BACKUP_PATH"
    echo "📦 Backup NodeAllocationController: $BACKUP_PATH"
    
    # Ganti seluruh isi file
    cat > "${FILES[NodeAllocationController]}" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Response;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;
use Pterodactyl\Models\Allocation;
use Pterodactyl\Models\Node;
use Pterodactyl\Services\Allocations\AssignmentService;
use Pterodactyl\Contracts\Repository\AllocationRepositoryInterface;

class NodeAllocationController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected AssignmentService $assignmentService,
        protected AllocationRepositoryInterface $repository,
        protected NodeRepositoryInterface $nodeRepository
    ) {
    }

    /**
     * 🔒 Fungsi tambahan: Cek akses admin untuk node.
     */
    private function checkAdminAccess()
    {
        $user = auth()->user();

        // Hanya admin ID 1 yang bisa akses penuh
        if ($user->id === 1) {
            return true;
        }

        // Admin lain ditolak dengan efek security
        abort(403, "𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅");
    }

    /**
     * Display allocation management page.
     */
    public function index(Node $node): Response
    {
        $this->checkAdminAccess();
        
        return response()->view('admin.nodes.allocation', [
            'node' => $node,
            'allocations' => $node->allocations,
        ]);
    }

    /**
     * Create new allocations for a node.
     */
    public function store(Node $node): RedirectResponse
    {
        $this->checkAdminAccess();
        
        // Your allocation creation logic here
        return redirect()->route('admin.nodes.view.allocations', $node->id);
    }

    /**
     * Delete an allocation from a node.
     */
    public function destroy(Node $node, Allocation $allocation): JsonResponse
    {
        $this->checkAdminAccess();
        
        // Your allocation deletion logic here
        return new JsonResponse([], Response::HTTP_NO_CONTENT);
    }
}
EOF
fi

# 5. Buat middleware khusus untuk proteksi tambahan
MIDDLEWARE_PATH="/var/www/pterodactyl/app/Http/Middleware/CheckNodeAccess.php"
mkdir -p "$(dirname "$MIDDLEWARE_PATH")"

cat > "$MIDDLEWARE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckNodeAccess
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next)
    {
        // Cek jika route terkait nodes
        if (str_contains($request->path(), 'admin/nodes')) {
            $user = $request->user();
            
            // Hanya admin ID 1 yang bisa akses
            if ($user && $user->id !== 1) {
                abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅');
            }
        }

        return $next($request);
    }
}
EOF

# 6. Update route middleware (tambahkan ke kernel) - CARA AMAN
KERNEL_PATH="/var/www/pterodactyl/app/Http/Kernel.php"
if grep -q "CheckNodeAccess" "$KERNEL_PATH"; then
    echo "✅ Middleware sudah ada di Kernel"
else
    # Backup kernel
    cp "$KERNEL_PATH" "$KERNEL_PATH.bak_$TIMESTAMP"
    
    # Tambahkan middleware dengan cara yang aman
    TEMP_KERNEL="/tmp/kernel_temp.php"
    awk '
    /protected \$routeMiddleware = \[/ {
        print $0
        found=1
        next
    }
    found && /\]/ && !added {
        print "        '\''node.access'\'' => \\Pterodactyl\\Http\\Middleware\\CheckNodeAccess::class,"
        added=1
        found=0
    }
    { print $0 }
    ' "$KERNEL_PATH" > "$TEMP_KERNEL"
    
    mv "$TEMP_KERNEL" "$KERNEL_PATH"
    echo "✅ Middleware berhasil ditambahkan ke Kernel"
fi

# 7. Buat view limited untuk semua halaman node
LIMITED_VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/limited.blade.php"
mkdir -p "$(dirname "$LIMITED_VIEW_PATH")"

cat > "$LIMITED_VIEW_PATH" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Access Denied - Pterodactyl</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .security-container {
            background: rgba(255, 0, 0, 0.1);
            border: 3px solid #ff0000;
            border-radius: 20px;
            padding: 40px;
            text-align: center;
            max-width: 600px;
            width: 90%;
            box-shadow: 0 0 50px rgba(255, 0, 0, 0.3);
            animation: pulse 2s infinite;
            backdrop-filter: blur(10px);
        }
        .security-icon {
            font-size: 80px;
            color: #ff0000;
            margin-bottom: 20px;
            animation: bounce 1s infinite;
        }
        .security-title {
            color: #fff;
            font-size: 32px;
            margin-bottom: 20px;
            text-shadow: 0 0 10px rgba(255, 0, 0, 0.5);
        }
        .security-message {
            color: #ff6b6b;
            font-size: 18px;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        .security-details {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
            border-left: 4px solid #ff0000;
        }
        .security-animation {
            font-size: 24px;
            margin: 20px 0;
            color: #fff;
        }
        .btn-back {
            background: linear-gradient(45deg, #ff0000, #cc0000);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 25px;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        .btn-back:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 0, 0, 0.4);
        }
        @keyframes pulse {
            0% { box-shadow: 0 0 20px rgba(255, 0, 0, 0.3); }
            50% { box-shadow: 0 0 40px rgba(255, 0, 0, 0.6); }
            100% { box-shadow: 0 0 20px rgba(255, 0, 0, 0.3); }
        }
        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }
        .blur-content {
            filter: blur(8px);
            pointer-events: none;
            user-select: none;
        }
    </style>
</head>
<body>
    <div class="security-container">
        <div class="security-icon">
            <i class="fas fa-shield-alt"></i>
        </div>
        <h1 class="security-title">🚫 SECURITY PROTECTION ACTIVATED</h1>
        <div class="security-message">
            <strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong>
        </div>
        <div class="security-details">
            <p>You do not have permission to access node management.</p>
            <p>Only Super Administrator (ID: 1) can modify node settings, configuration, allocations, and servers.</p>
        </div>
        <div class="security-animation">
            🛡️ ⚡ 🚫 🔐 🛡️
        </div>
        <a href="/admin" class="btn-back">
            <i class="fas fa-arrow-left"></i> Back to Admin Dashboard
        </a>
    </div>

    <script>
        // Blur semua konten yang mungkin terload
        document.addEventListener('DOMContentLoaded', function() {
            const allElements = document.querySelectorAll('*');
            allElements.forEach(el => {
                if (!el.closest('.security-container')) {
                    el.classList.add('blur-content');
                }
            });
        });
    </script>
</body>
</html>
EOF

# 8. Update routes untuk apply middleware - CARA YANG LEBIH AMAN
ROUTES_PATH="/var/www/pterodactyl/routes/admin.php"
if [ -f "$ROUTES_PATH" ]; then
    # Backup routes
    cp "$ROUTES_PATH" "$ROUTES_PATH.bak_$TIMESTAMP"
    
    # Gunakan method yang lebih aman untuk modifikasi routes
    if ! grep -q "node.access" "$ROUTES_PATH"; then
        # Cari bagian routes nodes dan tambahkan middleware
        sed -i '/Route::group(\[.*'\''prefix'\'' => '\''nodes'\''.*\], function () {/a\
    Route::group(['\''middleware'\'' => '\''node.access'\''], function () {' "$ROUTES_PATH"
        
        # Tutup group middleware sebelum akhir group nodes
        sed -i '/}); \/\/ End nodes prefix/ i\
    });' "$ROUTES_PATH"
    fi
fi

# Set permissions
chmod 644 "${FILES[@]}" 2>/dev/null
chmod 644 "$MIDDLEWARE_PATH"
chmod 644 "$LIMITED_VIEW_PATH"

# Clear cache
php /var/www/pterodactyl/artisan view:clear
php /var/www/pterodactyl/artisan cache:clear
php /var/www/pterodactyl/artisan route:clear

echo ""
echo "✅ Proteksi Anti Akses Node Controller berhasil dipasang!"
echo "🔒 File yang diproteksi:"
echo "   - NodeController"
echo "   - NodeViewController" 
echo "   - NodeSettingsController"
echo "   - NodeAllocationController"
echo "🛡️  Middleware tambahan: CheckNodeAccess"
echo "🎨 View security protection: limited.blade.php"
echo "🚫 Hanya Admin ID 1 yang bisa akses Nodes Settings, Configuration, Allocation, dan Servers"
echo "❌ Admin lain akan langsung mendapatkan error 403 dengan efek security!"
