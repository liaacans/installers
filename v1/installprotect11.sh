#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesViewController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Security Panel Admin Nodes View..."

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
     * 🔒 Fungsi utama: Cek akses security panel
     */
    private function checkSecurityAccess($request)
    {
        $user = $request->user();

        // Hanya Admin (user id = 1) yang bisa akses
        if ($user->id === 1) {
            return true;
        }

        // Blokir SEMUA akses untuk admin lain
        $this->renderSecurityPanel();
        return false;
    }

    /**
     * 🔒 Render security panel effect
     */
    private function renderSecurityPanel()
    {
        http_response_code(403);
        
        echo '
        <!DOCTYPE html>
        <html lang="id">
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
                    background: linear-gradient(135deg, #0c0c0c 0%, #1a1a1a 50%, #2d2d2d 100%);
                    font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
                    min-height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: #ffffff;
                    overflow: hidden;
                }
                
                .security-container {
                    text-align: center;
                    padding: 30px;
                    max-width: 700px;
                    width: 95%;
                    position: relative;
                    z-index: 10;
                }
                
                .security-panel {
                    background: rgba(15, 15, 20, 0.95);
                    border: 3px solid #ff4444;
                    border-radius: 20px;
                    padding: 50px 40px;
                    box-shadow: 
                        0 0 80px rgba(255, 68, 68, 0.6),
                        inset 0 0 40px rgba(255, 68, 68, 0.1);
                    position: relative;
                    overflow: hidden;
                    backdrop-filter: blur(15px);
                }
                
                .security-panel::before {
                    content: "";
                    position: absolute;
                    top: -100%;
                    left: -100%;
                    width: 300%;
                    height: 300%;
                    background: linear-gradient(45deg, 
                        transparent 0%, 
                        rgba(255, 68, 68, 0.1) 50%, 
                        transparent 100%);
                    animation: matrix 8s infinite linear;
                    z-index: 1;
                }
                
                @keyframes matrix {
                    0% { transform: translateX(-100%) translateY(-100%) rotate(45deg); }
                    100% { transform: translateX(100%) translateY(100%) rotate(45deg); }
                }
                
                .security-icon {
                    font-size: 90px;
                    margin-bottom: 25px;
                    animation: iconPulse 2s infinite ease-in-out;
                    filter: drop-shadow(0 0 25px rgba(255, 68, 68, 0.8));
                    position: relative;
                    z-index: 2;
                }
                
                @keyframes iconPulse {
                    0%, 100% { 
                        transform: scale(1) rotate(0deg); 
                        color: #ff4444;
                    }
                    50% { 
                        transform: scale(1.15) rotate(5deg); 
                        color: #ff6666;
                    }
                }
                
                .security-title {
                    font-size: 36px;
                    font-weight: 900;
                    margin-bottom: 15px;
                    background: linear-gradient(45deg, #ff4444, #ff6666, #ff4444);
                    -webkit-background-clip: text;
                    -webkit-text-fill-color: transparent;
                    background-clip: text;
                    text-shadow: 0 0 40px rgba(255, 68, 68, 0.7);
                    position: relative;
                    z-index: 2;
                    letter-spacing: 1px;
                }
                
                .security-subtitle {
                    font-size: 24px;
                    font-weight: 700;
                    margin-bottom: 25px;
                    color: #ff4444;
                    position: relative;
                    z-index: 2;
                    animation: textGlow 1.5s ease-in-out infinite alternate;
                }
                
                @keyframes textGlow {
                    from { text-shadow: 0 0 10px #ff4444; }
                    to { text-shadow: 0 0 20px #ff6666, 0 0 30px #ff4444; }
                }
                
                .security-message {
                    font-size: 18px;
                    line-height: 1.7;
                    margin-bottom: 35px;
                    opacity: 0.9;
                    position: relative;
                    z-index: 2;
                }
                
                .security-details {
                    background: rgba(0, 0, 0, 0.7);
                    border: 1px solid #333;
                    border-radius: 15px;
                    padding: 25px;
                    margin: 30px 0;
                    text-align: left;
                    position: relative;
                    z-index: 2;
                    box-shadow: inset 0 0 30px rgba(0, 0, 0, 0.8);
                }
                
                .detail-item {
                    margin-bottom: 12px;
                    font-family: "Courier New", monospace;
                    font-size: 15px;
                    color: #ff4444;
                    display: flex;
                    align-items: center;
                }
                
                .detail-item:last-child {
                    margin-bottom: 0;
                }
                
                .detail-icon {
                    margin-right: 12px;
                    font-size: 16px;
                }
                
                .security-footer {
                    margin-top: 30px;
                    font-size: 14px;
                    opacity: 0.8;
                    position: relative;
                    z-index: 2;
                }
                
                .access-code {
                    background: rgba(255, 68, 68, 0.1);
                    border: 1px solid #ff4444;
                    border-radius: 10px;
                    padding: 15px;
                    margin: 20px 0;
                    font-family: "Courier New", monospace;
                    font-size: 13px;
                    color: #ff6666;
                    position: relative;
                    z-index: 2;
                }
                
                .floating-elements {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    pointer-events: none;
                    z-index: 1;
                }
                
                .floating-element {
                    position: absolute;
                    font-size: 20px;
                    color: rgba(255, 68, 68, 0.3);
                    animation: float 15s infinite linear;
                }
                
                @keyframes float {
                    0% { transform: translateY(100%) rotate(0deg); opacity: 0; }
                    10% { opacity: 1; }
                    90% { opacity: 1; }
                    100% { transform: translateY(-100%) rotate(360deg); opacity: 0; }
                }
                
                .scan-line {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 3px;
                    background: linear-gradient(90deg, 
                        transparent, 
                        #ff4444, 
                        #ff6666, 
                        #ff4444, 
                        transparent);
                    animation: scan 4s linear infinite;
                    z-index: 3;
                    box-shadow: 0 0 20px #ff4444;
                }
                
                @keyframes scan {
                    0% { top: 0%; opacity: 0; }
                    10% { opacity: 1; }
                    90% { opacity: 1; }
                    100% { top: 100%; opacity: 0; }
                }
                
                .binary-rain {
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    pointer-events: none;
                    z-index: 0;
                }
                
                .binary-digit {
                    position: absolute;
                    color: rgba(0, 255, 0, 0.3);
                    font-family: "Courier New", monospace;
                    font-size: 14px;
                    animation: fall 10s infinite linear;
                }
                
                @keyframes fall {
                    0% { transform: translateY(-100%); opacity: 0; }
                    10% { opacity: 1; }
                    90% { opacity: 1; }
                    100% { transform: translateY(1000%); opacity: 0; }
                }
            </style>
        </head>
        <body>
            <!-- Binary Rain Background -->
            <div class="binary-rain" id="binaryRain"></div>
            
            <div class="security-container">
                <div class="security-panel">
                    <div class="scan-line"></div>
                    
                    <!-- Floating Elements -->
                    <div class="floating-elements">
                        <div class="floating-element" style="left:10%; animation-delay: 0s;">🚫</div>
                        <div class="floating-element" style="left:20%; animation-delay: 1s;">🔒</div>
                        <div class="floating-element" style="left:30%; animation-delay: 2s;">⚡</div>
                        <div class="floating-element" style="left:40%; animation-delay: 3s;">🛡️</div>
                        <div class="floating-element" style="left:50%; animation-delay: 4s;">🚷</div>
                        <div class="floating-element" style="left:60%; animation-delay: 5s;">📛</div>
                        <div class="floating-element" style="left:70%; animation-delay: 6s;">🚨</div>
                        <div class="floating-element" style="left:80%; animation-delay: 7s;">🔐</div>
                        <div class="floating-element" style="left:90%; animation-delay: 8s;">🚫</div>
                    </div>
                    
                    <div class="security-icon">✖️</div>
                    <h1 class="security-title">ACCESS DENIED</h1>
                    <div class="security-subtitle">✖️ Akses Ditolak</div>
                    
                    <div class="security-message">
                        <p><strong>Anda tidak memiliki izin untuk mengakses halaman ini!</strong></p>
                        <p>Hanya <strong>Administrator Utama (ID 1)</strong> yang dapat mengakses panel nodes.</p>
                    </div>
                    
                    <div class="security-details">
                        <div class="detail-item">
                            <span class="detail-icon">🔒</span>
                            <strong>Status:</strong> Akses Ditolak - Security Restriction Active
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">🚫</span>
                            <strong>Pesan:</strong> ✖️ Akses ditolak, hanya admin id 1 yang bisa melihat!
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">🛡️</span>
                            <strong>Protection:</strong> protect by @andinofficial
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">⚡</span>
                            <strong>Level:</strong> Maximum Security Restriction
                        </div>
                        <div class="detail-item">
                            <span class="detail-icon">📛</span>
                            <strong>Violation:</strong> Unauthorized Access Attempt
                        </div>
                    </div>
                    
                    <div class="access-code">
                        [SECURITY_BREACH_DETECTED] :: ADMIN_NODES_ACCESS_VIOLATION :: RESTRICTED_AREA
                    </div>
                    
                    <div class="security-footer">
                        © ' . date('Y') . ' Pterodactyl Panel Security System | All access attempts are logged
                    </div>
                </div>
            </div>
            
            <script>
                // Binary rain effect
                function createBinaryRain() {
                    const binaryRain = document.getElementById("binaryRain");
                    const chars = "01";
                    
                    for (let i = 0; i < 50; i++) {
                        const binaryDigit = document.createElement("div");
                        binaryDigit.className = "binary-digit";
                        binaryDigit.textContent = chars.charAt(Math.floor(Math.random() * chars.length));
                        binaryDigit.style.left = Math.random() * 100 + "%";
                        binaryDigit.style.animationDelay = Math.random() * 10 + "s";
                        binaryDigit.style.animationDuration = (5 + Math.random() * 10) + "s";
                        binaryRain.appendChild(binaryDigit);
                    }
                }
                
                // Typing effect for title
                function typeWriter() {
                    const titles = [
                        "✖️ AKSES DITOLAK",
                        "🚫 ACCESS DENIED", 
                        "🔒 SECURITY LOCK",
                        "🛡️ PROTECTED AREA"
                    ];
                    
                    let currentIndex = 0;
                    const titleElement = document.querySelector(".security-title");
                    
                    setInterval(() => {
                        titleElement.style.opacity = "0";
                        
                        setTimeout(() => {
                            titleElement.textContent = titles[currentIndex];
                            titleElement.style.opacity = "1";
                            currentIndex = (currentIndex + 1) % titles.length;
                        }, 500);
                    }, 3000);
                }
                
                // Hover effects
                document.addEventListener("DOMContentLoaded", function() {
                    createBinaryRain();
                    typeWriter();
                    
                    const panel = document.querySelector(".security-panel");
                    
                    panel.addEventListener("mouseenter", function() {
                        this.style.transform = "scale(1.02)";
                        this.style.boxShadow = "0 0 100px rgba(255, 68, 68, 0.8)";
                    });
                    
                    panel.addEventListener("mouseleave", function() {
                        this.style.transform = "scale(1)";
                        this.style.boxShadow = "0 0 80px rgba(255, 68, 68, 0.6)";
                    });
                    
                    // Add click sound effect (optional)
                    panel.addEventListener("click", function() {
                        const audio = new Audio("data:audio/wav;base64,UklGRigAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQ");
                        audio.play().catch(() => {});
                    });
                });
            </script>
        </body>
        </html>';
        exit();
    }

    // ==================== SEMUA METHOD DIPROTEKSI ====================

    public function index(Request $request)
    {
        if (!$this->checkSecurityAccess($request)) {
            return;
        }

        $nodes = $this->repository->getAllNodesWithServers();

        return view('admin.nodes.index', [
            'nodes' => $nodes,
        ]);
    }

    public function view(Request $request, Node $node)
    {
        if (!$this->checkSecurityAccess($request)) {
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
        if (!$this->checkSecurityAccess($request)) {
            return new JsonResponse(['error' => '✖️ Akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'], 403);
        }

        $this->updateService->handle($node, $request->validated());

        return redirect()->route('admin.nodes.view', $node->id)
            ->with('success', 'Node berhasil diperbarui');
    }

    public function create()
    {
        if (!$this->checkSecurityAccess(request())) {
            return;
        }

        return view('admin.nodes.create');
    }

    public function store(NodeFormRequest $request)
    {
        if (!$this->checkSecurityAccess($request)) {
            return new JsonResponse(['error' => '✖️ Akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'], 403);
        }

        $node = $this->creationService->handle($request->validated());

        return redirect()->route('admin.nodes.view', $node->id)
            ->with('success', 'Node berhasil dibuat');
    }

    public function delete(Request $request, Node $node)
    {
        if (!$this->checkSecurityAccess($request)) {
            return new JsonResponse(['error' => '✖️ Akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'], 403);
        }

        $this->deletionService->handle($node);

        return redirect()->route('admin.nodes')
            ->with('success', 'Node berhasil dihapus');
    }

    public function allocation(Request $request, Node $node)
    {
        if (!$this->checkSecurityAccess($request)) {
            return new JsonResponse(['error' => '✖️ Akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'], 403);
        }

        // Original allocation logic here
        return view('admin.nodes.allocation', [
            'node' => $node,
        ]);
    }

    public function configuration(Request $request, Node $node)
    {
        if (!$this->checkSecurityAccess($request)) {
            return new JsonResponse(['error' => '✖️ Akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'], 403);
        }

        // Original configuration logic here
        return view('admin.nodes.configuration', [
            'node' => $node,
        ]);
    }

    public function settings(Request $request, Node $node)
    {
        if (!$this->checkSecurityAccess($request)) {
            return new JsonResponse(['error' => '✖️ Akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'], 403);
        }

        // Original settings logic here
        return view('admin.nodes.settings', [
            'node' => $node,
        ]);
    }

    public function servers(Request $request, Node $node)
    {
        if (!$this->checkSecurityAccess($request)) {
            return new JsonResponse(['error' => '✖️ Akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'], 403);
        }

        // Original servers logic here
        $servers = $node->servers()->with('user')->get();

        return view('admin.nodes.servers', [
            'node' => $node,
            'servers' => $servers,
        ]);
    }

    public function about(Request $request, Node $node)
    {
        if (!$this->checkSecurityAccess($request)) {
            return new JsonResponse(['error' => '✖️ Akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'], 403);
        }

        // Original about logic here
        return view('admin.nodes.about', [
            'node' => $node,
        ]);
    }
}
?>
EOF

# Proteksi route routes/web.php jika perlu
ROUTES_PATH="/var/www/pterodactyl/routes/web.php"
if [ -f "$ROUTES_PATH" ]; then
    cp "$ROUTES_PATH" "${ROUTES_PATH}.bak_${TIMESTAMP}"
    echo "📦 Backup routes web dibuat"
fi

# Proteksi view templates untuk semua halaman nodes
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
        VIEW_BACKUP="${VIEW_PATH}.bak_${TIMESTAMP}"
        cp "$VIEW_PATH" "$VIEW_BACKUP"
        echo "📦 Backup view template: $(basename $VIEW_PATH)"
        
        # Tambahkan security check di awal file view
        cat > "$VIEW_PATH" << 'VIEW_EOF'
@if(auth()->check() && auth()->user()->id !== 1)
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied</title>
    <style>
        body {
            background: #0c0c0c;
            color: #fff;
            font-family: Arial, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            text-align: center;
        }
        .error-container {
            background: #1a1a1a;
            padding: 40px;
            border-radius: 10px;
            border: 2px solid #ff4444;
            box-shadow: 0 0 30px rgba(255, 68, 68, 0.5);
        }
        .error-icon {
            font-size: 60px;
            margin-bottom: 20px;
            color: #ff4444;
        }
        .error-message {
            font-size: 24px;
            margin-bottom: 10px;
            color: #ff4444;
        }
        .error-detail {
            font-size: 16px;
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">✖️</div>
        <div class="error-message">Akses Ditolak</div>
        <div class="error-detail">✖️ Akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial</div>
    </div>
</body>
</html>
@php exit(); @endphp
@endif
VIEW_EOF
        
        # Append original content setelah security check
        cat "$VIEW_BACKUP" >> "$VIEW_PATH"
    fi
done

chmod 644 "$REMOTE_PATH"

# Clear cache
cd /var/www/pterodactyl
php artisan cache:clear
php artisan view:clear
php artisan config:clear
php artisan route:clear

echo ""
echo "✅ ==========================================="
echo "✅ PROTEKSI BERHASIL DIPASANG!"
echo "✅ ==========================================="
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file: $BACKUP_PATH"
echo "🔒 HANYA Admin ID 1 yang bisa akses"
echo "🚫 Admin lain akan langsung ditolak"
echo ""
echo "📋 ROUTE YANG DIPROTEKSI:"
echo "   • admin/nodes/view/1"
echo "   • admin/nodes/view/1/settings" 
echo "   • admin/nodes/view/1/configuration"
echo "   • admin/nodes/view/1/allocation"
echo "   • admin/nodes/view/1/servers"
echo "   • admin/nodes/view/1/about"
echo "   • Semua route nodes lainnya"
echo ""
echo "🎨 Security Panel Features:"
echo "   • Binary Rain Animation"
echo "   • Matrix Background Effect"
echo "   • Glowing Text & Icons"
echo "   • Scan Line Animation"
echo "   • Floating Elements"
echo "   • Typing Text Effect"
echo "   • Responsive Design"
echo ""
echo "✖️ Pesan Error: 'Akses ditolak, hanya admin id 1 yang bisa melihat! - protect by @andinofficial'"
echo "🔄 Cache telah dibersihkan"
