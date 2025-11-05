#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/ServersController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti Lihat Server List..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\ServerRepositoryInterface;

class ServersController extends Controller
{
    /**
     * ServersController constructor.
     */
    public function __construct(private ServerRepositoryInterface $repository)
    {
    }

    /**
     * Returns a listing of all servers on the system.
     */
    public function index(Request $request): View
    {
        $servers = $this->repository->setSearchTerm($request->input('query'))->getAllServersDetailed(100);

        // Hilangkan tautan dari setiap server
        $servers->transform(function ($server) {
            $server->name = '[HIDDEN]';
            $server->owner_name = '[HIDDEN]';
            $server->node_name = '[HIDDEN]';
            $server->uuidShort = '[HIDDEN]';
            $server->identifier = '[HIDDEN]';
            $server->description = '[HIDDEN]';
            $server->external_id = '[HIDDEN]';
            
            return $server;
        });

        return view('admin.servers.index', ['servers' => $servers]);
    }
}
?>
EOF

chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi Anti Lihat Server List berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Server List sekarang disembunyikan di halaman Admin!"
