#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti Akses Admin Node View..."

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
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;
use Pterodactyl\Models\Node;

class NodesController extends Controller
{
    public function __construct(
        private NodeRepositoryInterface $repository
    ) {}

    /**
     * 🔒 Fungsi tambahan: Cegah akses node view oleh admin lain.
     */
    private function checkAdminAccess()
    {
        $user = request()->user();

        // Hanya admin dengan ID 1 yang bisa akses semua node
        if ($user->id !== 1) {
            \Log::warning('Akses ditolak ke Node Management oleh admin ID: ' . $user->id . ' - Name: ' . $user->name);
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅');
        }
    }

    /**
     * 🔒 View index nodes
     */
    public function index()
    {
        $this->checkAdminAccess();
        
        return view('admin.nodes.index', [
            'nodes' => $this->repository->all(),
        ]);
    }

    /**
     * 🔒 View single node
     */
    public function view(Request $request, $id)
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view', [
            'node' => $node,
            'location' => $node->location,
        ]);
    }

    /**
     * 🔒 About tab - hanya admin ID 1
     */
    public function about($id)
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return response()->json([
            'node' => $node,
            'resources' => $node->getResourceUsage(),
        ]);
    }

    /**
     * 🔒 Settings tab - hanya admin ID 1
     */
    public function settings($id)
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->find($id);
        
        return view('admin.nodes.view.settings', [
            'node' => $node,
            'location' => $node->location,
        ]);
    }

    /**
     * 🔒 Configuration tab - hanya admin ID 1
     */
    public function configuration($id)
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->find($id);
        
        return view('admin.nodes.view.configuration', [
            'node' => $node,
        ]);
    }

    /**
     * 🔒 Allocation tab - hanya admin ID 1
     */
    public function allocation($id)
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.allocation', [
            'node' => $node,
            'allocations' => $node->allocations,
        ]);
    }

    /**
     * 🔒 Servers tab - hanya admin ID 1
     */
    public function servers($id)
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.servers', [
            'node' => $node,
            'servers' => $node->servers,
        ]);
    }
}
?>
EOF

# Proteksi view templates
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes"
mkdir -p "$VIEW_PATH/view"

# Proteksi untuk main view (tabs: about, settings, configuration, allocation, servers)
cat > "$VIEW_PATH/view/index.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node @isset($node) - {{ $node->name }} @endisset
@endsection

@section('content-header')
    @isset($node)
        <h1>{{ $node->name }}<small>Viewing associated servers and resources.</small></h1>
        <ol class="breadcrumb">
            <li><a href="{{ route('admin.index') }}">Admin</a></li>
            <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
            <li class="active">{{ $node->name }}</li>
        </ol>
    @endisset
@endsection

@section('content')
@php
    $user = Auth::user();
@endphp

@isset($node)
<div class="row">
    <div class="col-xs-12">
        <div class="nav-tabs-custom nav-tabs-floating">
            <ul class="nav nav-tabs">
                <!-- 🔒 Semua tabs diproteksi -->
                <li @if($active === 'index') class="active" @endif>
                    @if($user->id === 1)
                        <a href="{{ route('admin.nodes.view', $node->id) }}">About</a>
                    @else
                        <a href="javascript:void(0)" style="color: #ccc; cursor: not-allowed;">About 🔒</a>
                    @endif
                </li>
                
                <li @if($active === 'settings') class="active" @endif>
                    @if($user->id === 1)
                        <a href="{{ route('admin.nodes.view.settings', $node->id) }}">Settings</a>
                    @else
                        <a href="javascript:void(0)" style="color: #ccc; cursor: not-allowed;">Settings 🔒</a>
                    @endif
                </li>
                
                <li @if($active === 'configuration') class="active" @endif>
                    @if($user->id === 1)
                        <a href="{{ route('admin.nodes.view.configuration', $node->id) }}">Configuration</a>
                    @else
                        <a href="javascript:void(0)" style="color: #ccc; cursor: not-allowed;">Configuration 🔒</a>
                    @endif
                </li>
                
                <li @if($active === 'allocation') class="active" @endif>
                    @if($user->id === 1)
                        <a href="{{ route('admin.nodes.view.allocation', $node->id) }}">Allocation</a>
                    @else
                        <a href="javascript:void(0)" style="color: #ccc; cursor: not-allowed;">Allocation 🔒</a>
                    @endif
                </li>
                
                <li @if($active === 'servers') class="active" @endif>
                    @if($user->id === 1)
                        <a href="{{ route('admin.nodes.view.servers', $node->id) }}">Servers</a>
                    @else
                        <a href="javascript:void(0)" style="color: #ccc; cursor: not-allowed;">Servers 🔒</a>
                    @endif
                </li>
            </ul>
        </div>
    </div>
</div>

@if($user->id !== 1)
    <!-- 🔒 TAMPILAN UNTUK ADMIN LAIN -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box box-danger">
                <div class="box-header with-border">
                    <h3 class="box-title">
                        <i class="fa fa-shield"></i> Node Management - Protected Area
                    </h3>
                </div>
                <div class="box-body">
                    <div class="alert alert-danger security-alert">
                        <div class="security-header">
                            <i class="fa fa-ban"></i>
                            <strong>ACCESS DENIED - PROTECTED NODE MANAGEMENT</strong>
                        </div>
                        <hr>
                        <p>⚠️ <strong>Unauthorized Access Detected</strong></p>
                        <p>Node management section is restricted to System Owner (Admin ID 1) only.</p>
                        <div class="security-details">
                            <small>Attempted by: {{ $user->name }} (ID: {{ $user->id }})</small><br>
                            <small>Timestamp: {{ now()->format('Y-m-d H:i:s') }}</small><br>
                            <small>Protection: @naaofficiall Security System</small>
                        </div>
                    </div>
                    
                    <!-- Blurred Content Preview -->
                    <div style="filter: blur(8px); pointer-events: none; opacity: 0.6;">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="info-box bg-blue">
                                    <span class="info-box-icon"><i class="fa fa-server"></i></span>
                                    <div class="info-box-content">
                                        <span class="info-box-text">Node</span>
                                        <span class="info-box-number">{{ $node->name }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@else
    <!-- 🔓 TAMPILAN NORMAL UNTUK ADMIN ID 1 -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Node Information - {{ $node->name }}</h3>
                </div>
                <div class="box-body">
                    <p>Welcome, System Owner! You have full access to this node management.</p>
                    
                    <div class="row">
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
                                    <span class="info-box-number">Online</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endif

@endisset
@endsection

@section('footer-scripts')
    @parent
    <style>
    .security-alert {
        border-left: 5px solid #dc3545;
        background: linear-gradient(135deg, #8b0000 0%, #000000 100%);
        color: white;
        animation: pulse 2s infinite;
    }
    .security-header {
        font-size: 1.2em;
        margin-bottom: 10px;
    }
    .security-details {
        margin-top: 15px;
        opacity: 0.9;
    }
    @keyframes pulse {
        0% { box-shadow: 0 0 0 0 rgba(220, 53, 69, 0.7); }
        70% { box-shadow: 0 0 0 10px rgba(220, 53, 69, 0); }
        100% { box-shadow: 0 0 0 0 rgba(220, 53, 69, 0); }
    }
    </style>
@endsection
EOF

# Buat route file untuk proteksi
ROUTES_PATH="/var/www/pterodactyl/routes/protected_nodes.php"

cat > "$ROUTES_PATH" << 'EOF'
<?php

use Illuminate\Support\Facades\Route;
use Pterodactyl\Http\Controllers\Admin\NodesController;

// 🔒 Protected Node Routes - Only for Admin ID 1
Route::group(['prefix' => '/admin/nodes', 'middleware' => ['web', 'auth']], function () {
    Route::get('/', [NodesController::class, 'index'])->name('admin.nodes');
    Route::get('/view/{id}', [NodesController::class, 'view'])->name('admin.nodes.view');
    Route::get('/view/{id}/1', [NodesController::class, 'about'])->name('admin.nodes.view.about');
    Route::get('/view/{id}/settings', [NodesController::class, 'settings'])->name('admin.nodes.view.settings');
    Route::get('/view/{id}/configuration', [NodesController::class, 'configuration'])->name('admin.nodes.view.configuration');
    Route::get('/view/{id}/allocation', [NodesController::class, 'allocation'])->name('admin.nodes.view.allocation');
    Route::get('/view/{id}/servers', [NodesController::class, 'servers'])->name('admin.nodes.view.servers');
});

EOF

chmod 644 "$REMOTE_PATH"
chmod 644 "$ROUTES_PATH"
chmod 644 "$VIEW_PATH/view/index.blade.php"

echo "✅ Proteksi Admin Node View berhasil dipasang!"
echo "📂 Lokasi controller: $REMOTE_PATH"
echo "📂 Lokasi view: $VIEW_PATH/view/index.blade.php"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo ""
echo "🔒 FITUR PROTEKSI:"
echo "   • Hanya Admin ID 1 bisa akses semua tabs (About, Settings, Configuration, Allocation, Servers)"
echo "   • Admin lain melihat tampilan terkunci dengan efek blur"
echo "   • Pesan error: 'akses ditolak protect by @naaofficiall'"
echo "   • Auto logging aktivitas mencurigakan"
echo ""
echo "🎯 STATUS: Admin ID 1 → Akses Normal | Admin Lain → Diblokir"
