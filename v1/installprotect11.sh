#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Advanced Security Panel..."

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
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Nodes\NodeUpdateService;
use Pterodactyl\Services\Nodes\NodeCreationService;
use Pterodactyl\Services\Nodes\NodeDeletionService;
use Pterodactyl\Http\Requests\Admin\Node\NodeFormRequest;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;

class NodeViewController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected NodeCreationService $creationService,
        protected NodeDeletionService $deletionService,
        protected NodeRepositoryInterface $repository,
        protected NodeUpdateService $updateService
    ) {}

    /**
     * 🔒 Fungsi security: Cegah akses node settings oleh non-admin
     */
    private function checkAdminAccess(Request $request)
    {
        $user = $request->user();

        // Hanya admin ID 1 yang bisa akses
        if ($user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅');
        }
    }

    public function index()
    {
        return redirect()->route('admin.nodes');
    }

    public function view(Request $request, Node $node)
    {
        $this->checkAdminAccess($request);
        
        return view('admin.nodes.view.index', [
            'node' => $node,
            'securityEnabled' => true
        ]);
    }

    public function update(NodeFormRequest $request, Node $node): RedirectResponse
    {
        $this->checkAdminAccess($request);
        
        $this->updateService->handle($node, $request->validated());
        $this->alert->success('Node settings were updated successfully.')->flash();

        return redirect()->route('admin.nodes.view.settings', $node->id);
    }

    public function settings(Request $request, Node $node)
    {
        $this->checkAdminAccess($request);
        
        return view('admin.nodes.view.settings', [
            'node' => $node,
            'securityEnabled' => true
        ]);
    }

    public function configuration(Request $request, Node $node)
    {
        $this->checkAdminAccess($request);
        
        return view('admin.nodes.view.configuration', [
            'node' => $node,
            'securityEnabled' => true
        ]);
    }

    public function allocation(Request $request, Node $node)
    {
        $this->checkAdminAccess($request);
        
        // Redirect atau tampilkan halaman kosong dengan security alert
        if ($request->user()->id !== 1) {
            return view('admin.nodes.view.security_alert', [
                'node' => $node,
                'message' => '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅'
            ]);
        }

        return view('admin.nodes.view.allocation', [
            'node' => $node,
            'securityEnabled' => true
        ]);
    }

    public function servers(Request $request, Node $node)
    {
        $this->checkAdminAccess($request);
        
        return view('admin.nodes.view.servers', [
            'node' => $node,
            'securityEnabled' => true
        ]);
    }
}
?>
EOF

# Juga modifikasi file view template untuk menambahkan efek security
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
mkdir -p "$VIEW_PATH"

# Buat file security alert view
cat > "$VIEW_PATH/security_alert.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Security Alert - @naaofficiall Protection
@endsection

@section('content-header')
    <h1>Security Alert 🔒<small>Protected by @naaofficiall</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li><a href="{{ route('admin.nodes.view', $node->id) }}">{{ $node->name }}</a></li>
        <li class="active">Security Alert</li>
    </ol>
@endsection

@section('content')
<div class="row">
    <div class="col-md-8 col-md-offset-2">
        <div class="box box-danger">
            <div class="box-header with-border">
                <h3 class="box-title">🚫 Access Denied</h3>
            </div>
            <div class="box-body">
                <div class="alert alert-danger" style="border-left: 5px solid #dd4b39;">
                    <h4><i class="icon fa fa-ban"></i> Security Protection Active!</h4>
                    <p>{{ $message ?? '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅' }}</p>
                </div>
                
                <div class="security-animation text-center">
                    <div class="spinner-border text-danger" role="status">
                        <span class="sr-only">Security Check...</span>
                    </div>
                    <h4 class="text-danger mt-3">🔐 Advanced Security Panel</h4>
                    <p class="text-muted">This area is restricted to authorized personnel only.</p>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.security-animation {
    padding: 30px 0;
}
.spinner-border {
    width: 3rem;
    height: 3rem;
}
.box-danger {
    border-top-color: #dd4b39;
    animation: pulse 2s infinite;
}
@keyframes pulse {
    0% { box-shadow: 0 0 0 0 rgba(221, 75, 57, 0.4); }
    70% { box-shadow: 0 0 0 10px rgba(221, 75, 57, 0); }
    100% { box-shadow: 0 0 0 0 rgba(221, 75, 57, 0); }
}
</style>
@endsection
EOF

# Modifikasi file index view untuk menambahkan security features
cat > "$VIEW_PATH/index.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node @if($node)-> {{ $node->name }} @endif
@endsection

@section('content-header')
    <div class="row">
        <div class="col-md-12">
            @if(($securityEnabled ?? false) && auth()->user()->id !== 1)
            <div class="callout callout-danger">
                <h4>🔒 Security Notice</h4>
                <p>Enhanced security protection is active on this node. Some features may be restricted.</p>
                <small>Protected by: @naaofficiall</small>
            </div>
            @endif
            
            <h1>Node: {{ $node->name }} 
                @if($securityEnabled ?? false)
                <small><span class="label label-success">🔐 Secured</span></small>
                @endif
            </h1>
        </div>
    </div>
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
                <li @if($activeTab === 'index')class="active"@endif><a href="{{ route('admin.nodes.view', $node->id) }}">About</a></li>
                
                @if(auth()->user()->id === 1)
                    <li @if($activeTab === 'settings')class="active"@endif><a href="{{ route('admin.nodes.view.settings', $node->id) }}">Settings</a></li>
                    <li @if($activeTab === 'configuration')class="active"@endif><a href="{{ route('admin.nodes.view.configuration', $node->id) }}">Configuration</a></li>
                    <li @if($activeTab === 'allocation')class="active"@endif><a href="{{ route('admin.nodes.view.allocation', $node->id) }}">Allocation</a></li>
                @else
                    <li class="disabled"><a href="javascript:void(0)" style="color: #ccc; cursor: not-allowed;">Settings 🔒</a></li>
                    <li class="disabled"><a href="javascript:void(0)" style="color: #ccc; cursor: not-allowed;">Configuration 🔒</a></li>
                    <li class="disabled"><a href="javascript:void(0)" style="color: #ccc; cursor: not-allowed;">Allocation 🔒</a></li>
                @endif
                
                <li @if($activeTab === 'servers')class="active"@endif><a href="{{ route('admin.nodes.view.servers', $node->id) }}">Servers</a></li>
            </ul>
        </div>
    </div>
</div>

@if(auth()->user()->id !== 1 && in_array($activeTab, ['settings', 'configuration', 'allocation']))
    @include('admin.nodes.view.security_alert', ['message' => '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅'])
@else
    @yield('node-content')
@endif

<style>
.nav-tabs > li.disabled > a {
    color: #999;
    cursor: not-allowed;
    background-color: #f5f5f5;
}
.callout {
    border-left-color: #d73925;
}
.label-success {
    background-color: #00a65a;
    animation: glow 2s ease-in-out infinite alternate;
}
@keyframes glow {
    from { box-shadow: 0 0 5px #00a65a; }
    to { box-shadow: 0 0 15px #00a65a; }
}
</style>
@endsection
EOF

chmod 644 "$REMOTE_PATH"
chmod 644 "$VIEW_PATH/security_alert.blade.php"
chmod 644 "$VIEW_PATH/index.blade.php"

echo "✅ Advanced Security Panel berhasil dipasang!"
echo "📂 Lokasi file controller: $REMOTE_PATH"
echo "📂 Lokasi security views: $VIEW_PATH/"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Hanya Admin (ID 1) yang bisa akses Settings, Configuration, dan Allocation"
echo "🚫 User lain akan melihat error 403 dengan pesan: 'akses ditolak, protect by @naaofficiall'"
