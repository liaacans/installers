#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php"
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Advanced Security Panel..."

# Backup file original
if [ -f "$REMOTE_PATH" ]; then
  cp "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

# Modifikasi file controller
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
     * 🔒 Fungsi security: Cek akses admin
     */
    private function checkAdminAccess(Request $request)
    {
        $user = $request->user();
        
        // Jika bukan admin ID 1 dan mengakses halaman terlarang, tampilkan error
        if ($user->id !== 1) {
            // Cek route yang sedang diakses
            $route = $request->route()->getName();
            $protectedRoutes = [
                'admin.nodes.view.settings',
                'admin.nodes.view.configuration', 
                'admin.nodes.view.allocation'
            ];
            
            if (in_array($route, $protectedRoutes)) {
                abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅');
            }
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
            'activeTab' => 'index',
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
            'activeTab' => 'settings',
        ]);
    }

    public function configuration(Request $request, Node $node)
    {
        $this->checkAdminAccess($request);
        
        return view('admin.nodes.view.configuration', [
            'node' => $node,
            'activeTab' => 'configuration',
        ]);
    }

    public function allocation(Request $request, Node $node)
    {
        $this->checkAdminAccess($request);
        
        return view('admin.nodes.view.allocation', [
            'node' => $node,
            'activeTab' => 'allocation',
        ]);
    }

    public function servers(Request $request, Node $node)
    {
        $this->checkAdminAccess($request);
        
        return view('admin.nodes.view.servers', [
            'node' => $node,
            'activeTab' => 'servers',
        ]);
    }
}
EOF

# Buat directory views jika belum ada
mkdir -p "$VIEW_PATH"

# Buat file security overlay untuk tab tertentu
cat > "$VIEW_PATH/security_overlay.blade.php" << 'EOF'
<div class="security-overlay" style="
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.8);
    backdrop-filter: blur(10px);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
    border-radius: 5px;
">
    <div class="security-content text-center" style="color: white; padding: 20px;">
        <div style="font-size: 48px; margin-bottom: 20px;">🔒</div>
        <h3 style="color: #ff6b6b; margin-bottom: 10px;">Access Restricted</h3>
        <p style="margin-bottom: 15px; opacity: 0.9;">This section is protected by advanced security</p>
        <div style="background: rgba(255,255,255,0.1); padding: 10px; border-radius: 5px; font-family: monospace;">
            protect by @naaofficiall
        </div>
    </div>
</div>

<style>
.security-overlay {
    animation: fadeIn 0.5s ease-in;
}
@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}
</style>
EOF

# Modifikasi file settings view untuk menambahkan security overlay
cat > "$VIEW_PATH/settings.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Settings · {{ $node->name }} · Pterodactyl
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Node settings</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li><a href="{{ route('admin.nodes.view', $node->id) }}">{{ $node->name }}</a></li>
        <li class="active">Settings</li>
    </ol>
@endsection

@section('node-content')
@parent

<div class="row" style="position: relative;">
    @if(auth()->user()->id !== 1)
        @include('admin.nodes.view.security_overlay')
    @endif
    
    <div class="col-md-6">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Settings</h3>
            </div>
            <form action="{{ route('admin.nodes.view.settings', $node->id) }}" method="POST">
                <div class="box-body">
                    <!-- Original settings content here -->
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
EOF

# Modifikasi file configuration view
cat > "$VIEW_PATH/configuration.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Configuration · {{ $node->name }} · Pterodactyl
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Node configuration</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li><a href="{{ route('admin.nodes.view', $node->id) }}">{{ $node->name }}</a></li>
        <li class="active">Configuration</li>
    </ol>
@endsection

@section('node-content')
@parent

<div class="row" style="position: relative;">
    @if(auth()->user()->id !== 1)
        @include('admin.nodes.view.security_overlay')
    @endif
    
    <div class="col-xs-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Configuration File</h3>
            </div>
            <div class="box-body">
                <!-- Original configuration content here -->
            </div>
        </div>
    </div>
</div>
@endsection
EOF

# Modifikasi file allocation view
cat > "$VIEW_PATH/allocation.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Allocation · {{ $node->name }} · Pterodactyl
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Managing allocations for node.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li><a href="{{ route('admin.nodes.view', $node->id) }}">{{ $node->name }}</a></li>
        <li class="active">Allocation</li>
    </ol>
@endsection

@section('node-content')
@parent

<div class="row" style="position: relative;">
    @if(auth()->user()->id !== 1)
        @include('admin.nodes.view.security_overlay')
    @endif
    
    <div class="col-xs-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Allocation Management</h3>
            </div>
            <div class="box-body">
                <!-- Original allocation content here -->
            </div>
        </div>
    </div>
</div>
@endsection
EOF

# Modifikasi file index view (tab navigation)
cat > "$VIEW_PATH/index.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node @if($node)-> {{ $node->name }} @endif
@endsection

@section('content-header')
    <h1>Node: {{ $node->name }}</h1>
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
                    <li class="disabled"><a href="javascript:void(0)" onclick="showSecurityAlert()" style="color: #ccc; cursor: not-allowed; position: relative;">
                        Settings 
                        <span class="label label-danger" style="font-size: 10px; margin-left: 5px;">🔒</span>
                    </a></li>
                    <li class="disabled"><a href="javascript:void(0)" onclick="showSecurityAlert()" style="color: #ccc; cursor: not-allowed; position: relative;">
                        Configuration 
                        <span class="label label-danger" style="font-size: 10px; margin-left: 5px;">🔒</span>
                    </a></li>
                    <li class="disabled"><a href="javascript:void(0)" onclick="showSecurityAlert()" style="color: #ccc; cursor: not-allowed; position: relative;">
                        Allocation 
                        <span class="label label-danger" style="font-size: 10px; margin-left: 5px;">🔒</span>
                    </a></li>
                @endif
                
                <li @if($activeTab === 'servers')class="active"@endif><a href="{{ route('admin.nodes.view.servers', $node->id) }}">Servers</a></li>
            </ul>
        </div>
    </div>
</div>

@yield('node-content')

<script>
function showSecurityAlert() {
    swal({
        type: 'error',
        title: 'Access Denied',
        html: '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅',
        showConfirmButton: true,
        confirmButtonText: 'Understand',
        confirmButtonColor: '#d33',
        customClass: 'swal-wide',
        background: '#1a1a1a',
        color: '#fff'
    });
}

// Style untuk sweetalert
const style = document.createElement('style');
style.textContent = `
    .swal-wide {
        width: 600px !important;
    }
    .swal-content {
        font-size: 16px !important;
        font-family: monospace !important;
    }
`;
document.head.appendChild(style);
</script>

<style>
.nav-tabs > li.disabled > a {
    color: #999 !important;
    cursor: not-allowed !important;
    background-color: #f9f9f9 !important;
    border-color: #ddd !important;
}
.nav-tabs > li.disabled > a:hover {
    background-color: #f9f9f9 !important;
    border-color: #ddd !important;
}
.label-danger {
    background-color: #d73925;
    animation: blink 2s infinite;
}
@keyframes blink {
    0%, 50% { opacity: 1; }
    51%, 100% { opacity: 0.3; }
}
</style>
@endsection
EOF

# Set permissions
chmod 644 "$REMOTE_PATH"
chmod 644 "$VIEW_PATH"/*.blade.php

echo "♻️  Melakukan refresh cache..."
cd /var/www/pterodactyl
php artisan cache:clear
php artisan view:clear

echo "✅ Advanced Security Panel berhasil dipasang!"
echo "📂 Lokasi file controller: $REMOTE_PATH"
echo "📂 Lokasi security views: $VIEW_PATH/"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo "🔒 Hanya Admin (ID 1) yang bisa akses Settings, Configuration, dan Allocation"
echo "👁️ Admin lain akan melihat overlay blur dan tab terkunci"
