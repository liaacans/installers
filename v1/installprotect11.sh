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
     * 🔒 View untuk halaman settings node - HANYA ADMIN ID 1
     */
    public function settings(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        // Admin ID 1 akan melanjutkan ke logic normal Pterodactyl
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.settings', [
            'node' => $node,
            'location' => $node->location,
        ]);
    }

    /**
     * 🔒 View untuk halaman configuration node - HANYA ADMIN ID 1
     */
    public function configuration(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        // Admin ID 1 akan melanjutkan ke logic normal Pterodactyl
        $node = $this->repository->find($id);
        
        return view('admin.nodes.view.configuration', [
            'node' => $node,
        ]);
    }

    /**
     * 🔒 View untuk halaman allocation node - HANYA ADMIN ID 1
     */
    public function allocation(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        // Admin ID 1 akan melanjutkan ke logic normal Pterodactyl
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.allocation', [
            'node' => $node,
            'allocations' => $node->allocations,
        ]);
    }

    /**
     * 🔒 View untuk halaman servers node - HANYA ADMIN ID 1
     */
    public function servers(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        // Admin ID 1 akan melanjutkan ke logic normal Pterodactyl
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
        
        // Admin ID 1 akan melanjutkan ke logic normal Pterodactyl
        $node = $this->repository->update($id, $request->validated());
        
        return response()->json($node);
    }

    /**
     * 🔒 Update configuration node - hanya admin ID 1
     */
    public function updateConfiguration(NodeFormRequest $request, $id)
    {
        $this->checkAdminAccess($request);
        
        // Admin ID 1 akan melanjutkan ke logic normal Pterodactyl
        $node = $this->repository->update($id, $request->validated());
        
        return response()->json($node);
    }
}
?>
EOF

# Buat view override untuk proteksi dengan efek security keren
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
mkdir -p "$VIEW_PATH"

# Override untuk settings view - TAMPILAN NORMAL UNTUK ADMIN ID 1
cat > "$VIEW_PATH/settings.blade.php" << 'EOF'
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
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

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
@else
<!-- 🟢 TAMPILAN NORMAL UNTUK ADMIN ID 1 -->
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
<div class="row">
    <div class="col-xs-12">
        <div class="nav-tabs-custom nav-tabs-floating">
            <ul class="nav nav-tabs">
                <li><a href="{{ route('admin.nodes.view', $node->id) }}">About</a></li>
                <li class="active"><a href="{{ route('admin.nodes.view.settings', $node->id) }}">Settings</a></li>
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
                <h3 class="box-title">Settings Information</h3>
            </div>
            <div class="box-body">
                <div class="row">
                    <div class="form-group col-xs-12">
                        <label for="pName" class="control-label">Name</label>
                        <div>
                            <input id="pName" type="text" class="form-control" name="name" value="{{ $node->name }}" />
                            <p class="text-muted small">Character limits: <code>a-zA-Z0-9_.-</code> and must not start or end with <code>_</code>, <code>-</code>, or <code>.</code>.</p>
                        </div>
                    </div>
                    <div class="form-group col-xs-12">
                        <label for="pDescription" class="control-label">Description</label>
                        <div>
                            <textarea id="pDescription" name="description" class="form-control" rows="4">{{ $node->description }}</textarea>
                        </div>
                    </div>
                    <div class="form-group col-xs-12">
                        <label for="pLocation" class="control-label">Location</label>
                        <div>
                            <select id="pLocation" name="location_id" class="form-control">
                                @foreach($locations as $location)
                                    <option value="{{ $location->id }}" {{ $node->location_id === $location->id ? 'selected' : '' }}>{{ $location->short }}</option>
                                @endforeach
                            </select>
                        </div>
                    </div>
                    <div class="form-group col-xs-12">
                        <label for="pPublic" class="control-label">Visibility</label>
                        <div>
                            <select id="pPublic" name="public" class="form-control">
                                <option value="1" {{ $node->public ? 'selected' : '' }}>Public</option>
                                <option value="0" {{ ! $node->public ? 'selected' : '' }}>Private</option>
                            </select>
                            <p class="text-muted small">If set to private, only administrators with allocated servers can deploy to this node.</p>
                        </div>
                    </div>
                    <div class="form-group col-xs-12">
                        <label for="pFQDN" class="control-label">FQDN</label>
                        <div>
                            <input id="pFQDN" type="text" class="form-control" name="fqdn" value="{{ $node->fqdn }}" />
                            <p class="text-muted small">Please enter domain name (e.g <code>node.example.com</code>) to be used for connecting to the daemon. An IP address may only be used if you are not using SSL for this node.</p>
                        </div>
                    </div>
                    <div class="form-group col-xs-12">
                        <label for="pScheme" class="control-label">Communication Scheme</label>
                        <div>
                            <select id="pScheme" name="scheme" class="form-control">
                                <option value="https" {{ $node->scheme === 'https' ? 'selected' : '' }}>HTTPS</option>
                                <option value="http" {{ $node->scheme === 'http' ? 'selected' : '' }}>HTTP</option>
                            </select>
                            <p class="text-muted small">For most cases you should select HTTPS. If using an IP address or you do not wish to use SSL, select HTTP.</p>
                        </div>
                    </div>
                    <div class="form-group col-xs-12">
                        <label for="pBehindProxy" class="control-label">Behind Proxy</label>
                        <div>
                            <select id="pBehindProxy" name="behind_proxy" class="form-control">
                                <option value="1" {{ $node->behind_proxy ? 'selected' : '' }}>Behind Proxy</option>
                                <option value="0" {{ ! $node->behind_proxy ? 'selected' : '' }}>Not Behind Proxy</option>
                            </select>
                            <p class="text-muted small">Select if this node is behind a proxy (e.g Cloudflare).</p>
                        </div>
                    </div>
                    <div class="form-group col-xs-12">
                        <label for="pMaintenance" class="control-label">Maintenance Mode</label>
                        <div>
                            <select id="pMaintenance" name="maintenance_mode" class="form-control">
                                <option value="1" {{ $node->maintenance_mode ? 'selected' : '' }}>Enabled</option>
                                <option value="0" {{ ! $node->maintenance_mode ? 'selected' : '' }}>Disabled</option>
                            </select>
                            <p class="text-muted small">If enabled, deployments and power actions will be blocked for servers on this node.</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="box-footer">
                {!! csrf_field() !!}
                <button type="submit" class="btn btn-primary pull-right">Save Changes</button>
            </div>
        </div>
    </div>
</div>
@endsection
@endif
EOF

# Buat file views untuk halaman lainnya dengan pola yang sama
cat > "$VIEW_PATH/configuration.blade.php" << 'EOF'
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
<!-- 🟢 TAMPILAN NORMAL UNTUK ADMIN ID 1 -->
@extends('layouts.admin')

@section('title')
    Node Configuration - {{ $node->name }}
@endsection

@section('content')
@include('admin.nodes.partials.configuration')
@endsection
@endif
EOF

cat > "$VIEW_PATH/allocation.blade.php" << 'EOF'
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
<!-- 🔒 SECURITY PROTECTION ACTIVATED -->
<div class="alert alert-warning security-alert">
    <h4><i class="fa fa-exclamation-triangle"></i> Allocation Access Restricted</h4>
    <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
</div>

<div style="filter: blur(5px); opacity: 0.7;">
    <!-- Hidden allocation content -->
</div>
@else
<!-- 🟢 TAMPILAN NORMAL UNTUK ADMIN ID 1 -->
@extends('layouts.admin')

@section('title')
    Node Allocation - {{ $node->name }}
@endsection

@section('content')
@include('admin.nodes.partials.allocation')
@endsection
@endif
EOF

cat > "$VIEW_PATH/servers.blade.php" << 'EOF'
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
<!-- 🔒 SECURITY PROTECTION ACTIVATED -->
<div class="alert alert-info security-alert">
    <h4><i class="fa fa-server"></i> Server Management Protected</h4>
    <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
</div>

<div style="filter: blur(6px); opacity: 0.6;">
    <!-- Hidden servers content -->
</div>
@else
<!-- 🟢 TAMPILAN NORMAL UNTUK ADMIN ID 1 -->
@extends('layouts.admin')

@section('title')
    Node Servers - {{ $node->name }}
@endsection

@section('content')
@include('admin.nodes.partials.servers')
@endsection
@endif
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
echo "🔒 Hanya Admin ID 1 yang bisa akses Settings, Configuration, Allocation, dan Servers"
echo "🟢 Admin ID 1: Akses normal seperti biasa"
echo "🔴 Admin lain: Diblokir dengan efek security"
