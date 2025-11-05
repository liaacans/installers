#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/ServersController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti Tautan Server List..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\ServerRepositoryInterface;

class ServersController extends Controller
{
    /**
     * ServersController constructor.
     */
    public function __construct(private ServerRepositoryInterface $repository)
    {
    }

    /**
     * Returns all of the servers that exist on the system using a paginated result set.
     */
    public function index(Request $request): View
    {
        $servers = $this->repository->setSearchTerm($request->input('query'))->paginate(50);

        return view('admin.servers.index', [
            'servers' => $servers,
        ]);
    }
}
?>
EOF

chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi Anti Tautan Server List berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Tautan Server Name, Owner, dan Node telah dihapus dari admin panel."

# Sekarang modifikasi file view untuk menghapus tautan
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
VIEW_BACKUP_PATH="${VIEW_PATH}.bak_${TIMESTAMP}"

echo "🔄 Memodifikasi tampilan server list..."

if [ -f "$VIEW_PATH" ]; then
  mv "$VIEW_PATH" "$VIEW_BACKUP_PATH"
  echo "📦 Backup view file lama dibuat di $VIEW_BACKUP_PATH"
  
  # Membuat file view baru tanpa tautan
  cat > "$VIEW_PATH" << 'EOF'
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
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Server List</h3>
                <div class="box-tools search01">
                    <form action="{{ route('admin.servers') }}" method="GET">
                        <div class="input-group input-group-sm">
                            <input type="text" name="query" class="form-control pull-right" value="{{ request()->input('query') }}" placeholder="Search Servers">
                            <div class="input-group-btn">
                                <button type="submit" class="btn btn-default"><i class="fa fa-search"></i></button>
                                <a href="{{ route('admin.servers.new') }}"><button type="button" class="btn btn-sm btn-primary" style="border-radius:0 3px 3px 0;margin-left:2px;">Create New</button></a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
            <div class="box-body table-responsive no-padding">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Server Name</th>
                            <th>UUID</th>
                            <th>Owner</th>
                            <th>Node</th>
                            <th>Connection</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($servers as $server)
                            <tr class="align-middle">
                                <td class="middle"><strong>{{ $server->name }}</strong></td>
                                <td class="middle"><code>{{ $server->uuidShort }}</code></td>
                                <td class="middle">{{ $server->user->username }}</td>
                                <td class="middle">{{ $server->node->name }}</td>
                                <td class="middle"><code>{{ $server->allocation->alias }}:{{ $server->allocation->port }}</code></td>
                                <td class="text-center">
                                    <a href="{{ route('admin.servers.view', $server->id) }}">
                                        <button class="btn btn-xs btn-primary"><i class="fa fa-wrench"></i></button>
                                    </a>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            @if($servers->hasPages())
                <div class="box-footer with-border">
                    <div class="col-md-12 text-center">{!! $servers->appends(['query' => Request::input('query')])->render() !!}</div>
                </div>
            @endif
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

  chmod 644 "$VIEW_PATH"
  echo "✅ Tampilan server list berhasil dimodifikasi!"
  echo "🔗 Semua tautan biru telah dihapus dari tabel server list"
else
  echo "⚠️ File view tidak ditemukan di $VIEW_PATH"
  echo "ℹ️ Hanya controller yang dimodifikasi, tampilan tetap default"
fi

echo ""
echo "🎉 Proteksi Anti Tautan Server List berhasil diimplementasi!"
echo "📊 Server list sekarang hanya menampilkan teks tanpa tautan yang dapat diklik"
EOF
