#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerViewController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti View Server Admin..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Servers;

use Illuminate\Http\Request;
use Pterodactyl\Models\Server;
use Illuminate\Support\Facades\Auth;
use Pterodactyl\Http\Controllers\Controller;

class ServerViewController extends Controller
{
    /**
     * Display a specific server on the system.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function show(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.index', [
            'server' => $server,
            'actions' => false,
        ]);
    }

    /**
     * Display all server details on the system.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function details(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.details', [
            'server' => $server,
        ]);
    }

    /**
     * Display server build settings.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function build(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.build', [
            'server' => $server,
        ]);
    }

    /**
     * Display server startup settings.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function startup(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.startup', [
            'server' => $server,
        ]);
    }

    /**
     * Display server database settings.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function database(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.database', [
            'server' => $server,
        ]);
    }

    /**
     * Display server users settings.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function users(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.users', [
            'server' => $server,
        ]);
    }
}
?>
EOF

chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi Anti View Server Admin berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Hanya Admin (ID 1) yang bisa melihat detail server di panel admin."
