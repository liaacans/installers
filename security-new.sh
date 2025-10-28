#!/bin/bash

# Pterodactyl Security Protection
# By @ginaabaikhati
# Features: Anti Delete, Anti Intip, Anti Akses Server Orang Lain

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PANEL_PATH="/var/www/pterodactyl"
BACKUP_PATH="/root/pterodactyl_backup"
SECURITY_BACKUP="$BACKUP_PATH/security_backup"
CUSTOM_ERROR="Ngapain sih? mau nyolong sc org? - By @ginaabaikhati"
CUSTOM_ERROR_500="ERROR 500: Dilarang mengintip! - By @ginaabaikhati"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Script harus dijalankan sebagai root${NC}"
   exit 1
fi

# Function to display banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "================================================"
    echo "    Pterodactyl Security Protection Installer"
    echo "    By: @ginaabaikhati"
    echo "================================================"
    echo -e "${NC}"
}

# Function to backup original files
backup_files() {
    echo -e "${YELLOW}Membuat backup file original...${NC}"
    mkdir -p "$SECURITY_BACKUP"
    
    # Backup important files
    local files=(
        "app/Http/Controllers/Api/Client/Servers/ServerController.php"
        "app/Http/Controllers/Admin/NodesController.php"
        "app/Http/Controllers/Admin/NestsController.php"
        "app/Http/Controllers/Admin/ServersController.php"
        "app/Http/Controllers/Admin/UsersController.php"
        "app/Http/Controllers/Admin/LocationsController.php"
        "app/Http/Controllers/Controller.php"
        "app/Http/Middleware/AdminAuthenticate.php"
        "app/Http/Middleware/ClientAuthenticate.php"
        "app/Http/Middleware/Authenticate.php"
        "app/Exceptions/Handler.php"
        "resources/views/errors/404.blade.php"
        "resources/views/errors/403.blade.php"
        "resources/views/errors/500.blade.php"
        "resources/views/errors/503.blade.php"
        "app/Providers/AppServiceProvider.php"
        "app/Providers/AuthServiceProvider.php"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$PANEL_PATH/$file" ]; then
            mkdir -p "$SECURITY_BACKUP/$(dirname "$file")"
            cp "$PANEL_PATH/$file" "$SECURITY_BACKUP/$file" 2>/dev/null
            echo -e "${GREEN}✓ Backup: $file${NC}"
        else
            echo -e "${YELLOW}⚠ File tidak ditemukan: $file${NC}"
        fi
    done
    
    echo -e "${GREEN}Backup selesai!${NC}"
}

# Function to restore from backup
restore_backup() {
    echo -e "${YELLOW}Memulihkan file dari backup...${NC}"
    
    if [ ! -d "$SECURITY_BACKUP" ]; then
        echo -e "${RED}Backup tidak ditemukan!${NC}"
        return 1
    fi
    
    # Restore files
    local files=(
        "app/Http/Controllers/Api/Client/Servers/ServerController.php"
        "app/Http/Controllers/Admin/NodesController.php"
        "app/Http/Controllers/Admin/NestsController.php"
        "app/Http/Controllers/Admin/ServersController.php"
        "app/Http/Controllers/Admin/UsersController.php"
        "app/Http/Controllers/Admin/LocationsController.php"
        "app/Http/Controllers/Controller.php"
        "app/Http/Middleware/AdminAuthenticate.php"
        "app/Http/Middleware/ClientAuthenticate.php"
        "app/Http/Middleware/Authenticate.php"
        "app/Exceptions/Handler.php"
        "resources/views/errors/404.blade.php"
        "resources/views/errors/403.blade.php"
        "resources/views/errors/500.blade.php"
        "resources/views/errors/503.blade.php"
        "app/Providers/AppServiceProvider.php"
        "app/Providers/AuthServiceProvider.php"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$SECURITY_BACKUP/$file" ]; then
            mkdir -p "$PANEL_PATH/$(dirname "$file")"
            cp "$SECURITY_BACKUP/$file" "$PANEL_PATH/$file" 2>/dev/null
            echo -e "${GREEN}✓ Restore: $file${NC}"
        fi
    done
    
    echo -e "${GREEN}Restore selesai!${NC}"
}

# Function to create custom error pages
create_error_pages() {
    echo -e "${BLUE}Membuat custom error pages...${NC}"
    
    # Create error directory if not exists
    mkdir -p "$PANEL_PATH/resources/views/errors"
    
    # Error 403 Forbidden
    cat > "$PANEL_PATH/resources/views/errors/403.blade.php" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>403 Forbidden - Pterodactyl</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            color: white;
        }
        .error-container {
            text-align: center;
            background: rgba(0,0,0,0.8);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        .error-code {
            font-size: 72px;
            font-weight: bold;
            margin-bottom: 20px;
            color: #ff6b6b;
        }
        .error-message {
            font-size: 24px;
            margin-bottom: 30px;
        }
        .security-message {
            font-size: 18px;
            color: #ffd93d;
            margin-top: 20px;
            padding: 15px;
            background: rgba(255,0,0,0.2);
            border-radius: 8px;
            border-left: 4px solid #ff6b6b;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">403</div>
        <div class="error-message">Forbidden</div>
        <div class="security-message">
            🔒 $CUSTOM_ERROR
        </div>
    </div>
</body>
</html>
EOF

    # Error 404 Not Found
    cat > "$PANEL_PATH/resources/views/errors/404.blade.php" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 Not Found - Pterodactyl</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            color: white;
        }
        .error-container {
            text-align: center;
            background: rgba(0,0,0,0.8);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        .error-code {
            font-size: 72px;
            font-weight: bold;
            margin-bottom: 20px;
            color: #ff6b6b;
        }
        .error-message {
            font-size: 24px;
            margin-bottom: 30px;
        }
        .security-message {
            font-size: 18px;
            color: #ffd93d;
            margin-top: 20px;
            padding: 15px;
            background: rgba(255,0,0,0.2);
            border-radius: 8px;
            border-left: 4px solid #ff6b6b;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">404</div>
        <div class="error-message">Page Not Found</div>
        <div class="security-message">
            🔍 $CUSTOM_ERROR
        </div>
    </div>
</body>
</html>
EOF

    # Error 500 Internal Server Error
    cat > "$PANEL_PATH/resources/views/errors/500.blade.php" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 Internal Server Error - Pterodactyl</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            color: white;
        }
        .error-container {
            text-align: center;
            background: rgba(0,0,0,0.8);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        .error-code {
            font-size: 72px;
            font-weight: bold;
            margin-bottom: 20px;
            color: #ff6b6b;
        }
        .error-message {
            font-size: 24px;
            margin-bottom: 30px;
        }
        .security-message {
            font-size: 18px;
            color: #ffd93d;
            margin-top: 20px;
            padding: 15px;
            background: rgba(255,0,0,0.2);
            border-radius: 8px;
            border-left: 4px solid #ff6b6b;
        }
        .warning-icon {
            font-size: 48px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="warning-icon">🚨</div>
        <div class="error-code">500</div>
        <div class="error-message">Internal Server Error</div>
        <div class="security-message">
            ⚠️ $CUSTOM_ERROR_500
        </div>
    </div>
</body>
</html>
EOF

    # Error 503 Service Unavailable
    cat > "$PANEL_PATH/resources/views/errors/503.blade.php" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>503 Service Unavailable - Pterodactyl</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            color: white;
        }
        .error-container {
            text-align: center;
            background: rgba(0,0,0,0.8);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        .error-code {
            font-size: 72px;
            font-weight: bold;
            margin-bottom: 20px;
            color: #ff6b6b;
        }
        .error-message {
            font-size: 24px;
            margin-bottom: 30px;
        }
        .security-message {
            font-size: 18px;
            color: #ffd93d;
            margin-top: 20px;
            padding: 15px;
            background: rgba(255,0,0,0.2);
            border-radius: 8px;
            border-left: 4px solid #ff6b6b;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">503</div>
        <div class="error-message">Service Unavailable</div>
        <div class="security-message">
            🔧 $CUSTOM_ERROR
        </div>
    </div>
</body>
</html>
EOF

    echo -e "${GREEN}Custom error pages berhasil dibuat!${NC}"
}

# Function to install security protection
install_security() {
    echo -e "${YELLOW}Memulai instalasi security protection...${NC}"
    
    # Backup original files first
    backup_files
    
    # 1. Anti Delete Server & User Protection
    echo -e "${BLUE}Menginstall Anti Delete Server & User...${NC}"
    
    # Modify ServersController.php for anti delete
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/ServersController.php" << EOF
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Server;
use Prologue\Alerts\AlertsMessageBag;

class ServersController extends Controller
{
    protected \$alerts;

    public function __construct(AlertsMessageBag \$alerts)
    {
        \$this->alerts = \$alerts;
    }

    public function delete(Request \$request, \$id)
    {
        \$this->alerts->danger('$CUSTOM_ERROR')->flash();
        return redirect()->route('admin.servers');
    }

    public function destroy(Request \$request, \$id)
    {
        \$this->alerts->danger('$CUSTOM_ERROR')->flash();
        return redirect()->route('admin.servers');
    }

    public function view(Request \$request, \$id)
    {
        // Additional protection for viewing servers
        if (!\$request->user() || !\$request->user()->root_admin) {
            abort(500, '$CUSTOM_ERROR_500');
        }

        return parent::view(\$request, \$id);
    }
}
EOF

    # Modify UsersController.php for anti delete
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/UsersController.php" << EOF
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\User;
use Prologue\Alerts\AlertsMessageBag;

class UsersController extends Controller
{
    protected \$alerts;

    public function __construct(AlertsMessageBag \$alerts)
    {
        \$this->alerts = \$alerts;
    }

    public function delete(Request \$request, \$id)
    {
        \$this->alerts->danger('$CUSTOM_ERROR')->flash();
        return redirect()->route('admin.users');
    }

    public function destroy(Request \$request, \$id)
    {
        \$this->alerts->danger('$CUSTOM_ERROR')->flash();
        return redirect()->route('admin.users');
    }

    public function view(Request \$request, \$id)
    {
        if (!\$request->user() || !\$request->user()->root_admin) {
            abort(500, '$CUSTOM_ERROR_500');
        }

        return parent::view(\$request, \$id);
    }
}
EOF

    # 2. Anti Intip Location, Nodes, Nest
    echo -e "${BLUE}Menginstall Anti Intip Location, Nodes, Nest...${NC}"
    
    # Modify NodesController.php
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NodesController.php" << EOF
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\Node;
use Prologue\Alerts\AlertsMessageBag;

class NodesController extends Controller
{
    protected \$alerts;

    public function __construct(AlertsMessageBag \$alerts)
    {
        \$this->alerts = \$alerts;
    }

    public function view(Request \$request, \$id)
    {
        if (!\$request->user() || !\$request->user()->root_admin) {
            abort(500, '$CUSTOM_ERROR_500');
        }

        \$this->alerts->danger('$CUSTOM_ERROR')->flash();
        return redirect()->route('admin.nodes');
    }

    public function index()
    {
        if (!auth()->user()->root_admin) {
            abort(500, '$CUSTOM_ERROR_500');
        }

        \$this->alerts->danger('$CUSTOM_ERROR')->flash();
        return redirect()->route('admin.index');
    }

    public function configuration(Request \$request, \$id)
    {
        abort(500, '$CUSTOM_ERROR_500');
    }
}
EOF

    # Modify NestsController.php
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/NestsController.php" << EOF
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Prologue\Alerts\AlertsMessageBag;

class NestsController extends Controller
{
    protected \$alerts;

    public function __construct(AlertsMessageBag \$alerts)
    {
        \$this->alerts = \$alerts;
    }

    public function view(Request \$request, \$id)
    {
        if (!\$request->user() || !\$request->user()->root_admin) {
            abort(500, '$CUSTOM_ERROR_500');
        }

        \$this->alerts->danger('$CUSTOM_ERROR')->flash();
        return redirect()->route('admin.nests');
    }

    public function index()
    {
        if (!auth()->user()->root_admin) {
            abort(500, '$CUSTOM_ERROR_500');
        }

        \$this->alerts->danger('$CUSTOM_ERROR')->flash();
        return redirect()->route('admin.index');
    }
}
EOF

    # Modify LocationsController.php
    cat > "$PANEL_PATH/app/Http/Controllers/Admin/LocationsController.php" << EOF
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Prologue\Alerts\AlertsMessageBag;

class LocationsController extends Controller
{
    protected \$alerts;

    public function __construct(AlertsMessageBag \$alerts)
    {
        \$this->alerts = \$alerts;
    }

    public function view(Request \$request, \$id)
    {
        if (!\$request->user() || !\$request->user()->root_admin) {
            abort(500, '$CUSTOM_ERROR_500');
        }

        \$this->alerts->danger('$CUSTOM_ERROR')->flash();
        return redirect()->route('admin.locations');
    }

    public function index()
    {
        if (!auth()->user()->root_admin) {
            abort(500, '$CUSTOM_ERROR_500');
        }

        \$this->alerts->danger('$CUSTOM_ERROR')->flash();
        return redirect()->route('admin.index');
    }
}
EOF

    # 3. Anti Akses Server Orang Lain
    echo -e "${BLUE}Menginstall Anti Akses Server Orang Lain...${NC}"
    
    # Modify ServerController for client API
    cat > "$PANEL_PATH/app/Http/Controllers/Api/Client/Servers/ServerController.php" << EOF
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Illuminate\Http\Response;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Models\Server;
use Prologue\Alerts\AlertsMessageBag;

class ServerController extends ClientApiController
{
    protected \$alerts;

    public function __construct(AlertsMessageBag \$alerts)
    {
        \$this->alerts = \$alerts;
    }

    public function index()
    {
        return response()->json([
            'error' => '$CUSTOM_ERROR'
        ], Response::HTTP_FORBIDDEN);
    }

    public function view(\$server)
    {
        // Check if user owns the server
        if (\$server->user_id !== auth()->user()->id) {
            abort(500, '$CUSTOM_ERROR_500');
        }

        return parent::view(\$server);
    }

    public function websocket(\$server)
    {
        if (\$server->user_id !== auth()->user()->id) {
            abort(500, '$CUSTOM_ERROR_500');
        }

        return parent::websocket(\$server);
    }

    public function resources(\$server)
    {
        if (\$server->user_id !== auth()->user()->id) {
            abort(500, '$CUSTOM_ERROR_500');
        }

        return parent::resources(\$server);
    }
}
EOF

    # 4. Enhanced Middleware Protection
    echo -e "${BLUE}Menginstall Enhanced Middleware Protection...${NC}"
    
    # Modify AdminAuthenticate middleware
    cat > "$PANEL_PATH/app/Http/Middleware/AdminAuthenticate.php" << EOF
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminAuthenticate
{
    public function handle(Request \$request, Closure \$next)
    {
        if (!\$request->user() || !\$request->user()->root_admin) {
            if (\$request->expectsJson()) {
                return response()->json([
                    'error' => '$CUSTOM_ERROR'
                ], 403);
            }

            abort(500, '$CUSTOM_ERROR_500');
        }

        return \$next(\$request);
    }
}
EOF

    # Modify ClientAuthenticate middleware
    cat > "$PANEL_PATH/app/Http/Middleware/ClientAuthenticate.php" << EOF
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ClientAuthenticate
{
    public function handle(Request \$request, Closure \$next)
    {
        if (!\$request->user()) {
            if (\$request->expectsJson()) {
                return response()->json([
                    'error' => '$CUSTOM_ERROR'
                ], 401);
            }

            abort(500, '$CUSTOM_ERROR_500');
        }

        return \$next(\$request);
    }
}
EOF

    # Modify main Authenticate middleware
    cat > "$PANEL_PATH/app/Http/Middleware/Authenticate.php" << EOF
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Auth\Middleware\Authenticate as Middleware;

class Authenticate extends Middleware
{
    public function handle(\$request, Closure \$next, ...\$guards)
    {
        if (!\$request->user()) {
            if (\$request->expectsJson()) {
                return response()->json([
                    'error' => '$CUSTOM_ERROR'
                ], 401);
            }

            abort(500, '$CUSTOM_ERROR_500');
        }

        return \$next(\$request);
    }
}
EOF

    # 5. Custom Error Handler dengan protection 500
    echo -e "${BLUE}Menginstall Custom Error Handler dengan Error 500 protection...${NC}"
    
    # Modify Exception Handler
    cat > "$PANEL_PATH/app/Exceptions/Handler.php" << EOF
<?php

namespace Pterodactyl\Exceptions;

use Exception;
use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Prologue\Alerts\AlertsMessageBag;
use Symfony\Component\HttpKernel\Exception\HttpException;

class Handler extends ExceptionHandler
{
    protected \$alerts;

    public function __construct(AlertsMessageBag \$alerts)
    {
        \$this->alerts = \$alerts;
    }

    public function render(\$request, Exception \$exception)
    {
        // Log all access attempts
        if (\$request->user()) {
            \\Log::warning('Security Alert - Unauthorized access attempt', [
                'user_id' => \$request->user()->id,
                'email' => \$request->user()->email,
                'url' => \$request->fullUrl(),
                'ip' => \$request->ip(),
                'user_agent' => \$request->userAgent()
            ]);
        }

        // For 500 Internal Server Error
        if (\$exception instanceof \\Symfony\\Component\\HttpKernel\\Exception\\HttpException && 
            \$exception->getStatusCode() == 500) {
            if (\$request->expectsJson()) {
                return response()->json([
                    'error' => '$CUSTOM_ERROR_500'
                ], 500);
            }
            
            return response()->view('errors.500', [
                'message' => '$CUSTOM_ERROR_500'
            ], 500);
        }

        // For 403 Forbidden errors
        if (\$exception instanceof \\Illuminate\\Auth\\Access\\AuthorizationException) {
            if (\$request->expectsJson()) {
                return response()->json([
                    'error' => '$CUSTOM_ERROR'
                ], 403);
            }
            
            \$this->alerts->danger('$CUSTOM_ERROR')->flash();
            return redirect()->back();
        }

        // For 404 Not Found errors
        if (\$exception instanceof \\Symfony\\Component\\HttpKernel\\Exception\\NotFoundHttpException) {
            if (\$request->expectsJson()) {
                return response()->json([
                    'error' => '$CUSTOM_ERROR'
                ], 404);
            }
            
            return response()->view('errors.404', [
                'message' => '$CUSTOM_ERROR'
            ], 404);
        }

        // For any other exceptions, show 500 error
        if (!config('app.debug')) {
            if (\$request->expectsJson()) {
                return response()->json([
                    'error' => '$CUSTOM_ERROR_500'
                ], 500);
            }
            
            return response()->view('errors.500', [
                'message' => '$CUSTOM_ERROR_500'
            ], 500);
        }

        return parent::render(\$request, \$exception);
    }
}
EOF

    # 6. Create custom error pages
    create_error_pages

    # 7. Additional Security in AppServiceProvider
    cat > "$PANEL_PATH/app/Providers/AppServiceProvider.php" << EOF
<?php

namespace Pterodactyl\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Gate;

class AppServiceProvider extends ServiceProvider
{
    public function boot()
    {
        // Additional security gates
        Gate::define('view-node', function (\$user) {
            if (!\$user->root_admin) {
                abort(500, '$CUSTOM_ERROR_500');
            }
            return \$user->root_admin;
        });

        Gate::define('view-nest', function (\$user) {
            if (!\$user->root_admin) {
                abort(500, '$CUSTOM_ERROR_500');
            }
            return \$user->root_admin;
        });

        Gate::define('view-location', function (\$user) {
            if (!\$user->root_admin) {
                abort(500, '$CUSTOM_ERROR_500');
            }
            return \$user->root_admin;
        });

        // Log all admin actions
        if (config('logging.channels.security')) {
            \\Log::channel('security')->info('Security Protection Activated', [
                'ip' => request()->ip(),
                'user_agent' => request()->userAgent(),
                'time' => now()
            ]);
        }
    }
}
EOF

    # Run panel optimizations
    echo -e "${YELLOW}Menjalankan optimasi panel...${NC}"
    cd "$PANEL_PATH" || exit 1
    php artisan config:cache
    php artisan view:cache
    php artisan route:cache

    # Set proper permissions
    chown -R www-data:www-data "$PANEL_PATH"
    chmod -R 755 "$PANEL_PATH"
    chmod -R 755 "$PANEL_PATH/storage"
    chmod -R 755 "$PANEL_PATH/bootstrap/cache"

    echo -e "${GREEN}Security protection berhasil diinstall!${NC}"
    echo -e "${YELLOW}Semua error pages telah diganti dengan custom messages.${NC}"
    echo -e "${PURPLE}Error 500 Protection: $CUSTOM_ERROR_500${NC}"
}

# Function to change error texts
change_error_texts() {
    echo -e "${YELLOW}Mengganti teks error...${NC}"
    
    # Update error messages in all files
    sed -i "s|Ngapain sih? mau nyolong sc org? - By @ginaabaikhati|$CUSTOM_ERROR|g" "$PANEL_PATH"/app/Http/Controllers/*.php 2>/dev/null
    sed -i "s|ERROR 500: Dilarang mengintip! - By @ginaabaikhati|$CUSTOM_ERROR_500|g" "$PANEL_PATH"/app/Http/Controllers/*.php 2>/dev/null
    sed -i "s|Ngapain sih? mau nyolong sc org? - By @ginaabaikhati|$CUSTOM_ERROR|g" "$PANEL_PATH"/app/Http/Middleware/*.php 2>/dev/null
    sed -i "s|ERROR 500: Dilarang mengintip! - By @ginaabaikhati|$CUSTOM_ERROR_500|g" "$PANEL_PATH"/app/Http/Middleware/*.php 2>/dev/null
    
    # Update error pages
    create_error_pages
    
    echo -e "${GREEN}Teks error berhasil diganti!${NC}"
    echo -e "${BLUE}Custom message: '$CUSTOM_ERROR'${NC}"
    echo -e "${BLUE}Error 500 message: '$CUSTOM_ERROR_500'${NC}"
}

# Function to uninstall security
uninstall_security() {
    echo -e "${YELLOW}Memulai uninstall security protection...${NC}"
    
    if [ ! -d "$SECURITY_BACKUP" ]; then
        echo -e "${RED}Backup tidak ditemukan! Tidak bisa melakukan uninstall.${NC}"
        return 1
    fi
    
    # Restore from backup
    restore_backup
    
    # Run panel optimizations
    echo -e "${YELLOW}Menjalankan optimasi panel...${NC}"
    cd "$PANEL_PATH" || exit 1
    php artisan config:clear
    php artisan view:clear
    php artisan route:clear
    php artisan cache:clear
    
    php artisan config:cache
    php artisan view:cache
    php artisan route:cache

    echo -e "${GREEN}Security protection berhasil diuninstall!${NC}"
}

# Function to check security status
check_status() {
    echo -e "${YELLOW}Memeriksa status security...${NC}"
    
    if [ -d "$SECURITY_BACKUP" ]; then
        echo -e "${GREEN}Security protection terdeteksi terinstall.${NC}"
        echo -e "${BLUE}Backup files tersedia di: $SECURITY_BACKUP${NC}"
    else
        echo -e "${RED}Security protection tidak terdeteksi.${NC}"
    fi
    
    # Check security features
    local features=(
        "Anti Delete Server:app/Http/Controllers/Admin/ServersController.php"
        "Anti Intip Nodes:app/Http/Controllers/Admin/NodesController.php"
        "Anti Intip Nests:app/Http/Controllers/Admin/NestsController.php"
        "Anti Intip Locations:app/Http/Controllers/Admin/LocationsController.php"
        "Error 500 Protection:app/Exceptions/Handler.php"
        "Custom Error Pages:resources/views/errors/500.blade.php"
    )
    
    for feature in "${features[@]}"; do
        local name="${feature%%:*}"
        local file="${feature##*:}"
        
        if grep -q "ginaabaikhati" "$PANEL_PATH/$file" 2>/dev/null; then
            echo -e "${GREEN}✓ $name aktif${NC}"
        else
            echo -e "${RED}✗ $name tidak aktif${NC}"
        fi
    done
}

# Function to test error pages
test_error_pages() {
    echo -e "${YELLOW}Testing error pages...${NC}"
    echo -e "${BLUE}Error pages yang tersedia:${NC}"
    
    local errors=("403" "404" "500" "503")
    for error in "${errors[@]}"; do
        if [ -f "$PANEL_PATH/resources/views/errors/$error.blade.php" ]; then
            echo -e "${GREEN}✓ Error $error.blade.php ditemukan${NC}"
        else
            echo -e "${RED}✗ Error $error.blade.php tidak ditemukan${NC}"
        fi
    done
}

# Main menu
main_menu() {
    while true; do
        show_banner
        echo -e "${GREEN}Pilih opsi:${NC}"
        echo -e "1. Install Security Panel"
        echo -e "2. Ganti Teks Error" 
        echo -e "3. Uninstall Security Panel"
        echo -e "4. Check Status Security"
        echo -e "5. Test Error Pages"
        echo -e "6. Exit Security Panel"
        echo -e ""
        read -p "Masukkan pilihan [1-6]: " choice
        
        case $choice in
            1)
                install_security
                ;;
            2)
                change_error_texts
                ;;
            3)
                uninstall_security
                ;;
            4)
                check_status
                ;;
            5)
                test_error_pages
                ;;
            6)
                echo -e "${GREEN}Keluar dari Security Panel.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Pilihan tidak valid!${NC}"
                ;;
        esac
        
        echo -e ""
        read -p "Tekan Enter untuk melanjutkan..."
    done
}

# Check if panel path exists
if [ ! -d "$PANEL_PATH" ]; then
    echo -e "${RED}Directory panel Pterodactyl tidak ditemukan di: $PANEL_PATH${NC}"
    echo -e "${YELLOW}Silakan edit variabel PANEL_PATH di script ini sesuai dengan path instalasi panel Anda.${NC}"
    exit 1
fi

# Start the script
main_menu
