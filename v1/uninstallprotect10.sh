#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerViewController.php"
BACKUP_PATH="${REMOTE_PATH}.bak_*"

echo "🔄 Menghapus proteksi Admin Server View..."

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATH 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
  mv "$LATEST_BACKUP" "$REMOTE_PATH"
  echo "✅ File asli berhasil dikembalikan dari: $LATEST_BACKUP"
else
  echo "⚠️  Backup file tidak ditemukan, membuat file default..."
  
  cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Servers;

use Illuminate\Http\Request;
use Pterodactyl\Models\Server;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Wings\DaemonServerRepository;

class ServerViewController extends Controller
{
    /**
     * Display the server index page.
     *
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\View\View
     */
    public function index(Request $request)
    {
        return view('admin.servers.index', [
            'servers' => Server::with(['user', 'node', 'allocation'])->paginate(50),
        ]);
    }

    /**
     * Display the server view page.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Pterodactyl\Models\Server $server
     * @return \Illuminate\View\View
     */
    public function show(Request $request, Server $server)
    {
        return view('admin.servers.view.index', [
            'server' => $server,
        ]);
    }
}
?>
EOF
fi

# Kembalikan view template asli
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
VIEW_BACKUP="${VIEW_PATH}.bak_*"

LATEST_VIEW_BACKUP=$(ls -t $VIEW_BACKUP 2>/dev/null | head -n1)
if [ -n "$LATEST_VIEW_BACKUP" ]; then
  mv "$LATEST_VIEW_BACKUP" "$VIEW_PATH"
  echo "✅ View template berhasil dikembalikan dari: $LATEST_VIEW_BACKUP"
fi

chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi berhasil dihapus!"
echo "🔓 Semua admin sekarang bisa mengakses Server View & List."
echo "📊 Tabel Node & Daemon info ditampilkan kembali."
