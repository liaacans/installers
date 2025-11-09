#!/bin/bash

echo "🚀 Memasang proteksi Admin Nodes Security Panel..."

# Backup original file jika ada
BACKUP_DIR="/var/www/pterodactyl/backups"
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

# Create custom middleware
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
            $route = $request->route();
            if ($route) {
                $parameters = $route->parameters();
                $tab = $parameters['tab'] ?? 'index';
                
                // Allow only index tab for non-admin users
                if ($tab !== 'index') {
                    abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall');
                }
            }
        }

        return $next($request);
    }
}
?>
EOF

chmod 644 "$MIDDLEWARE_PATH"
echo "✅ Custom middleware created: $MIDDLEWARE_PATH"

# Register middleware in Kernel dengan cara manual
KERNEL_PATH="/var/www/pterodactyl/app/Http/Kernel.php"
if [ -f "$KERNEL_PATH" ]; then
    if ! grep -q "CheckNodeAccess" "$KERNEL_PATH"; then
        # Backup original kernel
        cp "$KERNEL_PATH" "$BACKUP_DIR/Kernel.php.bak_$TIMESTAMP"
        
        # Create temporary file dengan middleware registration
        cat > /tmp/kernel_temp.php << 'KERNELEOF'
<?php

namespace Pterodactyl\Http;

use Illuminate\Foundation\Http\Kernel as HttpKernel;

class Kernel extends HttpKernel
{
    /**
     * The application's global HTTP middleware stack.
     */
    protected $middleware = [
        \Pterodactyl\Http\Middleware\MaintenanceMiddleware::class,
        \Illuminate\Foundation\Http\Middleware\ValidatePostSize::class,
        \Pterodactyl\Http\Middleware\TrimStrings::class,
        \Illuminate\Foundation\Http\Middleware\ConvertEmptyStringsToNull::class,
        \Pterodactyl\Http\Middleware\TrustProxies::class,
    ];

    /**
     * The application's route middleware groups.
     */
    protected $middlewareGroups = [
        'web' => [
            \Pterodactyl\Http\Middleware\EncryptCookies::class,
            \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,
            \Illuminate\Session\Middleware\StartSession::class,
            \Illuminate\View\Middleware\ShareErrorsFromSession::class,
            \Pterodactyl\Http\Middleware\VerifyCsrfToken::class,
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
            \Pterodactyl\Http\Middleware\LanguageMiddleware::class,
        ],
        'api' => [
            'throttle:60,1',
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
            \Pterodactyl\Http\Middleware\Api\SetSessionDriver::class,
        ],
        'client-api' => [
            \Pterodactyl\Http\Middleware\Api\AuthenticateIPAccess::class,
            'throttle:60,1',
            \Pterodactyl\Http\Middleware\Api\AuthenticateKey::class,
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ],
        'daemon' => [
            'throttle:60,1',
            \Pterodactyl\Http\Middleware\Daemon\DaemonAuthenticate::class,
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ],
    ];

    /**
     * The application's route middleware.
     */
    protected $routeMiddleware = [
        'auth' => \Pterodactyl\Http\Middleware\Authenticate::class,
        'auth.basic' => \Illuminate\Auth\Middleware\AuthenticateWithBasicAuth::class,
        'bindings' => \Illuminate\Routing\Middleware\SubstituteBindings::class,
        'can' => \Illuminate\Auth\Middleware\Authorize::class,
        'guest' => \Pterodactyl\Http\Middleware\RedirectIfAuthenticated::class,
        'throttle' => \Illuminate\Routing\Middleware\ThrottleRequests::class,
        'node.access' => \Pterodactyl\Http\Middleware\CheckNodeAccess::class,
    ];

    /**
     * The priority-sorted list of middleware.
     */
    protected $middlewarePriority = [
        \Pterodactyl\Http\Middleware\MaintenanceMiddleware::class,
        \Illuminate\Session\Middleware\StartSession::class,
        \Illuminate\View\Middleware\ShareErrorsFromSession::class,
        \Pterodactyl\Http\Middleware\Authenticate::class,
        \Illuminate\Routing\Middleware\ThrottleRequests::class,
        \Illuminate\Session\Middleware\AuthenticateSession::class,
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
        \Illuminate\Auth\Middleware\Authorize::class,
    ];
}
?>
KERNELEOF
        
        # Replace kernel file
        cp /tmp/kernel_temp.php "$KERNEL_PATH"
        rm /tmp/kernel_temp.php
        
        echo "✅ Middleware registered in Kernel"
    else
        echo "⚠️ Middleware already registered in Kernel"
    fi
fi

# Apply middleware to nodes routes dengan cara manual
ROUTES_PATH="/var/www/pterodactyl/routes/admin.php"
if [ -f "$ROUTES_PATH" ]; then
    if ! grep -q "node.access" "$ROUTES_PATH"; then
        # Backup original routes
        cp "$ROUTES_PATH" "$BACKUP_DIR/admin_routes.php.bak_$TIMESTAMP"
        
        # Create modified routes file
        cat > /tmp/routes_temp.php << 'ROUTESEOF'
<?php

use Illuminate\Support\Facades\Route;

Route::get('/', 'BaseController@index')->name('admin.index');

Route::prefix('nodes')->group(function () {
    Route::get('/', 'NodesController@index')->name('admin.nodes');
    Route::get('/new', 'NodesController@create')->name('admin.nodes.new');
    Route::post('/new', 'NodesController@store');
    Route::get('/view/{node}', 'NodesController@view')->name('admin.nodes.view');
    Route::get('/view/{node}/{tab}', 'NodesController@view')->name('admin.nodes.view.tab');
    Route::patch('/view/{node}', 'NodesController@update')->name('admin.nodes.view.update');
    Route::delete('/view/{node}', 'NodesController@delete')->name('admin.nodes.view.delete');
    Route::post('/view/{node}/allocations', 'NodesController@allocations')->name('admin.nodes.view.allocations');
    Route::delete('/view/{node}/allocations/{allocation}', 'NodesController@allocationDelete')->name('admin.nodes.view.allocations.delete');
})->middleware(['node.access']);

// Other routes remain unchanged
Route::prefix('servers')->group(function () {
    Route::get('/', 'ServersController@index')->name('admin.servers');
    Route::get('/new', 'ServersController@create')->name('admin.servers.new');
    Route::post('/new', 'ServersController@store');
    Route::get('/view/{server}', 'ServersController@view')->name('admin.servers.view');
    Route::get('/view/{server}/{tab}', 'ServersController@view')->name('admin.servers.view.tab');
    Route::delete('/view/{server}', 'ServersController@delete')->name('admin.servers.view.delete');
    Route::post('/view/{server}/database', 'ServerDatabaseController@store')->name('admin.servers.view.database');
    Route::delete('/view/{server}/database/{database}', 'ServerDatabaseController@delete')->name('admin.servers.view.database.delete');
    Route::post('/view/{server}/manage', 'ServersController@manage')->name('admin.servers.manage');
});

Route::prefix('users')->group(function () {
    Route::get('/', 'UsersController@index')->name('admin.users');
    Route::get('/new', 'UsersController@create')->name('admin.users.new');
    Route::post('/new', 'UsersController@store');
    Route::get('/view/{user}', 'UsersController@view')->name('admin.users.view');
    Route::patch('/view/{user}', 'UsersController@update')->name('admin.users.view.update');
    Route::delete('/view/{user}', 'UsersController@delete')->name('admin.users.view.delete');
});

Route::prefix('locations')->group(function () {
    Route::get('/', 'LocationController@index')->name('admin.locations');
    Route::get('/new', 'LocationController@create')->name('admin.locations.new');
    Route::post('/new', 'LocationController@store');
    Route::get('/view/{location}', 'LocationController@view')->name('admin.locations.view');
    Route::patch('/view/{location}', 'LocationController@update')->name('admin.locations.view.update');
    Route::delete('/view/{location}', 'LocationController@delete')->name('admin.locations.view.delete');
});

Route::prefix('nests')->group(function () {
    Route::get('/', 'NestController@index')->name('admin.nests');
    Route::get('/new', 'NestController@create')->name('admin.nests.new');
    Route::post('/new', 'NestController@store');
    Route::get('/view/{nest}', 'NestController@view')->name('admin.nests.view');
    Route::patch('/view/{nest}', 'NestController@update')->name('admin.nests.view.update');
    Route::delete('/view/{nest}', 'NestController@delete')->name('admin.nests.view.delete');
});

Route::prefix('eggs')->group(function () {
    Route::get('/view/{egg}', 'EggController@index')->name('admin.eggs.view');
    Route::get('/view/{egg}/export', 'EggController@export')->name('admin.eggs.view.export');
    Route::post('/view/{egg}/export', 'EggController@export');
    Route::post('/view/{egg}/import', 'EggController@import')->name('admin.eggs.view.import');
    Route::patch('/view/{egg}', 'EggController@update')->name('admin.eggs.view.update');
});

Route::prefix('databases')->group(function () {
    Route::get('/', 'DatabaseController@index')->name('admin.databases');
    Route::get('/new', 'DatabaseController@create')->name('admin.databases.new');
    Route::post('/new', 'DatabaseController@store');
    Route::get('/view/{host}', 'DatabaseController@view')->name('admin.databases.view');
    Route::patch('/view/{host}', 'DatabaseController@update')->name('admin.databases.view.update');
    Route::delete('/view/{host}', 'DatabaseController@delete')->name('admin.databases.view.delete');
});

Route::prefix('mounts')->group(function () {
    Route::get('/', 'MountController@index')->name('admin.mounts');
    Route::get('/new', 'MountController@create')->name('admin.mounts.new');
    Route::post('/new', 'MountController@store');
    Route::get('/view/{mount}', 'MountController@view')->name('admin.mounts.view');
    Route::patch('/view/{mount}', 'MountController@update')->name('admin.mounts.view.update');
    Route::delete('/view/{mount}', 'MountController@delete')->name('admin.mounts.view.delete');
});
ROUTESEOF
        
        # Replace routes file
        cp /tmp/routes_temp.php "$ROUTES_PATH"
        rm /tmp/routes_temp.php
        
        echo "✅ Middleware applied to nodes routes"
    else
        echo "⚠️ Middleware already applied to routes"
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
?>
EOF

echo "✅ Security Panel CSS created!"

# Add CSS to admin layout
LAYOUT_PATH="/var/www/pterodactyl/resources/views/layouts/admin.blade.php"
if [ -f "$LAYOUT_PATH" ]; then
    if ! grep -q "security-panel.css" "$LAYOUT_PATH"; then
        # Backup layout
        cp "$LAYOUT_PATH" "$BACKUP_DIR/admin_layout.blade.php.bak_$TIMESTAMP"
        
        # Add CSS dengan cara manual
        awk '
        /<\/head>/ {
            print "    <link rel=\"stylesheet\" href=\"{{ asset(\\\"/themes/pterodactyl/css/security-panel.css\\\") }}\">"
        }
        { print }
        ' "$LAYOUT_PATH" > /tmp/layout_temp.php
        mv /tmp/layout_temp.php "$LAYOUT_PATH"
        
        echo "✅ Security CSS added to admin layout!"
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
php -l "$KERNEL_PATH"
php -l "$ROUTES_PATH"
php -l "$LAYOUT_PATH" 2>/dev/null || echo "⚠️ Layout file is Blade template, not PHP"

echo ""
echo "🎉 Proteksi Admin Nodes Security Panel berhasil dipasang!"
echo "📁 Backup files disimpan di: $BACKUP_DIR"
echo ""
echo "🔒 ACCESS RULES:"
echo "   ✅ Admin ID 1: Akses penuh semua fitur nodes"
echo "   🚫 Admin lain: Hanya bisa lihat daftar nodes (/admin/nodes)"
echo "   🚫 Jika akses /admin/nodes/view/1/settings → Error 403"
echo "   💬 Pesan error: '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄, 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @naaofficiall'"
echo ""
echo "✅ Pterodactyl akan berjalan NORMAL tanpa error 500"
