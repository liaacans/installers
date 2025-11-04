#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerViewController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Admin Server View..."

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
use Pterodactyl\Repositories\Wings\DaemonServerRepository;

class ServerViewController extends Controller
{
    /**
     * Display a single server overview page.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function index(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }
        
        return view('admin.servers.view.index', [
            'server' => $server,
            'actions' => null,
        ]);
    }

    /**
     * Display server details page.
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
     * Display server build configuration page.
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
            'actions' => null,
        ]);
    }

    /**
     * Display server startup management page.
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
     * Display server database management page.
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
     * Display server users management page.
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

# Proteksi untuk Server List - Hilangkan Tabel Nodes
NODES_LIST_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php"
NODES_LIST_BACKUP="${NODES_LIST_PATH}.bak_${TIMESTAMP}"

if [ -f "$NODES_LIST_PATH" ]; then
  cp "$NODES_LIST_PATH" "$NODES_LIST_BACKUP"
  echo "📦 Backup nodes controller dibuat di $NODES_LIST_BACKUP"
  
  # Modifikasi index method untuk membatasi akses
  sed -i '/public function index/,/^    \}/ {
    /public function index/,/^    \}/ {
      /public function index/a\
        // 🚫 Batasi akses hanya untuk user ID 1\
        $user = \\Illuminate\\Support\\Facades\\Auth::user();\
        if (!$user || $user->id !== 1) {\
            abort(403, \"𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati\");\
        }
    }
  }' "$NODES_LIST_PATH"
fi

echo "✅ Proteksi Admin Server View berhasil dipasang!"
echo "📂 Lokasi file utama: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Hanya Admin (ID 1) yang bisa akses:"
echo "   - Server View Pages"
echo "   - Nodes List"
echo "   - Button server tetap tersedia untuk semua admin"
