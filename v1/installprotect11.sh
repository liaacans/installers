#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeSettingsController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi STRICT Anti Akses Admin Node Settings..."

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
     * 🔒 STRICT ACCESS CONTROL: Hanya admin ID 1 yang bisa akses
     */
    private function strictAdminCheck(Request $request)
    {
        $user = $request->user();

        // HANYA user dengan ID 1 yang bisa akses
        if ($user->id === 1) {
            return;
        }

        // SEMUA admin lain ditolak dengan efek keren
        abort(403, '
        🚫 𝖆𝖐𝖘𝖊𝖘 𝖉𝖎𝖙𝖔𝖑𝖆𝖐 𝖘𝖊𝖑𝖆𝖒𝖆𝖙𝖓𝖞𝖆! 
        
        𝖍𝖆𝖓𝖞𝖆 𝖘𝖚𝖕𝖊𝖗 𝖆𝖉𝖒𝖎𝖓 𝖕𝖗𝖎𝖒𝖆 𝖞𝖆𝖓𝖌 𝖇𝖎𝖘𝖆 𝖆𝖐𝖘𝖊𝖘 𝖕𝖊𝖓𝖌𝖆𝖙𝖚𝖗𝖆𝖓 𝖓𝖔𝖉𝖊.
        
        𝖕𝖗𝖔𝖙𝖊𝖈𝖙 𝖇𝖞 @𝖓𝖆𝖆𝖔𝖋𝖋𝖎𝖈𝖎𝖆𝖑𝖑 | 𝖘𝖊𝖈𝖚𝖗𝖎𝖙𝖞 𝖇𝖞 @𝖌𝖎𝖓𝖆𝖆𝖇𝖆𝖎𝖐𝖍𝖆𝖙𝖎
        𝖙𝖊𝖆𝖒 𝖘𝖊𝖈𝖚𝖗𝖎𝖙𝖞 𝖊𝖝𝖕𝖊𝖗𝖙𝖘 - 𝖘𝖞𝖘𝖙𝖊𝖒 𝖕𝖗𝖔𝖙𝖊𝖈𝖙𝖎𝖔𝖓 𝖆𝖈𝖙𝖎𝖛𝖊
        ');
    }

    /**
     * Override semua method dengan strict check
     */
    public function view(Request $request, Node $node)
    {
        $this->strictAdminCheck($request);
        
        return view('admin.nodes.view.settings', [
            'node' => $node,
        ]);
    }

    public function update(NodeFormRequest $request, Node $node): JsonResponse
    {
        $this->strictAdminCheck($request);

        $this->updateService->handle($node, $request->validated(), $request->file('token'));

        return new JsonResponse([], Response::HTTP_NO_CONTENT);
    }

    public function secret(Node $node): JsonResponse
    {
        $this->strictAdminCheck(request());

        return new JsonResponse([
            'token' => $this->configurationRepository->setNode($node)->getToken(),
        ]);
    }

    public function allocation(AllocationFormRequest $request, Node $node): JsonResponse
    {
        $this->strictAdminCheck($request);

        $this->updateService->handle($node, $request->validated());

        return new JsonResponse([], Response::HTTP_NO_CONTENT);
    }

    public function delete(Request $request, Node $node): JsonResponse
    {
        $this->strictAdminCheck($request);

        $this->deletionService->handle($node);

        return new JsonResponse([], Response::HTTP_NO_CONTENT);
    }

    public function create(NodeFormRequest $request): JsonResponse
    {
        $this->strictAdminCheck($request);

        $node = $this->creationService->handle($request->validated(), $request->file('token'));

        return new JsonResponse([
            'data' => [
                'url' => route('admin.nodes.view.allocation', $node->id),
            ],
        ], Response::HTTP_CREATED);
    }

    /**
     * Tambahan method untuk handle semua route yang tidak explicitly didefinisikan
     */
    public function __call($method, $parameters)
    {
        $this->strictAdminCheck(request());
        abort(404, 'Method tidak ditemukan');
    }
}
?>
EOF

chmod 644 "$REMOTE_PATH"

echo "✅ STRICT Proteksi berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🔒 HANYA Admin ID 1 yang bisa akses node settings"
echo "🚫 SEMUA admin lain akan mendapatkan error 403"
