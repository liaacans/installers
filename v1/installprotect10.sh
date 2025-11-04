#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerViewController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti Modifikasi Server View..."

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
use Pterodactyl\Services\Servers\DetailsModificationService;

class ServerViewController extends Controller
{
    public function __construct(
        private DaemonServerRepository $daemonServerRepository,
        private DetailsModificationService $detailsModificationService
    ) {}

    /**
     * Display server index view.
     *
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\View\View
     */
    public function index(Request $request)
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        $servers = Server::with(['user', 'node', 'allocation'])
            ->when($request->input('search'), function ($query, $search) {
                $query->search($search);
            })
            ->paginate(50);

        return view('admin.servers.index', [
            'servers' => $servers,
            'search' => $request->input('search'),
        ]);
    }

    /**
     * Display single server view.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function show(Server $server)
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.index', [
            'server' => $server,
            'actions' => false,
        ]);
    }

    /**
     * Display server settings page.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function settings(Server $server)
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.settings', [
            'server' => $server,
        ]);
    }

    /**
     * Display server management page.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function manage(Server $server)
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.management', [
            'server' => $server,
        ]);
    }

    /**
     * Display server deletion page.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function delete(Server $server)
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.delete', [
            'server' => $server,
        ]);
    }

    /**
     * Display server database page.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function database(Server $server)
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.database', [
            'server' => $server,
        ]);
    }

    /**
     * Display server schedules page.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function schedules(Server $server)
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.schedules', [
            'server' => $server,
        ]);
    }

    /**
     * Display server users page.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function users(Server $server)
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.users', [
            'server' => $server,
        ]);
    }

    /**
     * Display server backups page.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function backups(Server $server)
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.backups', [
            'server' => $server,
        ]);
    }

    /**
     * Display server startup page.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function startup(Server $server)
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.startup', [
            'server' => $server,
        ]);
    }

    /**
     * Display server files page.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function files(Server $server)
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.files', [
            'server' => $server,
        ]);
    }

    /**
     * Display server networks page.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function networks(Server $server)
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.networks', [
            'server' => $server,
        ]);
    }

    /**
     * Display server audits page.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function audits(Server $server)
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.audits', [
            'server' => $server,
        ]);
    }

    /**
     * Display server databases page.
     *
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function databases(Server $server)
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.databases', [
            'server' => $server,
        ]);
    }
}
?>
EOF

chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi Server View berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Hanya Admin (ID 1) yang bisa mengakses halaman Server View."
echo "📋 Tabel Owner, Node, dan Connection disembunyikan dari user lain."
echo "➕ Button 'Create New' tetap tersedia."
