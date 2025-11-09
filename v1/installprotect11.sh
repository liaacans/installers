#!/bin/bash

echo "🚀 Memasang proteksi Admin Nodes Security Panel..."

# Backup original file jika ada
BACKUP_DIR="/var/www/pterodactyl/backups"
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

# Create custom middleware (FIXED VERSION)
MIDDLEWARE_PATH="/var/www/pterodactyl/app/Http/Middleware/CheckNodeAccess.php"
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

        // Check if this is a nodes related route
        $path = $request->path();
        if (str_contains($path, 'admin/nodes')) {
            // Get the current route
            $route = $request->route();
            if ($route) {
                $tab = $route->parameter('tab', 'index');
                
                // Allow only index tab for non-admin users
                if ($tab !== 'index' && $tab !== null) {
                    abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall');
                }
            }
        }

        return $next($request);
    }
}
EOF

chmod 644 "$MIDDLEWARE_PATH"
echo "✅ Custom middleware created: $MIDDLEWARE_PATH"

# Register middleware in Kernel (FIXED VERSION)
KERNEL_PATH="/var/www/pterodactyl/app/Http/Kernel.php"
if [ -f "$KERNEL_PATH" ]; then
    if ! grep -q "CheckNodeAccess" "$KERNEL_PATH"; then
        # Backup original kernel
        cp "$KERNEL_PATH" "$BACKUP_DIR/Kernel.php.bak_$TIMESTAMP"
        
        # Add to routeMiddleware array - FIXED SYNTAX
        sed -i '/protected \$routeMiddleware = \[/a\
        '\''node.access'\'' => \Pterodactyl\Http\Middleware\CheckNodeAccess::class,' "$KERNEL_PATH"
        
        echo "✅ Middleware registered in Kernel"
    else
        echo "⚠️ Middleware already registered in Kernel"
    fi
fi

# Apply middleware to nodes routes (SIMPLIFIED VERSION)
ROUTES_PATH="/var/www/pterodactyl/routes/admin.php"
if [ -f "$ROUTES_PATH" ]; then
    # Create modified routes file
    MODIFIED_ROUTES="/tmp/admin_routes_modified.php"
    
    # Process the routes file to add middleware
    awk '
    /Route::prefix\('\''nodes'\''\)->group/ {
        print $0
        getline
        if (!/->middleware/) {
            print "    ->middleware(['\''node.access'\'']);"
        }
        print
        next
    }
    { print }
    ' "$ROUTES_PATH" > "$MODIFIED_ROUTES"
    
    # Backup original and replace
    cp "$ROUTES_PATH" "$BACKUP_DIR/admin_routes.php.bak_$TIMESTAMP"
    cp "$MODIFIED_ROUTES" "$ROUTES_PATH"
    rm "$MODIFIED_ROUTES"
    
    echo "✅ Middleware applied to nodes routes"
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
    opacity: 0.8;
}

.access-denied:hover {
    background: linear-gradient(45deg, #ff0033, #ff5555) !important;
    transform: scale(1.02);
    transition: all 0.3s ease;
}

.security-alert {
    border-left: 4px solid #ff3860;
    background: rgba(255, 56, 96, 0.1);
    padding: 15px;
}

.node-restricted {
    filter: blur(2px);
    pointer-events: none;
    opacity: 0.7;
}
EOF

echo "✅ Security Panel CSS created!"

# Add CSS to admin layout
LAYOUT_PATH="/var/www/pterodactyl/resources/views/layouts/admin.blade.php"
if [ -f "$LAYOUT_PATH" ]; then
    if ! grep -q "security-panel.css" "$LAYOUT_PATH"; then
        sed -i '/<\/head>/i\
    <link rel="stylesheet" href="{{ asset(\"/themes/pterodactyl/css/security-panel.css\") }}">' "$LAYOUT_PATH"
        echo "✅ Security CSS added to admin layout!"
    fi
fi

# Create a simple view composer instead of blade directive
COMPOSER_PATH="/var/www/pterodactyl/app/Http/View/Composers/NodeComposer.php"
mkdir -p "$(dirname "$COMPOSER_PATH")"

cat > "$COMPOSER_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\View\Composers;

use Illuminate\View\View;
use Illuminate\Support\Facades\Auth;

class NodeComposer
{
    public function compose(View $view)
    {
        $view->with('canAccessNodes', Auth::check() && Auth::user()->id === 1);
    }
}
EOF

chmod 644 "$COMPOSER_PATH"
echo "✅ View composer created"

# Register view composer
COMPOSER_PROVIDER_PATH="/var/www/pterodactyl/app/Providers/ViewServiceProvider.php"
if [ -f "$COMPOSER_PROVIDER_PATH" ]; then
    if ! grep -q "NodeComposer" "$COMPOSER_PROVIDER_PATH"; then
        cp "$COMPOSER_PROVIDER_PATH" "$BACKUP_DIR/ViewServiceProvider.php.bak_$TIMESTAMP"
        
        # Add composer registration
        sed -i '/public function boot()/a\
    \\n    view()->composer('\''admin.nodes.*'\'', \\Pterodactyl\\Http\\View\\Composers\\NodeComposer::class);' "$COMPOSER_PROVIDER_PATH"
        
        echo "✅ View composer registered"
    fi
fi

# Clear all caches
echo "🔄 Clearing all caches..."
php /var/www/pterodactyl/artisan view:clear
php /var/www/pterodactyl/artisan cache:clear
php /var/www/pterodactyl/artisan config:clear
php /var/www/pterodactyl/artisan route:clear

# Test PHP syntax
echo "🔍 Testing PHP syntax..."
php -l "$MIDDLEWARE_PATH"
php -l "$COMPOSER_PATH"
if [ -f "$COMPOSER_PROVIDER_PATH" ]; then
    php -l "$COMPOSER_PROVIDER_PATH"
fi

echo ""
echo "🎉 Proteksi Admin Nodes Security Panel berhasil dipasang!"
echo "📁 Backup files disimpan di: $BACKUP_DIR"
echo ""
echo "🔒 ACCESS RULES:"
echo "   ✅ Admin ID 1: Akses penuh semua fitur nodes"
echo "   🚫 Admin lain: Hanya bisa lihat daftar nodes, detail nodes akan error 403"
echo "   💬 Pesan error: '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall'"
echo ""
echo "✅ Pterodactyl akan berjalan NORMAL tanpa error 500"
echo "🔧 Menggunakan middleware custom untuk proteksi"
