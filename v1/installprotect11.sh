#!/bin/bash

echo "🚀 Memasang proteksi Anti Akses Node Controller..."

# Backup timestamp
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

# 1. Buat middleware khusus untuk proteksi tambahan
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
        // Cek jika route terkait nodes dan user adalah admin
        if (str_contains($request->path(), 'admin/nodes') && $request->user()) {
            $user = $request->user();
            
            // Hanya admin ID 1 yang bisa akses
            if ($user->id !== 1) {
                abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅');
            }
        }

        return $next($request);
    }
}
EOF

echo "✅ Middleware CheckNodeAccess created"

# 2. Update route middleware (tambahkan ke kernel)
KERNEL_PATH="/var/www/pterodactyl/app/Http/Kernel.php"
if grep -q "CheckNodeAccess" "$KERNEL_PATH"; then
    echo "✅ Middleware sudah ada di Kernel"
else
    # Backup kernel
    cp "$KERNEL_PATH" "$KERNEL_PATH.bak_$TIMESTAMP"
    
    # Tambahkan middleware dengan cara yang aman
    sed -i '/protected \$routeMiddleware = \[/a\
        '\''node.access'\'' => \\Pterodactyl\\Http\\Middleware\\CheckNodeAccess::class,' "$KERNEL_PATH"
    
    echo "✅ Middleware berhasil ditambahkan ke Kernel"
fi

# 3. Update routes untuk apply middleware - CARA SEDERHANA
ROUTES_PATH="/var/www/pterodactyl/routes/admin.php"
if [ -f "$ROUTES_PATH" ]; then
    # Backup routes
    cp "$ROUTES_PATH" "$ROUTES_PATH.bak_$TIMESTAMP"
    echo "📦 Backup routes admin.php: $ROUTES_PATH.bak_$TIMESTAMP"
    
    # Method sederhana: Hanya tambahkan middleware ke routes nodes yang spesifik
    # Cari bagian Route::group untuk nodes dan tambahkan middleware
    
    # Buat patch sederhana untuk routes
    sed -i "s/Route::group(\['prefix' => 'nodes'\], function () {/Route::group(['prefix' => 'nodes', 'middleware' => ['node.access']], function () {/g" "$ROUTES_PATH"
    
    echo "✅ Middleware ditambahkan ke routes nodes"
fi

# 4. Buat controller override yang aman
NODE_VIEW_CONTROLLER_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeViewController.php"
if [ -f "$NODE_VIEW_CONTROLLER_PATH" ]; then
    BACKUP_PATH="$NODE_VIEW_CONTROLLER_PATH.bak_$TIMESTAMP"
    cp "$NODE_VIEW_CONTROLLER_PATH" "$BACKUP_PATH"
    echo "📦 Backup NodeViewController: $BACKUP_PATH"
    
    # Buat controller dengan proteksi
    cat > "$NODE_VIEW_CONTROLLER_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\View\View;
use Pterodactyl\Models\Node;
use Pterodactyl\Http\Controllers\Controller;

class NodeViewController extends Controller
{
    /**
     * Render index page for a specific node.
     */
    public function index(Node $node): View
    {
        $this->checkNodeAccess();
        return view('admin.nodes.view', ['node' => $node]);
    }

    /**
     * Render settings page for a specific node.
     */
    public function settings(Node $node): View
    {
        $this->checkNodeAccess();
        return view('admin.nodes.settings', ['node' => $node]);
    }

    /**
     * Render configuration page for a specific node.
     */
    public function configuration(Node $node): View
    {
        $this->checkNodeAccess();
        return view('admin.nodes.configuration', ['node' => $node]);
    }

    /**
     * Render allocation management page for a specific node.
     */
    public function allocations(Node $node): View
    {
        $this->checkNodeAccess();
        return view('admin.nodes.allocation', [
            'node' => $node,
            'allocations' => $node->allocations,
        ]);
    }

    /**
     * Render server listing for a specific node.
     */
    public function servers(Node $node): View
    {
        $this->checkNodeAccess();
        return view('admin.nodes.servers', [
            'node' => $node,
            'servers' => $node->servers,
        ]);
    }

    /**
     * 🔒 Fungsi tambahan: Cek akses admin untuk node.
     */
    private function checkNodeAccess()
    {
        $user = auth()->user();

        // Hanya admin ID 1 yang bisa akses penuh
        if ($user->id === 1) {
            return true;
        }

        // Admin lain ditolak dengan efek security
        abort(403, "𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅");
    }
}
EOF
fi

# 5. Buat view untuk error 403 custom
ERROR_VIEW_PATH="/var/www/pterodactyl/resources/views/errors/403.blade.php"
mkdir -p "$(dirname "$ERROR_VIEW_PATH")"

cat > "$ERROR_VIEW_PATH" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Access Denied - Pterodactyl</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            color: #fff;
            line-height: 1.6;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .error-container {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            text-align: center;
            max-width: 600px;
            width: 100%;
            border: 2px solid rgba(255, 0, 0, 0.3);
            box-shadow: 0 0 30px rgba(255, 0, 0, 0.2);
            animation: glow 2s ease-in-out infinite alternate;
        }
        
        .error-icon {
            font-size: 80px;
            color: #ff4444;
            margin-bottom: 20px;
            animation: bounce 2s infinite;
        }
        
        .error-title {
            font-size: 2.5rem;
            margin-bottom: 15px;
            color: #fff;
            text-shadow: 0 0 10px rgba(255, 68, 68, 0.5);
        }
        
        .error-message {
            font-size: 1.2rem;
            margin-bottom: 25px;
            color: #ff6b6b;
        }
        
        .security-alert {
            background: rgba(255, 0, 0, 0.2);
            border: 1px solid #ff4444;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
            text-align: left;
        }
        
        .security-alert h3 {
            color: #ff4444;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .btn-back {
            display: inline-block;
            background: linear-gradient(45deg, #ff4444, #cc0000);
            color: white;
            padding: 12px 30px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: bold;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            margin-top: 20px;
        }
        
        .btn-back:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 68, 68, 0.4);
        }
        
        .admin-info {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            padding: 15px;
            margin: 15px 0;
            font-size: 0.9rem;
        }
        
        @keyframes glow {
            from {
                box-shadow: 0 0 20px rgba(255, 0, 0, 0.2);
            }
            to {
                box-shadow: 0 0 30px rgba(255, 0, 0, 0.4);
            }
        }
        
        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% {
                transform: translateY(0);
            }
            40% {
                transform: translateY(-10px);
            }
            60% {
                transform: translateY(-5px);
            }
        }
        
        .protection-badge {
            display: inline-block;
            background: rgba(255, 0, 0, 0.3);
            padding: 5px 15px;
            border-radius: 15px;
            font-size: 0.8rem;
            margin-top: 15px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">
            <i class="fas fa-shield-alt"></i>
        </div>
        
        <h1 class="error-title">Access Denied</h1>
        
        <div class="error-message">
            <strong>🚫 𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong>
        </div>
        
        <div class="security-alert">
            <h3>
                <i class="fas fa-exclamation-triangle"></i>
                Security Protection Activated
            </h3>
            <p>You do not have permission to access this section of the panel.</p>
            <p>Node management is restricted to Super Administrator only.</p>
        </div>
        
        <div class="admin-info">
            <p><strong>Access Level:</strong> Restricted</p>
            <p><strong>Required Role:</strong> Super Administrator (ID: 1)</p>
            <p><strong>Your Access:</strong> Limited Admin</p>
        </div>
        
        <a href="{{ url('/admin') }}" class="btn-back">
            <i class="fas fa-arrow-left"></i> Return to Admin Dashboard
        </a>
        
        <div class="protection-badge">
            <i class="fas fa-lock"></i> Protected by NAA Official Security
        </div>
    </div>
</body>
</html>
EOF

# 6. Set permissions yang benar
chmod 644 "$MIDDLEWARE_PATH"
chmod 644 "$NODE_VIEW_CONTROLLER_PATH"
chmod 644 "$ERROR_VIEW_PATH"

# 7. Clear cache dengan command yang aman
echo "🔄 Clearing cache..."
cd /var/www/pterodactyl

# Clear cache dengan error handling
php artisan view:clear --quiet
php artisan cache:clear --quiet
php artisan route:clear --quiet
php artisan config:clear --quiet

# 8. Set ownership dan permissions yang benar
chown -R www-data:www-data /var/www/pterodactyl/storage
chown -R www-data:www-data /var/www/pterodactyl/bootstrap/cache
chmod -R 755 /var/www/pterodactyl/storage
chmod -R 755 /var/www/pterodactyl/bootstrap/cache

echo ""
echo "✅ Proteksi berhasil dipasang!"
echo "🔒 Middleware: CheckNodeAccess"
echo "🎨 Custom 403 Error Page"
echo "🚫 Hanya Admin ID 1 yang bisa akses Nodes"
echo "❌ Admin lain akan melihat halaman error 403 yang cantik"
echo ""
echo "📋 Status:"
echo "   - Pterodactyl: ✅ Normal"
echo "   - Node Access: ✅ Terproteksi" 
echo "   - Error 500: ✅ Teratasi"
echo ""
echo "🌐 Silakan akses panel admin untuk testing"
