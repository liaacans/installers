#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/resources/views/admin/servers/view/26.blade.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Advanced Anti Tautan Server View..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
@extends('layouts.admin')
@section('title')
    Server — {{ $server->name }}
@endsection

@section('content-header')
    <h1>{{ $server->name }}<small>{{ $server->description }}</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.servers') }}">Servers</a></li>
        <li class="active">{{ $server->name }}</li>
    </ol>
@endsection

@section('content')
<div class="row">
    <div class="col-xs-12">
        <div class="box box-danger">
            <div class="box-header with-border">
                <h3 class="box-title">Server Information</h3>
                <div class="box-tools">
                    @if(auth()->user()->id === 1)
                        <a href="/admin/servers/view/{{ $server->id }}/manage" class="btn btn-xs btn-success">
                            <i class="fa fa-wrench"></i> Manage Server (Admin Access)
                        </a>
                    @else
                        <span class="label label-warning">
                            <i class="fa fa-shield"></i> Security Protected
                        </span>
                    @endif
                </div>
            </div>
            <div class="box-body">
                <div class="row">
                    <div class="col-md-6">
                        <dl>
                            <dt>Server Name</dt>
                            <dd>{{ $server->name }}</dd>
                            <dt>Server Description</dt>
                            <dd>{{ $server->description ?? 'No description provided' }}</dd>
                            <dt>Server UUID</dt>
                            <dd><code>{{ $server->uuid }}</code></dd>
                        </dl>
                    </div>
                    <div class="col-md-6">
                        <dl>
                            <dt>Server Owner</dt>
                            <dd>
                                <div class="alert alert-info" style="padding: 8px; margin: 0;">
                                    <i class="fa fa-eye-slash"></i> <strong>Information Hidden</strong>
                                    <br><small>Protected by security system</small>
                                </div>
                            </dd>
                            <dt>Server Node</dt>
                            <dd>
                                <div class="alert alert-info" style="padding: 8px; margin: 0;">
                                    <i class="fa fa-eye-slash"></i> <strong>Information Hidden</strong>
                                    <br><small>Protected by security system</small>
                                </div>
                            </dd>
                            <dt>More Info</dt>
                            <dd>
                                <div class="alert alert-warning" style="padding: 8px; margin: 0;">
                                    <i class="fa fa-lock"></i> <strong>Security Protected</strong>
                                    <br><small>Access restricted for security reasons</small>
                                </div>
                            </dd>
                        </dl>
                    </div>
                </div>
                
                <!-- Security Information Box -->
                <div class="alert alert-success" style="margin-top: 20px;">
                    <h4 style="margin-top: 0;">
                        <i class="fa fa-shield"></i> Advanced Security Protection
                    </h4>
                    <p style="margin-bottom: 5px;">
                        <strong>🔒 Security by:</strong> 
                        <span class="label label-primary">@ginaabaikhati</span>
                        <span class="label label-success">@AndinOfficial</span>
                        <span class="label label-info">@naaofficial</span>
                        <span class="label label-warning">Pterodactyl ID Security Team</span>
                    </p>
                    <p style="margin-bottom: 0; font-size: 12px;">
                        <i class="fa fa-info-circle"></i> 
                        Server information protected by advanced security system. Only authorized administrators can access management features.
                    </p>
                </div>
            </div>
        </div>

        <!-- Server Details Card -->
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Connection Details</h3>
            </div>
            <div class="box-body">
                <div class="row">
                    <div class="col-md-6">
                        <strong>Default Connection:</strong>
                        <code>0.0.0.0:2007</code>
                    </div>
                    <div class="col-md-6">
                        <strong>Connection Alias:</strong>
                        <code>ANDIN OFFICIAL:2007</code>
                    </div>
                </div>
            </div>
        </div>

        <!-- Security Features Card -->
        <div class="box box-default">
            <div class="box-header with-border">
                <h3 class="box-title">Security Features</h3>
            </div>
            <div class="box-body">
                <div class="row">
                    <div class="col-md-4 text-center">
                        <div class="info-box bg-green">
                            <span class="info-box-icon"><i class="fa fa-ban"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Anti Link</span>
                                <span class="info-box-number">Active</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4 text-center">
                        <div class="info-box bg-blue">
                            <span class="info-box-icon"><i class="fa fa-user-secret"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Info Protection</span>
                                <span class="info-box-number">Active</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4 text-center">
                        <div class="info-box bg-purple">
                            <span class="info-box-icon"><i class="fa fa-shield"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Admin Only</span>
                                <span class="info-box-number">Active</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('footer-scripts')
    @parent
    <script>
        $(document).ready(function() {
            // Add fade in effect to security elements
            $('.alert').hide().fadeIn(1000);
            $('.info-box').hide().each(function(i) {
                $(this).delay(i * 200).fadeIn(500);
            });
            
            // Add click protection
            $('a, button').not('.btn-success').on('click', function(e) {
                if (!$(this).hasClass('btn-success')) {
                    e.preventDefault();
                    $(this).effect('shake', { distance: 5, times: 2 }, 300);
                }
            });
        });
    </script>
@endsection
EOF

chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi Advanced Anti Tautan Server View berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo "👁️ Informasi Server Owner & Node telah disembunyikan"
echo "👑 Admin ID 1 dapat mengakses semua fitur"
echo "🎭 Efek security keren berhasil ditambahkan"

# Clear cache
echo "🔄 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear
php artisan cache:clear

echo ""
echo "🎉 Proteksi Advanced berhasil diimplementasi!"
echo "🔒 Security by: @ginaabaikhati, @AndinOfficial, @naaofficial, Pterodactyl ID Security Team"
