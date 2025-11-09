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
     * 🔒 Fungsi tambahan: Cek akses security panel
     */
    private function checkSecurityAccess($request, $nodeId = null)
    {
        $user = $request->user();

        // Admin (user id = 1) bebas akses semua
        if ($user->id === 1) {
            return true;
        }

        // Cek jika mengakses halaman view nodes dengan ID 1
        if ($nodeId === 1 || $request->route('node') == 1) {
            $this->showSecurityAlert();
            return false;
        }

        return true;
    }

    /**
     * 🔒 Tampilkan alert security
     */
    private function showSecurityAlert()
    {
        abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall');
    }

    /**
     * 🔒 Render security panel effect
     */
    private function renderSecurityPanel($request)
    {
        $user = $request->user();
        
        if ($user->id === 1) {
            return null;
        }

        echo '
        <style>
        .security-panel {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            border: 2px solid #e74c3c;
            border-radius: 10px;
            padding: 30px;
            margin: 20px 0;
            text-align: center;
            box-shadow: 0 0 30px rgba(231, 76, 60, 0.3);
            position: relative;
            overflow: hidden;
        }
        
        .security-panel::before {
            content: "";
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: linear-gradient(45deg, transparent, rgba(255,255,255,0.1), transparent);
            animation: shine 3s infinite;
        }
        
        @keyframes shine {
            0% { transform: translateX(-100%) translateY(-100%) rotate(45deg); }
            100% { transform: translateX(100%) translateY(100%) rotate(45deg); }
        }
        
        .security-icon {
            font-size: 48px;
            color: #e74c3c;
            margin-bottom: 20px;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }
        
        .security-title {
            color: #e74c3c;
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 15px;
            text-shadow: 0 0 10px rgba(231, 76, 60, 0.5);
        }
        
        .security-message {
            color: #ecf0f1;
            font-size: 16px;
            line-height: 1.6;
            margin-bottom: 20px;
        }
        
        .security-code {
            background: rgba(0,0,0,0.5);
            border: 1px solid #34495e;
            border-radius: 5px;
            padding: 15px;
            margin: 15px 0;
            font-family: "Courier New", monospace;
            color: #e74c3c;
        }
        
        .protected-section {
            opacity: 0.3;
            pointer-events: none;
            filter: blur(2px);
            transition: all 0.3s ease;
        }
        </style>
        
        <div class="security-panel">
            <div class="security-icon">🚫</div>
            <div class="security-title">SECURITY PANEL ACTIVATED</div>
            <div class="security-message">
                Akses ke panel ini dibatasi untuk keamanan sistem.<br>
                Hanya Administrator utama yang dapat mengakses bagian ini.
            </div>
            <div class="security-code">
                🔒 PROTECTED BY: @naaofficiall<br>
                ⚡ SECURITY LEVEL: MAXIMUM<br>
                🛡️ STATUS: ACTIVE PROTECTION
            </div>
        </div>';
        
        http_response_code(403);
        exit();
    }

    public function index(Request $request)
    {
        if (!$this->checkSecurityAccess($request)) {
            return $this->renderSecurityPanel($request);
        }

        $nodes = $this->repository->getAllNodesWithServers();

        return view('admin.nodes.index', [
            'nodes' => $nodes,
        ]);
    }

    public function view(Request $request, Node $node)
    {
        if (!$this->checkSecurityAccess($request, $node->id)) {
            return $this->renderSecurityPanel($request);
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
            return $this->renderSecurityPanel(request());
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
}
?>
EOF

# Juga proteksi view template jika ada
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view.blade.php"
VIEW_BACKUP="${VIEW_PATH}.bak_${TIMESTAMP}"

if [ -f "$VIEW_PATH" ]; then
  cp "$VIEW_PATH" "$VIEW_BACKUP"
  echo "📦 Backup view template dibuat di $VIEW_BACKUP"
  
  # Tambahkan security check di view template
  sed -i '1i\@if(auth()->check() && auth()->user()->id !== 1 && $node->id == 1)<div class="protected-section">@endif' "$VIEW_PATH"
  
  # Tambahkan security panel effect
  SECURITY_CODE='
  @if(auth()->check() && auth()->user()->id !== 1 && $node->id == 1)
  <style>
  .security-overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0,0,0,0.9);
      z-index: 9999;
      display: flex;
      align-items: center;
      justify-content: center;
  }
  .security-panel-view {
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
      border: 3px solid #e74c3c;
      border-radius: 15px;
      padding: 40px;
      text-align: center;
      box-shadow: 0 0 50px rgba(231, 76, 60, 0.5);
      max-width: 500px;
      animation: glow 2s infinite alternate;
  }
  @keyframes glow {
      from { box-shadow: 0 0 30px rgba(231, 76, 60, 0.5); }
      to { box-shadow: 0 0 50px rgba(231, 76, 60, 0.8); }
  }
  </style>
  <div class="security-overlay">
      <div class="security-panel-view">
          <div style="font-size: 60px; margin-bottom: 20px;">🔒</div>
          <h2 style="color: #e74c3c; margin-bottom: 20px;">SECURITY RESTRICTION</h2>
          <p style="color: #ecf0f1; margin-bottom: 20px;">Akses ditolak, protect by @naaofficiall</p>
          <div style="background: rgba(0,0,0,0.5); padding: 15px; border-radius: 8px; margin: 15px 0;">
              <code style="color: #e74c3c;">Node ID: {{ $node->id }} - PROTECTED</code>
          </div>
      </div>
  </div>
  @endif'
  
  echo "$SECURITY_CODE" >> "$VIEW_PATH"
fi

chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi Security Panel Admin Nodes View berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo "🔒 Hanya Admin (ID 1) yang bisa Akses Node ID 1"
echo "🎨 Security Panel Effect telah diaktifkan"
