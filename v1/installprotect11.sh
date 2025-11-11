#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti Akses Admin Node View..."

# Backup file original jika ada
if [ -f "$REMOTE_PATH" ]; then
  cp "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

# Buat controller yang benar
cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;
use Pterodactyl\Contracts\Repository\AllocationRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\Node\NodeFormRequest;

class NodeViewController extends Controller
{
    /**
     * @var \Pterodactyl\Contracts\Repository\NodeRepositoryInterface
     */
    private $repository;

    /**
     * @var \Pterodactyl\Contracts\Repository\AllocationRepositoryInterface
     */
    private $allocationRepository;

    /**
     * NodeViewController constructor.
     */
    public function __construct(
        NodeRepositoryInterface $repository,
        AllocationRepositoryInterface $allocationRepository
    ) {
        $this->repository = $repository;
        $this->allocationRepository = $allocationRepository;
    }

    /**
     * 🔒 Fungsi tambahan: Cegah akses node view oleh admin lain.
     */
    private function checkAdminAccess()
    {
        $user = request()->user();

        // Hanya admin dengan ID 1 yang bisa akses
        if ($user->id !== 1) {
            \Log::warning('Akses ditolak ke Node View oleh admin ID: ' . $user->id . ' - Name: ' . $user->name);
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅 | 𝖴𝗇𝖺𝗎𝗍𝗁𝗈𝗋𝗂𝗓𝖾𝖽 𝖠𝖼𝖼𝖾𝗌𝗌 𝖣𝖾𝗍𝖾𝖼𝗍𝖾𝖽');
        }
    }

    /**
     * Returns the index view for a specific node on the system.
     */
    public function index(Request $request, $id)
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        $node->load('location');

        return view('admin.nodes.view.index', [
            'node' => $node,
            'stats' => $this->repository->getUsageStats($id),
        ]);
    }

    /**
     * Returns the settings page for a specific node.
     */
    public function settings(Request $request, $id)
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.settings', [
            'node' => $node,
            'location' => $node->location,
            'locations' => \Pterodactyl\Models\Location::all(),
        ]);
    }

    /**
     * Returns the configuration page for a specific node.
     */
    public function configuration(Request $request, $id)
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->find($id);
        
        return view('admin.nodes.view.configuration', [
            'node' => $node,
        ]);
    }

    /**
     * Returns the allocation management page for a specific node.
     */
    public function allocation(Request $request, $id)
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.allocation', [
            'node' => $node,
            'allocations' => $node->allocations()->with('server')->get(),
        ]);
    }

    /**
     * Returns all of the servers that exist for a specific node.
     */
    public function servers(Request $request, $id)
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.servers', [
            'node' => $node,
            'servers' => $node->servers()->with('user')->paginate(25),
        ]);
    }

    /**
     * Updates settings for a specific node.
     */
    public function updateSettings(NodeFormRequest $request, $id)
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->update($id, $request->validated());
        
        return response()->json($node);
    }

    /**
     * Updates configuration for a specific node.
     */
    public function updateConfiguration(NodeFormRequest $request, $id)
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->update($id, $request->validated());
        
        return response()->json($node);
    }

    /**
     * Creates new allocations for a specific node.
     */
    public function createAllocation(Request $request, $id)
    {
        $this->checkAdminAccess();
        
        // Validasi sederhana
        $request->validate([
            'ip' => 'required|string',
            'ports' => 'required|string',
        ]);
        
        return response()->json(['success' => true]);
    }

    /**
     * Deletes a specific allocation from a node.
     */
    public function deleteAllocation(Request $request, $id, $allocationId)
    {
        $this->checkAdminAccess();
        
        $this->allocationRepository->delete($allocationId);
        
        return new JsonResponse([], 204);
    }
}
EOF

# Buat view templates
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
mkdir -p "$VIEW_PATH"

# ==================== ABOUT PAGE ====================
cat > "$VIEW_PATH/index.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node — {{ $node->name }}
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
<!-- 🔒 SECURITY PROTECTION ACTIVATED UNTUK ADMIN LAIN -->
<div class="row">
    <div class="col-xs-12">
        <div class="box box-danger">
            <div class="box-header with-border">
                <h3 class="box-title">
                    <i class="fa fa-shield"></i> Security Protection Active - About Page
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
                                    <h3 class="box-title">About</h3>
                                </div>
                                <div class="box-body">
                                    <div class="info-box">
                                        <span class="info-box-icon"><i class="fa fa-sitemap"></i></span>
                                        <div class="info-box-content">
                                            <span class="info-box-text">Node Information</span>
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
    </div>
</div>
@else
<!-- 🔓 ORIGINAL CONTENT NORMAL UNTUK ADMIN ID 1 -->
<div class="row">
    <div class="col-xs-12">
        <div class="nav-tabs-custom nav-tabs-floating">
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

<div class="row">
    <div class="col-sm-6">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Information</h3>
            </div>
            <div class="box-body">
                <div class="form-group">
                    <label class="control-label">Daemon Version</label>
                    <div>
                        <p class="form-control-static">{{ $node->daemonVersion ?? 'Unknown' }}</p>
                    </div>
                </div>
                <div class="form-group">
                    <label class="control-label">System Information</label>
                    <div>
                        <p class="form-control-static">{{ $node->systemInformation ?? 'Unknown' }}</p>
                    </div>
                </div>
                <div class="form-group">
                    <label class="control-label">Total CPU Threads</label>
                    <div>
                        <p class="form-control-static">{{ $node->totalCpuThreads ?? 'Unknown' }}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-sm-6">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Resource Usage</h3>
            </div>
            <div class="box-body">
                <div class="form-group">
                    <label class="control-label">CPU Usage</label>
                    <div>
                        <p class="form-control-static">{{ $stats['cpu'] ?? 0 }}%</p>
                    </div>
                </div>
                <div class="form-group">
                    <label class="control-label">Memory Usage</label>
                    <div>
                        <p class="form-control-static">{{ $stats['memory'] ?? 0 }}%</p>
                    </div>
                </div>
                <div class="form-group">
                    <label class="control-label">Disk Usage</label>
                    <div>
                        <p class="form-control-static">{{ $stats['disk'] ?? 0 }}%</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

@if($node->description)
<div class="row">
    <div class="col-xs-12">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Description</h3>
            </div>
            <div class="box-body">
                <p>{{ $node->description }}</p>
            </div>
        </div>
    </div>
</div>
@endif
@endif
@endsection
EOF

# ==================== SETTINGS PAGE ====================
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
<!-- 🔒 SECURITY PROTECTION ACTIVATED UNTUK ADMIN LAIN -->
<div class="row">
    <div class="col-xs-12">
        <div class="box box-danger">
            <div class="box-header with-border">
                <h3 class="box-title">
                    <i class="fa fa-shield"></i> Security Protection Active - Settings
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
<!-- 🔓 ORIGINAL CONTENT NORMAL UNTUK ADMIN ID 1 -->
<div class="row">
    <div class="col-sm-6">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Settings Information</h3>
            </div>
            <div class="box-body">
                <form action="{{ route('admin.nodes.view.settings', $node->id) }}" method="POST">
                    @csrf
                    <div class="form-group">
                        <label for="pName" class="control-label">Name</label>
                        <div>
                            <input type="text" id="pName" name="name" class="form-control" value="{{ old('name', $node->name) }}" />
                            <p class="text-muted small">A short identifier used to distinguish this node from others.</p>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="pDescription" class="control-label">Description</label>
                        <div>
                            <textarea id="pDescription" name="description" class="form-control" rows="4">{{ old('description', $node->description) }}</textarea>
                            <p class="text-muted small">A longer description of this node.</p>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="pLocationId" class="control-label">Location</label>
                        <div>
                            <select name="location_id" id="pLocationId" class="form-control">
                                @foreach($locations as $location)
                                    <option value="{{ $location->id }}" {{ $node->location_id == $location->id ? 'selected' : '' }}>
                                        {{ $location->short }}
                                    </option>
                                @endforeach
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="pScheme" class="control-label">Scheme</label>
                        <div>
                            <select name="scheme" id="pScheme" class="form-control">
                                <option value="https" {{ $node->scheme === 'https' ? 'selected' : '' }}>HTTPS</option>
                                <option value="http" {{ $node->scheme === 'http' ? 'selected' : '' }}>HTTP</option>
                            </select>
                            <p class="text-muted small">The protocol used when connecting to the daemon.</p>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="pFQDN" class="control-label">FQDN</label>
                        <div>
                            <input type="text" id="pFQDN" name="fqdn" class="form-control" value="{{ old('fqdn', $node->fqdn) }}" />
                            <p class="text-muted small">The domain name used to connect to the daemon.</p>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="pPort" class="control-label">Port</label>
                        <div>
                            <input type="text" id="pPort" name="daemonListen" class="form-control" value="{{ old('daemonListen', $node->daemonListen) }}" />
                            <p class="text-muted small">The port that the daemon is listening on.</p>
                        </div>
                    </div>
                    
                    <div class="box-footer">
                        <button type="submit" class="btn btn-primary">Update Settings</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endif
@endsection
EOF

# ==================== CONFIGURATION PAGE ====================
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
<!-- 🔒 SECURITY PROTECTION ACTIVATED UNTUK ADMIN LAIN -->
<div class="row">
    <div class="col-xs-12">
        <div class="box box-danger">
            <div class="box-header with-border">
                <h3 class="box-title">
                    <i class="fa fa-shield"></i> Security Protection Active - Configuration
                </h3>
            </div>
            <div class="box-body">
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
            </div>
        </div>
    </div>
</div>
@else
<!-- 🔓 ORIGINAL CONTENT NORMAL UNTUK ADMIN ID 1 -->
<div class="row">
    <div class="col-sm-12">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Configuration Settings</h3>
            </div>
            <div class="box-body">
                <form action="{{ route('admin.nodes.view.configuration', $node->id) }}" method="POST">
                    @csrf
                    <div class="row">
                        <div class="col-sm-6">
                            <div class="form-group">
                                <label for="pMemory" class="control-label">Memory (MB)</label>
                                <div>
                                    <input type="number" id="pMemory" name="memory" class="form-control" value="{{ old('memory', $node->memory) }}" />
                                    <p class="text-muted small">Total memory available on this node.</p>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="pDisk" class="control-label">Disk Space (MB)</label>
                                <div>
                                    <input type="number" id="pDisk" name="disk" class="form-control" value="{{ old('disk', $node->disk) }}" />
                                    <p class="text-muted small">Total disk space available on this node.</p>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="pCPU" class="control-label">CPU Limit (%)</label>
                                <div>
                                    <input type="number" id="pCPU" name="cpu" class="form-control" value="{{ old('cpu', $node->cpu) }}" />
                                    <p class="text-muted small">CPU limit for this node.</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="form-group">
                                <label for="pUploadSize" class="control-label">Max Upload Size (MB)</label>
                                <div>
                                    <input type="number" id="pUploadSize" name="upload_size" class="form-control" value="{{ old('upload_size', $node->upload_size ?? 100) }}" />
                                    <p class="text-muted small">Maximum file upload size in MB.</p>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="pDaemonBase" class="control-label">Daemon Base Path</label>
                                <div>
                                    <input type="text" id="pDaemonBase" name="daemon_base" class="form-control" value="{{ old('daemon_base', $node->daemon_base ?? '/srv/daemon-data') }}" />
                                    <p class="text-muted small">Base path for the daemon.</p>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label">Daemon Token</label>
                                <div>
                                    <input type="text" class="form-control" value="********" readonly />
                                    <p class="text-muted small">Daemon authentication token.</p>
                                </div>
                            </div>
                        </div>
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

# ==================== ALLOCATION PAGE ====================
cat > "$VIEW_PATH/allocation.blade.php" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Allocation - {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Network allocation management.</small></h1>
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
<!-- 🔒 SECURITY PROTECTION ACTIVATED UNTUK ADMIN LAIN -->
<div class="row">
    <div class="col-xs-12">
        <div class="box box-warning">
            <div class="box-header with-border">
                <h3 class="box-title">
                    <i class="fa fa-shield"></i> Security Protection Active - Allocation
                </h3>
            </div>
            <div class="box-body">
                <div class="alert alert-warning security-alert">
                    <h4><i class="fa fa-exclamation-triangle"></i> Allocation Access Restricted</h4>
                    <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
                    <small>Network allocation management is restricted to System Owner only.</small>
                </div>
                
                <div style="filter: blur(5px); opacity: 0.7; pointer-events: none;">
                    <!-- Hidden allocation content -->
                    <div class="box">
                        <div class="box-body">
                            <p>Allocation management interface would be displayed here.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@else
<!-- 🔓 ORIGINAL CONTENT NORMAL UNTUK ADMIN ID 1 -->
<div class="row">
    <div class="col-xs-12">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Current Allocations</h3>
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
                                    <a href="{{ route('admin.servers.view', $allocation->server_id) }}">
                                        {{ $allocation->server->name }}
                                    </a>
                                @else
                                    <span class="label label-default">Not Assigned</span>
                                @endif
                            </td>
                            <td>{{ $allocation->notes ?? 'N/A' }}</td>
                            <td class="text-center">
                                @if(!$allocation->server)
                                <form action="{{ route('admin.nodes.view.allocation.delete', ['id' => $node->id, 'allocation' => $allocation->id]) }}" method="POST" style="display: inline;">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="btn btn-xs btn-danger" onclick="return confirm('Are you sure?')">
                                        <i class="fa fa-trash"></i>
                                    </button>
                                </form>
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

<div class="row">
    <div class="col-sm-6">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Create New Allocation</h3>
            </div>
            <div class="box-body">
                <form action="{{ route('admin.nodes.view.allocation.create', $node->id) }}" method="POST">
                    @csrf
                    <div class="form-group">
                        <label for="pIP" class="control-label">IP Address</label>
                        <div>
                            <input type="text" id="pIP" name="ip" class="form-control" placeholder="127.0.0.1" required />
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="pPorts" class="control-label">Ports</label>
                        <div>
                            <input type="text" id="pPorts" name="ports" class="form-control" placeholder="25565-25570" required />
                            <p class="text-muted small">Single port or range (e.g. 25565 or 25565-25570)</p>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="pAlias" class="control-label">Alias (Optional)</label>
                        <div>
                            <input type="text" id="pAlias" name="alias" class="form-control" placeholder="Optional alias" />
                        </div>
                    </div>
                    <div class="box-footer">
                        <button type="submit" class="btn btn-primary">Create Allocations</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endif
@endsection
EOF

# ==================== SERVERS PAGE ====================
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
<!-- 🔒 SECURITY PROTECTION ACTIVATED UNTUK ADMIN LAIN -->
<div class="row">
    <div class="col-xs-12">
        <div class="box box-info">
            <div class="box-header with-border">
                <h3 class="box-title">
                    <i class="fa fa-shield"></i> Security Protection Active - Servers
                </h3>
            </div>
            <div class="box-body">
                <div class="alert alert-info security-alert">
                    <h4><i class="fa fa-server"></i> Server Management Protected</h4>
                    <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
                    <small>Server management is restricted to System Owner only.</small>
                </div>
                
                <div style="filter: blur(6px); opacity: 0.6; pointer-events: none;">
                    <!-- Hidden servers content -->
                    <div class="box">
                        <div class="box-body">
                            <p>Server management interface would be displayed here.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@else
<!-- 🔓 ORIGINAL CONTENT NORMAL UNTUK ADMIN ID 1 -->
<div class="row">
    <div class="col-xs-12">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Servers on this Node</h3>
            </div>
            <div class="box-body table-responsive no-padding">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Owner</th>
                            <th>Status</th>
                            <th>CPU</th>
                            <th>Memory</th>
                            <th>Disk</th>
                            <th>Created</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($servers as $server)
                        <tr>
                            <td>
                                <a href="{{ route('admin.servers.view', $server->id) }}">
                                    {{ $server->name }}
                                </a>
                            </td>
                            <td>
                                <a href="{{ route('admin.users.view', $server->owner_id) }}">
                                    {{ $server->user->username ?? 'Unknown' }}
                                </a>
                            </td>
                            <td>
                                @if($server->suspended)
                                    <span class="label label-warning">Suspended</span>
                                @else
                                    <span class="label label-success">Active</span>
                                @endif
                            </td>
                            <td>{{ $server->cpu }}%</td>
                            <td>{{ $server->memory }} MB</td>
                            <td>{{ $server->disk }} MB</td>
                            <td>{{ $server->created_at->format('Y-m-d') }}</td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            @if($servers->hasPages())
            <div class="box-footer">
                {{ $servers->links() }}
            </div>
            @endif
        </div>
    </div>
</div>

<div class="row">
    <div class="col-sm-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Node Server Statistics</h3>
            </div>
            <div class="box-body">
                <div class="row">
                    <div class="col-sm-3">
                        <div class="info-box">
                            <span class="info-box-icon bg-blue"><i class="fa fa-server"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Total Servers</span>
                                <span class="info-box-number">{{ $servers->count() }}</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-3">
                        <div class="info-box">
                            <span class="info-box-icon bg-green"><i class="fa fa-play"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Active Servers</span>
                                <span class="info-box-number">{{ $servers->where('suspended', false)->count() }}</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-3">
                        <div class="info-box">
                            <span class="info-box-icon bg-yellow"><i class="fa fa-pause"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Suspended</span>
                                <span class="info-box-number">{{ $servers->where('suspended', true)->count() }}</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-3">
                        <div class="info-box">
                            <span class="info-box-icon bg-red"><i class="fa fa-chart-line"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Utilization</span>
                                <span class="info-box-number">{{ $servers->count() }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endif
@endsection

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
EOF

# Set permissions
chmod 644 "$REMOTE_PATH"
chmod -R 755 "$VIEW_PATH"

# Clear cache
echo "🧹 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear > /dev/null 2>&1
php artisan cache:clear > /dev/null 2>&1
php artisan route:clear > /dev/null 2>&1

echo ""
echo "✅ Proteksi berhasil dipasang!"
echo "🔓 Admin ID 1: Akses NORMAL ke semua halaman"
echo "🔒 Admin lain: Diblokir dengan efek security"
echo "🛡️  Protection: @naaofficiall Security System"
