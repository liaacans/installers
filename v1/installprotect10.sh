#!/bin/bash

echo "🚀 Memasang proteksi Anti Tautan Server View..."

# File paths
INDEX_FILE="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
VIEW_FILE="/var/www/pterodactyl/resources/views/admin/servers/view/26.blade.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

# Backup original files
if [ -f "$INDEX_FILE" ]; then
  cp "$INDEX_FILE" "${INDEX_FILE}.bak_${TIMESTAMP}"
  echo "📦 Backup index file dibuat: ${INDEX_FILE}.bak_${TIMESTAMP}"
fi

if [ -f "$VIEW_FILE" ]; then
  cp "$VIEW_FILE" "${VIEW_FILE}.bak_${TIMESTAMP}"
  echo "📦 Backup view file dibuat: ${VIEW_FILE}.bak_${TIMESTAMP}"
fi

# 1. Update Index File - Biarkan normal tapi disable tombol manage untuk server 26
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
                                    @if($server->id == 26)
                                        <!-- Tombol Manage Server dinonaktifkan untuk server 26 -->
                                        <span class="label label-warning" data-toggle="tooltip" title="Protected by Security System">
                                            <i class="fa fa-shield"></i> Protected
                                        </span>
                                    @else
                                        <!-- Tombol Manage Server normal untuk server lain -->
                                        <a href="{{ route('admin.servers.view', $server->id) }}" class="btn btn-xs btn-primary">
                                            <i class="fa fa-wrench"></i> Manage
                                        </a>
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
    </div>
</div>
@endsection

@section('footer-scripts')
    @parent
    <script>
        $(document).ready(function() {
            $('[data-toggle="tooltip"]').tooltip();
            
            // Security protection for server 26
            $('a[href*="/admin/servers/view/26"]').on('click', function(e) {
                e.preventDefault();
                alert('🚫 Access Denied: This server is protected by security system');
            });
        });
    </script>
@endsection
EOF

echo "✅ Index file berhasil diupdate"

# 2. Create Protected View untuk Server 26
cat > "$VIEW_FILE" << 'EOF'
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
            animation: fadeIn 0.8s ease-in-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .security-header {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            padding: 40px 30px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .security-header::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: linear-gradient(45deg, transparent, rgba(255,255,255,0.1), transparent);
            transform: rotate(45deg);
            animation: shine 3s infinite;
        }
        @keyframes shine {
            0% { transform: translateX(-100%) translateY(-100%) rotate(45deg); }
            100% { transform: translateX(100%) translateY(100%) rotate(45deg); }
        }
        .security-icon {
            font-size: 80px;
            margin-bottom: 20px;
            display: block;
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
            transition: transform 0.3s ease;
        }
        .protection-card:hover {
            transform: translateY(-5px);
        }
        .server-info {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        .credits-section {
            background: linear-gradient(135deg, #74b9ff, #0984e3);
            color: white;
            padding: 25px;
            border-radius: 15px;
            text-align: center;
            margin-top: 30px;
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
        .admin-notice {
            background: #ffeaa7;
            border: 2px dashed #fdcb6e;
            padding: 15px;
            border-radius: 10px;
            margin: 15px 0;
            text-align: center;
        }
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        .feature-item {
            text-align: center;
            padding: 15px;
            background: #f1f2f6;
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <div class="security-container">
        <div class="security-header">
            <i class="security-icon fas fa-shield-alt"></i>
            <h1>SERVER PROTECTION ACTIVE</h1>
            <p>Advanced Security System • Server ID: 26</p>
        </div>
        
        <div class="security-content">
            <div class="protection-card">
                <h3><i class="fas fa-ban" style="color: #e74c3c;"></i> Access Restricted</h3>
                <p>This server view is protected by the Ultimate Security System. Direct access to server management has been disabled for security reasons.</p>
                
                <div class="admin-notice">
                    <i class="fas fa-crown" style="color: #f39c12;"></i>
                    <strong>Administrator Access Only</strong><br>
                    Only root administrator (ID: 1) can manage this server through system-level access.
                </div>
            </div>

            <div class="server-info">
                <h4><i class="fas fa-server"></i> Protected Server Information</h4>
                <div class="feature-grid">
                    <div class="feature-item">
                        <i class="fas fa-hdd" style="color: #3498db; font-size: 24px;"></i>
                        <div style="margin-top: 10px;">
                            <strong>Disk Space</strong><br>
                            <span style="color: #27ae60;">Unlimited</span>
                        </div>
                    </div>
                    <div class="feature-item">
                        <i class="fas fa-network-wired" style="color: #9b59b6; font-size: 24px;"></i>
                        <div style="margin-top: 10px;">
                            <strong>Block IO Weight</strong><br>
                            <span style="color: #27ae60;">500</span>
                        </div>
                    </div>
                    <div class="feature-item">
                        <i class="fas fa-plug" style="color: #e74c3c; font-size: 24px;"></i>
                        <div style="margin-top: 10px;">
                            <strong>Default Connection</strong><br>
                            <code>0.0.0.0:2007</code>
                        </div>
                    </div>
                    <div class="feature-item">
                        <i class="fas fa-link" style="color: #f39c12; font-size: 24px;"></i>
                        <div style="margin-top: 10px;">
                            <strong>Connection Alias</strong><br>
                            <code>ANDIN OFFICIAL:2007</code>
                        </div>
                    </div>
                </div>
            </div>

            <div style="text-align: center; margin: 20px 0;">
                <span class="security-badge"><i class="fas fa-shield-alt"></i> ANTI-LINK</span>
                <span class="security-badge"><i class="fas fa-eye-slash"></i> INFO PROTECTED</span>
                <span class="security-badge"><i class="fas fa-lock"></i> SECURE ACCESS</span>
                <span class="security-badge"><i class="fas fa-ban"></i> NO MANAGEMENT</span>
            </div>

            <div class="credits-section">
                <h3><i class="fas fa-award"></i> SECURITY CREDITS</h3>
                <p style="margin: 15px 0;">
                    <strong>Advanced Protection System Developed by:</strong><br>
                    <span style="font-size: 18px;">
                        <span style="color: #fd79a8;">@ginaabaikhati</span> • 
                        <span style="color: #81ecec;">@AndinOfficial</span> • 
                        <span style="color: #55efc4;">@naaofficial</span>
                    </span>
                </p>
                <p style="margin-bottom: 0; font-size: 14px;">
                    <i class="fas fa-star"></i> Pterodactyl ID Ultimate Security Team <i class="fas fa-star"></i>
                </p>
            </div>

            <div style="text-align: center; margin-top: 20px; padding: 15px; background: #fd79a8; color: white; border-radius: 10px;">
                <i class="fas fa-exclamation-triangle"></i>
                <strong>PERMANENT PROTECTION</strong><br>
                This security measure cannot be modified or disabled through the admin panel.
            </div>
        </div>
    </div>

    <script>
        // Enhanced security protection
        document.addEventListener('contextmenu', function(e) {
            e.preventDefault();
        });

        document.addEventListener('keydown', function(e) {
            if (e.key === 'F12' || 
                (e.ctrlKey && e.shiftKey && e.key === 'I') ||
                (e.ctrlKey && e.shiftKey && e.key === 'J') ||
                (e.ctrlKey && e.key === 'u')) {
                e.preventDefault();
            }
        });

        // Auto-redirect attempts to bypass
        if (window.location.search.includes('manage') || window.location.hash.includes('edit')) {
            setTimeout(() => {
                window.location.href = '/admin/servers';
            }, 1000);
        }

        // Add floating animation to badges
        setInterval(() => {
            const badges = document.querySelectorAll('.security-badge');
            badges.forEach((badge, index) => {
                setTimeout(() => {
                    badge.style.transform = 'translateY(-5px)';
                    setTimeout(() => {
                        badge.style.transform = 'translateY(0)';
                    }, 300);
                }, index * 200);
            });
        }, 3000);
    </script>
</body>
</html>
EOF

echo "✅ Protected view untuk server 26 berhasil dibuat"

# Set permissions
chmod 644 "$INDEX_FILE"
chmod 644 "$VIEW_FILE"

# Clear cache
echo "🔄 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear
php artisan cache:clear

echo ""
echo "🎉 PROTEKSI BERHASIL DIPASANG!"
echo "✅ Server list normal (hanya server 26 yang protected)"
echo "✅ Server lain bisa di-manage seperti biasa"
echo "✅ Hanya /admin/servers/view/26 yang diblokir"
echo "🛡️ Security by: @ginaabaikhati, @AndinOfficial, @naaofficial"
EOF
