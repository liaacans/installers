#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerTableController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Hide Node dari Server List..."

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
use Illuminate\Support\Facades\Auth;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\ServerRepositoryInterface;

class ServerTableController extends Controller
{
    /**
     * ServerTableController constructor.
     */
    public function __construct(private ServerRepositoryInterface $repository) {}

    /**
     * Returns a listing of servers that can be passed to the front-end.
     *
     * @param \Illuminate\Http\Request $request
     * @return array
     */
    public function __invoke(Request $request)
    {
        $user = Auth::user();
        $servers = $this->repository->setSearchTerm($request->input('search'))->getDataTables();

        // Jika bukan user ID 1, sembunyikan informasi node
        if (!$user || $user->id !== 1) {
            $servers = $servers->map(function ($server) {
                $server['node'] = 'Hidden';
                $server['connection'] = 'Hidden';
                return $server;
            });
        }

        return $servers->toArray();
    }
}
?>
EOF

chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi Hide Node dari Server List berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo "🔒 Kolom Node dan Connection disembunyikan dari daftar server"
