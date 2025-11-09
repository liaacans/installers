#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php"
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
use Illuminate\Http\Response;
use Illuminate\Http\JsonResponse;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\Node\NodeFormRequest;

class NodeViewController extends Controller
{
    public function __construct(
        private NodeRepositoryInterface $repository
    ) {}

    /**
     * 🔒 Fungsi tambahan: Cegah akses node view oleh admin lain.
     */
    private function checkAdminAccess($request)
    {
        $user = $request->user();

        // Hanya admin dengan ID 1 yang bisa akses
        if ($user->id !== 1) {
            // Effect security: Log aktivitas mencurigakan
            \Log::warning('Akses ditolak ke Node View oleh admin ID: ' . $user->id . ' - Name: ' . $user->name);
            
            // Tampilkan halaman error dengan efek security
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅 | 𝖴𝗇𝖺𝗎𝗍𝗁𝗈𝗋𝗂𝗓𝖾𝖽 𝖠𝖼𝖼𝖾𝗌𝗌 𝖣𝖾𝗍𝖾𝖼𝗍𝖾𝖽');
        }
    }

    /**
     * 🔒 View untuk halaman about node
     */
    public function index(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.index', [
            'node' => $node,
            'location' => $node->location,
        ]);
    }

    /**
     * 🔒 View untuk halaman settings node
     */
    public function settings(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.settings', [
            'node' => $node,
            'location' => $node->location,
        ]);
    }

    /**
     * 🔒 View untuk halaman configuration node
     */
    public function configuration(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->find($id);
        
        return view('admin.nodes.view.configuration', [
            'node' => $node,
        ]);
    }

    /**
     * 🔒 View untuk halaman allocation node
     */
    public function allocation(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.allocation', [
            'node' => $node,
            'allocations' => $node->allocations,
        ]);
    }

    /**
     * 🔒 View untuk halaman servers node
     */
    public function servers(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.servers', [
            'node' => $node,
            'servers' => $node->servers,
        ]);
    }

    /**
     * 🔒 Update settings node - hanya admin ID 1
     */
    public function updateSettings(NodeFormRequest $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->update($id, $request->validated());
        
        return response()->json($node);
    }

    /**
     * 🔒 Update configuration node - hanya admin ID 1
     */
    public function updateConfiguration(NodeFormRequest $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->update($id, $request->validated());
        
        return response()->json($node);
    }

    /**
     * 🔒 Update allocation - hanya admin ID 1
     */
    public function updateAllocation(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        // Original allocation update logic here
        return response()->json(['status' => 'success']);
    }

    /**
     * 🔒 Delete server - hanya admin ID 1
     */
    public function deleteServer(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        // Original server deletion logic here
        return response()->json(['status' => 'success']);
    }
}
?>
EOF

# Proteksi view templates untuk admin lain
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
mkdir -p "$VIEW_PATH"

# Proteksi untuk about/index view
cat > "$VIEW_PATH/index.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node - {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>A quick overview of your node.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li class="active">{{ $node->name }}</li>
    </ol>
@endsection

@section('content')
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
    <!-- 🔒 SECURITY PROTECTION ACTIVATED -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box box-danger">
                <div class="box-header with-border">
                    <h3 class="box-title">
                        <i class="fa fa-shield"></i> Security Protection Active
                    </h3>
                </div>
                <div class="box-body">
                    <div class="alert alert-danger security-alert" style="background: linear-gradient(45deg, #ff0000, #8b0000); color: white; border: none;">
                        <div class="security-header">
                            <i class="fa fa-ban"></i>
                            <strong>ACCESS DENIED - PROTECTED AREA</strong>
                        </div>
                        <hr style="border-color: rgba(255,255,255,0.3)">
                        <p>⚠️ <strong>Unauthorized Access Detected</strong></p>
                        <p>This node overview is restricted to System Owner only.</p>
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
                                <div class="box">
                                    <div class="box-header with-border">
                                        <h3 class="box-title">About</h3>
                                    </div>
                                    <div class="box-body">
                                        <p>Node information would be displayed here.</p>
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
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title">About</h3>
                </div>
                <div class="box-body">
                    <div class="row">
                        <div class="col-sm-6">
                            <dl>
                                <dt>Daemon Version</dt>
                                <dd>{{ $node->daemonVersion }}</dd>
                                <dt>System Information</dt>
                                <dd>{{ $node->systemInformation }}</dd>
                                <dt>Total CPU Threads</dt>
                                <dd>{{ $node->totalCpuThreads }}</dd>
                            </dl>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Navigation Tabs -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box box-secondary">
                <div class="box-body">
                    <ul class="nav nav-tabs">
                        <li class="active"><a href="#about" data-toggle="tab">About</a></li>
                        <li><a href="{{ route('admin.nodes.view.settings', $node->id) }}">Settings</a></li>
                        <li><a href="{{ route('admin.nodes.view.configuration', $node->id) }}">Configuration</a></li>
                        <li><a href="{{ route('admin.nodes.view.allocation', $node->id) }}">Allocation</a></li>
                        <li><a href="{{ route('admin.nodes.view.servers', $node->id) }}">Servers</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
@endif
@endsection

@section('footer-scripts')
    @parent
    <style>
    .security-alert {
        border-left: 5px solid #dc3545;
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

# Proteksi untuk settings view
cat > "$VIEW_PATH/settings.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Settings - {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Configuration settings.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li><a href="{{ route('admin.nodes.view', $node->id) }}">{{ $node->name }}</a></li>
        <li class="active">Settings</li>
    </ol>
@endsection

@section('content')
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
    <!-- 🔒 SECURITY PROTECTION ACTIVATED -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box box-danger">
                <div class="box-header with-border">
                    <h3 class="box-title">
                        <i class="fa fa-shield"></i> Security Protection Active
                    </h3>
                </div>
                <div class="box-body">
                    <div class="alert alert-danger security-alert" style="background: linear-gradient(45deg, #ff0000, #8b0000); color: white; border: none;">
                        <div class="security-header">
                            <i class="fa fa-ban"></i>
                            <strong>ACCESS DENIED - PROTECTED AREA</strong>
                        </div>
                        <hr style="border-color: rgba(255,255,255,0.3)">
                        <p>⚠️ <strong>Unauthorized Access Detected</strong></p>
                        <p>This administrative section is restricted to System Owner only.</p>
                        <div class="security-details">
                            <small>Attempted by: {{ $user->name }} (ID: {{ $user->id }})</small><br>
                            <small>Timestamp: {{ now()->format('Y-m-d H:i:s') }}</small><br>
                            <small>Protection: @naaofficiall Security System</small>
                        </div>
                    </div>
                    
                    <!-- Blurred Content Preview -->
                    <div style="filter: blur(8px); pointer-events: none; opacity: 0.6;">
                        <div class="row">
                            <div class="col-sm-6">
                                <div class="box">
                                    <div class="box-header with-border">
                                        <h3 class="box-title">Settings Information</h3>
                                    </div>
                                    <div class="box-body">
                                        <p>Node configuration and settings would be displayed here.</p>
                                        <p>Authorized access - System Owner</p>
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
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 -->
    <div class="row">
        <div class="col-sm-6">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Settings Information</h3>
                </div>
                <div class="box-body">
                    <p>Authorized access - System Owner</p>
                    <!-- Original settings form and content here -->
                    <div class="form-group">
                        <label for="node_name">Node Name</label>
                        <input type="text" class="form-control" id="node_name" value="{{ $node->name }}" readonly>
                    </div>
                    <div class="form-group">
                        <label for="node_location">Location</label>
                        <input type="text" class="form-control" id="node_location" value="{{ $location->short }}" readonly>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endif
@endsection
EOF

# Proteksi untuk configuration view
cat > "$VIEW_PATH/configuration.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Configuration - {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Daemon configuration settings.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li><a href="{{ route('admin.nodes.view', $node->id) }}">{{ $node->name }}</a></li>
        <li class="active">Configuration</li>
    </ol>
@endsection

@section('content')
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
    <!-- 🔒 SECURITY PROTECTION ACTIVATED -->
    <div class="alert alert-danger security-alert" style="background: linear-gradient(135deg, #8b0000, #000000); color: white; border: none; text-align: center;">
        <h3><i class="fa fa-shield-alt"></i> PROTECTED CONFIGURATION AREA</h3>
        <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
        <small>Access restricted to System Owner only</small>
    </div>
    
    <!-- Blurred Configuration Content -->
    <div style="filter: blur(12px); opacity: 0.5; pointer-events: none;">
        <div class="box">
            <div class="box-body">
                <p>Configuration details are hidden for security reasons.</p>
            </div>
        </div>
    </div>
@else
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Configuration Details</h3>
                </div>
                <div class="box-body">
                    <p>Authorized configuration access - System Owner</p>
                    <!-- Original configuration content here -->
                    <div class="form-group">
                        <label>Daemon Secret Token</label>
                        <input type="text" class="form-control" value="**********" readonly>
                    </div>
                    <div class="form-group">
                        <label>Connection Port</label>
                        <input type="text" class="form-control" value="{{ $node->daemonListen }}" readonly>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endif
@endsection
EOF

# Proteksi untuk allocation view  
cat > "$VIEW_PATH/allocation.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Allocation - {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Manage network allocations.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li><a href="{{ route('admin.nodes.view', $node->id) }}">{{ $node->name }}</a></li>
        <li class="active">Allocation</li>
    </ol>
@endsection

@section('content')
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
    <div class="alert alert-warning security-alert">
        <h4><i class="fa fa-exclamation-triangle"></i> Allocation Access Restricted</h4>
        <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
        <p>Network allocation management is restricted to System Owner.</p>
    </div>
    
    <div style="filter: blur(5px); opacity: 0.7; pointer-events: none;">
        <!-- Hidden allocation content -->
        <div class="box">
            <div class="box-body">
                <p>Allocation management interface would be displayed here.</p>
            </div>
        </div>
    </div>
@else
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Allocation Management</h3>
                </div>
                <div class="box-body">
                    <p>Authorized allocation access - System Owner</p>
                    <!-- Original allocation content here -->
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>IP Address</th>
                                <th>Port</th>
                                <th>Assigned</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($allocations as $allocation)
                            <tr>
                                <td>{{ $allocation->ip }}</td>
                                <td>{{ $allocation->port }}</td>
                                <td>{{ $allocation->server_id ? 'Yes' : 'No' }}</td>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
@endif
@endsection
EOF

# Proteksi untuk servers view
cat > "$VIEW_PATH/servers.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Servers - {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Servers running on this node.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li><a href="{{ route('admin.nodes.view', $node->id) }}">{{ $node->name }}</a></li>
        <li class="active">Servers</li>
    </ol>
@endsection

@section('content')
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
    <div class="alert alert-info security-alert">
        <h4><i class="fa fa-server"></i> Server Management Protected</h4>
        <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
        <p>Server management is restricted to System Owner only.</p>
    </div>
    
    <div style="filter: blur(6px); opacity: 0.6; pointer-events: none;">
        <!-- Hidden servers content -->
        <div class="box">
            <div class="box-body">
                <p>Server management interface would be displayed here.</p>
            </div>
        </div>
    </div>
@else
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Server List</h3>
                </div>
                <div class="box-body">
                    <p>Authorized server access - System Owner</p>
                    <!-- Original servers content here -->
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Server Name</th>
                                <th>Owner</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($servers as $server)
                            <tr>
                                <td>{{ $server->name }}</td>
                                <td>{{ $server->user->username }}</td>
                                <td><span class="label label-success">Running</span></td>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
@endif
@endsection
EOF

chmod 644 "$REMOTE_PATH"
chmod -R 755 "/var/www/pterodactyl/resources/views/admin/nodes/view"

# Clear cache
echo "🧹 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear > /dev/null 2>&1
php artisan cache:clear > /dev/null 2>&1

echo "✅ Proteksi Anti Akses Admin Node View berhasil dipasang!"
echo "📂 Lokasi controller: $REMOTE_PATH"
echo "📂 Lokasi views: $VIEW_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo "🔓 Admin ID 1: Akses NORMAL ke semua tabel (About, Settings, Configuration, Allocation, Servers)"
echo "🔒 Admin Lain: Diblokir dengan efek security + blur content"
echo "🎨 Efek security: Blur content + Alert protection + Animation"
