#!/bin/bash

echo "🚀 Memasang proteksi Anti Akses Admin Node View..."

# Path utama
CONTROLLER_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${CONTROLLER_PATH}.bak_${TIMESTAMP}"

# Backup file controller jika ada
if [ -f "$CONTROLLER_PATH" ]; then
  cp "$CONTROLLER_PATH" "$BACKUP_PATH"
  echo "📦 Backup file controller dibuat di: $BACKUP_PATH"
fi

# Install controller yang diproteksi
cat > "$CONTROLLER_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\JsonResponse;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\Node\NodeFormRequest;

class NodeViewController extends Controller
{
    /**
     * NodeViewController constructor.
     */
    public function __construct(
        private NodeRepositoryInterface $repository
    ) {}

    /**
     * 🔒 Fungsi proteksi: Hanya admin ID 1 yang bisa akses
     */
    private function checkAdminAccess()
    {
        $user = auth()->user();
        
        if ($user->id !== 1) {
            \Log::warning('Akses ditolak ke Node View oleh admin: ' . $user->email . ' (ID: ' . $user->id . ')');
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅');
        }
    }

    /**
     * Returns the settings for a node.
     */
    public function settings(int $id): View
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.settings', [
            'node' => $node,
            'location' => $node->location,
        ]);
    }

    /**
     * Returns the configuration for a node.
     */
    public function configuration(int $id): View
    {
        $this->checkAdminAccess();
        
        return view('admin.nodes.view.configuration', [
            'node' => $this->repository->find($id),
        ]);
    }

    /**
     * Return the allocation management page for a node.
     */
    public function allocation(int $id): View
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.allocation', [
            'node' => $node,
            'allocations' => $node->allocations->sortBy('server_id')->groupBy('server_id'),
        ]);
    }

    /**
     * Return the servers management page for a node.
     */
    public function servers(int $id): View
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.servers', [
            'node' => $node,
            'servers' => $node->servers,
        ]);
    }

    /**
     * Update settings for a node.
     */
    public function updateSettings(NodeFormRequest $request, int $id): JsonResponse
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->update($id, $request->validated());
        
        return new JsonResponse($node);
    }

    /**
     * Update configuration for a node.
     */
    public function updateConfiguration(NodeFormRequest $request, int $id): JsonResponse
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->update($id, $request->validated());
        
        return new JsonResponse($node);
    }
}
EOF

# Install view files yang diproteksi
VIEWS_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
mkdir -p "$VIEWS_PATH"

# Settings View dengan Proteksi
cat > "$VIEWS_PATH/settings.blade.php" << 'EOF'
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
<div class="row">
    <div class="col-xs-12">
        <div class="box box-danger">
            <div class="box-header with-border">
                <h3 class="box-title"><i class="fa fa-ban"></i> Access Denied</h3>
            </div>
            <div class="box-body">
                <div class="alert alert-danger security-alert">
                    <h4><i class="fa fa-shield-alt"></i> Security Protection Active</h4>
                    <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
                    <p>This administrative section is restricted to System Owner only.</p>
                    <hr>
                    <small>
                        Attempted by: {{ $user->name }} (ID: {{ $user->id }})<br>
                        Timestamp: {{ now()->format('Y-m-d H:i:s') }}
                    </small>
                </div>
                
                <!-- Blurred Content Preview -->
                <div style="filter: blur(5px); opacity: 0.6; pointer-events: none;">
                    <div class="row">
                        <div class="col-sm-6">
                            <div class="box box-primary">
                                <div class="box-header with-border">
                                    <h3 class="box-title">Settings Information</h3>
                                </div>
                                <div class="box-body">
                                    <div class="form-group">
                                        <label for="name" class="control-label">Node Name</label>
                                        <div>
                                            <input type="text" class="form-control" value="{{ $node->name }}" readonly>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label for="description" class="control-label">Description</label>
                                        <div>
                                            <textarea class="form-control" rows="3" readonly>Node description here</textarea>
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
</div>
@else
<!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 -->
<div class="row">
    <div class="col-sm-6">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Settings Information</h3>
            </div>
            <div class="box-body">
                <div class="form-group">
                    <label for="name" class="control-label">Node Name <span class="field-required"></span></label>
                    <div>
                        <input type="text" id="name" name="name" class="form-control" value="{{ old('name', $node->name) }}" />
                        <p class="text-muted small">A short identifier used to distinguish this node from others. Must be between 1 and 100 characters.</p>
                    </div>
                </div>
                <div class="form-group">
                    <label for="description" class="control-label">Description</label>
                    <div>
                        <textarea id="description" name="description" class="form-control" rows="4">{{ old('description', $node->description) }}</textarea>
                    </div>
                </div>
                <div class="form-group">
                    <label for="location_id" class="control-label">Location <span class="field-required"></span></label>
                    <div>
                        <select name="location_id" id="location_id" class="form-control">
                            @foreach($locations as $location)
                                <option value="{{ $location->id }}" {{ $node->location_id !== $location->id ?: 'selected' }}>{{ $location->short }}</option>
                            @endforeach
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label for="public" class="control-label">Visibility</label>
                    <div>
                        <div class="radio radio-success radio-inline">
                            <input type="radio" id="public_1" value="1" name="public" {{ $node->public ? 'checked' : '' }}>
                            <label for="public_1">Public</label>
                        </div>
                        <div class="radio radio-danger radio-inline">
                            <input type="radio" id="public_0" value="0" name="public" {{ !$node->public ? 'checked' : '' }}>
                            <label for="public_0">Private</label>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <label for="fqdn" class="control-label">FQDN <span class="field-required"></span></label>
                    <div>
                        <input type="text" id="fqdn" name="fqdn" class="form-control" value="{{ old('fqdn', $node->fqdn) }}" />
                        <p class="text-muted small">Please enter the domain name (e.g <code>node.example.com</code>) that will be used to connect to the daemon. An IP address may only be used if you are not using SSL for this node.</p>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><span class="label label-warning"><i class="fa fa-warning"></i></span> Communicate over SSL</label>
                    <div>
                        <div class="checkbox checkbox-success no-margin-bottom">
                            <input type="checkbox" id="scheme" name="scheme" value="https" {{ $node->scheme === 'https' ? 'checked' : '' }} />
                            <label for="scheme">Use SSL connection</label>
                            <p class="text-muted small">For most cases, this should be enabled. However, if you are using an IP address or do not have SSL setup on your node, this should be disabled.</p>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><span class="label label-warning"><i class="fa fa-warning"></i></span> Behind Proxy</label>
                    <div>
                        <div class="checkbox checkbox-success no-margin-bottom">
                            <input type="checkbox" id="behind_proxy" name="behind_proxy" {{ $node->behind_proxy ? 'checked' : '' }} />
                            <label for="behind_proxy">This node is behind a proxy</label>
                            <p class="text-muted small">Only check this if you are running the node behind a proxy such as Cloudflare. If you are unsure, leave this unchecked.</p>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><span class="label label-warning"><i class="fa fa-warning"></i></span> Maintenance Mode</label>
                    <div>
                        <div class="checkbox checkbox-warning no-margin-bottom">
                            <input type="checkbox" id="maintenance_mode" name="maintenance_mode" {{ $node->maintenance_mode ? 'checked' : '' }} />
                            <label for="maintenance_mode">Enable maintenance mode</label>
                            <p class="text-muted small">If enabled, no new servers can be deployed to this node and all current servers will be inaccessible until disabled.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-sm-6">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Configuration</h3>
            </div>
            <div class="box-body">
                <div class="form-group">
                    <label for="memory" class="control-label">Total Memory</label>
                    <div>
                        <div class="input-group">
                            <input type="text" id="memory" name="memory" class="form-control" value="{{ old('memory', $node->memory) }}" data-multiplicator="true" />
                            <span class="input-group-addon">MB</span>
                        </div>
                        <p class="text-muted small">The total amount of memory available for new servers.</p>
                    </div>
                </div>
                <div class="form-group">
                    <label for="memory_overallocate" class="control-label">Memory Over-allocation</label>
                    <div>
                        <div class="input-group">
                            <input type="text" id="memory_overallocate" name="memory_overallocate" class="form-control" value="{{ old('memory_overallocate', $node->memory_overallocate) }}" />
                            <span class="input-group-addon">%</span>
                        </div>
                        <p class="text-muted small">Enter the percentage of allowed memory over-allocation. To disable the over-allocation checks, enter <code>-1</code> into the field. Entering <code>0</code> will deny creating new servers if the node is at its limit.</p>
                    </div>
                </div>
                <div class="form-group">
                    <label for="disk" class="control-label">Total Disk Space</label>
                    <div>
                        <div class="input-group">
                            <input type="text" id="disk" name="disk" class="form-control" value="{{ old('disk', $node->disk) }}" data-multiplicator="true" />
                            <span class="input-group-addon">MB</span>
                        </div>
                        <p class="text-muted small">The total amount of disk space available for new servers.</p>
                    </div>
                </div>
                <div class="form-group">
                    <label for="disk_overallocate" class="control-label">Disk Space Over-allocation</label>
                    <div>
                        <div class="input-group">
                            <input type="text" id="disk_overallocate" name="disk_overallocate" class="form-control" value="{{ old('disk_overallocate', $node->disk_overallocate) }}" />
                            <span class="input-group-addon">%</span>
                        </div>
                        <p class="text-muted small">Enter the percentage of allowed disk space over-allocation. To disable the over-allocation checks, enter <code>-1</code> into the field. Entering <code>0</code> will deny creating new servers if the node is at its limit.</p>
                    </div>
                </div>
                <div class="form-group">
                    <label for="upload_size" class="control-label">Maximum Upload Size</label>
                    <div>
                        <div class="input-group">
                            <input type="text" id="upload_size" name="upload_size" class="form-control" value="{{ old('upload_size', $node->upload_size) }}" data-multiplicator="true" />
                            <span class="input-group-addon">MB</span>
                        </div>
                        <p class="text-muted small">Enter the maximum size of files that can be uploaded through this node's file manager.</p>
                    </div>
                </div>
                <div class="form-group">
                    <label for="daemonListen" class="control-label">Daemon Port</label>
                    <div>
                        <input type="text" id="daemonListen" name="daemonListen" class="form-control" value="{{ old('daemonListen', $node->daemonListen) }}" />
                        <p class="text-muted small">The primary port that the daemon will listen on. Almost all servers will want to leave this as the default <code>8080</code>.</p>
                    </div>
                </div>
                <div class="form-group">
                    <label for="daemonSFTP" class="control-label">SFTP Port</label>
                    <div>
                        <input type="text" id="daemonSFTP" name="daemonSFTP" class="form-control" value="{{ old('daemonSFTP', $node->daemonSFTP) }}" />
                        <p class="text-muted small">The port that the standalone SFTP will listen on.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-xs-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Save Settings</h3>
            </div>
            <div class="box-body">
                <p class="text-muted no-margin">Any changes made to settings on this page will take effect immediately.</p>
            </div>
            <div class="box-footer">
                {!! csrf_field() !!}
                <input type="submit" class="btn btn-primary btn-sm" value="Update Settings" />
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
        background: linear-gradient(45deg, #8b0000, #dc3545);
        color: white;
        border: none;
        border-left: 5px solid #ff0000;
        animation: pulse 2s infinite;
    }
    @keyframes pulse {
        0% { box-shadow: 0 0 0 0 rgba(220, 53, 69, 0.7); }
        70% { box-shadow: 0 0 0 10px rgba(220, 53, 69, 0); }
        100% { box-shadow: 0 0 0 0 rgba(220, 53, 69, 0); }
    }
    </style>
@endsection
EOF

# Configuration View dengan Proteksi
cat > "$VIEWS_PATH/configuration.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Configuration - {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Configure and deploy services.</small></h1>
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
<div class="row">
    <div class="col-xs-12">
        <div class="box box-danger">
            <div class="box-body text-center">
                <div class="alert alert-danger security-alert">
                    <h3><i class="fa fa-shield-alt"></i> PROTECTED CONFIGURATION</h3>
                    <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
                    <p>Node configuration access is restricted to System Owner only</p>
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
                <h3 class="box-title">Configuration Files</h3>
            </div>
            <div class="box-body">
                <div class="form-group">
                    <label for="config_content" class="control-label">Configuration File</label>
                    <textarea id="config_content" class="form-control" rows="20" readonly>{{ $node->getConfigurationAsJson() }}</textarea>
                    <p class="text-muted small">This file should be placed in your daemon's root directory (usually <code>/etc/pterodactyl</code>) as <code>config.yml</code>.</p>
                </div>
            </div>
            <div class="box-footer">
                <a href="{{ route('admin.nodes.view.configuration.download', $node->id) }}" class="btn btn-sm btn-primary"><i class="fa fa-download"></i> Download Configuration</a>
            </div>
        </div>
    </div>
</div>
@endif
@endsection
EOF

# Allocation View dengan Proteksi  
cat > "$VIEWS_PATH/allocation.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Allocation - {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Manage port allocations.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li><a href="{{ route('admin.nodes.view', $node->id) }}">{{ $node->name }}</a></li>
        <li class="active">Allocations</li>
    </ol>
@endsection

@section('content')
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
<div class="row">
    <div class="col-xs-12">
        <div class="box box-warning">
            <div class="box-body text-center">
                <div class="alert alert-warning">
                    <h4><i class="fa fa-exclamation-triangle"></i> Allocation Access Restricted</h4>
                    <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
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
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($allocations as $serverAllocations)
                            @foreach($serverAllocations as $allocation)
                                <tr>
                                    <td>{{ $allocation->ip }}</td>
                                    <td>{{ $allocation->port }}</td>
                                    <td>
                                        @if($allocation->server)
                                            <a href="{{ route('admin.servers.view', $allocation->server_id) }}">{{ $allocation->server->name }}</a>
                                        @else
                                            <span class="label label-default">Not Assigned</span>
                                        @endif
                                    </td>
                                    <td>
                                        @if($allocation->notes)
                                            {{ $allocation->notes }}
                                        @else
                                            <span class="text-muted">—</span>
                                        @endif
                                    </td>
                                </tr>
                            @endforeach
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

# Servers View dengan Proteksi
cat > "$VIEWS_PATH/servers.blade.php" << 'EOF'
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
<div class="row">
    <div class="col-xs-12">
        <div class="box box-info">
            <div class="box-body text-center">
                <div class="alert alert-info">
                    <h4><i class="fa fa-server"></i> Server Management Protected</h4>
                    <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
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
                <h3 class="box-title">Managed Servers</h3>
            </div>
            <div class="box-body table-responsive no-padding">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Server Name</th>
                            <th>Owner</th>
                            <th>Memory</th>
                            <th>Disk</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($servers as $server)
                            <tr>
                                <td>
                                    <a href="{{ route('admin.servers.view', $server->id) }}">{{ $server->name }}</a>
                                </td>
                                <td>
                                    <a href="{{ route('admin.users.view', $server->owner_id) }}">{{ $server->user->username }}</a>
                                </td>
                                <td>{{ $server->memory }} MB</td>
                                <td>{{ $server->disk }} MB</td>
                                <td>
                                    @if($server->suspended)
                                        <span class="label label-warning">Suspended</span>
                                    @else
                                        <span class="label label-success">Active</span>
                                    @endif
                                </td>
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

# Set permissions
chmod 644 "$CONTROLLER_PATH"
chmod -R 755 "$VIEWS_PATH"

# Clear cache
echo "🧹 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear > /dev/null 2>&1
php artisan cache:clear > /dev/null 2>&1

echo "✅ Proteksi berhasil dipasang!"
echo "📂 Controller: $CONTROLLER_PATH"
echo "📂 Views: $VIEWS_PATH"
echo "🔒 Hanya Admin ID 1 yang bisa akses:"
echo "   • Settings"
echo "   • Configuration" 
echo "   • Allocation"
echo "   • Servers"
echo "🎨 Admin lain akan melihat pesan error dengan efek security"
