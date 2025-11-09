#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeViewController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Admin Nodes Security Panel..."

# Backup file original
if [ -f "$REMOTE_PATH" ]; then
  cp "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

# Create modified controller
cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\View\View;
use Pterodactyl\Models\Node;
use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Nodes\NodeUpdateService;
use Pterodactyl\Traits\Controllers\JavascriptInjection;
use Pterodactyl\Http\Requests\Admin\Node\NodeFormRequest;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;
use Pterodactyl\Contracts\Repository\AllocationRepositoryInterface;

class NodeViewController extends Controller
{
    use JavascriptInjection;

    public function __construct(
        protected AlertsMessageBag $alert,
        protected AllocationRepositoryInterface $allocation,
        protected NodeRepositoryInterface $repository,
        protected NodeUpdateService $updateService
    ) {
    }

    /**
     * 🔒 Fungsi tambahan: Cek akses admin nodes
     */
    private function checkNodeAccess()
    {
        $user = auth()->user();
        
        // Admin (user id = 1) bebas akses semua
        if ($user->id === 1) {
            return true;
        }

        // Jika bukan admin ID 1, tolak akses dengan 403
        abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall');
    }

    /**
     * Display the index page with a listing of nodes.
     */
    public function index(): View
    {
        $this->checkNodeAccess();
        
        $this->setJavascript();
        $this->injset['nodeData'] = true;

        return view('admin.nodes.index', [
            'nodes' => $this->repository->getAllNodesWithServers(),
        ]);
    }

    /**
     * Display a single node on the system.
     */
    public function view(Node $node, string $tab = 'index'): View
    {
        $user = auth()->user();
        
        // Only check access for restricted tabs
        if ($tab !== 'index' && $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall');
        }

        $this->setJavascript();

        try {
            $stats = $this->repository->getUsageStats($node);
            $this->injset['node'] = array_merge($node->toArray(), [
                'disk_used' => $stats['disk']['used'] ?? 0,
                'disk_percent' => $stats['disk']['percent'] ?? 0,
                'memory_used' => $stats['memory']['used'] ?? 0,
                'memory_percent' => $stats['memory']['percent'] ?? 0,
            ]);
        } catch (\Exception $e) {
            $this->alert->warning(
                sprintf('There was an error while attempting to load usage statistics for this node: %s', $e->getMessage())
            )->flash();

            $this->injset['node'] = $node;
        }

        $this->injset['stats'] = $stats ?? null;

        // Return appropriate view based on tab
        if ($user->id === 1) {
            // Admin ID 1 can access all tabs normally
            switch ($tab) {
                case 'settings':
                    return view('admin.nodes.view.settings', ['node' => $node]);
                case 'configuration':
                    return view('admin.nodes.view.configuration', ['node' => $node]);
                case 'allocation':
                    return view('admin.nodes.view.allocation', [
                        'node' => $node,
                        'allocations' => $this->allocation->setColumns(['ip', 'port', 'alias', 'server_id'])->getAllocationsForNode($node->id),
                    ]);
                case 'servers':
                    return view('admin.nodes.view.servers', [
                        'node' => $node,
                        'servers' => $node->servers()->with(['user', 'nest', 'egg'])->paginate(25),
                    ]);
                default:
                    return view('admin.nodes.view.index', ['node' => $node]);
            }
        } else {
            // Non-admin users only get the index view
            if ($tab !== 'index') {
                abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall');
            }
            return view('admin.nodes.view.index_protected', ['node' => $node]);
        }
    }

    /**
     * Update a node's configuration.
     */
    public function update(NodeFormRequest $request, Node $node): RedirectResponse
    {
        $this->checkNodeAccess();
        
        $this->updateService->handle($node, $request->validated(), $request->input('reset_secret'));

        $this->alert->success('Node settings have been updated successfully.')->flash();

        return redirect()->route('admin.nodes.view', [$node->id, 'settings']);
    }
}
EOF

chmod 644 "$REMOTE_PATH"

# Create security CSS
SECURITY_CSS_PATH="/var/www/pterodactyl/public/themes/pterodactyl/css/security-panel.css"
mkdir -p "$(dirname "$SECURITY_CSS_PATH")"

cat > "$SECURITY_CSS_PATH" << 'EOF'
/* Security Panel Effects */
.security-shield {
    position: relative;
    padding: 20px;
    border-radius: 10px;
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
    border: 2px solid #00ffff;
    box-shadow: 0 0 20px rgba(0, 255, 255, 0.3);
    margin-bottom: 20px;
}

.security-shield::before {
    content: '🔒 SECURED';
    position: absolute;
    top: -10px;
    left: 20px;
    background: #00ffff;
    color: #000;
    padding: 2px 10px;
    border-radius: 5px;
    font-size: 10px;
    font-weight: bold;
    text-transform: uppercase;
}

.security-pulse {
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { box-shadow: 0 0 0 0 rgba(0, 255, 255, 0.4); }
    70% { box-shadow: 0 0 0 10px rgba(0, 255, 255, 0); }
    100% { box-shadow: 0 0 0 0 rgba(0, 255, 255, 0); }
}

.security-badge {
    background: linear-gradient(45deg, #ff0000, #ff8c00);
    color: white;
    padding: 3px 8px;
    border-radius: 12px;
    font-size: 9px;
    font-weight: bold;
    margin-left: 5px;
    animation: glow 1.5s ease-in-out infinite alternate;
}

@keyframes glow {
    from { box-shadow: 0 0 5px #ff0000; }
    to { box-shadow: 0 0 15px #ff8c00; }
}

.access-denied {
    background: linear-gradient(45deg, #ff3860, #ff7860) !important;
    color: white !important;
    cursor: not-allowed !important;
}

.access-denied:hover {
    background: linear-gradient(45deg, #ff0033, #ff5555) !important;
    transform: scale(1.02);
    transition: all 0.3s ease;
}

.security-alert {
    border-left: 4px solid #ff3860;
    background: rgba(255, 56, 96, 0.1);
}
EOF

echo "✅ Security Panel CSS created!"

# Add CSS to admin layout
LAYOUT_PATH="/var/www/pterodactyl/resources/views/layouts/admin.blade.php"
if [ -f "$LAYOUT_PATH" ]; then
    if ! grep -q "security-panel.css" "$LAYOUT_PATH"; then
        sed -i '/<\/head>/i <link rel="stylesheet" href="{{ asset(\"/themes/pterodactyl/css/security-panel.css\") }}">' "$LAYOUT_PATH"
        echo "✅ Security CSS added to admin layout!"
    fi
fi

# Create protected view for non-admin users
NODES_VIEW_DIR="/var/www/pterodactyl/resources/views/admin/nodes/view"
mkdir -p "$NODES_VIEW_DIR"

# Create the protected view
cat > "$NODES_VIEW_DIR/index_protected.blade.php" << 'EOF'
@extends('layouts.admin')
@section('title')
    Node — {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Security Protected Node</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li class="active">{{ $node->name }}</li>
    </ol>
@endsection

@section('content')
<div class="row">
    <div class="col-xs-12">
        <div class="nav-tabs-custom nav-tabs-floating">
            <ul class="nav nav-tabs">
                <li class="active"><a href="{{ route('admin.nodes.view', $node->id) }}">About</a></li>
                <li class="access-denied"><a href="javascript:void(0)" onclick="showAccessDenied()">Settings <span class="security-badge">LOCKED</span></a></li>
                <li class="access-denied"><a href="javascript:void(0)" onclick="showAccessDenied()">Configuration <span class="security-badge">LOCKED</span></a></li>
                <li class="access-denied"><a href="javascript:void(0)" onclick="showAccessDenied()">Allocation <span class="security-badge">LOCKED</span></a></li>
                <li class="access-denied"><a href="javascript:void(0)" onclick="showAccessDenied()">Servers <span class="security-badge">LOCKED</span></a></li>
            </ul>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-sm-8">
        <div class="security-shield security-pulse">
            <div class="row">
                <div class="col-xs-6 col-md-3 text-center">
                    <a href="javascript:void(0)"><p>Servers</p><h4>{{ $node->servers_count }}</h4></a>
                </div>
                <div class="col-xs-6 col-md-3 text-center">
                    <a href="javascript:void(0)"><p>Usage</p><h4>{{ $node->memory_percent ?? 0 }}%</h4></a>
                </div>
                <div class="col-xs-6 col-md-3 text-center">
                    <a href="javascript:void(0)"><p>CPU</p><h4>0%</h4></a>
                </div>
                <div class="col-xs-6 col-md-3 text-center">
                    <a href="javascript:void(0)"><p>Disk</p><h4>{{ $node->disk_percent ?? 0 }}%</h4></a>
                </div>
            </div>
        </div>
        
        <div class="security-shield">
            <h4><i class="fa fa-shield text-cyan"></i> Security Protected Area</h4>
            <p class="text-muted">This node is protected by advanced security measures. Only authorized administrators can access detailed information and settings.</p>
            
            <div class="security-alert alert alert-warning">
                <i class="fa fa-warning"></i> 
                <strong>Access Restricted:</strong> 
                Your account does not have permission to view node configuration details.
            </div>
            
            <div class="row mt-3">
                <div class="col-md-6">
                    <div class="info-box bg-blue">
                        <span class="info-box-icon"><i class="fa fa-server"></i></span>
                        <div class="info-box-content">
                            <span class="info-box-text">Node Name</span>
                            <span class="info-box-number">{{ $node->name }}</span>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="info-box bg-green">
                        <span class="info-box-icon"><i class="fa fa-plug"></i></span>
                        <div class="info-box-content">
                            <span class="info-box-text">Status</span>
                            <span class="info-box-number">OPERATIONAL</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-sm-4">
        <div class="box box-success">
            <div class="box-header with-border">
                <h3 class="box-title">Security Status</h3>
            </div>
            <div class="box-body">
                <div class="row">
                    <div class="col-xs-12">
                        <div class="info-box bg-green">
                            <span class="info-box-icon"><i class="fa fa-shield"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Protection Level</span>
                                <span class="info-box-number">MAXIMUM</span>
                                <div class="progress">
                                    <div class="progress-bar" style="width: 100%"></div>
                                </div>
                                <span class="progress-description">
                                    Protected by @naaofficiall
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="security-shield text-center" style="padding: 15px; margin-top: 15px;">
                    <i class="fa fa-user-secret fa-3x text-cyan"></i>
                    <h4 style="margin: 10px 0 5px 0;">Restricted Access</h4>
                    <p class="text-muted" style="font-size: 12px; margin: 0;">
                        Limited preview mode
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('footer-scripts')
    @parent
    <script>
        function showAccessDenied() {
            Swal.fire({
                icon: 'error',
                title: 'Access Denied',
                html: '<div style="color: #ff6b6b; font-weight: bold; font-size: 16px; font-family: monospace;">𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall</div>',
                confirmButtonText: 'OK',
                confirmButtonColor: '#ff3860',
                background: '#1a1a2e',
                customClass: {
                    popup: 'security-shield'
                }
            });
        }
        
        $(document).ready(function() {
            console.log('🔒 Node Security Protection Active - @naaofficiall');
        });
    </script>
EOF

echo "✅ Protected view created!"

# Clear view cache
echo "🔄 Clearing view cache..."
php /var/www/pterodactyl/artisan view:clear
php /var/www/pterodactyl/artisan cache:clear

echo ""
echo "🎉 Proteksi Admin Nodes Security Panel berhasil dipasang!"
echo "📂 File utama: $REMOTE_PATH"
echo "🎨 CSS Effects: $SECURITY_CSS_PATH"
echo "👁️ Protected View: $NODES_VIEW_DIR/index_protected.blade.php"
echo ""
echo "🔒 ACCESS RULES:"
echo "   ✅ Admin ID 1: Akses penuh semua tab"
echo "   🚫 Admin lain: Hanya bisa lihat 'About' tab, lainnya error 403"
echo "   💬 Pesan error: '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall'"
echo ""
echo "⚠️  Pterodactyl akan berjalan NORMAL untuk Admin ID 1"
echo "🚫 Admin lain akan mendapat ERROR 403 yang proper"
EOF
