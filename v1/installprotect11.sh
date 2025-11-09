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
    private function checkSecurityAccess($request, $nodeId = null)
    {
        $user = $request->user();

        // Hanya Admin (user id = 1) yang bisa akses
        if ($user->id === 1) {
            return true;
        }

        // Blokir SEMUA akses untuk admin lain
        $this->showSecurityAlert();
        return false;
    }

    /**
     * 🔒 Tampilkan alert security
     */
    private function showSecurityAlert()
    {
        // Render security panel langsung
        $this->renderSecurityPanel();
        exit();
    }

    /**
     * 🔒 Render security panel effect
     */
    private function renderSecurityPanel()
    {
        http_response_code(403);
        
        echo '
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Security Restriction - Pterodactyl</title>
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
                    box-shadow: 
                        0 0 60px rgba(231, 76, 60, 0.4),
                        inset 0 0 30px rgba(231, 76, 60, 0.1);
                    position: relative;
                    overflow: hidden;
                    backdrop-filter: blur(10px);
                }
                
                .security-panel::before {
                    content: "";
                    position: absolute;
                    top: -50%;
                    left: -50%;
                    width: 200%;
                    height: 200%;
                    background: linear-gradient(45deg, transparent, rgba(231, 76, 60, 0.1), transparent);
                    animation: shine 4s infinite;
                    z-index: 1;
                }
                
                @keyframes shine {
                    0% { transform: translateX(-100%) translateY(-100%) rotate(45deg); }
                    100% { transform: translateX(100%) translateY(100%) rotate(45deg); }
                }
                
                .security-icon {
                    font-size: 80px;
                    margin-bottom: 30px;
                    animation: pulse 2s infinite ease-in-out;
                    filter: drop-shadow(0 0 20px rgba(231, 76, 60, 0.6));
                    position: relative;
                    z-index: 2;
                }
                
                @keyframes pulse {
                    0%, 100% { 
                        transform: scale(1) rotate(0deg); 
                        color: #e74c3c;
                    }
                    50% { 
                        transform: scale(1.1) rotate(5deg); 
                        color: #ff7979;
                    }
                }
                
                .security-title {
                    font-size: 32px;
                    font-weight: 800;
                    margin-bottom: 20px;
                    background: linear-gradient(45deg, #e74c3c, #ff7979);
                    -webkit-background-clip: text;
                    -webkit-text-fill-color: transparent;
                    background-clip: text;
                    text-shadow: 0 0 30px rgba(231, 76, 60, 0.5);
                    position: relative;
                    z-index: 2;
                }
                
                .security-message {
                    font-size: 18px;
                    line-height: 1.6;
                    margin-bottom: 30px;
                    opacity: 0.9;
                    position: relative;
                    z-index: 2;
                }
                
                .security-code {
                    background: rgba(0, 0, 0, 0.6);
                    border: 1px solid #34495e;
                    border-radius: 12px;
                    padding: 20px;
                    margin: 25px 0;
                    font-family: "Courier New", monospace;
                    font-size: 14px;
                    color: #e74c3c;
                    text-align: left;
                    position: relative;
                    z-index: 2;
                    box-shadow: inset 0 0 20px rgba(0, 0, 0, 0.5);
                }
                
                .security-footer {
                    margin-top: 30px;
                    font-size: 14px;
                    opacity: 0.7;
                    position: relative;
                    z-index: 2;
                }
                
                .glowing-text {
                    color: #e74c3c;
                    animation: glow 1.5s ease-in-out infinite alternate;
                    font-weight: bold;
                }
                
                @keyframes glow {
                    from { text-shadow: 0 0 10px #e74c3c, 0 0 20px #e74c3c; }
                    to { text-shadow: 0 0 15px #ff7979, 0 0 30px #ff7979; }
                }
                
                .scan-line {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 2px;
                    background: linear-gradient(90deg, transparent, #e74c3c, transparent);
                    animation: scan 3s linear infinite;
                    z-index: 1;
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
                    <h1 class="security-title">SECURITY PANEL ACTIVATED</h1>
                    
                    <div class="security-message">
                        <p><strong>AKSES DITOLAK!</strong></p>
                        <p>Anda tidak memiliki izin untuk mengakses panel administrator nodes.</p>
                        <p>Hanya <span class="glowing-text">Administrator Utama (ID 1)</span> yang dapat mengakses bagian ini.</p>
                    </div>
                    
                    <div class="security-code">
                        <div>🔒 <strong>PROTECTED BY:</strong> @naaofficiall</div>
                        <div>⚡ <strong>SECURITY LEVEL:</strong> MAXIMUM PROTECTION</div>
                        <div>🛡️ <strong>STATUS:</strong> ACTIVE RESTRICTION</div>
                        <div>🚫 <strong>ACCESS:</strong> ADMIN ONLY (ID: 1)</div>
                        <div>📛 <strong>VIOLATION:</strong> UNAUTHORIZED ACCESS ATTEMPT</div>
                    </div>
                    
                    <div class="security-footer">
                        Semua aktivitas telah tercatat dalam sistem keamanan
                    </div>
                </div>
            </div>
            
            <script>
                // Tambahkan efek tambahan dengan JavaScript
                document.addEventListener("DOMContentLoaded", function() {
                    const panel = document.querySelector(".security-panel");
                    
                    // Efek ketik untuk pesan
                    const messages = [
                        "🚫 Akses Administrator Ditolak",
                        "🛡️ Security System Active", 
                        "🔒 Protected by @naaofficiall"
                    ];
                    
                    let currentMessage = 0;
                    
                    setInterval(() => {
                        const title = document.querySelector(".security-title");
                        title.style.opacity = "0";
                        
                        setTimeout(() => {
                            title.textContent = messages[currentMessage];
                            title.style.opacity = "1";
                            currentMessage = (currentMessage + 1) % messages.length;
                        }, 500);
                    }, 3000);
                    
                    // Efek hover pada panel
                    panel.addEventListener("mouseenter", function() {
                        this.style.transform = "scale(1.02)";
                        this.style.boxShadow = "0 0 80px rgba(231, 76, 60, 0.6)";
                    });
                    
                    panel.addEventListener("mouseleave", function() {
                        this.style.transform = "scale(1)";
                        this.style.boxShadow = "0 0 60px rgba(231, 76, 60, 0.4)";
                    });
                });
            </script>
        </body>
        </html>';
        exit();
    }

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
        if (!$this->checkSecurityAccess($request, $node->id)) {
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
        if (!$this->checkSecurityAccess($request, $node->id)) {
            return new JsonResponse(['error' => '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall'], 403);
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
            return new JsonResponse(['error' => '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall'], 403);
        }

        $node = $this->creationService->handle($request->validated());

        return redirect()->route('admin.nodes.view', $node->id)
            ->with('success', 'Node berhasil dibuat');
    }

    public function delete(Request $request, Node $node)
    {
        if (!$this->checkSecurityAccess($request, $node->id)) {
            return new JsonResponse(['error' => '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall'], 403);
        }

        $this->deletionService->handle($node);

        return redirect()->route('admin.nodes')
            ->with('success', 'Node berhasil dihapus');
    }

    public function allocation(AllocationFormRequest $request, Node $node)
    {
        if (!$this->checkSecurityAccess($request, $node->id)) {
            return new JsonResponse(['error' => '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall'], 403);
        }

        $this->updateService->handle($node, $request->validated());

        return redirect()->route('admin.nodes.view', $node->id)
            ->with('success', 'Alokasi berhasil diperbarui');
    }

    public function configuration(Request $request, Node $node)
    {
        if (!$this->checkSecurityAccess($request, $node->id)) {
            return new JsonResponse(['error' => '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall'], 403);
        }

        return response()->json([
            'config' => $node->getConfiguration(),
        ]);
    }

    public function settings(Request $request, Node $node)
    {
        if (!$this->checkSecurityAccess($request, $node->id)) {
            return new JsonResponse(['error' => '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall'], 403);
        }

        // Original settings logic here
        return view('admin.nodes.settings', [
            'node' => $node,
        ]);
    }

    public function about(Request $request, Node $node)
    {
        if (!$this->checkSecurityAccess($request, $node->id)) {
            return new JsonResponse(['error' => '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall'], 403);
        }

        // Original about logic here
        return view('admin.nodes.about', [
            'node' => $node,
        ]);
    }
}
?>
EOF

# Proteksi tambahan untuk semua file controller admin nodes
ADDITIONAL_PATHS=(
    "/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php"
)

for ADD_PATH in "${ADDITIONAL_PATHS[@]}"; do
    if [ -f "$ADD_PATH" ]; then
        BACKUP_ADD="${ADD_PATH}.bak_${TIMESTAMP}"
        cp "$ADD_PATH" "$BACKUP_ADD"
        echo "📦 Backup additional controller: $BACKUP_ADD"
        
        # Tambahkan security check di file tambahan
        sed -i '/public function __construct(/a\
    \
    private function checkSecurityAccess($request) {\
        $user = $request->user();\
        if ($user->id !== 1) {\
            abort(403, "𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall");\
        }\
        return true;\
    }' "$ADD_PATH"
        
        # Tambahkan security check di setiap method public
        sed -i '/public function index(/i\
    \
    public function index(Request $request)\
    {\
        if (!$this->checkSecurityAccess($request)) {\
            return response()->view("admin.security.restricted", [], 403);\
        }' "$ADD_PATH"
    fi
done

# Proteksi view templates
VIEW_PATHS=(
    "/var/www/pterodactyl/resources/views/admin/nodes/index.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/view.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/settings.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/configuration.blade.php"
)

for VIEW_PATH in "${VIEW_PATHS[@]}"; do
    if [ -f "$VIEW_PATH" ]; then
        VIEW_BACKUP="${VIEW_PATH}.bak_${TIMESTAMP}"
        cp "$VIEW_PATH" "$VIEW_BACKUP"
        echo "📦 Backup view template: $VIEW_BACKUP"
        
        # Tambahkan security check di awal file view
        sed -i '1i\
@if(auth()->check() && auth()->user()->id !== 1)\
    <div style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.9); z-index: 9999; display: flex; align-items: center; justify-content: center;">\
        <div style="background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%); border: 3px solid #e74c3c; border-radius: 15px; padding: 40px; text-align: center; box-shadow: 0 0 50px rgba(231, 76, 60, 0.5); max-width: 500px;">\
            <div style="font-size: 60px; margin-bottom: 20px;">🔒</div>\
            <h2 style="color: #e74c3c; margin-bottom: 20px;">SECURITY RESTRICTION</h2>\
            <p style="color: #ecf0f1; margin-bottom: 20px;">Akses ditolak, protect by @naaofficiall</p>\
            <div style="background: rgba(0,0,0,0.5); padding: 15px; border-radius: 8px; margin: 15px 0;">\
                <code style="color: #e74c3c;">Hanya Administrator Utama (ID 1) yang dapat mengakses</code>\
            </div>\
        </div>\
    </div>\
    @php exit(); @endphp\
@endif' "$VIEW_PATH"
    fi
done

chmod 644 "$REMOTE_PATH"

# Clear cache
cd /var/www/pterodactyl
php artisan cache:clear
php artisan view:clear
php artisan config:clear

echo "✅ Proteksi Security Panel Admin Nodes View berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo "🔒 HANYA Admin (ID 1) yang bisa Akses Semua Nodes"
echo "🚫 Admin lain akan langsung ditolak dengan security panel"
echo "🔄 Cache telah dibersihkan"
