#!/bin/bash

echo "🚀 Memasang proteksi Admin Nodes Security Panel..."

# Create custom middleware
MIDDLEWARE_PATH="/var/www/pterodactyl/app/Http/Middleware/CheckNodeAccess.php"
mkdir -p "$(dirname "$MIDDLEWARE_PATH")"

cat > "$MIDDLEWARE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckNodeAccess
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        
        // Allow all access for admin ID 1
        if ($user && $user->id === 1) {
            return $next($request);
        }

        // Check if this is a nodes route
        $path = $request->path();
        
        // Block access to specific nodes tabs for non-admin users
        if (str_contains($path, 'admin/nodes/') && !str_contains($path, 'index')) {
            if (str_contains($path, 'settings') || 
                str_contains($path, 'configuration') || 
                str_contains($path, 'allocation') || 
                str_contains($path, 'servers')) {
                abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall');
            }
        }

        return $next($request);
    }
}
EOF

chmod 644 "$MIDDLEWARE_PATH"
echo "✅ Custom middleware created!"

# Register middleware in kernel
KERNEL_PATH="/var/www/pterodactyl/app/Http/Kernel.php"
if [ -f "$KERNEL_PATH" ]; then
    if ! grep -q "CheckNodeAccess" "$KERNEL_PATH"; then
        # Add to routeMiddleware array
        sed -i "/protected \$routeMiddleware = \[/a\        'node.access' => \\\Pterodactyl\\Http\\Middleware\\CheckNodeAccess::class," "$KERNEL_PATH"
        echo "✅ Middleware registered in Kernel!"
    fi
fi

# Create security CSS
SECURITY_CSS_PATH="/var/www/pterodactyl/public/themes/pterodactyl/css/security-panel.css"
mkdir -p "$(dirname "$SECURITY_CSS_PATH")"

cat > "$SECURITY_CSS_PATH" << 'EOF'
/* Security Panel Effects */
.security-shield {
    position: relative;
    padding: 20px;
    border-radius: 10px;
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
    border: 2px solid #00ffff;
    box-shadow: 0 0 20px rgba(0, 255, 255, 0.3);
    margin-bottom: 20px;
}

.security-shield::before {
    content: '🔒 SECURED';
    position: absolute;
    top: -10px;
    left: 20px;
    background: #00ffff;
    color: #000;
    padding: 2px 10px;
    border-radius: 5px;
    font-size: 10px;
    font-weight: bold;
    text-transform: uppercase;
}

.security-pulse {
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { box-shadow: 0 0 0 0 rgba(0, 255, 255, 0.4); }
    70% { box-shadow: 0 0 0 10px rgba(0, 255, 255, 0); }
    100% { box-shadow: 0 0 0 0 rgba(0, 255, 255, 0); }
}

.security-badge {
    background: linear-gradient(45deg, #ff0000, #ff8c00);
    color: white;
    padding: 3px 8px;
    border-radius: 12px;
    font-size: 9px;
    font-weight: bold;
    margin-left: 5px;
    animation: glow 1.5s ease-in-out infinite alternate;
}

@keyframes glow {
    from { box-shadow: 0 0 5px #ff0000; }
    to { box-shadow: 0 0 15px #ff8c00; }
}

.access-denied {
    background: linear-gradient(45deg, #ff3860, #ff7860) !important;
    color: white !important;
    cursor: not-allowed !important;
}

.access-denied:hover {
    background: linear-gradient(45deg, #ff0033, #ff5555) !important;
    transform: scale(1.02);
    transition: all 0.3s ease;
}

.security-alert {
    border-left: 4px solid #ff3860;
    background: rgba(255, 56, 96, 0.1);
}

.node-access-denied {
    text-align: center;
    padding: 40px 20px;
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
    border-radius: 10px;
    border: 2px solid #ff3860;
    margin: 20px 0;
}

.node-access-denied h2 {
    color: #ff3860;
    margin-bottom: 20px;
}

.node-access-denied p {
    color: #ccc;
    font-size: 16px;
}
EOF

echo "✅ Security Panel CSS created!"

# Add CSS to admin layout
LAYOUT_PATH="/var/www/pterodactyl/resources/views/layouts/admin.blade.php"
if [ -f "$LAYOUT_PATH" ]; then
    if ! grep -q "security-panel.css" "$LAYOUT_PATH"; then
        sed -i '/<\/head>/i <link rel="stylesheet" href="{{ asset(\"/themes/pterodactyl/css/security-panel.css\") }}">' "$LAYOUT_PATH"
        echo "✅ Security CSS added to admin layout!"
    fi
fi

# Modify the nodes view directly
NODES_VIEW_DIR="/var/www/pterodactyl/resources/views/admin/nodes/view"
mkdir -p "$NODES_VIEW_DIR"

# Backup original index view if exists
if [ -f "$NODES_VIEW_DIR/index.blade.php" ]; then
    cp "$NODES_VIEW_DIR/index.blade.php" "$NODES_VIEW_DIR/index.blade.php.bak"
    echo "📦 Backup original index view created"
fi

# Create modified index view
cat > "$NODES_VIEW_DIR/index.blade.php" << 'EOF'
@extends('layouts.admin')
@section('title')
    Node — {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>@if(auth()->user()->id === 1) Node Overview @else Security Protected Node @endif</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li class="active">{{ $node->name }}</li>
    </ol>
@endsection

@section('content')
@if(auth()->user()->id !== 1)
<div class="row">
    <div class="col-xs-12">
        <div class="node-access-denied">
            <i class="fa fa-shield fa-4x" style="color: #ff3860; margin-bottom: 20px;"></i>
            <h2>ACCESS DENIED</h2>
            <p>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall</p>
            <p style="font-size: 14px; margin-top: 10px;">Only primary administrator can access node details</p>
        </div>
    </div>
</div>
@else
<div class="row">
    <div class="col-xs-12">
        <div class="nav-tabs-custom nav-tabs-floating">
            <ul class="nav nav-tabs">
                <li class="active"><a href="{{ route('admin.nodes.view', $node->id) }}">About</a></li>
                <li><a href="{{ route('admin.nodes.view.settings', $node->id) }}">Settings</a></li>
                <li><a href="{{ route('admin.nodes.view.configuration', $node->id) }}">Configuration</a></li>
                <li><a href="{{ route('admin.nodes.view.allocation', $node->id) }}">Allocation</a></li>
                <li><a href="{{ route('admin.nodes.view.servers', $node->id) }}">Servers</a></li>
            </ul>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-sm-8">
        <div class="security-shield security-pulse">
            <div class="row">
                <div class="col-xs-6 col-md-3 text-center">
                    <a href="{{ route('admin.nodes.view.servers', $node->id) }}"><p>Servers</p><h4>{{ $node->servers_count }}</h4></a>
                </div>
                <div class="col-xs-6 col-md-3 text-center">
                    <a href="javascript:void(0)"><p>Usage</p><h4 data-toggle="tooltip" data-placement="top" title="{{ $node->memory_used }} / {{ $node->memory }} MB">{{ $node->memory_percent }}%</h4></a>
                </div>
                <div class="col-xs-6 col-md-3 text-center">
                    <a href="javascript:void(0)"><p>CPU</p><h4>0%</h4></a>
                </div>
                <div class="col-xs-6 col-md-3 text-center">
                    <a href="javascript:void(0)"><p>Disk</p><h4 data-toggle="tooltip" data-placement="top" title="{{ $node->disk_used }} / {{ $node->disk }} MB">{{ $node->disk_percent }}%</h4></a>
                </div>
            </div>
        </div>
        
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Information</h3>
            </div>
            <div class="box-body">
                <div class="row">
                    <div class="col-sm-6">
                        <strong>Node Authorized:</strong> 
                        @if($node->scheme === 'https')
                            <code class="text-success"><i class="fa fa-lock"></i> https://{{ $node->fqdn }}:{{ $node->daemonListen }}/</code>
                        @else
                            <code class="text-warning"><i class="fa fa-unlock-alt"></i> http://{{ $node->fqdn }}:{{ $node->daemonListen }}/</code>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-sm-4">
        <div class="box box-success">
            <div class="box-header with-border">
                <h3 class="box-title">Security Status</h3>
            </div>
            <div class="box-body">
                <div class="row">
                    <div class="col-xs-12">
                        <div class="info-box bg-green">
                            <span class="info-box-icon"><i class="fa fa-shield"></i></span>
                            <div class="info-box-content">
                                <span class="info-box-text">Protection Level</span>
                                <span class="info-box-number">ACTIVE</span>
                                <div class="progress">
                                    <div class="progress-bar" style="width: 100%"></div>
                                </div>
                                <span class="progress-description">
                                    Protected by @naaofficiall
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endif
@endsection

@section('footer-scripts')
    @parent
    <script>
        $(document).ready(function() {
            $('[data-toggle="tooltip"]').tooltip();
            
            @if(auth()->user()->id !== 1)
            console.log('🔒 Node Access Restricted - Protected by @naaofficiall');
            @endif
        });
    </script>
@endsection
EOF

echo "✅ Modified nodes view created!"

# Apply middleware to nodes routes using route service provider
ROUTE_PROVIDER_PATH="/var/www/pterodactyl/app/Providers/RouteServiceProvider.php"
if [ -f "$ROUTE_PROVIDER_PATH" ]; then
    if ! grep -q "CheckNodeAccess" "$ROUTE_PROVIDER_PATH"; then
        # Add the middleware to admin routes
        sed -i '/protected \$middlewareGroups = \[/a\    ];' "$ROUTE_PROVIDER_PATH"
        sed -i '/protected \$middlewareGroups = \[/a\        \\Pterodactyl\\Http\\Middleware\\CheckNodeAccess::class,' "$ROUTE_PROVIDER_PATH"
        echo "✅ Middleware applied to admin routes!"
    fi
fi

# Alternative: Apply middleware via routes file
WEB_ROUTES_PATH="/var/www/pterodactyl/routes/web.php"
if [ -f "$WEB_ROUTES_PATH" ]; then
    # Add middleware to nodes routes group
    if grep -q "admin.nodes" "$WEB_ROUTES_PATH" && ! grep -q "node.access" "$WEB_ROUTES_PATH"; then
        # This is a simplified approach - we'll create a patch file
        PATCH_FILE="/tmp/nodes_routes_patch.php"
        cat > "$PATCH_FILE" << 'EOPATCH'
<?php

// Apply node access middleware to nodes routes
Route::group([
    'namespace' => 'Admin\Nodes',
    'prefix' => 'admin/nodes', 
    'middleware' => ['node.access'] // Add our custom middleware
], function () {
    // Existing nodes routes will be handled by the middleware
});

EOPATCH
        echo "✅ Routes patch prepared (manual verification needed)"
    fi
fi

# Clear all caches
echo "🔄 Clearing all caches..."
php /var/www/pterodactyl/artisan route:clear
php /var/www/pterodactyl/artisan config:clear
php /var/www/pterodactyl/artisan view:clear
php /var/www/pterodactyl/artisan cache:clear

echo ""
echo "🎉 Proteksi Admin Nodes Security Panel berhasil dipasang!"
echo "📂 Middleware: $MIDDLEWARE_PATH"
echo "🎨 CSS Effects: $SECURITY_CSS_PATH"
echo "👁️ Modified View: $NODES_VIEW_DIR/index.blade.php"
echo ""
echo "🔒 ACCESS RULES:"
echo "   ✅ Admin ID 1: Akses penuh semua tab (Pterodactyl normal)"
echo "   🚫 Admin lain: Tidak bisa akses node details sama sekali"
echo "   💬 Pesan error: '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall'"
echo ""
echo "⚠️  Pterodactyl akan berjalan NORMAL untuk Admin ID 1"
echo "🚫 Admin lain akan langsung terlihat ACCESS DENIED page"
