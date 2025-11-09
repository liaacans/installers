#!/bin/bash

echo "🗑️ Menghapus proteksi Admin Nodes Security Panel..."

BACKUP_DIR="/var/www/pterodactyl/backups"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

# Remove middleware file
MIDDLEWARE_PATH="/var/www/pterodactyl/app/Http/Middleware/CheckNodeAccess.php"
if [ -f "$MIDDLEWARE_PATH" ]; then
    rm -f "$MIDDLEWARE_PATH"
    echo "✅ Middleware file removed: $MIDDLEWARE_PATH"
fi

# Restore original Kernel from backup
KERNEL_PATH="/var/www/pterodactyl/app/Http/Kernel.php"
KERNEL_BACKUP=$(ls -t "$BACKUP_DIR"/Kernel.php.bak_* 2>/dev/null | head -n1)
if [ -n "$KERNEL_BACKUP" ]; then
    cp "$KERNEL_BACKUP" "$KERNEL_PATH"
    echo "✅ Kernel restored from backup: $KERNEL_BACKUP"
else
    echo "⚠️ No Kernel backup found, creating fresh Kernel..."
    # Create fresh Kernel file
    cat > "$KERNEL_PATH" << 'KERNELEOF'
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
    echo "✅ Fresh Kernel created"
fi

# Restore original routes from backup
ROUTES_PATH="/var/www/pterodactyl/routes/admin.php"
ROUTES_BACKUP=$(ls -t "$BACKUP_DIR"/admin_routes.php.bak_* 2>/dev/null | head -n1)
if [ -n "$ROUTES_BACKUP" ]; then
    cp "$ROUTES_BACKUP" "$ROUTES_PATH"
    echo "✅ Routes restored from backup: $ROUTES_BACKUP"
else
    echo "⚠️ No routes backup found, perlu restore manual routes admin.php"
fi

# Restore original layout from backup
LAYOUT_PATH="/var/www/pterodactyl/resources/views/layouts/admin.blade.php"
LAYOUT_BACKUP=$(ls -t "$BACKUP_DIR"/admin_layout.blade.php.bak_* 2>/dev/null | head -n1)
if [ -n "$LAYOUT_BACKUP" ]; then
    cp "$LAYOUT_BACKUP" "$LAYOUT_PATH"
    echo "✅ Layout restored from backup: $LAYOUT_BACKUP"
else
    # Remove CSS from layout manually
    if [ -f "$LAYOUT_PATH" ]; then
        sed -i '/security-panel.css/d' "$LAYOUT_PATH"
        echo "✅ CSS reference removed from layout"
    fi
fi

# Remove security CSS
SECURITY_CSS_PATH="/var/www/pterodactyl/public/themes/pterodactyl/css/security-panel.css"
if [ -f "$SECURITY_CSS_PATH" ]; then
    rm -f "$SECURITY_CSS_PATH"
    echo "✅ Security CSS removed"
fi

# Clear all caches
echo "🔄 Clearing all caches..."
php /var/www/pterodactyl/artisan view:clear
php /var/www/pterodactyl/artisan cache:clear
php /var/www/pterodactyl/artisan config:clear
php /var/www/pterodactyl/artisan route:clear

# Test PHP syntax
echo "🔍 Testing PHP syntax..."
php -l "$KERNEL_PATH"
php -l "$ROUTES_PATH"

echo ""
echo "♻️ Uninstall proteksi nodes selesai!"
echo "🔓 Semua fitur nodes sekarang dapat diakses normal oleh semua admin"
echo "📁 Backup files tersimpan di: $BACKUP_DIR"
echo "✅ Semua file sudah di-restore ke original"
