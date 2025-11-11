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
}
?>
EOF

# Buat view templates untuk proteksi
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
mkdir -p "$VIEW_PATH"

# Proteksi untuk index/about view
cat > "$VIEW_PATH/index.blade.php" << 'EOF'
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied - Node View</title>
    <style>
        body {
            background: linear-gradient(135deg, #0c0c0c 0%, #1a1a1a 100%);
            color: #fff;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .security-container {
            text-align: center;
            padding: 40px;
            border: 2px solid #ff0000;
            border-radius: 10px;
            background: rgba(0, 0, 0, 0.8);
            box-shadow: 0 0 30px rgba(255, 0, 0, 0.3);
            animation: pulse 2s infinite;
            max-width: 600px;
            width: 90%;
        }
        @keyframes pulse {
            0% { box-shadow: 0 0 20px rgba(255, 0, 0, 0.3); }
            50% { box-shadow: 0 0 40px rgba(255, 0, 0, 0.6); }
            100% { box-shadow: 0 0 20px rgba(255, 0, 0, 0.3); }
        }
        .security-icon {
            font-size: 4em;
            margin-bottom: 20px;
            color: #ff0000;
        }
        .security-title {
            font-size: 2em;
            margin-bottom: 20px;
            color: #ff0000;
            font-weight: bold;
        }
        .security-message {
            font-size: 1.2em;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        .security-details {
            background: rgba(255, 0, 0, 0.1);
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
            font-size: 0.9em;
        }
        .admin-info {
            margin-top: 20px;
            padding: 10px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="security-container">
        <div class="security-icon">🚫</div>
        <div class="security-title">ACCESS DENIED</div>
        <div class="security-message">
            <strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong>
            <br><br>
            You are not authorized to access this node management section.
            This area is restricted to System Owner only.
        </div>
        <div class="security-details">
            <strong>Security Alert Details:</strong><br>
            • Unauthorized access attempt detected<br>
            • User: {{ $user->name }} (ID: {{ $user->id }})<br>
            • Timestamp: {{ now()->format('Y-m-d H:i:s') }}<br>
            • Protected Resource: Node About Page
        </div>
        <div class="admin-info">
            🔒 <strong>Protected by NAA OFFICIAL Security System</strong>
        </div>
    </div>
</body>
</html>
@else
{{-- Original About/Index content untuk admin ID 1 --}}
@extends('layouts.admin')

@section('title')
    {{ $node->name }}
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
<div class="row">
    <div class="col-xs-12">
        <div class="nav-tabs-custom nav-tabs-floating">
            <ul class="nav nav-tabs">
                <li class="active"><a href="{{ route('admin.nodes.view', $node->id) }}">About</a></li>
                <li><a href="{{ route('admin.nodes.view.settings', $node->id) }}">Settings</a></li>
                <li><a href="{{ route('admin.nodes.view.configuration', $node->id) }}">Configuration</a></li>
                <li><a href="{{ route('admin.nodes.view.allocation', $node->id) }}">Allocation</a></li>
                <li><a href="{{ route('admin.nodes.view.servers', $node->id) }}">Servers</a></li>
            </ul>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-sm-8">
        <div class="row">
            <div class="col-xs-6">
                <div class="info-box bg-blue">
                    <span class="info-box-icon"><i class="fa fa-server"></i></span>
                    <div class="info-box-content">
                        <span class="info-box-text">Servers Allocated</span>
                        <span class="info-box-number">{{ $node->servers_count }}</span>
                    </div>
                </div>
            </div>
            <div class="col-xs-6">
                <div class="info-box bg-green">
                    <span class="info-box-icon"><i class="fa fa-wifi"></i></span>
                    <div class="info-box-content">
                        <span class="info-box-text">Allocations</span>
                        <span class="info-box-number">{{ $node->allocations_count }}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

{{-- Original Information Section --}}
<div class="row">
    <div class="col-xs-12">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Information</h3>
            </div>
            <div class="box-body">
                <div class="row">
                    <div class="col-sm-4">
                        <strong>Daemon Version</strong><br>
                        <span>{{ $node->daemonVersion }}</span>
                        @if($node->getDaemonVersion() === $node->daemonVersion)
                            <span class="label label-success">Latest</span>
                        @else
                            <span class="label label-danger">Outdated</span>
                        @endif
                    </div>
                    <div class="col-sm-4">
                        <strong>System Information</strong><br>
                        <span>{{ $node->systemInformation }}</span>
                    </div>
                    <div class="col-sm-4">
                        <strong>Total CPU Threads</strong><br>
                        <span>{{ $node->cpuThreads }}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

{{-- Delete Node Section --}}
@can('delete', $node)
<div class="row">
    <div class="col-xs-12">
        <div class="box box-danger">
            <div class="box-header with-border">
                <h3 class="box-title">Delete Node</h3>
            </div>
            <div class="box-body">
                <p>Deleting a node is a irreversible action and will immediately remove this node from the panel. There must be no servers associated with this node in order to continue.</p>
            </div>
            <div class="box-footer">
                <form action="{{ route('admin.nodes.view.delete', $node->id) }}" method="POST">
                    {!! csrf_field() !!}
                    {!! method_field('DELETE') !!}
                    <button type="submit" class="btn btn-danger"><i class="fa fa-trash-o"></i> Delete this Node</button>
                </form>
            </div>
        </div>
    </div>
</div>
@endcan
@endsection
@endif
EOF

# Proteksi untuk settings view
cat > "$VIEW_PATH/settings.blade.php" << 'EOF'
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied - Node Settings</title>
    <style>
        body {
            background: linear-gradient(135deg, #0c0c0c 0%, #1a1a1a 100%);
            color: #fff;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .security-container {
            text-align: center;
            padding: 40px;
            border: 2px solid #ff6b00;
            border-radius: 10px;
            background: rgba(0, 0, 0, 0.8);
            box-shadow: 0 0 30px rgba(255, 107, 0, 0.3);
            animation: pulse 2s infinite;
            max-width: 600px;
            width: 90%;
        }
        @keyframes pulse {
            0% { box-shadow: 0 0 20px rgba(255, 107, 0, 0.3); }
            50% { box-shadow: 0 0 40px rgba(255, 107, 0, 0.6); }
            100% { box-shadow: 0 0 20px rgba(255, 107, 0, 0.3); }
        }
        .security-icon {
            font-size: 4em;
            margin-bottom: 20px;
            color: #ff6b00;
        }
        .security-title {
            font-size: 2em;
            margin-bottom: 20px;
            color: #ff6b00;
            font-weight: bold;
        }
        .security-message {
            font-size: 1.2em;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        .security-details {
            background: rgba(255, 107, 0, 0.1);
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="security-container">
        <div class="security-icon">⚙️</div>
        <div class="security-title">SETTINGS PROTECTED</div>
        <div class="security-message">
            <strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong>
            <br><br>
            Node settings configuration is restricted to System Owner only.
        </div>
        <div class="security-details">
            <strong>Protected Section:</strong> Settings Management<br>
            <strong>User:</strong> {{ $user->name }} (ID: {{ $user->id }})<br>
            <strong>Time:</strong> {{ now()->format('Y-m-d H:i:s') }}
        </div>
    </div>
</body>
</html>
@else
{{-- Original Settings content untuk admin ID 1 --}}
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

{{-- Original Settings Content --}}
<div class="row">
    <div class="col-sm-6">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Settings Information</h3>
            </div>
            <div class="box-body">
                <p>Authorized access - System Owner</p>
                {{-- Original settings form/content would be here --}}
            </div>
        </div>
    </div>
</div>
@endsection
@endif
EOF

# Proteksi untuk configuration view
cat > "$VIEW_PATH/configuration.blade.php" << 'EOF'
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied - Node Configuration</title>
    <style>
        body {
            background: linear-gradient(135deg, #0c0c0c 0%, #1a1a1a 100%);
            color: #fff;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .security-container {
            text-align: center;
            padding: 40px;
            border: 2px solid #00bcd4;
            border-radius: 10px;
            background: rgba(0, 0, 0, 0.8);
            box-shadow: 0 0 30px rgba(0, 188, 212, 0.3);
            animation: pulse 2s infinite;
            max-width: 600px;
            width: 90%;
        }
        @keyframes pulse {
            0% { box-shadow: 0 0 20px rgba(0, 188, 212, 0.3); }
            50% { box-shadow: 0 0 40px rgba(0, 188, 212, 0.6); }
            100% { box-shadow: 0 0 20px rgba(0, 188, 212, 0.3); }
        }
        .security-icon {
            font-size: 4em;
            margin-bottom: 20px;
            color: #00bcd4;
        }
        .security-title {
            font-size: 2em;
            margin-bottom: 20px;
            color: #00bcd4;
            font-weight: bold;
        }
        .security-message {
            font-size: 1.2em;
            margin-bottom: 30px;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <div class="security-container">
        <div class="security-icon">🔧</div>
        <div class="security-title">CONFIGURATION LOCKED</div>
        <div class="security-message">
            <strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong>
            <br><br>
            Node configuration access is restricted to System Owner.
        </div>
    </div>
</body>
</html>
@else
{{-- Original Configuration content untuk admin ID 1 --}}
@extends('layouts.admin')

@section('title')
    Node Configuration - {{ $node->name }}
@endsection

@section('content')
<div class="row">
    <div class="col-xs-12">
        <div class="nav-tabs-custom nav-tabs-floating">
            <ul class="nav nav-tabs">
                <li><a href="{{ route('admin.nodes.view', $node->id) }}">About</a></li>
                <li><a href="{{ route('admin.nodes.view.settings', $node->id) }}">Settings</a></li>
                <li class="active"><a href="{{ route('admin.nodes.view.configuration', $node->id) }}">Configuration</a></li>
                <li><a href="{{ route('admin.nodes.view.allocation', $node->id) }}">Allocation</a></li>
                <li><a href="{{ route('admin.nodes.view.servers', $node->id) }}">Servers</a></li>
            </ul>
        </div>
    </div>
</div>

{{-- Original Configuration Content --}}
<div class="row">
    <div class="col-md-12">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Configuration</h3>
            </div>
            <div class="box-body">
                <p>Authorized configuration access - System Owner</p>
                {{-- Original configuration form/content would be here --}}
            </div>
        </div>
    </div>
</div>
@endsection
@endif
EOF

# Proteksi untuk allocation view
cat > "$VIEW_PATH/allocation.blade.php" << 'EOF'
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied - Node Allocation</title>
    <style>
        body {
            background: linear-gradient(135deg, #0c0c0c 0%, #1a1a1a 100%);
            color: #fff;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .security-container {
            text-align: center;
            padding: 40px;
            border: 2px solid #4caf50;
            border-radius: 10px;
            background: rgba(0, 0, 0, 0.8);
            box-shadow: 0 0 30px rgba(76, 175, 80, 0.3);
            animation: pulse 2s infinite;
            max-width: 600px;
            width: 90%;
        }
        @keyframes pulse {
            0% { box-shadow: 0 0 20px rgba(76, 175, 80, 0.3); }
            50% { box-shadow: 0 0 40px rgba(76, 175, 80, 0.6); }
            100% { box-shadow: 0 0 20px rgba(76, 175, 80, 0.3); }
        }
        .security-icon {
            font-size: 4em;
            margin-bottom: 20px;
            color: #4caf50;
        }
        .security-title {
            font-size: 2em;
            margin-bottom: 20px;
            color: #4caf50;
            font-weight: bold;
        }
        .security-message {
            font-size: 1.2em;
            margin-bottom: 30px;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <div class="security-container">
        <div class="security-icon">🌐</div>
        <div class="security-title">ALLOCATION PROTECTED</div>
        <div class="security-message">
            <strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong>
            <br><br>
            Node allocation management is system owner restricted.
        </div>
    </div>
</body>
</html>
@else
{{-- Original Allocation content untuk admin ID 1 --}}
@extends('layouts.admin')

@section('title')
    Node Allocation - {{ $node->name }}
@endsection

@section('content')
<div class="row">
    <div class="col-xs-12">
        <div class="nav-tabs-custom nav-tabs-floating">
            <ul class="nav nav-tabs">
                <li><a href="{{ route('admin.nodes.view', $node->id) }}">About</a></li>
                <li><a href="{{ route('admin.nodes.view.settings', $node->id) }}">Settings</a></li>
                <li><a href="{{ route('admin.nodes.view.configuration', $node->id) }}">Configuration</a></li>
                <li class="active"><a href="{{ route('admin.nodes.view.allocation', $node->id) }}">Allocation</a></li>
                <li><a href="{{ route('admin.nodes.view.servers', $node->id) }}">Servers</a></li>
            </ul>
        </div>
    </div>
</div>

{{-- Original Allocation Content --}}
<div class="row">
    <div class="col-md-12">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Allocation Management</h3>
            </div>
            <div class="box-body">
                <p>Authorized allocation access - System Owner</p>
                {{-- Original allocation form/content would be here --}}
            </div>
        </div>
    </div>
</div>
@endsection
@endif
EOF

# Proteksi untuk servers view
cat > "$VIEW_PATH/servers.blade.php" << 'EOF'
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied - Node Servers</title>
    <style>
        body {
            background: linear-gradient(135deg, #0c0c0c 0%, #1a1a1a 100%);
            color: #fff;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .security-container {
            text-align: center;
            padding: 40px;
            border: 2px solid #9c27b0;
            border-radius: 10px;
            background: rgba(0, 0, 0, 0.8);
            box-shadow: 0 0 30px rgba(156, 39, 176, 0.3);
            animation: pulse 2s infinite;
            max-width: 600px;
            width: 90%;
        }
        @keyframes pulse {
            0% { box-shadow: 0 0 20px rgba(156, 39, 176, 0.3); }
            50% { box-shadow: 0 0 40px rgba(156, 39, 176, 0.6); }
            100% { box-shadow: 0 0 20px rgba(156, 39, 176, 0.3); }
        }
        .security-icon {
            font-size: 4em;
            margin-bottom: 20px;
            color: #9c27b0;
        }
        .security-title {
            font-size: 2em;
            margin-bottom: 20px;
            color: #9c27b0;
            font-weight: bold;
        }
        .security-message {
            font-size: 1.2em;
            margin-bottom: 30px;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <div class="security-container">
        <div class="security-icon">🖥️</div>
        <div class="security-title">SERVERS RESTRICTED</div>
        <div class="security-message">
            <strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong>
            <br><br>
            Server management access is system owner exclusive.
        </div>
    </div>
</body>
</html>
@else
{{-- Original Servers content untuk admin ID 1 --}}
@extends('layouts.admin')

@section('title')
    Node Servers - {{ $node->name }}
@endsection

@section('content')
<div class="row">
    <div class="col-xs-12">
        <div class="nav-tabs-custom nav-tabs-floating">
            <ul class="nav nav-tabs">
                <li><a href="{{ route('admin.nodes.view', $node->id) }}">About</a></li>
                <li><a href="{{ route('admin.nodes.view.settings', $node->id) }}">Settings</a></li>
                <li><a href="{{ route('admin.nodes.view.configuration', $node->id) }}">Configuration</a></li>
                <li><a href="{{ route('admin.nodes.view.allocation', $node->id) }}">Allocation</a></li>
                <li class="active"><a href="{{ route('admin.nodes.view.servers', $node->id) }}">Servers</a></li>
            </ul>
        </div>
    </div>
</div>

{{-- Original Servers Content --}}
<div class="row">
    <div class="col-md-12">
        <div class="box">
            <div class="box-header with-border">
                <h3 class="box-title">Server Management</h3>
            </div>
            <div class="box-body">
                <p>Authorized servers access - System Owner</p>
                {{-- Original servers form/content would be here --}}
            </div>
        </div>
    </div>
</div>
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

echo ""
echo "✅ Proteksi Anti Akses Admin Node View berhasil dipasang!"
echo "📂 Lokasi controller: $REMOTE_PATH"
echo "📂 Lokasi views: $VIEW_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo ""
echo "🔒 PROTEKSI AKTIF:"
echo "   • Hanya Admin ID 1 yang bisa akses semua halaman nodes view"
echo "   • Admin lain akan mendapatkan error 403 dengan efek security"
echo "   • Semua tab diproteksi: About, Settings, Configuration, Allocation, Servers"
echo ""
echo "🎨 FITUR SECURITY:"
echo "   • Full-page security design dengan gradient background"
echo "   • Animasi pulse pada container"
echo "   • Warna berbeda untuk setiap halaman"
echo "   • Detail informasi akses yang ditolak"
echo "   • Log aktivitas mencurigakan"
EOF
