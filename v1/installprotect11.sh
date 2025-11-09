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
}
?>
EOF

# Juga proteksi view templates untuk efek blur/proteksi
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
mkdir -p "$VIEW_PATH"

# Proteksi untuk settings view - HANYA ADMIN ID 1 BISA AKSES NORMAL
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
                            <div class="col-sm-12">
                                <div class="box">
                                    <div class="box-header with-border">
                                        <h3 class="box-title">Settings Information</h3>
                                    </div>
                                    <div class="box-body">
                                        <p>Node configuration and settings would be displayed here.</p>
                                        <div class="form-group">
                                            <label for="node_name">Node Name</label>
                                            <input type="text" class="form-control" value="{{ $node->name }}" readonly>
                                        </div>
                                        <div class="form-group">
                                            <label for="node_location">Location</label>
                                            <input type="text" class="form-control" value="{{ $node->location->short }}" readonly>
                                        </div>
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
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 - AKSES NORMAL -->
    <div class="row">
        <div class="col-sm-12">
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title">Settings Information</h3>
                </div>
                <div class="box-body">
                    <div class="alert alert-success">
                        <i class="fa fa-check-circle"></i> <strong>Authorized Access - System Owner</strong>
                        <p>You have full access to manage this node configuration.</p>
                    </div>
                    
                    <!-- Original Settings Form -->
                    <form action="{{ route('admin.nodes.view.settings', $node->id) }}" method="post">
                        @csrf
                        <div class="form-group">
                            <label for="name" class="control-label">Node Name</label>
                            <div>
                                <input type="text" name="name" value="{{ $node->name }}" class="form-control" />
                                <p class="text-muted small">Character limits: <code>a-zA-Z0-9_.-</code> and must not start or end with <code>_</code>, <code>-</code> or <code>.</code>.</p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="description" class="control-label">Description</label>
                            <div>
                                <textarea name="description" class="form-control" rows="4">{{ $node->description }}</textarea>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="location_id" class="control-label">Location</label>
                            <div>
                                <select name="location_id" class="form-control">
                                    <option value="{{ $node->location->id }}" selected>{{ $node->location->short }} ({{ $node->location->long }})</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="name" class="control-label">FQDN</label>
                            <div>
                                <input type="text" name="fqdn" value="{{ $node->fqdn }}" class="form-control" />
                                <p class="text-muted small">Please enter the domain name (e.g <code>node.example.com</code>) to be used for connecting to the daemon. An IP address may only be used if you are not using SSL for this node.</code>.</p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="scheme" class="control-label">Communication Scheme</label>
                            <div>
                                <select name="scheme" class="form-control">
                                    <option value="https" {{ $node->scheme === 'https' ? 'selected' : '' }}>HTTPS</option>
                                    <option value="http" {{ $node->scheme === 'http' ? 'selected' : '' }}>HTTP</option>
                                </select>
                                <p class="text-muted small">For most cases you should select HTTPS. If using SSL on your node, you should select HTTPS.</p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="behind_proxy" class="control-label">Behind Proxy</label>
                            <div>
                                <input type="checkbox" name="behind_proxy" value="1" {{ $node->behind_proxy ? 'checked' : '' }}> This node is running behind a proxy
                                <p class="text-muted small">If you are running the node behind a proxy such as Cloudflare, check this box.</p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="maintenance_mode" class="control-label">Maintenance Mode</label>
                            <div>
                                <input type="checkbox" name="maintenance_mode" value="1" {{ $node->maintenance_mode ? 'checked' : '' }}> Enable maintenance mode
                                <p class="text-muted small">If enabled, no servers can be scheduled on this node.</p>
                            </div>
                        </div>
                        
                        <div class="box-footer">
                            <button type="submit" class="btn btn-primary pull-right">Save Settings</button>
                        </div>
                    </form>
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

# Proteksi untuk configuration view - HANYA ADMIN ID 1 BISA AKSES NORMAL
cat > "$VIEW_PATH/configuration.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Configuration - {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Configure daemon connection settings.</small></h1>
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
    <div class="row">
        <div class="col-xs-12">
            <div class="alert alert-danger security-alert" style="background: linear-gradient(135deg, #8b0000, #000000); color: white; border: none; text-align: center;">
                <h3><i class="fa fa-shield-alt"></i> PROTECTED CONFIGURATION AREA</h3>
                <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
                <small>Access restricted to System Owner only</small>
                <div class="security-details">
                    <small>Attempted by: {{ $user->name }} (ID: {{ $user->id }})</small>
                </div>
            </div>
            
            <!-- Blurred Configuration Content -->
            <div style="filter: blur(12px); opacity: 0.5; pointer-events: none;">
                <div class="box">
                    <div class="box-header with-border">
                        <h3 class="box-title">Configuration Details</h3>
                    </div>
                    <div class="box-body">
                        <p>Configuration details are hidden for security reasons.</p>
                        <div class="form-group">
                            <label>Daemon SFTP Port</label>
                            <input type="text" class="form-control" value="2022" readonly>
                        </div>
                        <div class="form-group">
                            <label>Daemon Listen Port</label>
                            <input type="text" class="form-control" value="8080" readonly>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@else
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 - AKSES NORMAL -->
    <div class="row">
        <div class="col-sm-12">
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title">Configuration Details</h3>
                </div>
                <div class="box-body">
                    <div class="alert alert-success">
                        <i class="fa fa-check-circle"></i> <strong>Authorized Access - System Owner</strong>
                        <p>You have full access to configure this node.</p>
                    </div>
                    
                    <!-- Original Configuration Form -->
                    <form action="{{ route('admin.nodes.view.configuration', $node->id) }}" method="post">
                        @csrf
                        <div class="form-group">
                            <label for="daemonBase" class="control-label">Daemon Base Directory</label>
                            <div>
                                <input type="text" name="daemonBase" value="{{ $node->daemonBase }}" class="form-control" />
                                <p class="text-muted small">This should be the absolute path to the base directory of the Wings instance. Usually <code>/var/lib/pterodactyl/volumes</code> or <code>/srv/daemon-data</code>.</p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="memory" class="control-label">Total Memory</label>
                            <div>
                                <input type="text" name="memory" value="{{ $node->memory }}" class="form-control" />
                                <p class="text-muted small">Enter the total amount of RAM available for this node in megabytes.</p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="memory_overallocate" class="control-label">Memory Overallocation</label>
                            <div>
                                <input type="text" name="memory_overallocate" value="{{ $node->memory_overallocate }}" class="form-control" />
                                <p class="text-muted small">Enter the percentage of overallocated memory allowed. To disable checking, enter <code>-1</code>. To block overallocation entirely enter <code>0</code>.</p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="disk" class="control-label">Total Disk Space</label>
                            <div>
                                <input type="text" name="disk" value="{{ $node->disk }}" class="form-control" />
                                <p class="text-muted small">Enter the total amount of disk space available for this node in megabytes.</p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="disk_overallocate" class="control-label">Disk Overallocation</label>
                            <div>
                                <input type="text" name="disk_overallocate" value="{{ $node->disk_overallocate }}" class="form-control" />
                                <p class="text-muted small">Enter the percentage of overallocated disk space allowed. To disable checking, enter <code>-1</code>. To block overallocation entirely enter <code>0</code>.</p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="daemonListen" class="control-label">Daemon Port</label>
                            <div>
                                <input type="text" name="daemonListen" value="{{ $node->daemonListen }}" class="form-control" />
                                <p class="text-muted small">The port that the daemon should listen on. Usually <code>8080</code>.</p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="daemonSFTP" class="control-label">Daemon SFTP Port</label>
                            <div>
                                <input type="text" name="daemonSFTP" value="{{ $node->daemonSFTP }}" class="form-control" />
                                <p class="text-muted small">The port that the daemon SFTP server should listen on. Usually <code>2022</code>.</p>
                            </div>
                        </div>
                        
                        <div class="box-footer">
                            <button type="submit" class="btn btn-primary pull-right">Save Configuration</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
@endif
@endsection
EOF

# Proteksi untuk allocation view - HANYA ADMIN ID 1 BISA AKSES NORMAL  
cat > "$VIEW_PATH/allocation.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Allocation - {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Manage allocation availability.</small></h1>
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
    <!-- 🔒 SECURITY PROTECTION ACTIVATED -->
    <div class="row">
        <div class="col-xs-12">
            <div class="alert alert-warning security-alert">
                <h4><i class="fa fa-exclamation-triangle"></i> Allocation Access Restricted</h4>
                <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
                <small>Access restricted to System Owner only</small>
            </div>
            
            <div style="filter: blur(5px); opacity: 0.7; pointer-events: none;">
                <!-- Hidden allocation content -->
                <div class="box">
                    <div class="box-header with-border">
                        <h3 class="box-title">Allocation Management</h3>
                    </div>
                    <div class="box-body">
                        <p>Allocation management features are protected.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
@else
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 - AKSES NORMAL -->
    <div class="row">
        <div class="col-sm-12">
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title">Allocation Management</h3>
                </div>
                <div class="box-body">
                    <div class="alert alert-success">
                        <i class="fa fa-check-circle"></i> <strong>Authorized Access - System Owner</strong>
                        <p>You have full access to manage allocations.</p>
                    </div>
                    
                    <!-- Original Allocation Content -->
                    <div class="box">
                        <div class="box-header with-border">
                            <h3 class="box-title">Existing Allocations</h3>
                        </div>
                        <div class="box-body table-responsive no-padding">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>IP Address</th>
                                        <th>Port</th>
                                        <th>Assigned To</th>
                                        <th>Notes</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($allocations as $allocation)
                                    <tr>
                                        <td>{{ $allocation->ip }}</td>
                                        <td>{{ $allocation->port }}</td>
                                        <td>
                                            @if($allocation->server)
                                                <a href="{{ route('admin.servers.view', $allocation->server->id) }}">{{ $allocation->server->name }}</a>
                                            @else
                                                <span class="label label-success">Available</span>
                                            @endif
                                        </td>
                                        <td>{{ $allocation->notes }}</td>
                                        <td>
                                            @if(!$allocation->server)
                                            <button type="button" class="btn btn-xs btn-danger" data-action="delete-allocation" data-id="{{ $allocation->id }}">
                                                <i class="fa fa-trash"></i>
                                            </button>
                                            @endif
                                        </td>
                                    </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    </div>
                    
                    <!-- Add Allocation Form -->
                    <div class="box">
                        <div class="box-header with-border">
                            <h3 class="box-title">Add New Allocation</h3>
                        </div>
                        <div class="box-body">
                            <form action="{{ route('admin.nodes.view.allocation', $node->id) }}" method="post">
                                @csrf
                                <div class="form-group">
                                    <label for="ip" class="control-label">IP Address</label>
                                    <div>
                                        <input type="text" name="ip" class="form-control" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="port" class="control-label">Port Range</label>
                                    <div>
                                        <input type="text" name="port" class="form-control" placeholder="e.g. 25565-25570" />
                                    </div>
                                </div>
                                <div class="box-footer">
                                    <button type="submit" class="btn btn-primary">Add Allocations</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endif
@endsection
EOF

# Proteksi untuk servers view - HANYA ADMIN ID 1 BISA AKSES NORMAL
cat > "$VIEW_PATH/servers.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Servers - {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>All servers currently assigned to this node.</small></h1>
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
    <!-- 🔒 SECURITY PROTECTION ACTIVATED -->
    <div class="row">
        <div class="col-xs-12">
            <div class="alert alert-info security-alert">
                <h4><i class="fa fa-server"></i> Server Management Protected</h4>
                <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
                <small>Access restricted to System Owner only</small>
            </div>
            
            <div style="filter: blur(6px); opacity: 0.6; pointer-events: none;">
                <!-- Hidden servers content -->
                <div class="box">
                    <div class="box-header with-border">
                        <h3 class="box-title">Servers on this Node</h3>
                    </div>
                    <div class="box-body">
                        <p>Server management features are protected.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
@else
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 - AKSES NORMAL -->
    <div class="row">
        <div class="col-sm-12">
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title">Servers on this Node</h3>
                </div>
                <div class="box-body">
                    <div class="alert alert-success">
                        <i class="fa fa-check-circle"></i> <strong>Authorized Access - System Owner</strong>
                        <p>You have full access to manage servers on this node.</p>
                    </div>
                    
                    <!-- Original Servers Content -->
                    <div class="box">
                        <div class="box-body table-responsive no-padding">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Server Name</th>
                                        <th>Owner</th>
                                        <th>Status</th>
                                        <th>CPU</th>
                                        <th>Memory</th>
                                        <th>Disk</th>
                                        <th>Creation Date</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($servers as $server)
                                    <tr>
                                        <td>
                                            <a href="{{ route('admin.servers.view', $server->id) }}">{{ $server->name }}</a>
                                        </td>
                                        <td>
                                            <a href="{{ route('admin.users.view', $server->owner->id) }}">{{ $server->owner->username }}</a>
                                        </td>
                                        <td>
                                            @if($server->status === 'running')
                                                <span class="label label-success">Running</span>
                                            @elseif($server->status === 'offline')
                                                <span class="label label-danger">Offline</span>
                                            @else
                                                <span class="label label-default">{{ ucfirst($server->status) }}</span>
                                            @endif
                                        </td>
                                        <td>{{ $server->cpu }}%</td>
                                        <td>{{ $server->memory }}MB</td>
                                        <td>{{ $server->disk }}MB</td>
                                        <td>{{ $server->created_at->format('M j, Y') }}</td>
                                        <td>
                                            <a href="{{ route('admin.servers.view', $server->id) }}" class="btn btn-xs btn-primary">
                                                <i class="fa fa-wrench"></i>
                                            </a>
                                        </td>
                                    </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    </div>
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
php artisan view:clear 2>/dev/null || echo "⚠️ Gagal clear view cache"
php artisan cache:clear 2>/dev/null || echo "⚠️ Gagal clear cache"

echo "✅ Proteksi Anti Akses Admin Node View berhasil dipasang!"
echo "📂 Lokasi controller: $REMOTE_PATH"
echo "📂 Lokasi views: $VIEW_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo "🔓 HANYA Admin ID 1 yang bisa akses NORMAL ke Settings, Configuration, Allocation, dan Servers"
echo "🚫 Admin lain akan mendapatkan error 403 dengan efek security"
echo "🎨 Efek security: Blur content + Alert protection + Animation"
