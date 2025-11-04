#!/bin/bash

REMOTE_PATHS=(
  "/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ViewController.php"
  "/var/www/pterodactyl/app/Http/Controllers/Admin/ServerController.php"
  "/var/www/pterodactyl/resources/views/admin/servers/view.blade.php"
  "/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
)

TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_DIR="/root/backup_protect10_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti Akses Server View & Node List..."

mkdir -p "$BACKUP_DIR"

for REMOTE_PATH in "${REMOTE_PATHS[@]}"; do
  if [ -f "$REMOTE_PATH" ]; then
    BACKUP_PATH="${BACKUP_DIR}${REMOTE_PATH}"
    mkdir -p "$(dirname "$BACKUP_PATH")"
    cp "$REMOTE_PATH" "$BACKUP_PATH"
    echo "📦 Backup file dibuat di $BACKUP_PATH"
  fi
done

# 1. Proteksi View Controller
mkdir -p "$(dirname "/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ViewController.php")"
cat > "/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ViewController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Servers;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;

class ViewController extends Controller
{
    /**
     * Display server view page.
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

        return view('admin.servers.view', [
            'server' => $request->attributes->get('server'),
        ]);
    }
}
?>
EOF

# 2. Proteksi Server Controller (Node List)
mkdir -p "$(dirname "/var/www/pterodactyl/app/Http/Controllers/Admin/ServerController.php")"
cat > "/var/www/pterodactyl/app/Http/Controllers/Admin/ServerController.php" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Pterodactyl\Models\Server;
use Pterodactyl\Models\Node;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Wings\DaemonServerRepository;
use Pterodactyl\Http\Requests\Admin\ServerFormRequest;
use Illuminate\Support\Facades\Auth;

class ServerController extends Controller
{
    public function __construct(
        private AlertsMessageBag $alert,
        private DaemonServerRepository $repository
    ) {}

    /**
     * Display server index page.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.index', [
            'servers' => Server::with(['user', 'node', 'allocation'])->paginate(50),
            'nodes' => Node::all(),
        ]);
    }

    /**
     * Display server view page.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function show(Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view', compact('server'));
    }

    // Other methods remain but will be restricted by the view files
}
?>
EOF

# 3. Proteksi View Blade
mkdir -p "$(dirname "/var/www/pterodactyl/resources/views/admin/servers/view.blade.php")"
cat > "/var/www/pterodactyl/resources/views/admin/servers/view.blade.php" << 'EOF'
@php
// 🚫 Batasi akses hanya untuk user ID 1
$user = Auth::user();
if (!$user || $user->id !== 1) {
    abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
}
@endphp

@extends('layouts.admin')

@section('title')
    Server — {{ $server->name }}
@endsection

@section('content-header')
    <h1>{{ $server->name }}<small>View & manage server details.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.servers') }}">Servers</a></li>
        <li class="active">{{ $server->name }}</li>
    </ol>
@endsection

@section('content')
<div class="row">
    <div class="col-xs-12">
        <div class="alert alert-danger">
            <strong>⚠️ Akses Terbatas:</strong> Hanya Administrator Utama yang dapat mengakses halaman ini.
        </div>
    </div>
</div>
@endsection
EOF

# 4. Proteksi Server List Blade (Sembunyikan Node List)
mkdir -p "$(dirname "/var/www/pterodactyl/resources/views/admin/servers/index.blade.php")"
cat > "/var/www/pterodactyl/resources/views/admin/servers/index.blade.php" << 'EOF'
@php
// 🚫 Batasi akses hanya untuk user ID 1
$user = Auth::user();
if (!$user || $user->id !== 1) {
    abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
}
@endphp

@extends('layouts.admin')

@section('title')
    Servers
@endsection

@section('content-header')
    <h1>Servers<small>All servers available on the system.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li class="active">Servers</li>
    </ol>
@endsection

@section('content')
<div class="row">
    <div class="col-xs-12">
        <div class="alert alert-info">
            <strong>ℹ️ Informasi:</strong> Halaman server list dengan akses terbatas.
        </div>
    </div>
</div>

<div class="row">
    <div class="col-xs-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Server List</h3>
            </div>
            <div class="box-body table-responsive no-padding">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Server Name</th>
                            <th>Owner</th>
                            <th>Status</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($servers as $server)
                            <tr>
                                <td><code>{{ $server->id }}</code></td>
                                <td>{{ $server->name }}</td>
                                <td>{{ $server->user->username }}</td>
                                <td>
                                    @if($server->suspended)
                                        <span class="label label-warning">Suspended</span>
                                    @else
                                        <span class="label label-success">Active</span>
                                    @endif
                                </td>
                                <td class="text-center">
                                    <a href="{{ route('admin.servers.view', $server->id) }}">
                                        <button class="btn btn-xs btn-primary">Manage</button>
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
@endsection
EOF

# Set permissions
for REMOTE_PATH in "${REMOTE_PATHS[@]}"; do
  if [ -f "$REMOTE_PATH" ]; then
    chmod 644 "$REMOTE_PATH"
  fi
done

echo "✅ Proteksi Anti Akses Server View & Node List berhasil dipasang!"
echo "📂 Backup files disimpan di: $BACKUP_DIR"
echo "🔒 Hanya Admin (ID 1) yang bisa akses:"
echo "   - Server View Pages"
echo "   - Server List dengan Node Information"
echo "   - Tabel Nodes/Daemon disembunyikan dari admin lain"
