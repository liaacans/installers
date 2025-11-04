#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/admin/servers/view/1"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Admin Only untuk Server List..."

if [ -d "$REMOTE_PATH" ]; then
  cp -r "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup folder lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$REMOTE_PATH"
chmod 755 "$REMOTE_PATH"

# File utama untuk view server
cat > "$REMOTE_PATH/index.blade.php" << 'EOF'
@extends('admin.layouts.default')

@section('title')
    Servers • Admin
@endsection

@section('content')
<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Servers</h3>
                <div class="card-tools">
                    <a href="{{ route('admin.servers.new') }}" class="btn btn-primary btn-sm">
                        <i class="fas fa-plus"></i> Create New
                    </a>
                </div>
            </div>
            <div class="card-body">
                @php
                    $user = Auth::user();
                @endphp
                
                @if(!$user || $user->id !== 1)
                    <div class="alert alert-danger text-center">
                        <h4><i class="fas fa-ban"></i> Akses Ditolak</h4>
                        <p class="mb-0">Hanya Administrator yang dapat mengakses halaman ini.</p>
                        <p class="mb-0">𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati</p>
                    </div>
                @else
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Owner</th>
                                    <th>Node</th>
                                    <th>Status</th>
                                    <th>Created</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($servers as $server)
                                <tr>
                                    <td>{{ $server->id }}</td>
                                    <td>
                                        <a href="{{ route('admin.servers.view', $server->id) }}">
                                            {{ $server->name }}
                                        </a>
                                    </td>
                                    <td>{{ $server->user->username ?? 'N/A' }}</td>
                                    <td>
                                        @if($server->node)
                                            {{ $server->node->name }}
                                        @else
                                            <span class="text-muted">N/A</span>
                                        @endif
                                    </td>
                                    <td>
                                        <span class="badge badge-{{ $server->status === 'installing' ? 'warning' : ($server->status === 'suspended' ? 'danger' : 'success') }}">
                                            {{ ucfirst($server->status) }}
                                        </span>
                                    </td>
                                    <td>{{ $server->created_at->format('Y-m-d') }}</td>
                                    <td>
                                        <div class="btn-group">
                                            <a href="{{ route('admin.servers.view', $server->id) }}" class="btn btn-sm btn-primary">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <a href="{{ route('admin.servers.settings', $server->id) }}" class="btn btn-sm btn-info">
                                                <i class="fas fa-cog"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                    
                    @if($servers->hasPages())
                        <div class="card-footer">
                            {{ $servers->links() }}
                        </div>
                    @endif
                @endif
            </div>
        </div>
    </div>
</div>
@endsection
EOF

# File untuk create new server
cat > "$REMOTE_PATH/new.blade.php" << 'EOF'
@extends('admin.layouts.default')

@section('title')
    Create Server • Admin
@endsection

@section('content')
<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Create New Server</h3>
                <div class="card-tools">
                    <a href="{{ route('admin.servers') }}" class="btn btn-secondary btn-sm">
                        <i class="fas fa-arrow-left"></i> Back to Servers
                    </a>
                </div>
            </div>
            <div class="card-body">
                @php
                    $user = Auth::user();
                @endphp
                
                @if(!$user || $user->id !== 1)
                    <div class="alert alert-danger text-center">
                        <h4><i class="fas fa-ban"></i> Akses Ditolak</h4>
                        <p class="mb-0">Hanya Administrator yang dapat mengakses halaman ini.</p>
                        <p class="mb-0">𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati</p>
                    </div>
                @else
                    <form action="{{ route('admin.servers.create') }}" method="POST">
                        @csrf
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="name">Server Name *</label>
                                    <input type="text" class="form-control" id="name" name="name" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="user_id">Owner *</label>
                                    <select class="form-control" id="user_id" name="user_id" required>
                                        <option value="">Select User</option>
                                        @foreach($users as $user)
                                            <option value="{{ $user->id }}">{{ $user->email }} ({{ $user->username }})</option>
                                        @endforeach
                                    </select>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="node_id">Node *</label>
                                    <select class="form-control" id="node_id" name="node_id" required>
                                        <option value="">Select Node</option>
                                        @foreach($nodes as $node)
                                            <option value="{{ $node->id }}">{{ $node->name }}</option>
                                        @endforeach
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="nest_id">Nest *</label>
                                    <select class="form-control" id="nest_id" name="nest_id" required>
                                        <option value="">Select Nest</option>
                                        @foreach($nests as $nest)
                                            <option value="{{ $nest->id }}">{{ $nest->name }}</option>
                                        @endforeach
                                    </select>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="description">Description</label>
                            <textarea class="form-control" id="description" name="description" rows="3"></textarea>
                        </div>
                        
                        <div class="text-right">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save"></i> Create Server
                            </button>
                        </div>
                    </form>
                @endif
            </div>
        </div>
    </div>
</div>
@endsection
EOF

chmod 644 "$REMOTE_PATH/index.blade.php"
chmod 644 "$REMOTE_PATH/new.blade.php"

echo "✅ Proteksi Admin Only untuk Server List berhasil dipasang!"
echo "📂 Lokasi folder: $REMOTE_PATH"
echo "🗂️ Backup folder lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Hanya Admin (ID 1) yang bisa melihat Server List dan Nodes"
echo "➕ Tombol 'Create New' tetap tersedia untuk Admin"
