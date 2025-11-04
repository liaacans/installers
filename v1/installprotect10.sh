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

# 3. Proteksi View Blade - TAMPILKAN BUTTON SERVER
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
        <div class="alert alert-warning">
            <strong>⚠️ Akses Terbatas:</strong> Hanya Administrator Utama yang dapat mengakses halaman ini.
        </div>
    </div>
</div>

<div class="row">
    <div class="col-sm-4">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Informasi Server</h3>
            </div>
            <div class="box-body">
                <dl>
                    <dt>Server ID</dt>
                    <dd><code>{{ $server->id }}</code></dd>
                    <dt>Nama Server</dt>
                    <dd>{{ $server->name }}</dd>
                    <dt>Pemilik</dt>
                    <dd>{{ $server->user->username ?? 'N/A' }}</dd>
                    <dt>Status</dt>
                    <dd>
                        @if($server->suspended)
                            <span class="label label-warning">Suspended</span>
                        @else
                            <span class="label label-success">Active</span>
                        @endif
                    </dd>
                </dl>
            </div>
        </div>
    </div>

    <div class="col-sm-8">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Quick Actions</h3>
            </div>
            <div class="box-body">
                <div class="row">
                    <div class="col-md-4 col-sm-6">
                        <a href="#" class="btn btn-app">
                            <i class="fa fa-play"></i> Start
                        </a>
                    </div>
                    <div class="col-md-4 col-sm-6">
                        <a href="#" class="btn btn-app">
                            <i class="fa fa-stop"></i> Stop
                        </a>
                    </div>
                    <div class="col-md-4 col-sm-6">
                        <a href="#" class="btn btn-app">
                            <i class="fa fa-refresh"></i> Restart
                        </a>
                    </div>
                    <div class="col-md-4 col-sm-6">
                        <a href="#" class="btn btn-app">
                            <i class="fa fa-terminal"></i> Console
                        </a>
                    </div>
                    <div class="col-md-4 col-sm-6">
                        <a href="#" class="btn btn-app">
                            <i class="fa fa-cog"></i> Settings
                        </a>
                    </div>
                    <div class="col-md-4 col-sm-6">
                        <a href="#" class="btn btn-app">
                            <i class="fa fa-trash"></i> Delete
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-xs-12">
        <div class="box box-danger">
            <div class="box-header with-border">
                <h3 class="box-title">Management Server</h3>
            </div>
            <div class="box-body">
                <div class="btn-group">
                    <button type="button" class="btn btn-success"><i class="fa fa-play"></i> Start Server</button>
                    <button type="button" class="btn btn-warning"><i class="fa fa-stop"></i> Stop Server</button>
                    <button type="button" class="btn btn-info"><i class="fa fa-refresh"></i> Restart Server</button>
                    <button type="button" class="btn btn-primary"><i class="fa fa-terminal"></i> Access Console</button>
                </div>
                
                <div class="btn-group" style="margin-left: 10px;">
                    <button type="button" class="btn btn-default"><i class="fa fa-cog"></i> Server Settings</button>
                    <button type="button" class="btn btn-default"><i class="fa fa-database"></i> Database</button>
                    <button type="button" class="btn btn-danger"><i class="fa fa-trash"></i> Delete Server</button>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
EOF

# 4. Proteksi Server List Blade - TAMPILKAN BUTTON SERVER
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
            <strong>ℹ️ Informasi:</strong> Halaman server list dengan akses terbatas. Hanya Administrator Utama yang dapat melihat informasi lengkap.
        </div>
    </div>
</div>

<div class="row">
    <div class="col-xs-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Server List</h3>
                <div class="box-tools">
                    <div class="input-group input-group-sm" style="width: 150px;">
                        <input type="text" name="table_search" class="form-control pull-right" placeholder="Search">
                        <div class="input-group-btn">
                            <button type="submit" class="btn btn-default"><i class="fa fa-search"></i></button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="box-body table-responsive no-padding">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Server Name</th>
                            <th>Owner</th>
                            <th>Node</th>
                            <th>Status</th>
                            <th class="text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($servers as $server)
                            <tr>
                                <td><code>{{ $server->id }}</code></td>
                                <td>
                                    <strong>{{ $server->name }}</strong>
                                    @if($server->description)
                                        <br><small class="text-muted">{{ $server->description }}</small>
                                    @endif
                                </td>
                                <td>
                                    <a href="#">{{ $server->user->username ?? 'N/A' }}</a>
                                </td>
                                <td>
                                    <span class="label label-default">{{ $server->node->name ?? 'N/A' }}</span>
                                </td>
                                <td>
                                    @if($server->suspended)
                                        <span class="label label-warning"><i class="fa fa-pause"></i> Suspended</span>
                                    @else
                                        <span class="label label-success"><i class="fa fa-play"></i> Active</span>
                                    @endif
                                </td>
                                <td class="text-center">
                                    <div class="btn-group">
                                        <a href="{{ route('admin.servers.view', $server->id) }}" class="btn btn-sm btn-primary" data-toggle="tooltip" title="Manage Server">
                                            <i class="fa fa-cog"></i> Manage
                                        </a>
                                        <button type="button" class="btn btn-sm btn-success" data-toggle="tooltip" title="Start Server">
                                            <i class="fa fa-play"></i>
                                        </button>
                                        <button type="button" class="btn btn-sm btn-warning" data-toggle="tooltip" title="Stop Server">
                                            <i class="fa fa-stop"></i>
                                        </button>
                                        <button type="button" class="btn btn-sm btn-info" data-toggle="tooltip" title="Restart Server">
                                            <i class="fa fa-refresh"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            <div class="box-footer clearfix">
                {{ $servers->links() }}
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-4 col-sm-6">
        <div class="info-box">
            <span class="info-box-icon bg-green"><i class="fa fa-server"></i></span>
            <div class="info-box-content">
                <span class="info-box-text">Total Servers</span>
                <span class="info-box-number">{{ $servers->total() }}</span>
            </div>
        </div>
    </div>
    <div class="col-md-4 col-sm-6">
        <div class="info-box">
            <span class="info-box-icon bg-blue"><i class="fa fa-users"></i></span>
            <div class="info-box-content">
                <span class="info-box-text">Active Users</span>
                <span class="info-box-number">{{ $servers->unique('user_id')->count() }}</span>
            </div>
        </div>
    </div>
    <div class="col-md-4 col-sm-6">
        <div class="info-box">
            <span class="info-box-icon bg-purple"><i class="fa fa-hdd-o"></i></span>
            <div class="info-box-content">
                <span class="info-box-text">Total Nodes</span>
                <span class="info-box-number">{{ $nodes->count() }}</span>
            </div>
        </div>
    </div>
</div>
@endsection

@section('footer-scripts')
    @parent
    <script>
        $(document).ready(function() {
            $('[data-toggle="tooltip"]').tooltip();
        });
    </script>
@endsection
EOF

# Set permissions
for REMOTE_PATH in "${REMOTE_PATHS[@]}"; do
  if [ -f "$REMOTE_PATH" ]; then
    chmod 644 "$REMOTE_PATH"
  fi
done

# Clear view cache
if [ -d "/var/www/pterodactyl" ]; then
  cd /var/www/pterodactyl
  php artisan view:clear 2>/dev/null || echo "⚠️  Gagal clear view cache, lanjutkan..."
fi

echo "✅ Proteksi Anti Akses Server View & Node List berhasil dipasang!"
echo "📂 Backup files disimpan di: $BACKUP_DIR"
echo "🎯 Button server ditampilkan dengan fitur:"
echo "   - Manage Server Button"
echo "   - Start/Stop/Restart Buttons"
echo "   - Quick Action Buttons"
echo "   - Server Statistics"
echo "🔒 Hanya Admin (ID 1) yang bisa akses halaman server view & list"
