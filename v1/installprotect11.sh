#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesViewController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Specific Routes Admin Nodes View..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

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

    /**
     * 🔒 Fungsi: Cek akses untuk route spesifik node 1
     */
    private function checkNode1Access($request)
    {
        $user = $request->user();
        $nodeId = $request->route('node');

        // Jika bukan node ID 1, izinkan akses
        if ($nodeId != 1) {
            return true;
        }

        // Jika admin ID 1, izinkan akses
        if ($user->id === 1) {
            return true;
        }

        // Untuk admin lain, tolak akses dengan style keren
        $this->showAccessDenied();
        return false;
    }

    /**
     * 🔒 Tampilkan pesan akses ditolak
     */
    private function showAccessDenied()
    {
        http_response_code(403);
        
        echo '
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Access Denied - Pterodactyl</title>
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }
                
                body {
                    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
                    font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
                    min-height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: #ecf0f1;
                }
                
                .denied-container {
                    text-align: center;
                    padding: 40px;
                    max-width: 600px;
                    width: 90%;
                }
                
                .denied-panel {
                    background: rgba(23, 25, 35, 0.95);
                    border: 3px solid #e74c3c;
                    border-radius: 20px;
                    padding: 50px 40px;
                    box-shadow: 
                        0 0 60px rgba(231, 76, 60, 0.4),
                        inset 0 0 30px rgba(231, 76, 60, 0.1);
                    position: relative;
                    overflow: hidden;
                    backdrop-filter: blur(10px);
                }
                
                .denied-icon {
                    font-size: 80px;
                    margin-bottom: 30px;
                    animation: shake 0.5s ease-in-out infinite alternate;
                    filter: drop-shadow(0 0 20px rgba(231, 76, 60, 0.6));
                }
                
                @keyframes shake {
                    0% { transform: translateX(-5px) rotate(-5deg); }
                    100% { transform: translateX(5px) rotate(5deg); }
                }
                
                .denied-title {
                    font-size: 36px;
                    font-weight: 800;
                    margin-bottom: 20px;
                    color: #e74c3c;
                    text-shadow: 0 0 30px rgba(231, 76, 60, 0.5);
                }
                
                .denied-message {
                    font-size: 20px;
                    line-height: 1.6;
                    margin-bottom: 30px;
                    opacity: 0.9;
                }
                
                .denied-protection {
                    background: rgba(0, 0, 0, 0.6);
                    border: 1px solid #34495e;
                    border-radius: 12px;
                    padding: 20px;
                    margin: 25px 0;
                    font-family: "Courier New", monospace;
                    font-size: 16px;
                    color: #e74c3c;
                    text-align: center;
                    box-shadow: inset 0 0 20px rgba(0, 0, 0, 0.5);
                }
                
                .glowing-text {
                    color: #e74c3c;
                    animation: glow 1.5s ease-in-out infinite alternate;
                    font-weight: bold;
                    font-size: 24px;
                }
                
                @keyframes glow {
                    from { 
                        text-shadow: 0 0 10px #e74c3c, 0 0 20px #e74c3c; 
                    }
                    to { 
                        text-shadow: 0 0 15px #ff7979, 0 0 30px #ff7979; 
                    }
                }
                
                .scan-line {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 2px;
                    background: linear-gradient(90deg, transparent, #e74c3c, transparent);
                    animation: scan 2s linear infinite;
                }
                
                @keyframes scan {
                    0% { top: 0%; }
                    100% { top: 100%; }
                }
                
                .pulse-effect {
                    animation: pulse 2s infinite;
                }
                
                @keyframes pulse {
                    0%, 100% { opacity: 1; }
                    50% { opacity: 0.7; }
                }
            </style>
        </head>
        <body>
            <div class="denied-container">
                <div class="denied-panel">
                    <div class="scan-line"></div>
                    <div class="denied-icon">🚫</div>
                    <h1 class="denied-title">ACCESS DENIED</h1>
                    
                    <div class="denied-message">
                        <p class="pulse-effect">✖️ akses ditolak, hanya admin id 1 yang bisa melihat!</p>
                    </div>
                    
                    <div class="denied-protection">
                        <div class="glowing-text">- protect by @andinofficial -</div>
                    </div>
                    
                    <div style="margin-top: 30px; opacity: 0.7;">
                        <p>Node ID: <strong>1</strong> • Restricted Area • Admin Only</p>
                    </div>
                </div>
            </div>
            
            <script>
                document.addEventListener("DOMContentLoaded", function() {
                    const messages = [
                        "✖️ akses ditolak, hanya admin id 1 yang bisa melihat!",
                        "🚫 Unauthorized Access Attempt",
                        "🔒 Restricted Area - Node 1"
                    ];
                    
                    let currentMessage = 0;
                    const messageElement = document.querySelector(".denied-message p");
                    
                    setInterval(() => {
                        messageElement.style.opacity = "0";
                        
                        setTimeout(() => {
                            messageElement.textContent = messages[currentMessage];
                            messageElement.style.opacity = "1";
                            currentMessage = (currentMessage + 1) % messages.length;
                        }, 500);
                    }, 3000);
                });
            </script>
        </body>
        </html>';
        exit();
    }

    /**
     * ==============================================
     * 🔒 ROUTE YANG DIPROTEKSI - HANYA NODE ID 1
     * ==============================================
     */

    public function settings(Request $request, Node $node)
    {
        if (!$this->checkNode1Access($request)) {
            return;
        }

        // Original settings logic
        return view('admin.nodes.settings', [
            'node' => $node,
        ]);
    }

    public function configuration(Request $request, Node $node)
    {
        if (!$this->checkNode1Access($request)) {
            return;
        }

        // Original configuration logic
        return response()->json([
            'config' => $node->getConfiguration(),
        ]);
    }

    public function allocation(Request $request, Node $node)
    {
        if (!$this->checkNode1Access($request)) {
            return;
        }

        // Original allocation logic
        $this->updateService->handle($node, $request->validated());

        return redirect()->route('admin.nodes.view', $node->id)
            ->with('success', 'Alokasi berhasil diperbarui');
    }

    public function servers(Request $request, Node $node)
    {
        if (!$this->checkNode1Access($request)) {
            return;
        }

        // Original servers logic
        $servers = $node->servers()->with('user')->get();

        return view('admin.nodes.servers', [
            'node' => $node,
            'servers' => $servers,
        ]);
    }

    /**
     * ==============================================
     * ✅ ROUTE YANG TIDAK DIPROTEKSI - SEMUA NODE
     * ==============================================
     */

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

    public function about(Request $request, Node $node)
    {
        // Original about logic
        return view('admin.nodes.about', [
            'node' => $node,
        ]);
    }
}
?>
EOF

# Proteksi view templates untuk route spesifik
VIEW_PATHS=(
    "/var/www/pterodactyl/resources/views/admin/nodes/settings.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/configuration.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/allocations.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/servers.blade.php"
)

for VIEW_PATH in "${VIEW_PATHS[@]}"; do
    if [ -f "$VIEW_PATH" ]; then
        VIEW_BACKUP="${VIEW_PATH}.bak_${TIMESTAMP}"
        cp "$VIEW_PATH" "$VIEW_BACKUP"
        echo "📦 Backup view template: $VIEW_BACKUP"
        
        # Ganti konten view dengan security panel
        cat > "$VIEW_PATH" << 'VIEW_EOF'
@php
    $user = auth()->user();
    $nodeId = isset($node) ? $node->id : request()->route('node');
    
    if ($nodeId == 1 && $user->id !== 1) {
        http_response_code(403);
@endphp

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied - Pterodactyl</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ecf0f1;
        }
        .security-container {
            text-align: center;
            padding: 40px;
            max-width: 600px;
            width: 90%;
        }
        .security-panel {
            background: rgba(23, 25, 35, 0.95);
            border: 3px solid #e74c3c;
            border-radius: 20px;
            padding: 50px 40px;
            box-shadow: 0 0 60px rgba(231, 76, 60, 0.4);
            position: relative;
            overflow: hidden;
        }
        .security-icon {
            font-size: 80px;
            margin-bottom: 30px;
            animation: shake 0.5s ease-in-out infinite alternate;
        }
        @keyframes shake {
            0% { transform: translateX(-5px) rotate(-5deg); }
            100% { transform: translateX(5px) rotate(5deg); }
        }
        .security-title {
            font-size: 36px;
            font-weight: 800;
            margin-bottom: 20px;
            color: #e74c3c;
        }
        .security-message {
            font-size: 20px;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        .protection-text {
            background: rgba(0, 0, 0, 0.6);
            border: 1px solid #34495e;
            border-radius: 12px;
            padding: 20px;
            margin: 25px 0;
            font-family: "Courier New", monospace;
            font-size: 16px;
            color: #e74c3c;
            animation: glow 1.5s ease-in-out infinite alternate;
        }
        @keyframes glow {
            from { text-shadow: 0 0 10px #e74c3c; }
            to { text-shadow: 0 0 20px #ff7979; }
        }
        .scan-line {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 2px;
            background: linear-gradient(90deg, transparent, #e74c3c, transparent);
            animation: scan 2s linear infinite;
        }
        @keyframes scan {
            0% { top: 0%; }
            100% { top: 100%; }
        }
    </style>
</head>
<body>
    <div class="security-container">
        <div class="security-panel">
            <div class="scan-line"></div>
            <div class="security-icon">🚫</div>
            <h1 class="security-title">ACCESS DENIED</h1>
            <div class="security-message">
                <p>✖️ akses ditolak, hanya admin id 1 yang bisa melihat!</p>
            </div>
            <div class="protection-text">
                - protect by @andinofficial -
            </div>
            <div style="margin-top: 30px; opacity: 0.7;">
                <p>Route: {{ request()->path() }} • Node ID: 1 • Admin Only</p>
            </div>
        </div>
    </div>
</body>
</html>

@php
    exit();
    endif
@endphp

{{-- Original View Content Below --}}
VIEW_EOF

        # Append original content jika perlu, tapi biasanya tidak perlu karena sudah diblokir
        echo "# Original content preserved in backup: $VIEW_BACKUP" >> "$VIEW_PATH"
    fi
done

chmod 644 "$REMOTE_PATH"

# Clear cache
cd /var/www/pterodactyl
php artisan cache:clear
php artisan view:clear
php artisan config:clear

echo "✅ Proteksi Specific Routes berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo "🔒 Route yang diproteksi:"
echo "   • admin/nodes/view/1/settings"
echo "   • admin/nodes/view/1/configuration" 
echo "   • admin/nodes/view/1/allocation"
echo "   • admin/nodes/view/1/servers"
echo "🚫 Pesan Error: '✖️ akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'"
echo "👤 Hanya Admin ID 1 yang bisa akses route di atas"
echo "🔓 Route lain tetap bisa diakses semua admin"
