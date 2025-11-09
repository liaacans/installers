#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesViewController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Total Admin Nodes View..."

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
     * 🔒 FUNGSI UTAMA: CEK AKSES NODE 1
     */
    private function checkNode1Access($node)
    {
        $user = request()->user();

        // Jika admin ID 1, izinkan akses
        if ($user->id === 1) {
            return true;
        }

        // Jika node ID 1, tolak akses untuk admin lain
        if ($node->id == 1) {
            $this->showSecurityPanel();
            return false;
        }

        return true;
    }

    /**
     * 🔒 TAMPILKAN SECURITY PANEL KEREN
     */
    private function showSecurityPanel()
    {
        http_response_code(403);
        
        echo '
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>🔒 Security Restriction - Pterodactyl</title>
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }
                
                body {
                    background: linear-gradient(135deg, #0c0c0c 0%, #1a1a2e 50%, #16213e 100%);
                    font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
                    min-height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: #ecf0f1;
                    overflow: hidden;
                }
                
                .security-container {
                    text-align: center;
                    padding: 40px;
                    max-width: 700px;
                    width: 95%;
                    position: relative;
                    z-index: 10;
                }
                
                .security-panel {
                    background: rgba(10, 12, 18, 0.95);
                    border: 4px solid;
                    border-image: linear-gradient(45deg, #ff0000, #ff6b6b, #ff0000) 1;
                    border-radius: 25px;
                    padding: 60px 50px;
                    box-shadow: 
                        0 0 80px rgba(255, 0, 0, 0.6),
                        inset 0 0 50px rgba(255, 0, 0, 0.1);
                    position: relative;
                    overflow: hidden;
                    backdrop-filter: blur(15px);
                }
                
                .security-panel::before {
                    content: "";
                    position: absolute;
                    top: -150%;
                    left: -150%;
                    width: 400%;
                    height: 400%;
                    background: linear-gradient(45deg, 
                        transparent 0%, 
                        rgba(255, 0, 0, 0.1) 25%, 
                        transparent 50%, 
                        rgba(255, 107, 107, 0.1) 75%, 
                        transparent 100%);
                    animation: matrix 8s linear infinite;
                    z-index: 1;
                }
                
                @keyframes matrix {
                    0% { transform: translateX(-50%) translateY(-50%) rotate(45deg); }
                    100% { transform: translateX(50%) translateY(50%) rotate(45deg); }
                }
                
                .security-icon {
                    font-size: 100px;
                    margin-bottom: 40px;
                    animation: float 3s ease-in-out infinite;
                    filter: drop-shadow(0 0 30px rgba(255, 0, 0, 0.8));
                    position: relative;
                    z-index: 2;
                }
                
                @keyframes float {
                    0%, 100% { transform: translateY(0px) rotate(0deg); }
                    50% { transform: translateY(-20px) rotate(5deg); }
                }
                
                .security-title {
                    font-size: 42px;
                    font-weight: 900;
                    margin-bottom: 25px;
                    background: linear-gradient(45deg, #ff0000, #ff6b6b, #ff0000);
                    -webkit-background-clip: text;
                    -webkit-text-fill-color: transparent;
                    background-clip: text;
                    text-shadow: 0 0 40px rgba(255, 0, 0, 0.7);
                    position: relative;
                    z-index: 2;
                    letter-spacing: 2px;
                }
                
                .security-subtitle {
                    font-size: 24px;
                    margin-bottom: 40px;
                    color: #ff6b6b;
                    position: relative;
                    z-index: 2;
                    animation: pulse-text 2s infinite;
                }
                
                @keyframes pulse-text {
                    0%, 100% { opacity: 1; }
                    50% { opacity: 0.7; }
                }
                
                .security-message {
                    font-size: 20px;
                    line-height: 1.8;
                    margin-bottom: 40px;
                    background: rgba(255, 255, 255, 0.05);
                    padding: 25px;
                    border-radius: 15px;
                    border: 1px solid rgba(255, 107, 107, 0.3);
                    position: relative;
                    z-index: 2;
                }
                
                .protection-badge {
                    background: linear-gradient(45deg, #ff0000, #8b0000);
                    border: 2px solid #ff6b6b;
                    border-radius: 50px;
                    padding: 15px 30px;
                    margin: 30px 0;
                    font-family: "Courier New", monospace;
                    font-size: 18px;
                    font-weight: bold;
                    color: #fff;
                    text-shadow: 0 0 10px rgba(255, 255, 255, 0.5);
                    box-shadow: 0 0 30px rgba(255, 0, 0, 0.5);
                    position: relative;
                    z-index: 2;
                    animation: glow-badge 2s ease-in-out infinite alternate;
                }
                
                @keyframes glow-badge {
                    0% { box-shadow: 0 0 20px rgba(255, 0, 0, 0.5); }
                    100% { box-shadow: 0 0 40px rgba(255, 0, 0, 0.8); }
                }
                
                .security-details {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 20px;
                    margin: 40px 0;
                    position: relative;
                    z-index: 2;
                }
                
                .detail-box {
                    background: rgba(255, 0, 0, 0.1);
                    border: 1px solid rgba(255, 107, 107, 0.3);
                    border-radius: 12px;
                    padding: 20px;
                    text-align: center;
                }
                
                .detail-label {
                    font-size: 14px;
                    color: #ff6b6b;
                    margin-bottom: 8px;
                }
                
                .detail-value {
                    font-size: 18px;
                    font-weight: bold;
                    color: #fff;
                }
                
                .scan-line {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 3px;
                    background: linear-gradient(90deg, 
                        transparent, 
                        #ff0000, 
                        #ff6b6b, 
                        #ff0000, 
                        transparent);
                    animation: scan 3s linear infinite;
                    z-index: 2;
                }
                
                @keyframes scan {
                    0% { top: 0%; }
                    100% { top: 100%; }
                }
                
                .hacker-text {
                    font-family: "Courier New", monospace;
                    color: #00ff00;
                    text-shadow: 0 0 10px #00ff00;
                    animation: hacker 0.1s infinite;
                }
                
                @keyframes hacker {
                    0% { opacity: 0.8; }
                    50% { opacity: 1; }
                    100% { opacity: 0.8; }
                }
                
                .floating-particles {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    z-index: 1;
                }
                
                .particle {
                    position: absolute;
                    background: rgba(255, 107, 107, 0.3);
                    border-radius: 50%;
                    animation: float-particle 10s infinite linear;
                }
                
                @keyframes float-particle {
                    0% { transform: translateY(100%) translateX(0); opacity: 0; }
                    50% { opacity: 1; }
                    100% { transform: translateY(-100%) translateX(100px); opacity: 0; }
                }
            </style>
        </head>
        <body>
            <div class="floating-particles" id="particles"></div>
            
            <div class="security-container">
                <div class="security-panel">
                    <div class="scan-line"></div>
                    
                    <div class="security-icon">🚫⚡</div>
                    <h1 class="security-title">SECURITY LOCKDOWN</h1>
                    <div class="security-subtitle">NAA OFFICIAL NODE PROTECTION</div>
                    
                    <div class="security-message">
                        <p>✖️ <strong>AKSES DITOLAK!</strong> Hanya Administrator Utama (ID 1) yang dapat mengakses Node NAA OFFICIAL.</p>
                        <p style="margin-top: 15px; font-size: 16px; color: #ff6b6b;">
                            Semua tab dan fitur pada node ini dilindungi oleh sistem keamanan tingkat tinggi.
                        </p>
                    </div>
                    
                    <div class="protection-badge">
                        🔒 PROTECT BY @andinofficial
                    </div>
                    
                    <div class="security-details">
                        <div class="detail-box">
                            <div class="detail-label">NODE ID</div>
                            <div class="detail-value">#1</div>
                        </div>
                        <div class="detail-box">
                            <div class="detail-label">STATUS</div>
                            <div class="detail-value" style="color: #ff6b6b;">LOCKED</div>
                        </div>
                        <div class="detail-box">
                            <div class="detail-label">ACCESS LEVEL</div>
                            <div class="detail-value">ADMIN ONLY</div>
                        </div>
                        <div class="detail-box">
                            <div class="detail-label">SECURITY</div>
                            <div class="detail-value" style="color: #00ff00;">ACTIVE</div>
                        </div>
                    </div>
                    
                    <div style="margin-top: 30px; opacity: 0.8; font-size: 14px;">
                        <p class="hacker-text">>> SYSTEM_SECURITY: ACTIVE | NODE_1: PROTECTED | UNAUTHORIZED_ACCESS: BLOCKED</p>
                    </div>
                </div>
            </div>

            <script>
                // Create floating particles
                document.addEventListener("DOMContentLoaded", function() {
                    const particlesContainer = document.getElementById("particles");
                    const particleCount = 15;
                    
                    for (let i = 0; i < particleCount; i++) {
                        const particle = document.createElement("div");
                        particle.className = "particle";
                        
                        // Random size and position
                        const size = Math.random() * 10 + 5;
                        const left = Math.random() * 100;
                        const delay = Math.random() * 10;
                        const duration = Math.random() * 10 + 10;
                        
                        particle.style.width = `${size}px`;
                        particle.style.height = `${size}px`;
                        particle.style.left = `${left}%`;
                        particle.style.animationDelay = `${delay}s`;
                        particle.style.animationDuration = `${duration}s`;
                        
                        particlesContainer.appendChild(particle);
                    }
                    
                    // Matrix effect text
                    const hackerText = document.querySelector(".hacker-text");
                    const originalText = hackerText.textContent;
                    let matrixInterval;
                    
                    function startMatrixEffect() {
                        let text = originalText;
                        let iterations = 0;
                        
                        matrixInterval = setInterval(() => {
                            hackerText.textContent = text
                                .split("")
                                .map((char, index) => {
                                    if (index < iterations) {
                                        return originalText[index];
                                    }
                                    return String.fromCharCode(33 + Math.random() * 94);
                                })
                                .join("");
                            
                            if (iterations >= originalText.length) {
                                clearInterval(matrixInterval);
                                setTimeout(startMatrixEffect, 2000);
                            }
                            
                            iterations += 1 / 3;
                        }, 50);
                    }
                    
                    startMatrixEffect();
                    
                    // Add click effect
                    document.querySelector(".security-panel").addEventListener("click", function() {
                        this.style.transform = "scale(0.98)";
                        setTimeout(() => {
                            this.style.transform = "scale(1)";
                        }, 150);
                    });
                });
            </script>
        </body>
        </html>';
        exit();
    }

    /**
     * ==============================================
     * 🔒 SEMUA METHOD DIPROTEKSI UNTUK NODE 1
     * ==============================================
     */

    public function index(Request $request)
    {
        $nodes = $this->repository->getAllNodesWithServers();
        return view('admin.nodes.index', ['nodes' => $nodes]);
    }

    public function view(Request $request, Node $node)
    {
        if (!$this->checkNode1Access($node)) {
            return;
        }

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
        if (!$this->checkNode1Access($node)) {
            return new JsonResponse(['error' => '✖️ akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'], 403);
        }

        $this->updateService->handle($node, $request->validated());
        return redirect()->route('admin.nodes.view', $node->id)
            ->with('success', 'Node berhasil diperbarui');
    }

    public function settings(Request $request, Node $node)
    {
        if (!$this->checkNode1Access($node)) {
            return;
        }

        return view('admin.nodes.settings', ['node' => $node]);
    }

    public function updateSettings(Request $request, Node $node)
    {
        if (!$this->checkNode1Access($node)) {
            return new JsonResponse(['error' => '✖️ akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'], 403);
        }

        $this->updateService->handle($node, $request->validated());
        return redirect()->route('admin.nodes.view.settings', $node->id)
            ->with('success', 'Settings berhasil diperbarui');
    }

    public function configuration(Request $request, Node $node)
    {
        if (!$this->checkNode1Access($node)) {
            return;
        }

        return response()->json(['config' => $node->getConfiguration()]);
    }

    public function updateConfiguration(Request $request, Node $node)
    {
        if (!$this->checkNode1Access($node)) {
            return new JsonResponse(['error' => '✖️ akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'], 403);
        }

        $this->updateService->handle($node, $request->validated());
        return redirect()->route('admin.nodes.view.configuration', $node->id)
            ->with('success', 'Configuration berhasil diperbarui');
    }

    public function allocation(Request $request, Node $node)
    {
        if (!$this->checkNode1Access($node)) {
            return;
        }

        $allocations = $node->allocations()->with('server')->get();
        return view('admin.nodes.allocations', [
            'node' => $node,
            'allocations' => $allocations,
        ]);
    }

    public function updateAllocation(AllocationFormRequest $request, Node $node)
    {
        if (!$this->checkNode1Access($node)) {
            return new JsonResponse(['error' => '✖️ akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'], 403);
        }

        $this->updateService->handle($node, $request->validated());
        return redirect()->route('admin.nodes.view.allocation', $node->id)
            ->with('success', 'Alokasi berhasil diperbarui');
    }

    public function servers(Request $request, Node $node)
    {
        if (!$this->checkNode1Access($node)) {
            return;
        }

        $servers = $node->servers()->with('user')->get();
        return view('admin.nodes.servers', [
            'node' => $node,
            'servers' => $servers,
        ]);
    }

    public function about(Request $request, Node $node)
    {
        if (!$this->checkNode1Access($node)) {
            return;
        }

        return view('admin.nodes.about', ['node' => $node]);
    }

    public function delete(Request $request, Node $node)
    {
        if (!$this->checkNode1Access($node)) {
            return new JsonResponse(['error' => '✖️ akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'], 403);
        }

        $this->deletionService->handle($node);
        return redirect()->route('admin.nodes')
            ->with('success', 'Node berhasil dihapus');
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
}
?>
EOF

# Proteksi SEMUA view templates untuk node 1
VIEW_PATHS=(
    "/var/www/pterodactyl/resources/views/admin/nodes/view.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/settings.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/configuration.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/allocations.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/servers.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/about.blade.php"
)

for VIEW_PATH in "${VIEW_PATHS[@]}"; do
    if [ -f "$VIEW_PATH" ]; then
        VIEW_BACKUP="${VIEW_PATH}.bak_${TIMESTAMP}"
        cp "$VIEW_PATH" "$VIEW_BACKUP"
        echo "📦 Backup view template: $VIEW_BACKUP"
        
        # Buat security template untuk semua view
        cat > "$VIEW_PATH" << 'VIEW_EOF'
@php
    // SECURITY CHECK UNTUK NODE 1
    $user = auth()->user();
    $node = isset($node) ? $node : null;
    
    if ($node && $node->id == 1 && $user->id !== 1) {
        http_response_code(403);
@endphp

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🔒 Security Lock - Pterodactyl</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: linear-gradient(135deg, #0c0c0c 0%, #1a1a2e 50%, #16213e 100%);
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ecf0f1;
        }
        .lock-container {
            text-align: center;
            padding: 40px;
            max-width: 600px;
            width: 90%;
        }
        .lock-panel {
            background: rgba(10, 12, 18, 0.95);
            border: 3px solid;
            border-image: linear-gradient(45deg, #ff0000, #ff6b6b) 1;
            border-radius: 20px;
            padding: 50px 40px;
            box-shadow: 0 0 60px rgba(255, 0, 0, 0.5);
            position: relative;
            overflow: hidden;
        }
        .lock-icon {
            font-size: 80px;
            margin-bottom: 30px;
            animation: bounce 2s infinite;
        }
        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }
        .lock-title {
            font-size: 36px;
            font-weight: 800;
            margin-bottom: 20px;
            background: linear-gradient(45deg, #ff0000, #ff6b6b);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .lock-message {
            font-size: 20px;
            line-height: 1.6;
            margin-bottom: 30px;
            padding: 20px;
            background: rgba(255, 0, 0, 0.1);
            border-radius: 10px;
            border: 1px solid rgba(255, 107, 107, 0.3);
        }
        .lock-badge {
            background: linear-gradient(45deg, #ff0000, #8b0000);
            border-radius: 50px;
            padding: 15px 30px;
            font-family: "Courier New", monospace;
            font-size: 16px;
            font-weight: bold;
            color: #fff;
            box-shadow: 0 0 30px rgba(255, 0, 0, 0.5);
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { box-shadow: 0 0 20px rgba(255, 0, 0, 0.5); }
            50% { box-shadow: 0 0 40px rgba(255, 0, 0, 0.8); }
        }
        .tab-info {
            margin-top: 30px;
            opacity: 0.8;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="lock-container">
        <div class="lock-panel">
            <div class="lock-icon">🔒</div>
            <h1 class="lock-title">TAB LOCKED</h1>
            <div class="lock-message">
                <p>✖️ akses ditolak, hanya admin id 1 yang bisa melihat!</p>
                <p style="margin-top: 10px; font-size: 16px; color: #ff6b6b;">
                    Tab <strong>{{ basename(request()->path()) }}</strong> pada Node NAA OFFICIAL dilindungi
                </p>
            </div>
            <div class="lock-badge">
                🔒 PROTECT BY @andinofficial
            </div>
            <div class="tab-info">
                <p>Node: <strong>NAA OFFICIAL (#1)</strong> • Access: <strong>RESTRICTED</strong></p>
            </div>
        </div>
    </div>
</body>
</html>

@php
    exit();
    endif
@endphp

{{-- Original Content --}}
VIEW_EOF

        # Append original content
        if [ -f "$VIEW_BACKUP" ]; then
            echo "{{-- Original content below --}}" >> "$VIEW_PATH"
            # Cari line dimana content asli mulai (setelah PHP tag pertama)
            awk '/@php/,/@endphp/ {next} {print}' "$VIEW_BACKUP" | tail -n +20 >> "$VIEW_PATH" 2>/dev/null || echo "<!-- Original content in backup: $VIEW_BACKUP -->" >> "$VIEW_PATH"
        fi
    fi
done

chmod 644 "$REMOTE_PATH"

# Clear cache
cd /var/www/pterodactyl
php artisan cache:clear
php artisan view:clear
php artisan config:clear
php artisan route:clear

echo "✅ Proteksi TOTAL Admin Nodes View berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo "🔒 SEMUA TAB di Node 1 diproteksi:"
echo "   • About"
echo "   • Settings" 
echo "   • Configuration"
echo "   • Allocation"
echo "   • Servers"
echo "🚫 Pesan Error: '✖️ akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'"
echo "👤 HANYA Admin ID 1 yang bisa akses Node NAA OFFICIAL"
echo "🔓 Node lain tetap bisa diakses semua admin"
echo "🎨 Security Panel Effect: Matrix Style + Animations"
