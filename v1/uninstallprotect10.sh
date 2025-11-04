#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerViewController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

echo "🔄 Menghapus proteksi Admin Server View..."

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    echo "✅ Proteksi berhasil dihapus! File dikembalikan dari backup: $(basename $LATEST_BACKUP)"
else
    echo "⚠️  Backup file tidak ditemukan. Membuat file default..."
    
    cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Servers;

use Illuminate\Http\Request;
use Pterodactyl\Models\Server;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Wings\DaemonServerRepository;
use Pterodactyl\Repositories\Eloquent\ServerRepository;

class ServerViewController extends Controller
{
    /**
     * ServerViewController constructor.
     */
    public function __construct(
        private ServerRepository $repository,
        private DaemonServerRepository $daemonServerRepository
    ) {}

    /**
     * Get the server index view.
     */
    public function index(Request $request)
    {
        $servers = $this->repository->setSearchTerm($request->input('query'))->getAllServersForAdmin(
            $request->input('status'),
            config('pterodactyl.paginate.admin.servers')
        );

        return view('admin.servers.index', [
            'servers' => $servers,
            'status' => $request->input('status'),
        ]);
    }

    /**
     * Get the server view page.
     */
    public function show(Request $request, Server $server)
    {
        $server->loadMissing(['allocations', 'egg', 'node']);

        return view('admin.servers.view.index', [
            'server' => $server,
            'allocations' => $server->allocations->sortBy('port')->sortBy('ip'),
            'egg' => $server->egg,
            'node' => $server->node,
        ]);
    }

    /**
     * Get the server details page.
     */
    public function details(Request $request, Server $server)
    {
        return view('admin.servers.view.details', ['server' => $server]);
    }

    /**
     * Get the server build configuration page.
     */
    public function build(Request $request, Server $server)
    {
        $allocations = $server->node->allocations->sortBy('ip')->sortBy('port');

        return view('admin.servers.view.build', [
            'server' => $server,
            'allocations' => $allocations,
        ]);
    }

    /**
     * Get the server startup configuration page.
     */
    public function startup(Request $request, Server $server)
    {
        return view('admin.servers.view.startup', ['server' => $server]);
    }

    /**
     * Get the server database management page.
     */
    public function database(Request $request, Server $server)
    {
        return view('admin.servers.view.database', ['server' => $server]);
    }

    /**
     * Get the server management page.
     */
    public function manage(Request $request, Server $server)
    {
        return view('admin.servers.view.manage', ['server' => $server]);
    }

    /**
     * Get the server deletion page.
     */
    public function delete(Request $request, Server $server)
    {
        return view('admin.servers.view.delete', ['server' => $server]);
    }
}
?>
EOF
    echo "✅ File default berhasil dibuat"
fi

# Kembalikan juga view index ke default
INDEX_VIEW_PATH="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
INDEX_BACKUP_PATTERN="${INDEX_VIEW_PATH}.bak_*"
LATEST_INDEX_BACKUP=$(ls -t $INDEX_BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_INDEX_BACKUP" ]; then
    mv "$LATEST_INDEX_BACKUP" "$INDEX_VIEW_PATH"
    echo "✅ Index view dikembalikan dari backup: $(basename $LATEST_INDEX_BACKUP)"
else
    echo "ℹ️  Backup index view tidak ditemukan, file tetap menggunakan versi saat ini"
fi

chmod 644 "$REMOTE_PATH"

echo "🎉 Uninstall selesai! Akses Server View sekarang tersedia untuk semua admin."
echo "📂 File controller: $REMOTE_PATH"
echo "🔄 Silakan restart queue jika diperlukan: php artisan queue:restart"
