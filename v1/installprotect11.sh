#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeViewController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Admin Nodes Security Panel..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\View\View;
use Pterodactyl\Models\Node;
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
    private function checkNodeAccess($user)
    {
        // Admin (user id = 1) bebas akses semua
        if ($user->id === 1) {
            return true;
        }

        // Jika bukan admin ID 1, tolak akses
        $this->alert->danger('𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall')->flash();
        abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall');
    }

    /**
     * Display the index page with a listing of nodes.
     */
    public function index(): View
    {
        $this->checkNodeAccess(auth()->user());
        
        $this->setJavascript();
        $this->injset['nodeData'] = true;

        return view('admin.nodes.index', [
            'nodes' => $this->repository->getAllNodesWithServers(),
        ]);
    }

    /**
     * Display a single node on the system.
     */
    public function view(Node $node, string $tab = 'index'): View|RedirectResponse
    {
        $this->checkNodeAccess(auth()->user());
        
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

        switch ($tab) {
            case 'settings':
                return view('admin.nodes.view.settings', [
                    'node' => $node,
                ]);
            case 'configuration':
                return view('admin.nodes.view.configuration', [
                    'node' => $node,
                ]);
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
        }

        return view('admin.nodes.view.index', ['node' => $node]);
    }

    /**
     * Update a node's configuration.
     *
     * @throws \Pterodactyl\Exceptions\Model\DataValidationException
     * @throws \Pterodactyl\Exceptions\Repository\RecordNotFoundException
     */
    public function update(NodeFormRequest $request, Node $node): RedirectResponse
    {
        $this->checkNodeAccess(auth()->user());
        
        $this->updateService->handle($node, $request->validated(), $request->input('reset_secret'));

        $this->alert->success('Node settings have been updated successfully.')->flash();

        return redirect()->route('admin.nodes.view', [$node->id, 'settings']);
    }
}
?>
EOF

chmod 644 "$REMOTE_PATH"

# Membuat file CSS untuk efek security panel
SECURITY_CSS_PATH="/var/www/pterodactyl/public/themes/pterodactyl/css/security-panel.css"
cat > "$SECURITY_CSS_PATH" << 'EOF'
/* Security Panel Effects */
.security-shield {
    position: relative;
    padding: 15px;
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

.protected-table {
    position: relative;
    overflow: hidden;
}

.protected-table::after {
    content: 'PROTECTED BY @naaofficiall';
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%) rotate(-45deg);
    font-size: 24px;
    font-weight: bold;
    color: rgba(255, 0, 0, 0.1);
    z-index: 1;
    pointer-events: none;
}

.access-denied {
    background: linear-gradient(45deg, #ff0000, #8b0000) !important;
    color: white !important;
    border: 2px solid #ff4444 !important;
}

.security-badge {
    background: linear-gradient(45deg, #ff0000, #ff8c00);
    color: white;
    padding: 5px 10px;
    border-radius: 15px;
    font-size: 10px;
    font-weight: bold;
    margin-left: 10px;
    animation: glow 1.5s ease-in-out infinite alternate;
}

@keyframes glow {
    from { box-shadow: 0 0 5px #ff0000; }
    to { box-shadow: 0 0 20px #ff8c00; }
}
EOF

echo "✅ Security Panel CSS created!"

# Update layout untuk include CSS security
LAYOUT_PATH="/var/www/pterodactyl/resources/views/layouts/admin.blade.php"
if [ -f "$LAYOUT_PATH" ]; then
    if ! grep -q "security-panel.css" "$LAYOUT_PATH"; then
        sed -i '/<\/head>/i <link rel="stylesheet" href="{{ asset(\"/themes/pterodactyl/css/security-panel.css\") }}">' "$LAYOUT_PATH"
        echo "✅ Security CSS added to admin layout!"
    fi
fi

# Membuat view modified untuk nodes
NODES_VIEW_DIR="/var/www/pterodactyl/resources/views/admin/nodes/view"
mkdir -p "$NODES_VIEW_DIR"

# Index view dengan proteksi
cat > "$NODES_VIEW_DIR/index.blade.php" << 'EOF'
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
                @if(auth()->user()->id === 1)
                    <li><a href="{{ route('admin.nodes.view.settings', $node->id) }}">Settings</a></li>
                    <li><a href="{{ route('admin.nodes.view.configuration', $node->id) }}">Configuration</a></li>
                    <li><a href="{{ route('admin.nodes.view.allocation', $node->id) }}">Allocation</a></li>
                    <li><a href="{{ route('admin.nodes.view.servers', $node->id) }}">Servers</a></li>
                @else
                    <li class="access-denied"><a href="javascript:void(0)" onclick="alert('𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall')">Settings <span class="security-badge">LOCKED</span></a></li>
                    <li class="access-denied"><a href="javascript:void(0)" onclick="alert('𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall')">Configuration <span class="security-badge">LOCKED</span></a></li>
                    <li class="access-denied"><a href="javascript:void(0)" onclick="alert('𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall')">Allocation <span class="security-badge">LOCKED</span></a></li>
                    <li class="access-denied"><a href="javascript:void(0)" onclick="alert('𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall')">Servers <span class="security-badge">LOCKED</span></a></li>
                @endif
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
                    <a href="javascript:void(0)"><p>Usage</p><h4 data-toggle="tooltip" data-placement="top" title="{{ $node->memory_used }} / {{ $node->memory }} MB">{{ $node->memory_percent }}%</h4></a>
                </div>
                <div class="col-xs-6 col-md-3 text-center">
                    <a href="javascript:void(0)"><p>CPU</p><h4>0%</h4></a>
                </div>
                <div class="col-xs-6 col-md-3 text-center">
                    <a href="javascript:void(0)"><p>Disk</p><h4 data-toggle="tooltip" data-placement="top" title="{{ $node->disk_used }} / {{ $node->disk }} MB">{{ $node->disk_percent }}%</h4></a>
                </div>
            </div>
        </div>
        
        @if(auth()->user()->id === 1)
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title">Information</h3>
                </div>
                <div class="box-body">
                    <!-- Original content for admin -->
                    <div class="row">
                        <div class="col-sm-6">
                            <strong>Node Authorized:</strong> 
                            @if($node->scheme === 'https')
                                <code class="text-success"><i class="fa fa-lock"></i> https://{{ $node->fqdn }}:{{ $node->daemonListen }}/</code>
                            @else
                                <code class="text-warning"><i class="fa fa-unlock-alt"></i> http://{{ $node->fqdn }}:{{ $node->daemonListen }}/</code>
                            @endif
                        </div>
                    </div>
                </div>
            </div>
        @else
            <div class="security-shield">
                <h4><i class="fa fa-shield text-cyan"></i> Security Protected Area</h4>
                <p class="text-muted">This node is protected by advanced security measures. Only authorized administrators can access detailed information and settings.</p>
                <div class="alert alert-warning">
                    <i class="fa fa-warning"></i> <strong>Access Restricted:</strong> Your account does not have permission to view node details.
                </div>
            </div>
        @endif
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
            </div>
        </div>
    </div>
</div>
@endsection

@section('footer-scripts')
    @parent
    <script>
        $(document).ready(function() {
            $('[data-toggle="tooltip"]').tooltip();
            
            // Security protection for unauthorized access attempts
            $('.access-denied a').click(function(e) {
                e.preventDefault();
                Swal.fire({
                    icon: 'error',
                    title: 'Access Denied',
                    html: '<div style="color: #ff6b6b; font-weight: bold; font-size: 16px;">𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall</div>',
                    confirmButtonColor: '#ff3860',
                    background: '#1a1a2e',
                    customClass: {
                        popup: 'security-shield'
                    }
                });
            });
        });
    </script>
    
    <style>
        .access-denied a {
            background: linear-gradient(45deg, #ff3860, #ff7860) !important;
            color: white !important;
            cursor: not-allowed;
        }
        
        .access-denied a:hover {
            background: linear-gradient(45deg, #ff0033, #ff5555) !important;
            transform: scale(1.05);
            transition: all 0.3s ease;
        }
    </style>
EOF

echo "✅ Modified node view created!"

echo "🎉 Proteksi Admin Nodes Security Panel berhasil dipasang!"
echo "📂 File utama: $REMOTE_PATH"
echo "🎨 CSS Effects: $SECURITY_CSS_PATH"
echo "👁️ Modified View: $NODES_VIEW_DIR/index.blade.php"
echo "🔒 Hanya Admin ID 1 yang bisa akses semua tab nodes"
echo "🚫 Admin lain akan mendapat error 403 dengan pesan proteksi"
