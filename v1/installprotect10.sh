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
     * Display the server index page.
     *
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\View\View
     */
    public function index(Request $request)
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

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
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.servers.view.index', [
            'server' => $server,
            'actions' => false, // Hide action buttons for non-admin-1 users
        ]);
    }
}
?>
EOF

# Juga proteksi file view template untuk menyembunyikan node info
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
VIEW_BACKUP="${VIEW_PATH}.bak_${TIMESTAMP}"

if [ -f "$VIEW_PATH" ]; then
  cp "$VIEW_PATH" "$VIEW_BACKUP"
  echo "📦 Backup view template dibuat di $VIEW_BACKUP"
  
  # Modifikasi template untuk menyembunyikan node info dan menggunakan style bootstrap
  sed -i '/<td class="text-center">{{ $server->node }}</td>/d' "$VIEW_PATH"
  sed -i '/<th class="text-center">Node<\/th>/d' "$VIEW_PATH"
  sed -i 's/<table class="table table-borderless table-hover">/<table class="table table-borderless table-hover table-striped">/g' "$VIEW_PATH"
  sed -i 's/<div class="row">/<div class="row" style="margin: 20px 0;">/g' "$VIEW_PATH"
  
  # Tambahkan alert info untuk admin ID 1
  sed -i '/<div class="row"/i @if(\\Auth::user()->id === 1)\n<div class="alert alert-info">\n    <i class="fa fa-info-circle"></i> Protected View - Only visible to Super Admin\n</div>\n@endif' "$VIEW_PATH"
fi

chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi Admin Server View berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "📂 View template dimodifikasi: $VIEW_PATH"
echo "🗂️ Backup file: $BACKUP_PATH"
echo "🔒 Hanya Admin (ID 1) yang bisa akses Server View & List."
echo "📊 Tabel Node & Daemon info disembunyikan dari Server List."
