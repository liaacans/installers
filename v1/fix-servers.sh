#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/resources/scripts/admin/servers/index.blade.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti Modifikasi Servers List..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
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
<style>
.protection-notice {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 12px 15px;
    border-radius: 6px;
    margin-bottom: 20px;
    border-left: 4px solid #ffa502;
}
.protection-notice h5 {
    margin: 0 0 5px 0;
    font-weight: 600;
}
.protection-notice p {
    margin: 0;
    opacity: 0.9;
    font-size: 13px;
}
.server-table-modified {
    border: 2px solid #e9ecef;
    border-radius: 8px;
    overflow: hidden;
}
.server-table-modified th {
    background: #f8f9fa !important;
    border-bottom: 2px solid #dee2e6 !important;
}
.hidden-column {
    display: none;
}
</style>

<div class="row">
    <div class="col-xs-12">
        <div class="protection-notice">
            <h5>🛡️ Protected Servers List</h5>
            <p>Server owner and node information are hidden for security purposes. Protected by @ginaabaikhati</p>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-xs-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Server List</h3>
                <div class="box-tools">
                    <a href="{{ route('admin.servers.new') }}" class="btn btn-sm btn-primary">Create New</a>
                </div>
                <div class="box-tools" style="display: inline-block; margin-left: 10px;">
                    <div class="input-group input-group-sm" style="width: 200px;">
                        <input type="text" name="table_search" class="form-control pull-right" placeholder="Search">
                        <div class="input-group-btn">
                            <button type="submit" class="btn btn-default"><i class="fa fa-search"></i></button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="box-body table-responsive no-padding server-table-modified">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th class="hidden-column">Owner</th>
                            <th class="hidden-column">Node</th>
                            <th>Name</th>
                            <th>Connection</th>
                            <th>Active</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($servers as $server)
                            <tr>
                                <td class="hidden-column">{{ $server->user->username ?? 'N/A' }}</td>
                                <td class="hidden-column">{{ $server->node->name ?? 'N/A' }}</td>
                                <td>
                                    <a href="{{ route('admin.servers.view', $server->id) }}">
                                        <code>{{ $server->uuidShort }}</code> - {{ $server->name }}
                                    </a>
                                </td>
                                <td>
                                    <code>{{ $server->allocation->ip }}:{{ $server->allocation->port }}</code>
                                </td>
                                <td>
                                    @if($server->suspended)
                                        <span class="label label-danger">Suspended</span>
                                    @else
                                        <span class="label label-success">Active</span>
                                    @endif
                                </td>
                                <td style="text-align: right;">
                                    <a href="{{ route('admin.servers.view', $server->id) }}" class="btn btn-xs btn-primary">Manage</a>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            @if($servers->hasPages())
                <div class="box-footer with-border">
                    <div class="col-md-12 text-center">
                        {!! $servers->render() !!}
                    </div>
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

chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi Servers List berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo "🔒 Kolom Owner dan Node disembunyikan untuk keamanan."
