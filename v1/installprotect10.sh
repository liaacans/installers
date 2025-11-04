#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/ServersController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Panel Admin Servers..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Models\Server;
use Pterodactyl\Models\Node;
use Illuminate\Support\Facades\DB;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Wings\DaemonServerRepository;

class ServersController extends Controller
{
    private $daemonServerRepository;

    public function __construct(DaemonServerRepository $daemonServerRepository)
    {
        $this->daemonServerRepository = $daemonServerRepository;
    }

    public function index()
    {
        $user = auth()->user();
        
        // 🚫 Batasi akses hanya untuk admin
        if (!$user || !$user->root_admin) {
            abort(403, '
            <div style="font-family: Arial, sans-serif; text-align: center; padding: 50px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; min-height: 100vh;">
                <div style="background: rgba(0,0,0,0.7); padding: 40px; border-radius: 15px; max-width: 600px; margin: 0 auto;">
                    <div style="font-size: 80px; margin-bottom: 20px;">🚫</div>
                    <h1 style="color: #ff6b6b; margin-bottom: 20px;">Akses Ditolak</h1>
                    <p style="font-size: 18px; margin-bottom: 30px; line-height: 1.6;">
                        𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati<br>
                        Hanya administrator yang diizinkan mengakses halaman ini.
                    </p>
                    <div style="background: rgba(255,255,255,0.1); padding: 20px; border-radius: 10px; margin: 20px 0;">
                        <strong>User ID:</strong> ' . ($user ? $user->id : 'Tidak terautentikasi') . '<br>
                        <strong>Status Admin:</strong> ' . ($user && $user->root_admin ? 'Ya' : 'Tidak') . '
                    </div>
                    <a href="/admin" style="display: inline-block; background: #ff6b6b; color: white; padding: 12px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; transition: all 0.3s;">
                        Kembali ke Dashboard
                    </a>
                </div>
            </div>');
        }

        $servers = Server::with(['user', 'node', 'egg'])
            ->when(request()->has('search'), function ($query) {
                $query->where('name', 'like', '%' . request()->input('search') . '%')
                      ->orWhere('uuid', 'like', '%' . request()->input('search') . '%');
            })
            ->orderBy('created_at', 'desc')
            ->paginate(50);

        $nodes = Node::all()->keyBy('id');
        $totalResources = [
            'memory' => $servers->sum('memory'),
            'disk' => $servers->sum('disk'),
        ];

        return view('admin.servers.index', [
            'servers' => $servers,
            'nodes' => $nodes,
            'totalResources' => $totalResources,
        ]);
    }

    public function show($id)
    {
        $user = auth()->user();
        
        // 🚫 Batasi akses hanya untuk admin
        if (!$user || !$user->root_admin) {
            abort(403, '
            <div style="font-family: Arial, sans-serif; text-align: center; padding: 50px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; min-height: 100vh;">
                <div style="background: rgba(0,0,0,0.7); padding: 40px; border-radius: 15px; max-width: 600px; margin: 0 auto;">
                    <div style="font-size: 80px; margin-bottom: 20px;">🚫</div>
                    <h1 style="color: #ff6b6b; margin-bottom: 20px;">Akses Ditolak</h1>
                    <p style="font-size: 18px; margin-bottom: 30px; line-height: 1.6;">
                        𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati<br>
                        Hanya administrator yang diizinkan mengakses detail server.
                    </p>
                    <div style="background: rgba(255,255,255,0.1); padding: 20px; border-radius: 10px; margin: 20px 0;">
                        <strong>User ID:</strong> ' . ($user ? $user->id : 'Tidak terautentikasi') . '<br>
                        <strong>Status Admin:</strong> ' . ($user && $user->root_admin ? 'Ya' : 'Tidak') . '
                    </div>
                    <a href="/admin/servers" style="display: inline-block; background: #ff6b6b; color: white; padding: 12px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; transition: all 0.3s;">
                        Kembali ke Daftar Server
                    </a>
                </div>
            </div>');
        }

        $server = Server::with(['user', 'node', 'egg', 'allocations'])->findOrFail($id);

        return view('admin.servers.view', [
            'server' => $server,
            'node' => $server->node,
        ]);
    }

    public function create()
    {
        $user = auth()->user();
        
        // 🚫 Batasi akses hanya untuk admin
        if (!$user || !$user->root_admin) {
            abort(403, '
            <div style="font-family: Arial, sans-serif; text-align: center; padding: 50px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; min-height: 100vh;">
                <div style="background: rgba(0,0,0,0.7); padding: 40px; border-radius: 15px; max-width: 600px; margin: 0 auto;">
                    <div style="font-size: 80px; margin-bottom: 20px;">🚫</div>
                    <h1 style="color: #ff6b6b; margin-bottom: 20px;">Akses Ditolak</h1>
                    <p style="font-size: 18px; margin-bottom: 30px; line-height: 1.6;">
                        𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati<br>
                        Hanya administrator yang diizinkan membuat server baru.
                    </p>
                    <div style="background: rgba(255,255,255,0.1); padding: 20px; border-radius: 10px; margin: 20px 0;">
                        <strong>User ID:</strong> ' . ($user ? $user->id : 'Tidak terautentikasi') . '<br>
                        <strong>Status Admin:</strong> ' . ($user && $user->root_admin ? 'Ya' : 'Tidak') . '
                    </div>
                    <a href="/admin/servers" style="display: inline-block; background: #ff6b6b; color: white; padding: 12px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; transition: all 0.3s;">
                        Kembali ke Daftar Server
                    </a>
                </div>
            </div>');
        }

        return view('admin.servers.new');
    }
}
?>
EOF

chmod 644 "$REMOTE_PATH"

# Install CSS custom untuk menyembunyikan sidebar
CSS_PATH="/var/www/pterodactyl/public/themes/pterodactyl/css/custom-protect.css"
cat > "$CSS_PATH" << 'EOF'
/* Sembunyikan menu yang tidak diinginkan */
.sidebar-navigation [href="/admin/nodes"],
.sidebar-navigation [href="/admin/locations"],
.sidebar-navigation [href="/admin/nests"],
.sidebar-navigation [href="/admin/mounts"],
.sidebar-navigation [href="/admin/databases"] {
    display: none !important;
}

/* Sembunyikan kolom Active dan Public di tabel servers */
th:contains("Active"),
td .status-active,
th:contains("Public"),
td .status-public {
    display: none !important;
}

/* Alert custom untuk proteksi */
.protect-alert {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 15px;
    border-radius: 10px;
    margin: 15px 0;
    border-left: 5px solid #ff6b6b;
    text-align: center;
}

.protect-alert strong {
    color: #ffeb3b;
}

.protect-alert .admin-id {
    background: rgba(255,255,255,0.2);
    padding: 5px 10px;
    border-radius: 5px;
    margin: 0 5px;
}
EOF

echo "✅ Proteksi Panel Admin Servers berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🎨 CSS Custom: $CSS_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Hanya Admin Root yang bisa akses Servers"
echo "📱 Sidebar Nodes, Locations, Nests, Mounts, Databases disembunyikan"
