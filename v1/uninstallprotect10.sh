#!/bin/bash

echo "🛠️  Menghapus proteksi dari SEMUA server..."

# File paths
INDEX_FILE="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"

# Find latest backup for index file
INDEX_BACKUP=$(ls -t "${INDEX_FILE}.bak_"* 2>/dev/null | head -n1)

# Restore index file
if [ -n "$INDEX_BACKUP" ]; then
    echo "✅ Memulihkan index file dari backup: $INDEX_BACKUP"
    cp -f "$INDEX_BACKUP" "$INDEX_FILE"
    echo "📦 Index file berhasil dipulihkan"
else
    echo "⚠️  Backup index tidak ditemukan, membuat file default..."
    # Create default index file
    cat > "$INDEX_FILE" << 'EOF'
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
                                    <a href="{{ route('admin.servers.view', $server->id) }}" class="btn btn-xs btn-primary">
                                        <i class="fa fa-wrench"></i> Manage
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
EOF
fi

# Restore all view files from backups
echo "🔄 Memulihkan semua view server..."
find /var/www/pterodactyl/resources/views/admin/servers/view -name "*.blade.php.bak_*" -type f | while read backup_file; do
    original_file="${backup_file%.bak_*}"
    echo "✅ Memulihkan: $original_file"
    cp -f "$backup_file" "$original_file"
done

# Remove any protected view files that don't have backups
find /var/www/pterodactyl/resources/views/admin/servers/view -name "*.blade.php" -type f | while read view_file; do
    if ! grep -q "ULTIMATE SECURITY SYSTEM" "$view_file" 2>/dev/null; then
        continue
    fi
    
    backup_file=$(ls -t "${view_file}.bak_"* 2>/dev/null | head -n1)
    if [ -z "$backup_file" ]; then
        echo "🗑️  Menghapus protected view: $view_file"
        rm -f "$view_file"
    fi
done

# Set proper permissions
chmod 644 "$INDEX_FILE"

# Clear cache
echo "🔄 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear
php artisan cache:clear

echo ""
echo "🎉 UNINSTALL BERHASIL!"
echo "✅ Semua proteksi telah dihapus"
echo "✅ SEMUA server sekarang dapat di-manage normal"
echo "✅ Tombol manage berfungsi kembali"
echo "✅ View server dapat diakses normal"
echo "🔓 Sistem kembali normal sepenuhnya"

echo ""
echo "⚠️  CATATAN:"
echo "Backup file masih disimpan dengan ekstensi .bak_*"
echo "Hapus manual jika tidak diperlukan lagi"
