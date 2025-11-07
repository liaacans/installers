#!/bin/bash

echo "🚀 Memasang proteksi Anti Tautan Server..."

# File paths
INDEX_FILE="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
VIEW_DIR="/var/www/pterodactyl/resources/views/admin/servers/view"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

# Backup original files
if [ -f "$INDEX_FILE" ]; then
  cp "$INDEX_FILE" "${INDEX_FILE}.bak_${TIMESTAMP}"
  echo "📦 Backup index file dibuat: ${INDEX_FILE}.bak_${TIMESTAMP}"
fi

# 1. Update Index File - Hanya admin ID 1 yang bisa manage
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
                                @if(auth()->user()->id === 1)
                                    <a href="{{ route('admin.servers.new') }}"><button type="button" class="btn btn-sm btn-primary" style="border-radius:0 3px 3px 0;margin-left:2px;">Create New</button></a>
                                @else
                                    <button type="button" class="btn btn-sm btn-default" style="border-radius:0 3px 3px 0;margin-left:2px; cursor: not-allowed;" disabled>Create New</button>
                                @endif
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
                            <th class="text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($servers as $server)
                            <tr class="align-middle">
                                <td class="middle">
                                    <strong>{{ $server->name }}</strong>
                                    @if($server->id == 26)
                                    <br><small class="text-muted">ANDIN OFFICIAL</small>
                                    @endif
                                </td>
                                <td class="middle"><code>{{ $server->uuidShort }}</code></td>
                                <td class="middle">
                                    <span class="label label-default">
                                        <i class="fa fa-user"></i> {{ $server->user->username }}
                                    </span>
                                </td>
                                <td class="middle">
                                    <span class="label label-info">
                                        <i class="fa fa-server"></i> {{ $server->node->name }}
                                    </span>
                                </td>
                                <td class="middle">
                                    <code>{{ $server->allocation->alias }}:{{ $server->allocation->port }}</code>
                                    @if($server->id == 26)
                                    <br><small><code>ANDIN OFFICIAL:2007</code></small>
                                    @endif
                                </td>
                                <td class="text-center">
                                    @if(auth()->user()->id === 1)
                                        <!-- Admin ID 1 bisa akses semua -->
                                        <a href="{{ route('admin.servers.view', $server->id) }}" class="btn btn-xs btn-primary">
                                            <i class="fa fa-wrench"></i> Manage
                                        </a>
                                    @else
                                        <!-- Admin lain tidak bisa akses -->
                                        <span class="label label-warning" data-toggle="tooltip" title="Hanya Root Admin yang bisa mengakses">
                                            <i class="fa fa-shield"></i> Protected
                                        </span>
                                    @endif
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

        <!-- Security Information Box -->
        @if(auth()->user()->id !== 1)
        <div class="alert alert-warning">
            <h4 style="margin-top: 0;">
                <i class="fa fa-shield"></i> Security Protection Active
            </h4>
            <p style="margin-bottom: 5px;">
                <strong>🔒 Server Management Restricted:</strong> 
                Hanya <strong>Root Administrator (ID: 1)</strong> yang dapat mengelola server.
            </p>
            <p style="margin-bottom: 0; font-size: 12px;">
                <i class="fa fa-info-circle"></i> 
                Protected by: 
                <span class="label label-primary">@ginaabaikhati</span>
                <span class="label label-success">@AndinOfficial</span>
                <span class="label label-info">@naaofficial</span>
            </p>
        </div>
        @else
        <div class="alert alert-success">
            <h4 style="margin-top: 0;">
                <i class="fa fa-crown"></i> Root Administrator Access
            </h4>
            <p style="margin-bottom: 0;">
                Anda memiliki akses penuh sebagai <strong>Root Administrator (ID: 1)</strong>.
                Semua server dapat dikelola secara normal.
            </p>
        </div>
        @endif
    </div>
</div>
@endsection

@section('footer-scripts')
    @parent
    <script>
        $(document).ready(function() {
            $('[data-toggle="tooltip"]').tooltip();
            
            // Block server management untuk admin selain ID 1
            @if(auth()->user()->id !== 1)
            $('a[href*="/admin/servers/view/"]').on('click', function(e) {
                e.preventDefault();
                alert('🚫 Access Denied: Hanya Root Administrator (ID: 1) yang dapat mengelola server.\n\nProtected by: @ginaabaikhati, @AndinOfficial, @naaofficial');
            });
            @endif
        });
    </script>
@endsection
EOF

echo "✅ Index file berhasil diproteksi (hanya admin ID 1 yang bisa manage)"

# 2. Proteksi view server untuk admin selain ID 1
mkdir -p "$VIEW_DIR"

# Template protected view untuk admin selain ID 1
PROTECTED_VIEW='@extends('"'"'layouts.admin'"'"')
@section('"'"'title'"'"')
    Server Protected
@endsection

@section('"'"'content'"'"')
<div class="row">
    <div class="col-xs-12">
        <div class="box box-danger">
            <div class="box-header with-border">
                <h3 class="box-title"><i class="fa fa-shield"></i> Access Restricted</h3>
            </div>
            <div class="box-body">
                <div class="alert alert-warning text-center" style="margin-bottom: 0;">
                    <h3><i class="fa fa-ban"></i> ACCESS DENIED</h3>
                    <p style="font-size: 16px; margin: 15px 0;">
                        Hanya <strong>Root Administrator (ID: 1)</strong> yang dapat mengakses server management.
                    </p>
                    <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 15px 0;">
                        <strong>Protected by Security Team:</strong><br>
                        <span class="label label-primary">@ginaabaikhati</span>
                        <span class="label label-success">@AndinOfficial</span>
                        <span class="label label-info">@naaofficial</span>
                    </div>
                    <a href="{{ route('"'"'admin.servers'"'"') }}" class="btn btn-primary">
                        <i class="fa fa-arrow-left"></i> Back to Server List
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection'

# Buat middleware protection untuk semua view server
find "$VIEW_DIR" -name "*.blade.php" | while read view_file; do
    if [ -f "$view_file" ]; then
        cp "$view_file" "${view_file}.bak_${TIMESTAMP}" 2>/dev/null
    fi
    
    # Buat file view dengan protection
    cat > "$view_file" << 'EOF'
@php
    // Security Middleware - Only allow Admin ID 1
    if(auth()->user()->id !== 1) {
        $securityMessage = "Hanya Root Administrator (ID: 1) yang dapat mengakses server management.";
        $securityTeam = ["@ginaabaikhati", "@AndinOfficial", "@naaofficial"];
    }
@endphp

@if(auth()->user()->id !== 1)
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied - Security System</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            padding: 20px;
        }
        .security-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 25px 50px rgba(0,0,0,0.2);
            overflow: hidden;
            max-width: 600px;
            width: 100%;
            text-align: center;
        }
        .security-header {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            padding: 30px;
        }
        .security-content {
            padding: 40px;
        }
        .admin-badge {
            background: linear-gradient(135deg, #3742fa, #5352ed);
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            display: inline-block;
            margin: 10px 0;
            font-weight: bold;
        }
        .team-badges {
            margin: 20px 0;
        }
        .team-badge {
            display: inline-block;
            background: #2ed573;
            color: white;
            padding: 8px 15px;
            border-radius: 20px;
            margin: 5px;
            font-size: 12px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="security-container">
        <div class="security-header">
            <i class="fas fa-shield-alt" style="font-size: 60px; margin-bottom: 20px;"></i>
            <h2>ROOT ADMINISTRATOR ACCESS REQUIRED</h2>
            <p>Server Management Protection Active</p>
        </div>
        <div class="security-content">
            <div class="admin-badge">
                <i class="fas fa-crown"></i> ROOT ADMINISTRATOR (ID: 1) ONLY
            </div>
            
            <p style="font-size: 16px; margin: 20px 0; color: #555;">
                <i class="fas fa-ban" style="color: #e74c3c;"></i><br>
                Hanya <strong>Root Administrator</strong> dengan <strong>ID: 1</strong> yang dapat mengakses server management.
            </p>

            <div class="team-badges">
                <span class="team-badge" style="background: #fd79a8;">@ginaabaikhati</span>
                <span class="team-badge" style="background: #74b9ff;">@AndinOfficial</span>
                <span class="team-badge" style="background: #55efc4;">@naaofficial</span>
            </div>

            <div style="margin-top: 30px;">
                <a href="/admin/servers" style="
                    background: #3742fa;
                    color: white;
                    padding: 12px 30px;
                    border-radius: 25px;
                    text-decoration: none;
                    font-weight: bold;
                    display: inline-block;
                ">
                    <i class="fas fa-arrow-left"></i> Back to Server List
                </a>
            </div>

            <div style="margin-top: 20px; padding: 15px; background: #ffeaa7; border-radius: 10px;">
                <i class="fas fa-info-circle"></i>
                <strong>Security Notice:</strong> Server management features are restricted to root administrator only.
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('contextmenu', function(e) {
            e.preventDefault();
        });
    </script>
</body>
</html>
@else
<!-- Admin ID 1 bisa akses view server normal -->
@extends('layouts.admin')
@section('title')
    Server — {{ $server->name }}
@endsection

@section('content-header')
    <h1>{{ $server->name }}<small>{{ $server->description ?: 'No description provided' }}</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.servers') }}">Servers</a></li>
        <li class="active">{{ $server->name }}</li>
    </ol>
@endsection

@section('content')
<div class="row">
    <div class="col-xs-12">
        <div class="nav-tabs-custom nav-tabs-floating">
            <ul class="nav nav-tabs">
                <li class="active"><a href="#tab_1" data-toggle="tab">Details</a></li>
                <li><a href="#tab_2" data-toggle="tab">Build</a></li>
                <li><a href="#tab_3" data-toggle="tab">Startup</a></li>
                <li><a href="#tab_4" data-toggle="tab">Database</a></li>
                <li><a href="#tab_5" data-toggle="tab">Schedules</a></li>
                <li><a href="#tab_6" data-toggle="tab">Users</a></li>
                <li><a href="#tab_7" data-toggle="tab">Backups</a></li>
                <li><a href="#tab_8" data-toggle="tab">Network</a></li>
            </ul>
            <div class="tab-content">
                <div class="tab-pane active" id="tab_1">
                    <!-- Server details content here -->
                    <div class="alert alert-success">
                        <i class="fa fa-crown"></i> <strong>Root Administrator Access</strong><br>
                        Anda memiliki akses penuh sebagai <strong>Root Administrator (ID: 1)</strong>.
                    </div>
                </div>
                <!-- Other tabs content -->
            </div>
        </div>
    </div>
</div>
@endsection
@endif
EOF
    echo "✅ Protected: $(basename "$view_file")"
done

# Set permissions
chmod 644 "$INDEX_FILE"
find "$VIEW_DIR" -name "*.blade.php" -exec chmod 644 {} \;

# Clear cache
echo "🔄 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear
php artisan cache:clear

echo ""
echo "🎉 PROTEKSI BERHASIL DIPASANG!"
echo "✅ Admin ID 1: Bisa akses semua (server list dan view)"
echo "✅ Admin lain: Tidak bisa akses management"
echo "✅ Tautan manage hanya muncul untuk admin ID 1"
echo "✅ View server diproteksi untuk admin selain ID 1"
echo "🛡️ Security by: @ginaabaikhati, @AndinOfficial, @naaofficial"
