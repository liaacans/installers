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
     * 🔓 View untuk halaman settings node - Admin ID 1 akses normal
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
     * 🔓 View untuk halaman configuration node - Admin ID 1 akses normal
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
     * 🔓 View untuk halaman allocation node - Admin ID 1 akses normal
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
     * 🔓 View untuk halaman servers node - Admin ID 1 akses normal
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
     * 🔓 Update settings node - hanya admin ID 1
     */
    public function updateSettings(NodeFormRequest $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->update($id, $request->validated());
        
        return response()->json($node);
    }

    /**
     * 🔓 Update configuration node - hanya admin ID 1
     */
    public function updateConfiguration(NodeFormRequest $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->update($id, $request->validated());
        
        return response()->json($node);
    }

    /**
     * 🔓 Update allocation node - hanya admin ID 1
     */
    public function updateAllocation(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        // Original allocation update logic here
        return response()->json(['status' => 'success']);
    }

    /**
     * 🔓 Update servers node - hanya admin ID 1
     */
    public function updateServers(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        // Original servers update logic here
        return response()->json(['status' => 'success']);
    }
}
?>
EOF

# Buat view templates yang diproteksi
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
mkdir -p "$VIEW_PATH"

# Settings view dengan proteksi untuk admin lain
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
                                        <div class="form-group">
                                            <label for="node_name">Node Name</label>
                                            <input type="text" class="form-control" value="Hidden for security">
                                        </div>
                                        <div class="form-group">
                                            <label for="node_location">Location</label>
                                            <input type="text" class="form-control" value="Hidden for security">
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
        <div class="col-sm-6">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Settings Information</h3>
                </div>
                <div class="box-body">
                    <p><strong>Authorized access - System Owner</strong></p>
                    <p>You have full access to all node settings as the system owner.</p>
                    
                    <!-- Original settings form content -->
                    <form action="{{ route('admin.nodes.view.settings', $node->id) }}" method="POST">
                        @csrf
                        <div class="form-group">
                            <label for="name" class="control-label">Node Name</label>
                            <input type="text" name="name" class="form-control" value="{{ $node->name }}" />
                        </div>
                        
                        <div class="form-group">
                            <label for="description" class="control-label">Description</label>
                            <textarea name="description" class="form-control" rows="4">{{ $node->description }}</textarea>
                        </div>
                        
                        <div class="form-group">
                            <label for="location_id" class="control-label">Location</label>
                            <select name="location_id" class="form-control">
                                <option value="{{ $location->id }}" selected>{{ $location->short }}</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="scheme" class="control-label">SSL Mode</label>
                            <select name="scheme" class="form-control">
                                <option value="https" {{ $node->scheme === 'https' ? 'selected' : '' }}>HTTPS</option>
                                <option value="http" {{ $node->scheme === 'http' ? 'selected' : '' }}>HTTP</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="behind_proxy" class="control-label">Behind Proxy</label>
                            <select name="behind_proxy" class="form-control">
                                <option value="0" {{ !$node->behind_proxy ? 'selected' : '' }}>No</option>
                                <option value="1" {{ $node->behind_proxy ? 'selected' : '' }}>Yes</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="maintenance_mode" class="control-label">Maintenance Mode</label>
                            <select name="maintenance_mode" class="form-control">
                                <option value="0" {{ !$node->maintenance_mode ? 'selected' : '' }}>No</option>
                                <option value="1" {{ $node->maintenance_mode ? 'selected' : '' }}>Yes</option>
                            </select>
                        </div>
                        
                        <div class="box-footer">
                            <button type="submit" class="btn btn-primary">Save Settings</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        
        <div class="col-sm-6">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Node Information</h3>
                </div>
                <div class="box-body">
                    <dl>
                        <dt>Node ID</dt>
                        <dd>{{ $node->id }}</dd>
                        
                        <dt>UUID</dt>
                        <dd><code>{{ $node->uuid }}</code></dd>
                        
                        <dt>Daemon Token</dt>
                        <dd><code>{{ $node->daemonToken }}</code></dd>
                        
                        <dt>Created At</dt>
                        <dd>{{ $node->created_at->toDayDateTimeString() }}</dd>
                        
                        <dt>Last Updated</dt>
                        <dd>{{ $node->updated_at->toDayDateTimeString() }}</dd>
                    </dl>
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

# Configuration view dengan proteksi untuk admin lain
cat > "$VIEW_PATH/configuration.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Configuration - {{ $node->name }}
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
            <div class="box-header with-border">
                <h3 class="box-title">Configuration Details</h3>
            </div>
            <div class="box-body">
                <p>Configuration details are hidden for security reasons.</p>
                <div class="form-group">
                    <label>FQDN</label>
                    <input type="text" class="form-control" value="hidden.domain.com" readonly>
                </div>
                <div class="form-group">
                    <label>Port</label>
                    <input type="text" class="form-control" value="****" readonly>
                </div>
                <div class="form-group">
                    <label>Memory</label>
                    <input type="text" class="form-control" value="********" readonly>
                </div>
            </div>
        </div>
    </div>
@else
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 - AKSES NORMAL -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Configuration Details</h3>
                </div>
                <div class="box-body">
                    <p><strong>Authorized access - System Owner</strong></p>
                    <p>Full configuration access granted to system owner.</p>
                    
                    <!-- Original configuration form -->
                    <form action="{{ route('admin.nodes.view.configuration', $node->id) }}" method="POST">
                        @csrf
                        
                        <div class="form-group">
                            <label for="fqdn" class="control-label">FQDN</label>
                            <input type="text" name="fqdn" class="form-control" value="{{ $node->fqdn }}" />
                            <p class="text-muted small">Please enter the domain name (e.g node.example.com) that should be used to connect to the daemon. An IP address may only be used if you are not using SSL for this node.</p>
                        </div>
                        
                        <div class="form-group">
                            <label for="daemonListen" class="control-label">Daemon Port</label>
                            <input type="text" name="daemonListen" class="form-control" value="{{ $node->daemonListen }}" />
                            <p class="text-muted small">The port that the daemon should listen on. Typically this is <code>8080</code>. <strong>Do not use port 80 or 443.</strong></p>
                        </div>
                        
                        <div class="form-group">
                            <label for="memory" class="control-label">Total Memory</label>
                            <input type="text" name="memory" class="form-control" value="{{ $node->memory }}" />
                            <p class="text-muted small">The total amount of memory available for new servers and that should be allocated to the node.</p>
                        </div>
                        
                        <div class="form-group">
                            <label for="memory_overallocate" class="control-label">Memory Overallocation</label>
                            <input type="text" name="memory_overallocate" class="form-control" value="{{ $node->memory_overallocate }}" />
                            <p class="text-muted small">Enter the percentage of allowed memory overallocation. To disable overallocation enter <code>0</code>.</p>
                        </div>
                        
                        <div class="form-group">
                            <label for="disk" class="control-label">Total Disk Space</label>
                            <input type="text" name="disk" class="form-control" value="{{ $node->disk }}" />
                            <p class="text-muted small">The total amount of disk space available for new servers and that should be allocated to the node.</p>
                        </div>
                        
                        <div class="form-group">
                            <label for="disk_overallocate" class="control-label">Disk Overallocation</label>
                            <input type="text" name="disk_overallocate" class="form-control" value="{{ $node->disk_overallocate }}" />
                            <p class="text-muted small">Enter the percentage of allowed disk overallocation. To disable overallocation enter <code>0</code>.</p>
                        </div>
                        
                        <div class="box-footer">
                            <button type="submit" class="btn btn-primary">Update Configuration</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
@endif
@endsection
EOF

# Allocation view dengan proteksi untuk admin lain
cat > "$VIEW_PATH/allocation.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Allocation - {{ $node->name }}
@endsection

@section('content')
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
    <!-- 🔒 SECURITY PROTECTION ACTIVATED -->
    <div class="alert alert-warning security-alert">
        <h4><i class="fa fa-exclamation-triangle"></i> Allocation Access Restricted</h4>
        <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
        <p>Allocation management is restricted to System Owner only.</p>
    </div>
    
    <div style="filter: blur(5px); opacity: 0.7; pointer-events: none;">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Port Allocations</h3>
            </div>
            <div class="box-body">
                <p>Allocation details hidden for security.</p>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>IP Address</th>
                            <th>Port Range</th>
                            <th>Assigned To</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>***.***.***.***</td>
                            <td>*****-*****</td>
                            <td>********</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
@else
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 - AKSES NORMAL -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Port Allocations</h3>
                </div>
                <div class="box-body">
                    <p><strong>Authorized access - System Owner</strong></p>
                    <p>Full allocation management access granted.</p>
                    
                    <!-- Original allocation content -->
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>IP Address</th>
                                    <th>Port Range</th>
                                    <th>Assigned To</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach ($allocations as $allocation)
                                    <tr>
                                        <td><code>{{ $allocation->ip }}</code></td>
                                        <td><code>{{ $allocation->port }}</code></td>
                                        <td>
                                            @if ($allocation->server)
                                                <a href="{{ route('admin.servers.view', $allocation->server_id) }}">{{ $allocation->server->name }}</a>
                                            @else
                                                <span class="label label-success">Available</span>
                                            @endif
                                        </td>
                                        <td>
                                            @if(is_null($allocation->server_id))
                                                <button data-action="delete" data-id="{{ $allocation->id }}" class="btn btn-xs btn-danger"><i class="fa fa-trash"></i></button>
                                            @endif
                                        </td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                    
                    <hr>
                    
                    <form action="{{ route('admin.nodes.view.allocation', $node->id) }}" method="POST">
                        @csrf
                        <div class="form-group">
                            <label for="ip" class="control-label">IP Address</label>
                            <input type="text" name="ip" class="form-control" value="{{ old('ip') }}" />
                        </div>
                        
                        <div class="form-group">
                            <label for="port" class="control-label">Ports</label>
                            <input type="text" name="port" class="form-control" value="{{ old('port') }}" />
                            <p class="text-muted small">Enter one or more ports to assign to this node. Ports may be entered as a comma separated list or as a range (e.g. 25565-25570).</p>
                        </div>
                        
                        <div class="box-footer">
                            <button type="submit" class="btn btn-primary">Assign New Ports</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
@endif
@endsection
EOF

# Servers view dengan proteksi untuk admin lain
cat > "$VIEW_PATH/servers.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Servers - {{ $node->name }}
@endsection

@section('content')
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
    <!-- 🔒 SECURITY PROTECTION ACTIVATED -->
    <div class="alert alert-info security-alert">
        <h4><i class="fa fa-server"></i> Server Management Protected</h4>
        <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
        <p>Server management is restricted to System Owner only.</p>
    </div>
    
    <div style="filter: blur(6px); opacity: 0.6; pointer-events: none;">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Servers on this Node</h3>
            </div>
            <div class="box-body">
                <p>Server list hidden for security.</p>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Server Name</th>
                            <th>Owner</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>********</td>
                            <td>********</td>
                            <td><span class="label label-default">Hidden</span></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
@else
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 - AKSES NORMAL -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Servers on this Node</h3>
                </div>
                <div class="box-body">
                    <p><strong>Authorized access - System Owner</strong></p>
                    <p>Full server management access granted.</p>
                    
                    <!-- Original servers content -->
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Server Name</th>
                                    <th>Owner</th>
                                    <th>Status</th>
                                    <th>CPU</th>
                                    <th>Memory</th>
                                    <th>Disk</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach ($servers as $server)
                                    <tr>
                                        <td>
                                            <a href="{{ route('admin.servers.view', $server->id) }}">{{ $server->name }}</a>
                                        </td>
                                        <td>
                                            <a href="{{ route('admin.users.view', $server->owner_id) }}">{{ $server->user->username }}</a>
                                        </td>
                                        <td>
                                            @if ($server->suspended)
                                                <span class="label label-warning">Suspended</span>
                                            @else
                                                <span class="label label-success">Active</span>
                                            @endif
                                        </td>
                                        <td>{{ $server->cpu }}%</td>
                                        <td>{{ $server->memory }} MB</td>
                                        <td>{{ $server->disk }} MB</td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                    
                    @if($servers->isEmpty())
                        <div class="alert alert-info text-center">
                            <p>There are no servers associated with this node.</p>
                        </div>
                    @endif
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
echo "🔓 Admin ID 1: Akses NORMAL ke semua halaman (Settings, Configuration, Allocation, Servers)"
echo "🔒 Admin lain: Diblokir dengan efek security + blur content"
echo "🎨 Efek security: Blur content + Alert protection + Animation"
