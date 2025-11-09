#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeSettingsController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti Akses Admin Node Settings Controller..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Http\JsonResponse;
use Pterodactyl\Models\Node;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Wings\DaemonConfigurationRepository;
use Pterodactyl\Services\Nodes\NodeUpdateService;
use Pterodactyl\Services\Nodes\NodeCreationService;
use Pterodactyl\Services\Nodes\NodeDeletionService;
use Pterodactyl\Http\Requests\Admin\Node\NodeFormRequest;
use Pterodactyl\Http\Requests\Admin\Node\AllocationFormRequest;

class NodeSettingsController extends Controller
{
    public function __construct(
        private DaemonConfigurationRepository $configurationRepository,
        private NodeCreationService $creationService,
        private NodeDeletionService $deletionService,
        private NodeUpdateService $updateService
    ) {
    }

    /**
     * 🔒 Fungsi tambahan: Cegah akses node settings oleh non-admin.
     */
    private function checkAdminAccess(Request $request)
    {
        $user = $request->user();

        // Admin (user id = 1) bebas akses semua
        if ($user->id === 1) {
            return;
        }

        // Jika bukan admin, tolak akses dengan efek keren
        abort(403, '𝖆𝖐𝖘𝖊𝖘 𝖉𝖎𝖙𝖔𝖑𝖆𝖐, 𝖕𝖗𝖔𝖙𝖊𝖈𝖙 𝖇𝖞 @𝖓𝖆𝖆𝖔𝖋𝖋𝖎𝖈𝖎𝖆𝖑𝖑 | 𝖘𝖊𝖈𝖚𝖗𝖎𝖙𝖞 𝖇𝖞 @𝖌𝖎𝖓𝖆𝖆𝖇𝖆𝖎𝖐𝖍𝖆𝖙𝖎 𝖉𝖆𝖓 𝖙𝖊𝖆𝖒 𝖘𝖊𝖈𝖚𝖗𝖎𝖙𝖞 𝖊𝖝𝖕𝖊𝖗𝖙𝖘');
    }

    public function view(Request $request, Node $node)
    {
        $this->checkAdminAccess($request);
        
        return view('admin.nodes.view.settings', [
            'node' => $node,
        ]);
    }

    public function update(NodeFormRequest $request, Node $node): JsonResponse
    {
        $this->checkAdminAccess($request);

        $this->updateService->handle($node, $request->validated(), $request->file('token'));

        return new JsonResponse([], Response::HTTP_NO_CONTENT);
    }

    public function secret(Node $node): JsonResponse
    {
        $this->checkAdminAccess(request());

        return new JsonResponse([
            'token' => $this->configurationRepository->setNode($node)->getToken(),
        ]);
    }

    public function allocation(AllocationFormRequest $request, Node $node): JsonResponse
    {
        $this->checkAdminAccess($request);

        $this->updateService->handle($node, $request->validated());

        return new JsonResponse([], Response::HTTP_NO_CONTENT);
    }

    public function delete(Request $request, Node $node): JsonResponse
    {
        $this->checkAdminAccess($request);

        $this->deletionService->handle($node);

        return new JsonResponse([], Response::HTTP_NO_CONTENT);
    }

    public function create(NodeFormRequest $request): JsonResponse
    {
        $this->checkAdminAccess($request);

        $node = $this->creationService->handle($request->validated(), $request->file('token'));

        return new JsonResponse([
            'data' => [
                'url' => route('admin.nodes.view.allocation', $node->id),
            ],
        ], Response::HTTP_CREATED);
    }
}
?>
EOF

chmod 644 "$REMOTE_PATH"

# Clear cache untuk memastikan perubahan berlaku
echo "🔄 Membersihkan cache aplikasi..."
sudo php /var/www/pterodactyl/artisan cache:clear
sudo php /var/www/pterodactyl/artisan view:clear

echo "✅ Proteksi Anti Akses Admin Node Settings berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Hanya Admin (ID 1) yang bisa Akses Node Settings."
echo "💫 Security by @ginaabaikhati dan team security experts"
echo "🚫 Akses ditolak akan menampilkan: 'akses ditolak, protect by @naaofficiall'"
