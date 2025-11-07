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

# 1. Update Index File - Sembunyikan tautan manage untuk SEMUA server
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
                            <th>Status</th>
                            <th class="text-center">Security</th>
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
                                        <i class="fa fa-user-secret"></i> {{ $server->user->username }}
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
                                <td class="middle">
                                    <span class="label label-success"><i class="fa fa-circle"></i> Online</span>
                                </td>
                                <td class="text-center">
                                    <span class="label label-warning" data-toggle="tooltip" title="Protected by Security System">
                                        <i class="fa fa-shield"></i> Protected
                                    </span>
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
        <div class="alert alert-success" style="margin-top: 20px;">
            <h4 style="margin-top: 0;">
                <i class="fa fa-shield"></i> Security Protection Active
            </h4>
            <p style="margin-bottom: 5px;">
                <strong>🔒 Server Management Protected by:</strong> 
                <span class="label label-primary">@ginaabaikhati</span>
                <span class="label label-success">@AndinOfficial</span>
                <span class="label label-info">@naaofficial</span>
            </p>
            <p style="margin-bottom: 0; font-size: 12px;">
                <i class="fa fa-info-circle"></i> 
                Server management features have been disabled for security reasons. All servers are protected by the security system.
            </p>
        </div>
    </div>
</div>
@endsection

@section('footer-scripts')
    @parent
    <script>
        $(document).ready(function() {
            $('[data-toggle="tooltip"]').tooltip();
            
            // Block any attempts to access server management
            $('a[href*="/admin/servers/view/"]').on('click', function(e) {
                e.preventDefault();
                alert('🚫 Access Denied: Server management is disabled by security system\n\nProtected by: @ginaabaikhati, @AndinOfficial, @naaofficial');
            });

            // Add security protection
            document.addEventListener('contextmenu', function(e) {
                e.preventDefault();
            });

            // Prevent F12, Ctrl+Shift+I, etc.
            document.addEventListener('keydown', function(e) {
                if (e.key === 'F12' || 
                    (e.ctrlKey && e.shiftKey && e.key === 'I') ||
                    (e.ctrlKey && e.shiftKey && e.key === 'J') ||
                    (e.ctrlKey && e.key === 'u')) {
                    e.preventDefault();
                }
            });
        });
    </script>
@endsection
EOF

echo "✅ Index file berhasil diproteksi (tautan manage disembunyikan)"

# 2. Proteksi SEMUA view server
mkdir -p "$VIEW_DIR"

# Proteksi khusus untuk server 26
SERVER_26="$VIEW_DIR/26.blade.php"
if [ -f "$SERVER_26" ]; then
    cp "$SERVER_26" "${SERVER_26}.bak_${TIMESTAMP}"
fi

cat > "$SERVER_26" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Protected - Security System</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .security-container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.2);
            overflow: hidden;
            max-width: 800px;
            width: 100%;
        }
        .security-header {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        .security-content {
            padding: 40px;
        }
        .protection-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 20px;
            border-left: 5px solid #3742fa;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        .server-specs {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        .spec-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 15px 0;
        }
        .spec-item {
            text-align: center;
            padding: 15px;
            background: white;
            border-radius: 8px;
            border: 1px solid #e9ecef;
        }
        .security-badge {
            display: inline-block;
            background: #2ed573;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            margin: 5px;
            font-size: 12px;
            font-weight: bold;
        }
        .connection-info {
            background: #2d3436;
            color: white;
            padding: 15px;
            border-radius: 10px;
            margin: 15px 0;
            font-family: 'Courier New', monospace;
        }
        .credits-section {
            background: linear-gradient(135deg, #74b9ff, #0984e3);
            color: white;
            padding: 25px;
            border-radius: 15px;
            text-align: center;
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <div class="security-container">
        <div class="security-header">
            <i class="fas fa-shield-alt" style="font-size: 60px; margin-bottom: 20px;"></i>
            <h1>ANDIN OFFICIAL - PROTECTED</h1>
            <p>Server ID: 26 • Ultimate Security System</p>
        </div>
        
        <div class="security-content">
            <div class="protection-card">
                <h3><i class="fas fa-ban" style="color: #e74c3c;"></i> Management Disabled</h3>
                <p>Server management features have been permanently disabled for security protection.</p>
                
                <div style="text-align: center; margin: 20px 0;">
                    <span class="security-badge"><i class="fas fa-shield-alt"></i> ANTI-LINK</span>
                    <span class="security-badge"><i class="fas fa-lock"></i> READ-ONLY</span>
                    <span class="security-badge"><i class="fas fa-ban"></i> NO SETTINGS</span>
                </div>
            </div>

            <div class="server-specs">
                <h4><i class="fas fa-server"></i> Server Specifications</h4>
                
                <div class="connection-info">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                        <div>
                            <strong>Default Connection:</strong><br>
                            <code>0.0.0.0:2007</code>
                        </div>
                        <div>
                            <strong>Connection Alias:</strong><br>
                            <code>ANDIN OFFICIAL:2007</code>
                        </div>
                    </div>
                </div>

                <div class="spec-grid">
                    <div class="spec-item">
                        <i class="fas fa-hdd" style="color: #3498db; font-size: 24px;"></i>
                        <div style="margin-top: 10px;">
                            <strong>Disk Space</strong><br>
                            <span style="color: #27ae60;">Unlimited</span>
                        </div>
                    </div>
                    <div class="spec-item">
                        <i class="fas fa-network-wired" style="color: #9b59b6; font-size: 24px;"></i>
                        <div style="margin-top: 10px;">
                            <strong>Block IO Weight</strong><br>
                            <span style="color: #27ae60;">500</span>
                        </div>
                    </div>
                    <div class="spec-item">
                        <i class="fas fa-microchip" style="color: #e74c3c; font-size: 24px;"></i>
                        <div style="margin-top: 10px;">
                            <strong>CPU Limit</strong><br>
                            <span style="color: #27ae60;">100%</span>
                        </div>
                    </div>
                    <div class="spec-item">
                        <i class="fas fa-memory" style="color: #f39c12; font-size: 24px;"></i>
                        <div style="margin-top: 10px;">
                            <strong>Memory</strong><br>
                            <span style="color: #27ae60;">Unlimited</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="credits-section">
                <h3><i class="fas fa-award"></i> SECURITY PROTECTION</h3>
                <p style="margin: 15px 0;">
                    <strong>Protected by Elite Security Team:</strong><br>
                    <span style="font-size: 18px;">
                        <span style="color: #fd79a8;">@ginaabaikhati</span> • 
                        <span style="color: #81ecec;">@AndinOfficial</span> • 
                        <span style="color: #55efc4;">@naaofficial</span>
                    </span>
                </p>
                <p style="margin-bottom: 0; font-size: 14px;">
                    <i class="fas fa-star"></i> Pterodactyl ID Security System <i class="fas fa-star"></i>
                </p>
            </div>
        </div>
    </div>

    <script>
        // Security protection
        document.addEventListener('contextmenu', function(e) {
            e.preventDefault();
        });

        document.addEventListener('keydown', function(e) {
            if (e.key === 'F12' || 
                (e.ctrlKey && e.shiftKey && e.key === 'I') ||
                (e.ctrlKey && e.shiftKey && e.key === 'J') ||
                (e.ctrlKey && e.key === 'u')) {
                e.preventDefault();
                alert('🚫 Developer tools disabled for security');
            }
        });

        // Auto-redirect to server list
        setTimeout(() => {
            window.location.href = '/admin/servers';
        }, 8000);
    </script>
</body>
</html>
EOF

echo "✅ Protected view untuk server 26 berhasil dibuat"

# 3. Proteksi untuk SEMUA view server lainnya
echo "🛡️ Membuat proteksi untuk semua view server..."

PROTECTED_VIEW='<!DOCTYPE html>
<html>
<head>
    <title>Server Protected</title>
    <style>
        body {
            background: linear-gradient(135deg, #667eea, #764ba2);
            font-family: Arial, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }
        .protection-box {
            background: white;
            padding: 40px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            max-width: 500px;
            width: 100%;
        }
    </style>
</head>
<body>
    <div class="protection-box">
        <div style="font-size: 60px; margin-bottom: 20px;">🛡️</div>
        <h2>Server Protected</h2>
        <p>This server is protected by security system.</p>
        <div style="margin-top: 20px; padding: 15px; background: #f8f9fa; border-radius: 10px;">
            <strong>Security Team:</strong><br>
            @ginaabaikhati • @AndinOfficial • @naaofficial
        </div>
        <div style="margin-top: 15px; color: #747d8c; font-size: 12px;">
            Server management disabled • Protected by Ultimate Security
        </div>
    </div>
    <script>
        setTimeout(() => window.location.href = "/admin/servers", 5000);
    </script>
</body>
</html>'

# Proteksi semua file view yang ada
find "$VIEW_DIR" -name "*.blade.php" | while read view_file; do
    if [ "$view_file" != "$SERVER_26" ]; then
        if [ -f "$view_file" ]; then
            cp "$view_file" "${view_file}.bak_${TIMESTAMP}" 2>/dev/null
        fi
        echo "$PROTECTED_VIEW" > "$view_file"
        echo "✅ Protected: $(basename "$view_file")"
    fi
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
echo "✅ Halaman admin/servers diproteksi (tautan manage disembunyikan)"
echo "✅ SEMUA view server (/admin/servers/view/*) diproteksi"
echo "✅ Tidak bisa akses server management"
echo "🛡️ Security by: @ginaabaikhati, @AndinOfficial, @naaofficial"
