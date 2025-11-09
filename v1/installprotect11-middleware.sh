#!/bin/bash

MIDDLEWARE_PATH="/var/www/pterodactyl/app/Http/Middleware/StrictNodeAccess.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

echo "🚀 Membuat middleware strict access control..."

# Buat middleware baru
cat > "$MIDDLEWARE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class StrictNodeAccess
{
    /**
     * 🔒 STRICT NODE ACCESS MIDDLEWARE
     * Hanya izinkan admin ID 1 untuk akses node-related routes
     */
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        
        // Check jika route terkait nodes
        $path = $request->path();
        if (str_contains($path, 'admin/nodes')) {
            // HANYA admin ID 1 yang diizinkan
            if ($user->id !== 1) {
                abort(403, '
                🚫 𝖆𝖐𝖘𝖊𝖘 𝖉𝖎𝖙𝖔𝖑𝖆𝖐 𝖘𝖊𝖑𝖆𝖒𝖆𝖙𝖓𝖞𝖆! 
                
                𝖍𝖆𝖓𝖞𝖆 𝖘𝖚𝖕𝖊𝖗 𝖆𝖉𝖒𝖎𝖓 𝖕𝖗𝖎𝖒𝖆 𝖞𝖆𝖓𝖌 𝖇𝖎𝖘𝖆 𝖆𝖐𝖘𝖊𝖘 𝖕𝖊𝖓𝖌𝖆𝖙𝖚𝖗𝖆𝖓 𝖓𝖔𝖉𝖊.
                
                𝖕𝖗𝖔𝖙𝖊𝖈𝖙 𝖇𝖞 @𝖓𝖆𝖆𝖔𝖋𝖋𝖎𝖈𝖎𝖆𝖑𝖑 | 𝖘𝖊𝖈𝖚𝖗𝖎𝖙𝖞 𝖇𝖞 @𝖌𝖎𝖓𝖆𝖆𝖇𝖆𝖎𝖐𝖍𝖆𝖙𝖎
                𝖙𝖊𝖆𝖒 𝖘𝖊𝖈𝖚𝖗𝖎𝖙𝖞 𝖊𝖝𝖕𝖊𝖗𝖙𝖘 - 𝖘𝖞𝖘𝖙𝖊𝖒 𝖕𝖗𝖔𝖙𝖊𝖈𝖙𝖎𝖔𝖓 𝖆𝖈𝖙𝖎𝖛𝖊
                ');
            }
        }

        return $next($request);
    }
}
EOF

chmod 644 "$MIDDLEWARE_PATH"

# Register middleware ke Kernel
KERNEL_PATH="/var/www/pterodactyl/app/Http/Kernel.php"
if grep -q "StrictNodeAccess" "$KERNEL_PATH"; then
    echo "✅ Middleware sudah terdaftar"
else
    # Tambahkan ke routeMiddleware
    sed -i "/protected \$routeMiddleware = \[/a\
        'strict.node' => \\\\Pterodactyl\\\\Http\\\\Middleware\\\\StrictNodeAccess::class," "$KERNEL_PATH"
    echo "✅ Middleware berhasil didaftarkan"
fi

# Apply middleware ke routes
ROUTES_PATH="/var/www/pterodactyl/routes/admin.php"
if grep -q "strict.node" "$ROUTES_PATH"; then
    echo "✅ Middleware sudah diapply ke routes"
else
    # Tambahkan middleware group untuk nodes
    sed -i "/Route::group(\['prefix' => 'nodes'\], function () {/a\
    Route::group(['middleware' => 'strict.node'], function () {" "$ROUTES_PATH"
    sed -i "/}\); \/\/ End nodes prefix group/ i\
    });" "$ROUTES_PATH"
    echo "✅ Middleware berhasil diapply ke routes nodes"
fi

echo "🔄 Membersihkan cache..."
sudo php /var/www/pterodactyl/artisan cache:clear
sudo php /var/www/pterodactyl/artisan route:clear

echo ""
echo "🎉 MIDDLEWARE STRICT ACCESS BERHASIL DIPASANG!"
echo "🔒 SEMUA akses ke /admin/nodes/* sekarang hanya untuk Admin ID 1"
echo "🚫 Admin lain akan langsung ditolak di level middleware"
