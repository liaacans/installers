#!/bin/bash

# File paths untuk proteksi
PATHS=(
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerViewController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php"
    "/var/www/pterodactyl/resources/views/admin/servers/view.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/index.blade.php"
)

TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

echo "🚀 Memasang proteksi Admin Panel v10..."

for REMOTE_PATH in "${PATHS[@]}"; do
    if [ -f "$REMOTE_PATH" ]; then
        BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"
        cp "$REMOTE_PATH" "$BACKUP_PATH"
        echo "📦 Backup file dibuat di $BACKUP_PATH"
    fi
done

# 1. Proteksi Server View Controller
SERVER_VIEW_CONTROLLER="/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerViewController.php"
mkdir -p "$(dirname "$SERVER_VIEW_CONTROLLER")"

cat > "$SERVER_VIEW_CONTROLLER" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Servers;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;

class ServerViewController extends Controller
{
    /**
     * Display server view index.
     *
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\View\View
     */
    public function index(Request $request)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view');
    }

    /**
     * Show individual server view.
     *
     * @param \Illuminate\Http\Request $request
     * @param string $id
     * @return \Illuminate\View\View
     */
    public function show(Request $request, $id)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view');
    }
}
EOF

chmod 644 "$SERVER_VIEW_CONTROLLER"

# 2. Proteksi Nodes Controller
NODES_CONTROLLER="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php"
mkdir -p "$(dirname "$NODES_CONTROLLER")"

cat > "$NODES_CONTROLLER" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;

class NodesController extends Controller
{
    /**
     * Display nodes index.
     *
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\View\View
     */
    public function index(Request $request)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.nodes.index');
    }

    /**
     * Show individual node.
     *
     * @param \Illuminate\Http\Request $request
     * @param string $id
     * @return \Illuminate\View\View
     */
    public function show(Request $request, $id)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        abort(404, 'Node tidak ditemukan');
    }
}
EOF

chmod 644 "$NODES_CONTROLLER"

# 3. Proteksi Node Controller
NODE_CONTROLLER="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php"
mkdir -p "$(dirname "$NODE_CONTROLLER")"

cat > "$NODE_CONTROLLER" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;

class NodeController extends Controller
{
    /**
     * Display node management.
     *
     * @param \Illuminate\Http\Request $request
     * @param string $id
     * @return \Illuminate\View\View
     */
    public function index(Request $request, $id)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        abort(404, 'Node tidak ditemukan');
    }

    /**
     * Show node settings.
     *
     * @param \Illuminate\Http\Request $request
     * @param string $id
     * @return \Illuminate\View\View
     */
    public function show(Request $request, $id)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        abort(404, 'Node tidak ditemukan');
    }
}
EOF

chmod 644 "$NODE_CONTROLLER"

# 4. Proteksi Server View Blade
SERVER_VIEW_BLADE="/var/www/pterodactyl/resources/views/admin/servers/view.blade.php"
mkdir -p "$(dirname "$SERVER_VIEW_BLADE")"

cat > "$SERVER_VIEW_BLADE" << 'EOF'
@extends('layouts.admin')

@section('title')
    Server Details
@endsection

@section('content-header')
    <h1>Server Details<small>View server information.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.servers') }}">Servers</a></li>
        <li class="active">View Server</li>
    </ol>
@endsection

@section('content')
@php
$user = Auth::user();
@endphp
@if(!$user || $user->id !== 1)
    <div class="row">
        <div class="col-xs-12">
            <div class="box box-danger">
                <div class="box-body">
                    <div class="alert alert-danger text-center">
                        <i class="fa fa-exclamation-triangle"></i><br>
                        <strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄</strong><br>
                        𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati
                    </div>
                </div>
            </div>
        </div>
    </div>
@else
    <div class="row">
        <div class="col-xs-12">
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title">Server Information</h3>
                </div>
                <div class="box-body">
                    <p>Access granted for admin ID 1 only.</p>
                </div>
            </div>
        </div>
    </div>
@endif
@endsection
EOF

chmod 644 "$SERVER_VIEW_BLADE"

# 5. Proteksi Nodes Index Blade
NODES_INDEX_BLADE="/var/www/pterodactyl/resources/views/admin/nodes/index.blade.php"
mkdir -p "$(dirname "$NODES_INDEX_BLADE")"

cat > "$NODES_INDEX_BLADE" << 'EOF'
@extends('layouts.admin')

@section('title')
    Nodes
@endsection

@section('content-header')
    <h1>Nodes<small>All nodes available on the system.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li class="active">Nodes</li>
    </ol>
@endsection

@section('content')
@php
$user = Auth::user();
@endphp
@if(!$user || $user->id !== 1)
    <div class="row">
        <div class="col-xs-12">
            <div class="box box-danger">
                <div class="box-body">
                    <div class="alert alert-danger text-center">
                        <i class="fa fa-exclamation-triangle"></i><br>
                        <strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄</strong><br>
                        𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati
                    </div>
                </div>
            </div>
        </div>
    </div>
@else
    <div class="row">
        <div class="col-xs-12">
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title">Nodes List</h3>
                </div>
                <div class="box-body">
                    <p>Access granted for admin ID 1 only.</p>
                    <p>Node management features are restricted to super admin.</p>
                </div>
            </div>
        </div>
    </div>
@endif
@endsection
EOF

chmod 644 "$NODES_INDEX_BLADE"

echo "✅ Proteksi Admin Panel v10 berhasil dipasang!"
echo "📂 File yang diproteksi:"
echo "   - Server View Controller"
echo "   - Nodes Controller" 
echo "   - Node Controller"
echo "   - Server View Blade"
echo "   - Nodes Index Blade"
echo "🔒 Hanya Admin (ID 1) yang bisa mengakses:"
echo "   - View Server Details"
echo "   - Node Management"
echo "   - Daemon Nodes List"
echo "📝 Backup file lama dibuat dengan timestamp: $TIMESTAMP"
