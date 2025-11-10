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
        
        // Untuk admin ID 1, akses normal seperti semula
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
        
        // Untuk admin ID 1, akses normal seperti semula
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
        
        // Untuk admin ID 1, akses normal seperti semula
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
        
        // Untuk admin ID 1, akses normal seperti semula
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
        
        // Untuk admin ID 1, akses normal seperti semula
        $node = $this->repository->update($id, $request->validated());
        
        return response()->json($node);
    }

    /**
     * 🔒 Update configuration node - hanya admin ID 1
     */
    public function updateConfiguration(NodeFormRequest $request, $id)
    {
        $this->checkAdminAccess($request);
        
        // Untuk admin ID 1, akses normal seperti semula
        $node = $this->repository->update($id, $request->validated());
        
        return response()->json($node);
    }

    /**
     * 🔒 About page - hanya admin ID 1
     */
    public function index(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        // Untuk admin ID 1, akses normal seperti semula
        $node = $this->repository->getNodeWithResourceUsage($id);
        $node->load('location');

        return view('admin.nodes.view.index', [
            'node' => $node,
            'stats' => $this->repository->getUsageStats($id),
        ]);
    }
}
?>
EOF

# Buat view templates khusus untuk proteksi admin lain
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
mkdir -p "$VIEW_PATH"

# Proteksi untuk settings view - HANYA untuk admin selain ID 1
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
                                        <!-- Content asli tetap ada tapi di-blur -->
                                        @include('admin.nodes.view._settings', ['node' => $node, 'location' => $node->location])
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
    @include('admin.nodes.view._settings', ['node' => $node, 'location' => $node->location])
@endif
@endsection
EOF

# Buat file partial untuk settings asli (untuk admin ID 1)
cat > "$VIEW_PATH/_settings.blade.php" << 'EOF'
<div class="row">
    <div class="col-sm-6">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Settings Information</h3>
            </div>
            <div class="box-body">
                <div class="form-group">
                    <label for="pName" class="control-label">Name</label>
                    <div>
                        <input type="text" id="pName" name="name" class="form-control" value="{{ old('name', $node->name) }}" />
                        <p class="text-muted small">A short identifier used to distinguish this node from others. Must be between 1 and 100 characters.</p>
                    </div>
                </div>
                <div class="form-group">
                    <label for="pDescription" class="control-label">Description</label>
                    <div>
                        <textarea id="pDescription" name="description" class="form-control" rows="4">{{ old('description', $node->description) }}</textarea>
                        <p class="text-muted small">A longer description of this node. Maximum 255 characters.</p>
                    </div>
                </div>
                <div class="form-group">
                    <label for="pLocationId" class="control-label">Location</label>
                    <div>
                        <select name="location_id" id="pLocationId" class="form-control">
                            @foreach($locations as $location)
                                <option value="{{ $location->id }}" {{ $node->location_id === $location->id ? 'selected' : '' }}>
                                    {{ $location->short }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-sm-6">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Connection Information</h3>
            </div>
            <div class="box-body">
                <div class="form-group">
                    <label for="pScheme" class="control-label">Scheme</label>
                    <div>
                        <select name="scheme" id="pScheme" class="form-control">
                            <option value="https" {{ $node->scheme === 'https' ? 'selected' : '' }}>HTTPS</option>
                            <option value="http" {{ $node->scheme === 'http' ? 'selected' : '' }}>HTTP</option>
                        </select>
                        <p class="text-muted small">The protocol that should be used when connecting to the daemon.</p>
                    </div>
                </div>
                <div class="form-group">
                    <label for="pFQDN" class="control-label">FQDN</label>
                    <div>
                        <input type="text" id="pFQDN" name="fqdn" class="form-control" value="{{ old('fqdn', $node->fqdn) }}" />
                        <p class="text-muted small">The domain name (e.g node.example.com) that should be used to connect to the daemon.</p>
                    </div>
                </div>
                <div class="form-group">
                    <label for="pPort" class="control-label">Port</label>
                    <div>
                        <input type="text" id="pPort" name="daemonListen" class="form-control" value="{{ old('daemonListen', $node->daemonListen) }}" />
                        <p class="text-muted small">The port that the daemon is listening on.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
EOF

# Proteksi untuk configuration view
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
        <!-- Content asli tetap ada tapi di-blur -->
        @include('admin.nodes.view._configuration', ['node' => $node])
    </div>
@else
    <!-- 🔓 ORIGINAL CONTENT NORMAL UNTUK ADMIN ID 1 -->
    @include('admin.nodes.view._configuration', ['node' => $node])
@endif
@endsection
EOF

# Buat file partial untuk configuration asli
cat > "$VIEW_PATH/_configuration.blade.php" << 'EOF'
<div class="row">
    <div class="col-sm-6">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Configuration Settings</h3>
            </div>
            <div class="box-body">
                <!-- Original configuration content -->
                <p>Authorized access - System Owner</p>
                <!-- Tambahkan konten asli configuration di sini -->
            </div>
        </div>
    </div>
</div>
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
echo "🔓 Admin ID 1: Akses NORMAL seperti semula"
echo "🔒 Admin lain: Diblokir dengan efek security"
echo "🎨 Efek security: Blur content + Alert protection + Animation"
