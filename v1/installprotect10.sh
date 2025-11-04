#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerViewController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Admin Server View..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Servers;

use Illuminate\Http\Request;
use Pterodactyl\Models\Server;
use Illuminate\Support\Facades\Auth;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Wings\DaemonServerRepository;
use Pterodactyl\Repositories\Eloquent\ServerRepository;

class ServerViewController extends Controller
{
    /**
     * ServerViewController constructor.
     */
    public function __construct(
        private ServerRepository $repository,
        private DaemonServerRepository $daemonServerRepository
    ) {}

    /**
     * Get the server index view.
     *
     * @throws \Illuminate\Auth\Access\AuthorizationException
     */
    public function index(Request $request)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        $servers = $this->repository->setSearchTerm($request->input('query'))->getAllServersForAdmin(
            $request->input('status'),
            config('pterodactyl.paginate.admin.servers')
        );

        return view('admin.servers.index', [
            'servers' => $servers,
            'status' => $request->input('status'),
        ]);
    }

    /**
     * Get the server view page.
     *
     * @throws \Illuminate\Auth\Access\AuthorizationException
     */
    public function show(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        $server->loadMissing(['allocations', 'egg', 'node']);

        return view('admin.servers.view.index', [
            'server' => $server,
            'allocations' => $server->allocations->sortBy('port')->sortBy('ip'),
            'egg' => $server->egg,
            'node' => $server->node,
        ]);
    }

    /**
     * Get the server details page.
     *
     * @throws \Illuminate\Auth\Access\AuthorizationException
     */
    public function details(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.details', [
            'server' => $server,
        ]);
    }

    /**
     * Get the server build configuration page.
     *
     * @throws \Illuminate\Auth\Access\AuthorizationException
     */
    public function build(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        $allocations = $server->node->allocations->sortBy('ip')->sortBy('port');

        return view('admin.servers.view.build', [
            'server' => $server,
            'allocations' => $allocations,
        ]);
    }

    /**
     * Get the server startup configuration page.
     *
     * @throws \Illuminate\Auth\Access\AuthorizationException
     */
    public function startup(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.startup', [
            'server' => $server,
        ]);
    }

    /**
     * Get the server database management page.
     *
     * @throws \Illuminate\Auth\Access\AuthorizationException
     */
    public function database(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.database', [
            'server' => $server,
        ]);
    }

    /**
     * Get the server management page.
     *
     * @throws \Illuminate\Auth\Access\AuthorizationException
     */
    public function manage(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.manage', [
            'server' => $server,
        ]);
    }

    /**
     * Get the server deletion page.
     *
     * @throws \Illuminate\Auth\Access\AuthorizationException
     */
    public function delete(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.delete', [
            'server' => $server,
        ]);
    }
}
?>
EOF

# Juga proteksi file index view untuk menghilangkan tabel server list
INDEX_VIEW_PATH="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
INDEX_BACKUP_PATH="${INDEX_VIEW_PATH}.bak_${TIMESTAMP}"

if [ -f "$INDEX_VIEW_PATH" ]; then
  mv "$INDEX_VIEW_PATH" "$INDEX_BACKUP_PATH"
  echo "📦 Backup index view dibuat di $INDEX_BACKUP_PATH"
fi

cat > "$INDEX_VIEW_PATH" << 'EOF'
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
@php
    $user = Auth::user();
@endphp

@if(!$user || $user->id !== 1)
    <div class="row">
        <div class="col-xs-12">
            <div class="alert alert-danger">
                <h4><i class="icon fa fa-ban"></i> Akses Ditolak</h4>
                𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati
            </div>
        </div>
    </div>
@else
<div class="row">
    <div class="col-xs-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Server List</h3>
                <div class="box-tools">
                    <a href="{{ route('admin.servers.new') }}" class="btn btn-sm btn-primary">Create New</a>
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
                            <th>Connection</th>
                            <th>Status</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($servers as $server)
                            <tr>
                                <td class="middle"><code>{{ $server->id }}</code></td>
                                <td class="middle">
                                    <a href="{{ route('admin.servers.view', $server->id) }}">{{ $server->name }}</a>
                                </td>
                                <td class="middle">
                                    <a href="{{ route('admin.users.view', $server->user->id) }}">{{ $server->user->username }}</a>
                                </td>
                                <td class="middle">
                                    <a href="{{ route('admin.nodes.view', $server->node->id) }}">{{ $server->node->name }}</a>
                                </td>
                                <td class="middle">
                                    <code>{{ $server->allocation->ip }}:{{ $server->allocation->port }}</code>
                                </td>
                                <td class="middle">
                                    @if(! is_null($server->status))
                                        @if($server->status === 'installing')
                                            <span class="label label-warning">Installing</span>
                                        @elseif($server->status === 'suspended')
                                            <span class="label label-danger">Suspended</span>
                                        @elseif($server->status === 'restoring_backup')
                                            <span class="label label-warning">Restoring Backup</span>
                                        @else
                                            <span class="label label-success">Active</span>
                                        @endif
                                    @else
                                        <span class="label label-default">Unknown</span>
                                    @endif
                                </td>
                                <td class="text-center">
                                    <a href="#" data-action="recovery" data-id="{{ $server->id }}">
                                        <i class="fa fa-refresh text-info"></i>
                                    </a>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            @if($servers->hasPages())
                <div class="box-footer with-border">
                    <div class="col-md-12 text-center">
                        {!! $servers->appends(['query' => Request::input('query')])->render() !!}
                    </div>
                </div>
            @endif
        </div>
    </div>
</div>
@endif
@endsection

@section('footer-scripts')
    @parent
    <script>
        $(document).ready(function() {
            $('[data-action="recovery"]').click(function (event) {
                event.preventDefault();
                var self = $(this);
                swal({
                    type: 'warning',
                    title: 'Recover Server',
                    text: 'This will attempt to recover a server that is stuck in a bad state.',
                    showCancelButton: true,
                    allowOutsideClick: true,
                    closeOnConfirm: false,
                    confirmButtonText: 'Recover',
                    confirmButtonColor: '#d9534f',
                    showLoaderOnConfirm: true
                }, function () {
                    $.ajax({
                        method: 'POST',
                        url: '/admin/servers/view/' + self.data('id') + '/recover',
                        headers: {
                            'X-CSRF-TOKEN': '{{ csrf_token() }}'
                        }
                    }).done(function () {
                        swal({
                            type: 'success',
                            title: 'Success',
                            text: 'Server has been queued for recovery.'
                        });
                    }).fail(function (jqXHR) {
                        console.error(jqXHR);
                        swal({
                            type: 'error',
                            title: 'Whoops!',
                            text: 'An error occurred while attempting to recover this server.'
                        });
                    });
                });
            });
        });
    </script>
@endsection
EOF

chmod 644 "$REMOTE_PATH"
chmod 644 "$INDEX_VIEW_PATH"

echo "✅ Proteksi Admin Server View berhasil dipasang!"
echo "📂 Lokasi file controller: $REMOTE_PATH"
echo "📂 Lokasi file view: $INDEX_VIEW_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Hanya Admin (ID 1) yang bisa akses Server List dan View."
echo "➕ Tombol 'Create New' tetap tersedia"
