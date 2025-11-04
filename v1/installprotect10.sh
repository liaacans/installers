#!/bin/bash

# File paths
MAIN_SERVICE_PATH="/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php"
VIEW_PATH="/var/www/pterodactyl/resources/scripts/components/server/ServerConsoleContainer.tsx"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

# Backup paths
MAIN_BACKUP_PATH="${MAIN_SERVICE_PATH}.bak_${TIMESTAMP}"
VIEW_BACKUP_PATH="${VIEW_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti Modifikasi Server v10..."

# Backup and replace main service file
if [ -f "$MAIN_SERVICE_PATH" ]; then
  cp "$MAIN_SERVICE_PATH" "$MAIN_BACKUP_PATH"
  echo "📦 Backup file utama dibuat di $MAIN_BACKUP_PATH"
fi

mkdir -p "$(dirname "$MAIN_SERVICE_PATH")"
chmod 755 "$(dirname "$MAIN_SERVICE_PATH")"

cat > "$MAIN_SERVICE_PATH" << 'EOF'
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
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
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

chmod 644 "$MAIN_SERVICE_PATH"

# Backup and modify view file
if [ -f "$VIEW_PATH" ]; then
  cp "$VIEW_PATH" "$VIEW_BACKUP_PATH"
  echo "📦 Backup file view dibuat di $VIEW_BACKUP_PATH"
  
  # Cari dan modifikasi bagian yang menampilkan server list
  sed -i '/<Table\.Head>/,/<\/Table\.Head>/c\
          <Table.Head>\
            <Table.THeadCell>Name</Table.THeadCell>\
            <Table.THeadCell>Status</Table.THeadCell>\
            <Table.THeadCell align={"center"}>Actions</Table.THeadCell>\
          </Table.Head>' "$VIEW_PATH"
  
  # Hapus kolom Owner, Node, dan Connection dari body table
  sed -i '/{server.owner}/d' "$VIEW_PATH"
  sed -i '/{server.node}/d' "$VIEW_PATH"
  sed -i '/{server.connection}/d' "$VIEW_PATH"
  
  # Modifikasi body table untuk hanya menampilkan name, status, dan actions
  sed -i '/<Table.TBody>/,/<\/Table.TBody>/c\
        <Table.TBody>\
          {servers.items.map((server: Server) => (\
            <Table.TRow key={server.uuid}>\
              <Table.TD>\
                <Link to={`/server/${server.uuid}`}>\
                  {server.name}\
                </Link>\
              </Table.TD>\
              <Table.TD>\
                <ServerStatusBadge server={server} />\
              </Table.TD>\
              <Table.TD align={"center"}>\
                <Can action={[\\x27\\x27view\\x27\\x27]} on={server}>\
                  <Link to={`/server/${server.uuid}`}>\
                    <Button variant={ButtonVariants.Secondary}>Manage</Button>\
                  </Link>\
                </Can>\
              </Table.TD>\
            </Table.TRow>\
          ))}\
        </Table.TBody>' "$VIEW_PATH"
  
  # Tambahkan proteksi akses untuk non-admin
  sed -i '1i\
import { useStoreState } from "@/state/hooks";' "$VIEW_PATH"
  
  sed -i '/const servers = useServerSWR/a\
  const user = useStoreState(state => state.user.data);\
  if (!user || user.id !== 1) {\
    return (\
      <div className="flex justify-center items-center h-64">\
        <div className="text-center">\
          <p className="text-red-500 text-lg font-semibold">🚫 Akses Ditolak</p>\
          <p className="text-gray-600">Hanya Admin yang dapat mengakses server list</p>\
        </div>\
      </div>\
    );\
  }' "$VIEW_PATH"
fi

echo "✅ Proteksi Anti Modifikasi Server v10 berhasil dipasang!"
echo "📂 Lokasi file utama: $MAIN_SERVICE_PATH"
echo "📂 Lokasi file view: $VIEW_PATH"
echo "🗂️ Backup file utama: $MAIN_BACKUP_PATH"
echo "🗂️ Backup file view: $VIEW_BACKUP_PATH"
echo "🔒 Hanya Admin (ID 1) yang bisa Modifikasi Server dan melihat Server List."
echo "📋 Tabel Server List disederhanakan (hanya Name, Status, Actions)"
