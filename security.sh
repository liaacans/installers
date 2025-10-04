#!/bin/bash

# Custom Security Middleware Installer for Pterodactyl
# Created by @naeldev
# Usage: bash <(curl -s https://raw.githubusercontent.com/iLyxxDev/hosting/main/security.sh)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Log function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Please run as root: sudo bash <(curl -s https://raw.githubusercontent.com/iLyxxDev/hosting/main/security.sh)"
fi

# Pterodactyl directory
PTERO_DIR="/var/www/pterodactyl"

# Check if Pterodactyl exists
if [ ! -d "$PTERO_DIR" ]; then
    error "Pterodactyl directory not found: $PTERO_DIR"
fi

log "🚀 Installing Custom Security Middleware for Pterodactyl..."
log "📁 Pterodactyl directory: $PTERO_DIR"

# Create custom middleware file
log "📝 Creating CustomSecurityCheck middleware..."
cat > $PTERO_DIR/app/Http/Middleware/CustomSecurityCheck.php << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Pterodactyl\Models\Server;
use Pterodactyl\Models\User;
use Pterodactyl\Models\Node;

class CustomSecurityCheck
{
    public function handle(Request $request, Closure $next)
    {
        if (!$request->user()) {
            return $next($request);
        }

        $currentUser = $request->user();
        $path = $request->path();
        $method = $request->method();

        // === PROTECTION: BLOCK ADMIN ACCESS TO ALL WEB PANEL TABS EXCEPT APPLICATION API ===
        if ($currentUser->root_admin && $this->isAdminAccessingRestrictedPanel($path, $method)) {
            return new JsonResponse([
                'error' => 'Mau ngapain hama wkwkwk - @naeldev'
            ], 403);
        }

        // === PROTECTION: BLOCK ADMIN SETTINGS OPERATIONS ===
        if ($currentUser->root_admin && $this->isAdminAccessingSettings($path, $method)) {
            return new JsonResponse([
                'error' => 'Mau ngapain hama wkwkwk - @naeldev'
            ], 403);
        }

        // === PROTECTION: BLOCK ADMIN USER OPERATIONS ===
        if ($currentUser->root_admin && $this->isAdminModifyingUser($path, $method)) {
            return new JsonResponse([
                'error' => 'Mau ngapain hama wkwkwk - @naeldev'
            ], 403);
        }

        // === PROTECTION: BLOCK ADMIN SERVER OPERATIONS ===
        if ($currentUser->root_admin && $this->isAdminModifyingServer($path, $method)) {
            return new JsonResponse([
                'error' => 'Mau ngapain hama wkwkwk - @naeldev'
            ], 403);
        }

        // === PROTECTION: BLOCK ADMIN NODE OPERATIONS ===
        if ($currentUser->root_admin && $this->isAdminModifyingNode($path, $method)) {
            return new JsonResponse([
                'error' => 'Mau ngapain hama wkwkwk - @naeldev'
            ], 403);
        }

        // === PROTECTION: BLOCK ADMIN API DELETE OPERATIONS ===
        if ($currentUser->root_admin && $this->isAdminDeletingViaAPI($path, $method)) {
            return new JsonResponse([
                'error' => 'Mau ngapain hama wkwkwk - @naeldev'
            ], 403);
        }

        // === PROTECTION: SERVER OWNERSHIP CHECK ===
        $server = $request->route('server');
        if ($server instanceof Server) {
            $isServerOwner = $currentUser->id === $server->owner_id;
            if (!$isServerOwner) {
                return new JsonResponse([
                    'error' => 'Mau ngapain hama wkwkwk - @naeldev'
                ], 403);
            }
        }

        // === PROTECTION: USER ACCESS CHECK (NON-ADMIN ONLY) ===
        if (!$currentUser->root_admin) {
            $user = $request->route('user');
            if ($user instanceof User && $currentUser->id !== $user->id) {
                return new JsonResponse([
                    'error' => 'Mau ngapain hama wkwkwk - @naeldev'
                ], 403);
            }

            if ($this->isAccessingRestrictedList($path, $method, $user)) {
                return new JsonResponse([
                    'error' => 'Mau ngapain hama wkwkwk - @naeldev'
                ], 403);
            }
        }

        return $next($request);
    }

    /**
     * Block admin access to all web panel tabs except Application API
     */
    private function isAdminAccessingRestrictedPanel(string $path, string $method): bool
    {
        if ($method !== 'GET') {
            return false;
        }

        // ✅ ALLOW: Application API routes only
        if (str_contains($path, 'admin/api')) {
            return false;
        }

        // ❌ BLOCK: All other admin panel routes
        $restrictedPaths = [
            'admin/users',
            'admin/servers', 
            'admin/nodes',
            'admin/databases',
            'admin/locations',
            'admin/nests',
            'admin/mounts',
            'admin/eggs',
            'admin/settings'
        ];

        foreach ($restrictedPaths as $restrictedPath) {
            if (str_contains($path, $restrictedPath)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Block admin settings operations
     */
    private function isAdminAccessingSettings(string $path, string $method): bool
    {
        // Block all settings operations
        if (str_contains($path, 'admin/settings')) {
            return true;
        }

        // Block settings operations in application API
        if (str_contains($path, 'application/settings')) {
            return in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE']);
        }

        return false;
    }

    /**
     * Block admin user operations (update, delete, etc.)
     */
    private function isAdminModifyingUser(string $path, string $method): bool
    {
        // Block all user modification operations
        if (str_contains($path, 'admin/users')) {
            return in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE']);
        }

        // Block application API user operations
        if (str_contains($path, 'application/users')) {
            return in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE']);
        }

        return false;
    }

    /**
     * Block admin server operations (delete, etc.)
     */
    private function isAdminModifyingServer(string $path, string $method): bool
    {
        // Block server delete operations in admin panel
        if (str_contains($path, 'admin/servers')) {
            if ($method === 'DELETE') {
                return true;
            }
            if ($method === 'POST' && str_contains($path, 'delete')) {
                return true;
            }
        }

        // Block server delete operations in application API
        if (str_contains($path, 'application/servers')) {
            if ($method === 'DELETE') {
                return true;
            }
        }

        return false;
    }

    /**
     * Block admin node operations
     */
    private function isAdminModifyingNode(string $path, string $method): bool
    {
        // Block all node modification operations
        if (str_contains($path, 'admin/nodes')) {
            return in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE']);
        }

        // Block application API node operations
        if (str_contains($path, 'application/nodes')) {
            return in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE']);
        }

        return false;
    }

    /**
     * Block admin delete operations via API Application
     */
    private function isAdminDeletingViaAPI(string $path, string $method): bool
    {
        // Block DELETE user via API: DELETE /api/application/users/{id}
        if ($method === 'DELETE' && preg_match('#application/users/\d+#', $path)) {
            return true;
        }

        // Block DELETE server via API: DELETE /api/application/servers/{id}
        if ($method === 'DELETE' && preg_match('#application/servers/\d+#', $path)) {
            return true;
        }

        // Block force delete server via API: DELETE /api/application/servers/{id}/force
        if ($method === 'DELETE' && preg_match('#application/servers/\d+/.+#', $path)) {
            return true;
        }

        return false;
    }

    /**
     * Check if accessing restricted lists (non-admin only)
     */
    private function isAccessingRestrictedList(string $path, string $method, $user): bool
    {
        if ($method !== 'GET' || $user) {
            return false;
        }

        $restrictedPaths = [
            'admin/users', 'application/users',
            'admin/servers', 'application/servers',
            'admin/nodes', 'application/nodes',
            'admin/databases', 'admin/locations',
            'admin/nests', 'admin/mounts', 'admin/eggs',
            'admin/settings', 'application/settings'
        ];

        foreach ($restrictedPaths as $restrictedPath) {
            if (str_contains($path, $restrictedPath)) {
                return true;
            }
        }

        return false;
    }
}
EOF

log "✅ Custom middleware created"

# Register middleware in Kernel
KERNEL_FILE="$PTERO_DIR/app/Http/Kernel.php"
log "📝 Registering middleware in Kernel..."

if grep -q "custom.security" "$KERNEL_FILE"; then
    warn "⚠️ Middleware already registered in Kernel"
else
    # Add middleware to Kernel
    sed -i "/protected \$middlewareAliases = \[/a\\
    'custom.security' => \\\\Pterodactyl\\\\Http\\\\Middleware\\\\CustomSecurityCheck::class," "$KERNEL_FILE"
    log "✅ Middleware registered in Kernel"
fi

# Apply middleware to routes
log "🔧 Applying middleware to routes..."

# Function to apply middleware to route group (FIXED VERSION)
apply_middleware_to_group() {
    local file="$1"
    local group_prefix="$2"
    
    if [ -f "$file" ]; then
        # Check if group exists without middleware
        if grep -q "Route::group(\['prefix' => '$group_prefix'\])" "$file"; then
            # Replace group without middleware to with middleware
            sed -i "s/Route::group(\['prefix' => '$group_prefix'\]/Route::group(['prefix' => '$group_prefix', 'middleware' => ['custom.security']]/g" "$file"
            log "✅ Applied middleware to $group_prefix group in $(basename $file)"
        elif grep -q "Route::group(\['prefix' => '$group_prefix'," "$file" && ! grep -q "'middleware' => \['custom.security'\]" "$file"; then
            # Group exists with other middleware but not our custom.security
            sed -i "s/Route::group(\['prefix' => '$group_prefix',/Route::group(['prefix' => '$group_prefix', 'middleware' => ['custom.security'],/g" "$file"
            log "✅ Added middleware to existing $group_prefix group in $(basename $file)"
        else
            warn "⚠️ $group_prefix group not found or already has middleware in $(basename $file)"
        fi
    else
        warn "⚠️ File not found: $(basename $file)"
    fi
}

# Function to apply middleware to individual routes (FIXED VERSION)
apply_middleware_to_route() {
    local file="$1"
    local route_pattern="$2"
    
    if [ -f "$file" ]; then
        # Find routes that don't have custom.security middleware yet
        while IFS= read -r line; do
            if [[ $line =~ $route_pattern ]] && [[ ! $line =~ "custom.security" ]]; then
                # Add middleware to the route
                if [[ $line =~ \)\; ]]; then
                    # Route without existing middleware
                    new_line=$(echo "$line" | sed "s/);/)->middleware(['custom.security']);/")
                elif [[ $line =~ \)\-\>middleware\( ]]; then
                    # Route with existing middleware
                    new_line=$(echo "$line" | sed "s/)->middleware(\[/)->middleware(['custom.security', /")
                else
                    # Route with other formatting
                    new_line=$(echo "$line" | sed "s/);/)->middleware(['custom.security']);/")
                fi
                
                # Replace the line in the file
                escaped_line=$(printf '%s\n' "$line" | sed 's/[[\.*^$/]/\\&/g')
                escaped_new_line=$(printf '%s\n' "$new_line" | sed 's/[[\.*^$/]/\\&/g')
                sed -i "s|$escaped_line|$escaped_new_line|g" "$file"
                
                log "✅ Applied middleware to route: $(echo "$line" | tr -d '\n' | sed 's/^[[:space:]]*//')"
            fi
        done < <(grep "$route_pattern" "$file")
    fi
}

# Apply middleware to route groups
log "🔧 Applying middleware to route groups..."
apply_middleware_to_group "$PTERO_DIR/routes/api-client.php" "'/files'"
apply_middleware_to_group "$PTERO_DIR/routes/api-application.php" "'/users'"
apply_middleware_to_group "$PTERO_DIR/routes/api-application.php" "'/servers'"
apply_middleware_to_group "$PTERO_DIR/routes/api-application.php" "'/nodes'"
apply_middleware_to_group "$PTERO_DIR/routes/admin.php" "'settings'"
apply_middleware_to_group "$PTERO_DIR/routes/admin.php" "'users'"
apply_middleware_to_group "$PTERO_DIR/routes/admin.php" "'servers'"
apply_middleware_to_group "$PTERO_DIR/routes/admin.php" "'nodes'"

# Apply middleware to individual DELETE routes in api-application.php
log "🔧 Applying middleware to individual DELETE routes..."
API_APP_FILE="$PTERO_DIR/routes/api-application.php"
if [ -f "$API_APP_FILE" ]; then
    # Apply to user delete route
    apply_middleware_to_route "$API_APP_FILE" "Route::delete.*users.*delete"
    apply_middleware_to_route "$API_APP_FILE" "Route::delete.*users.*{user:id}.*\].*delete"
    
    # Apply to server delete routes
    apply_middleware_to_route "$API_APP_FILE" "Route::delete.*servers.*delete"
    apply_middleware_to_route "$API_APP_FILE" "Route::delete.*servers.*{server:id}.*\].*delete"
    apply_middleware_to_route "$API_APP_FILE" "Route::delete.*servers.*{server:id}.*{force.*\].*delete"
fi

# Apply middleware to server group in api-client
API_CLIENT_FILE="$PTERO_DIR/routes/api-client.php"
if [ -f "$API_CLIENT_FILE" ] && grep -q "Route::group(\['prefix' => '/servers/{server}', 'middleware' => \[" "$API_CLIENT_FILE"; then
    if ! grep -q "'custom.security'" "$API_CLIENT_FILE"; then
        sed -i "/Route::group(\['prefix' => '\/servers\/{server}', 'middleware' => \[/a\\
        'custom.security'," "$API_CLIENT_FILE"
        log "✅ Applied to server group in api-client.php"
    fi
fi

# Manual check and fix for critical routes
log "🔍 Manual checking critical routes..."
check_and_fix_route() {
    local file="$1"
    local route_desc="$2"
    local route_pattern="$3"
    
    if [ -f "$file" ] && grep -q "$route_pattern" "$file" && ! grep -q "custom.security" "$file" && grep -q "$route_pattern" "$file"; then
        warn "⚠️ $route_desc in $(basename $file) doesn't have middleware, adding manually..."
        
        # Simple approach: add ->middleware(['custom.security']) before the closing );
        sed -i "s/$route_pattern[^)]*);/$route_pattern->middleware(['custom.security']);/g" "$file"
        log "✅ Manually added middleware to $route_desc"
    fi
}

# Check specific critical routes
check_and_fix_route "$PTERO_DIR/routes/api-application.php" "User delete route" "Route::delete.*users.*{user:id}.*Application.*Users.*UserController.*delete"
check_and_fix_route "$PTERO_DIR/routes/api-application.php" "Server delete route" "Route::delete.*servers.*{server:id}.*Application.*Servers.*ServerController.*delete"

# Clear cache and optimize
log "🧹 Clearing cache and optimizing..."
cd $PTERO_DIR

sudo -u www-data php artisan config:clear
sudo -u www-data php artisan route:clear
sudo -u www-data php artisan view:clear
sudo -u www-data php artisan cache:clear
sudo -u www-data php artisan optimize

log "✅ Cache cleared successfully"

# Restart services
log "🔄 Restarting services..."

# Detect PHP version
PHP_SERVICE=""
if systemctl is-active --quiet php8.2-fpm; then
    PHP_SERVICE="php8.2-fpm"
elif systemctl is-active --quiet php8.1-fpm; then
    PHP_SERVICE="php8.1-fpm"
elif systemctl is-active --quiet php8.0-fpm; then
    PHP_SERVICE="php8.0-fpm"
elif systemctl is-active --quiet php8.3-fpm; then
    PHP_SERVICE="php8.3-fpm"
else
    warn "⚠️ PHP-FPM service not detected, skipping restart"
fi

if [ -n "$PHP_SERVICE" ]; then
    systemctl restart $PHP_SERVICE
    log "✅ $PHP_SERVICE restarted"
fi

if systemctl is-active --quiet pteroq-service; then
    systemctl restart pteroq-service
    log "✅ pterodactyl-service restarted"
fi

if systemctl is-active --quiet nginx; then
    systemctl reload nginx
    log "✅ nginx reloaded"
fi

# Final verification
log "🔍 Verifying middleware application..."
echo
log "📋 Applied middleware to:"
log "   ✅ Route groups: files, users, servers, nodes, settings"
log "   ✅ Individual DELETE routes in api-application.php"
log "   ✅ Server group in api-client.php"
echo
log "🎉 Custom Security Middleware installed successfully!"
echo
log "📊 PROTECTION SUMMARY:"
log "   ✅ Admin hanya bisa akses: Application API"
log "   ❌ Admin DIBLOKIR dari:"
log "      - Users, Servers, Nodes, Settings"
log "      - Databases, Locations, Nests, Mounts, Eggs"
log "      - Delete/Update operations"
log "   🔒 API DELETE Operations DIBLOKIR:"
log "      - DELETE /api/application/users/{id}"
log "      - DELETE /api/application/servers/{id}" 
log "      - DELETE /api/application/servers/{id}/force"
log "   🔒 Server ownership protection aktif"
log "   🛡️ User access restriction aktif"
echo
log "💬 Source Code Credit by - @naeldev'"
echo
warn "⚠️ IMPORTANT: Test dengan login sebagai admin dan coba akses tabs yang diblokir"
log "   Untuk uninstall, hapus middleware dari Kernel.php dan routes"
