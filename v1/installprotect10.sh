#!/bin/bash

# Path untuk proteksi server modification
SERVER_MOD_PATH="/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php"
# Path untuk proteksi admin view
ADMIN_VIEW_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ViewController.php"
# Path untuk proteksi server list
SERVER_LIST_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerTableController.php"

TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

echo "🚀 Memasang Proteksi Level 10 - Advanced Security..."

# Fungsi untuk backup file
backup_file() {
    local file_path=$1
    if [ -f "$file_path" ]; then
        local backup_path="${file_path}.bak_${TIMESTAMP}"
        cp "$file_path" "$backup_path"
        echo "📦 Backup file dibuat: $backup_path"
    fi
}

# 1. Proteksi Server Modification
echo "🔧 Memasang proteksi modifikasi server..."
backup_file "$SERVER_MOD_PATH"

mkdir -p "$(dirname "$SERVER_MOD_PATH")"
chmod 755 "$(dirname "$SERVER_MOD_PATH")"

cat > "$SERVER_MOD_PATH" << 'EOF'
<?php

namespace Pterodactyl\Services\Servers;

use Illuminate\Support\Arr;
use Pterodactyl\Models\Server;
use Illuminate\Support\Facades\Auth;
use Illuminate\Database\ConnectionInterface;
use Pterodactyl\Traits\Services\ReturnsUpdatedModels;
use Pterodactyl\Repositories\Wings\DaemonServerRepository;
use Pterodactyl\Exceptions\Http\Connection\DaemonConnectionException;

class DetailsModificationService
{
    use ReturnsUpdatedModels;

    public function __construct(
        private ConnectionInterface $connection,
        private DaemonServerRepository $serverRepository
    ) {}

    /**
     * Update the details for a single server instance.
     *
     * @throws \Throwable
     */
    public function handle(Server $server, array $data): Server
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati | 𝗌𝗎𝗉𝖾𝗋 𝖺𝖽𝗆𝗂𝗇 𝗈𝗇𝗅𝗒');
        }

        return $this->connection->transaction(function () use ($data, $server) {
            $owner = $server->owner_id;

            $server->forceFill([
                'external_id' => Arr::get($data, 'external_id'),
                'owner_id' => Arr::get($data, 'owner_id'),
                'name' => Arr::get($data, 'name'),
                'description' => Arr::get($data, 'description') ?? '',
            ])->saveOrFail();

            // Jika owner berubah, revoke token lama
            if ($server->owner_id !== $owner) {
                try {
                    $this->serverRepository->setServer($server)->revokeUserJTI($owner);
                } catch (DaemonConnectionException $exception) {
                    // Abaikan error dari Wings offline
                }
            }

            return $server;
        });
    }
}
?>
EOF

chmod 644 "$SERVER_MOD_PATH"

# 2. Proteksi Admin View
echo "🔧 Memasang proteksi admin view..."
backup_file "$ADMIN_VIEW_PATH"

mkdir -p "$(dirname "$ADMIN_VIEW_PATH")"
chmod 755 "$(dirname "$ADMIN_VIEW_PATH")"

cat > "$ADMIN_VIEW_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Servers;

use Illuminate\Http\Request;
use Pterodactyl\Models\Server;
use Illuminate\Support\Facades\Auth;
use Pterodactyl\Http\Controllers\Controller;

class ViewController extends Controller
{
    /**
     * Return server view for admin.
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
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati | 𝗌𝗎𝗉𝖾𝗋 𝖺𝖽𝗆𝗂𝗇 𝗈𝗇𝗅𝗒');
        }

        return view('admin.servers.view', ['server' => $server]);
    }

    /**
     * Return server management view for admin.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function manage(Request $request, Server $server)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati | 𝗌𝗎𝗉𝖾𝗋 𝖺𝖽𝗆𝗂𝗇 𝗈𝗇𝗅𝗒');
        }

        return view('admin.servers.manage', ['server' => $server]);
    }
}
?>
EOF

chmod 644 "$ADMIN_VIEW_PATH"

# 3. Proteksi Server List (Nodes & Daemon)
echo "🔧 Memasang proteksi server list dengan nodes..."
backup_file "$SERVER_LIST_PATH"

mkdir -p "$(dirname "$SERVER_LIST_PATH")"
chmod 755 "$(dirname "$SERVER_LIST_PATH")"

cat > "$SERVER_LIST_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Servers;

use Illuminate\Http\JsonResponse;
use Illuminate\View\View;
use Pterodactyl\Models\Server;
use Illuminate\Support\Facades\Auth;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Eloquent\ServerRepository;
use Pterodactyl\Contracts\Repository\ServerRepositoryInterface;

class ServerTableController extends Controller
{
    /**
     * ServerTableController constructor.
     */
    public function __construct(private ServerRepositoryInterface $repository)
    {
        parent::__construct();
    }

    /**
     * Return the server overview page.
     */
    public function index(): View
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            // Tampilkan pesan error yang lebih informatif
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati | 𝗌𝗎𝗉𝖾𝗋 𝖺𝖽𝗆𝗂𝗇 𝗈𝗇𝗅𝗒');
        }

        return view('admin.servers.index', [
            'nodes' => $user->id === 1 ? $this->repository->getAllNodes() : [],
            'servers' => $user->id === 1 ? $this->repository->getAllServers() : [],
        ]);
    }

    /**
     * Return server data for the server list.
     */
    public function __invoke(): JsonResponse
    {
        $user = Auth::user();
        
        // 🚫 Batasi akses hanya untuk user ID 1
        if (!$user || $user->id !== 1) {
            return response()->json([
                'data' => [],
                'recordsTotal' => 0,
                'recordsFiltered' => 0,
                'draw' => (int) request()->get('draw', 0)
            ]);
        }

        $servers = $this->repository->setSearchTerm(request()->get('search', ''))->getDataTables();

        $data = [];
        foreach ($servers->items() as $server) {
            $data[] = [
                'id' => $server->id,
                'identifier' => $server->uuidShort,
                'name' => $server->name,
                'owner' => $server->user->username,
                'node' => $server->node->name,
                'connection' => $server->node->getConnectionAddress(),
                'created_at' => $server->created_at->toDateTimeString(),
            ];
        }

        return response()->json([
            'data' => $data,
            'recordsTotal' => $servers->total(),
            'recordsFiltered' => $servers->total(),
            'draw' => (int) request()->get('draw', 0)
        ]);
    }
}
?>
EOF

chmod 644 "$SERVER_LIST_PATH"

echo ""
echo "✅ Proteksi Level 10 berhasil dipasang!"
echo "📂 File yang diproteksi:"
echo "   - $SERVER_MOD_PATH"
echo "   - $ADMIN_VIEW_PATH" 
echo "   - $SERVER_LIST_PATH"
echo ""
echo "🔒 Fitur Keamanan:"
echo "   ✓ Hanya Admin ID 1 bisa modifikasi server"
echo "   ✓ Admin lain tidak bisa akses view server"
echo "   ✓ Server list dengan nodes hanya bisa dilihat Admin ID 1"
echo "   ✓ Button 'Create New' tetap tersedia untuk semua admin"
echo "   ✓ Proteksi tiga lapis keamanan"
echo ""
echo "⚠️  Jangan lupa jalankan: php artisan optimize:clear"
