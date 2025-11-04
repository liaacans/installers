#!/bin/bash

# Konfigurasi path
NODES_VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view.blade.php"
SERVERS_INDEX_PATH="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

# Backup paths
NODES_BACKUP="${NODES_VIEW_PATH}.bak_${TIMESTAMP}"
SERVERS_BACKUP="${SERVERS_INDEX_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Admin Panel..."

# Proteksi untuk nodes/view
if [ -f "$NODES_VIEW_PATH" ]; then
  cp "$NODES_VIEW_PATH" "$NODES_BACKUP"
  echo "📦 Backup nodes view dibuat di $NODES_BACKUP"
fi

# Install proteksi nodes/view
cat > "$NODES_VIEW_PATH" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node — {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Detail lengkap node ini.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li class="active">{{ $node->name }}</li>
    </ol>
@endsection

@section('content')
<?php
// 🚫 Proteksi hanya untuk user ID 1
if (Auth::user()->id !== 1) {
    abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
}
?>
<div class="row">
    <div class="col-xs-12">
        <div class="nav-tabs-custom nav-tabs-floating">
            <ul class="nav nav-tabs">
                <li class="active"><a href="{{ route('admin.nodes.view', $node->id) }}">About</a></li>
                <li><a href="{{ route('admin.nodes.view.settings', $node->id) }}">Settings</a></li>
                <li><a href="{{ route('admin.nodes.view.configuration', $node->id) }}">Configuration</a></li>
                <li><a href="{{ route('admin.nodes.view.allocation', $node->id) }}">Allocations</a></li>
                <li><a href="{{ route('admin.nodes.view.servers', $node->id) }}">Servers</a></li>
            </ul>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-sm-8">
        <div class="row">
            <div class="col-xs-12">
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title">Information</h3>
                    </div>
                    <div class="box-body table-responsive no-padding">
                        <table class="table table-hover">
                            <tr>
                                <td>Name</td>
                                <td>{{ $node->name }}</td>
                            </tr>
                            <tr>
                                <td>Location</td>
                                <td>{{ $node->location->short }}</td>
                            </tr>
                            <tr>
                                <td>URL</td>
                                <td><code>{{ $node->getScheme() }}://{{ $node->fqdn }}:{{ $node->daemonListen }}/</code></td>
                            </tr>
                            <tr>
                                <td>Memory</td>
                                <td>{{ $node->memory }} MB</td>
                            </tr>
                            <tr>
                                <td>Disk</td>
                                <td>{{ $node->disk }} MB</td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-sm-4">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Usage Statistics</h3>
            </div>
            <div class="box-body">
                <div class="row">
                    <div class="col-xs-6">
                        <div class="info-box bg-blue">
                            <span class="info-box-icon"><i class="fa fa-server"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Servers</span>
                                <span class="info-box-number">{{ number_format($node->servers_count) }}</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-xs-6">
                        <div class="info-box bg-green">
                            <span class="info-box-icon"><i class="fa fa-plug"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Allocations</span>
                                <span class="info-box-number">{{ number_format($node->allocations_count) }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
EOF

echo "✅ Proteksi nodes/view berhasil dipasang!"

# Proteksi untuk servers/index
if [ -f "$SERVERS_INDEX_PATH" ]; then
  cp "$SERVERS_INDEX_PATH" "$SERVERS_BACKUP"
  echo "📦 Backup servers index dibuat di $SERVERS_BACKUP"
fi

# Install proteksi servers/index (menghilangkan owner dan node)
cat > "$SERVERS_INDEX_PATH" << 'EOF'
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
<?php
// 🚫 Proteksi hanya untuk user ID 1
if (Auth::user()->id !== 1) {
    abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
}
?>
<div class="row">
    <div class="col-xs-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Server List</h3>
                <div class="box-tools">
                    <div class="box-tools pull-right">
                        <a href="{{ route('admin.servers.new') }}" class="btn btn-sm btn-primary">Create New</a>
                    </div>
                    <div class="input-group input-group-sm">
                        <input type="text" class="form-control pull-right" name="table_search" placeholder="Search Servers">
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
                            <th>Name</th>
                            <th>Connection</th>
                            <th>Memory</th>
                            <th>Disk</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($servers as $server)
                            <tr>
                                <td>
                                    <a href="{{ route('admin.servers.view', $server->id) }}">{{ $server->name }}</a>
                                </td>
                                <td>
                                    <code>{{ $server->allocation->ip }}:{{ $server->allocation->port }}</code>
                                </td>
                                <td>{{ $server->memory }} MB</td>
                                <td>{{ $server->disk }} MB</td>
                                <td class="text-center">
                                    <a href="#" data-action="edit" data-id="{{ $server->id }}">
                                        <i class="fa fa-edit text-gray"></i>
                                    </a>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            @if($servers->hasPages())
                <div class="box-footer with-border">
                    <div class="col-md-12 text-center">{!! $servers->appends($_GET)->render() !!}</div>
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
            $('input[name="table_search"]').on('keyup', function() {
                var value = $(this).val().toLowerCase();
                $('table tbody tr').filter(function() {
                    $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
                });
            });
        });
    </script>
@endsection
EOF

echo "✅ Proteksi servers/index berhasil dipasang!"
echo "🔒 Hanya Admin (ID 1) yang bisa akses panel!"
echo "📂 Backup files:"
echo "   - $NODES_BACKUP"
echo "   - $SERVERS_BACKUP"
