#!/bin/bash

# Konfigurasi path
NODES_VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view.blade.php"
SERVERS_INDEX_PATH="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
BACKUP_DIR="/var/www/pterodactyl/resources/views/admin/backups"

echo "🔄 Memulai proses uninstall proteksi..."

# Cek dan restore backup untuk nodes/view
BACKUP_FILES_NODES=$(ls -t "${NODES_VIEW_PATH}.bak_"* 2>/dev/null | head -1)
if [ -n "$BACKUP_FILES_NODES" ]; then
    echo "📦 Menemukan backup nodes view: $BACKUP_FILES_NODES"
    cp "$BACKUP_FILES_NODES" "$NODES_VIEW_PATH"
    echo "✅ Nodes view berhasil dikembalikan ke versi original"
    
    # Opsional: hapus file backup
    read -p "🗑️ Hapus file backup? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$BACKUP_FILES_NODES"
        echo "✅ Backup nodes view dihapus"
    fi
else
    echo "⚠️ Tidak ditemukan backup untuk nodes view"
    echo "📝 Membuat backup sebelum uninstall..."
    TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
    cp "$NODES_VIEW_PATH" "${NODES_VIEW_PATH}.pre_uninstall_${TIMESTAMP}.bak"
    
    # Reset ke template default nodes view
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
    echo "✅ Nodes view berhasil direset ke default"
fi

# Cek dan restore backup untuk servers/index
BACKUP_FILES_SERVERS=$(ls -t "${SERVERS_INDEX_PATH}.bak_"* 2>/dev/null | head -1)
if [ -n "$BACKUP_FILES_SERVERS" ]; then
    echo "📦 Menemukan backup servers index: $BACKUP_FILES_SERVERS"
    cp "$BACKUP_FILES_SERVERS" "$SERVERS_INDEX_PATH"
    echo "✅ Servers index berhasil dikembalikan ke versi original"
    
    # Opsional: hapus file backup
    read -p "🗑️ Hapus file backup? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$BACKUP_FILES_SERVERS"
        echo "✅ Backup servers index dihapus"
    fi
else
    echo "⚠️ Tidak ditemukan backup untuk servers index"
    echo "📝 Membuat backup sebelum uninstall..."
    TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
    cp "$SERVERS_INDEX_PATH" "${SERVERS_INDEX_PATH}.pre_uninstall_${TIMESTAMP}.bak"
    
    # Reset ke template default servers index
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
                            <th>Owner</th>
                            <th>Node</th>
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
                                    <a href="{{ route('admin.users.view', $server->user->id) }}">{{ $server->user->username }}</a>
                                </td>
                                <td>
                                    <a href="{{ route('admin.nodes.view', $server->node->id) }}">{{ $server->node->name }}</a>
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
    echo "✅ Servers index berhasil direset ke default"
fi

echo "🎉 Uninstall proteksi berhasil!"
echo "🔓 Panel sekarang dapat diakses oleh semua admin"
echo "📂 File yang dipulihkan:"
echo "   - $NODES_VIEW_PATH"
echo "   - $SERVERS_INDEX_PATH"
