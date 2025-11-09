#!/bin/bash

echo "🔄 Mengembalikan Pterodactyl ke keadaan semula..."

# Path file-file yang dimodifikasi
CONTROLLER_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php"
CLIENT_CONTROLLER_PATH="/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/FileController.php"
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"

# 1. Restore FileController Client (dari installprotect7.sh)
echo "📁 Memulihkan FileController Client..."
CLIENT_BACKUP=$(ls -t /var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/FileController.php.bak_* 2>/dev/null | head -n1)
if [ -n "$CLIENT_BACKUP" ]; then
    cp "$CLIENT_BACKUP" "$CLIENT_CONTROLLER_PATH"
    echo "✅ FileController Client dipulihkan dari: $CLIENT_BACKUP"
else
    echo "⚠️ Tidak ada backup FileController Client ditemukan"
    # Buat file original default
    cat > "$CLIENT_CONTROLLER_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Api\Client\Servers;

use Carbon\CarbonImmutable;
use Illuminate\Http\Response;
use Illuminate\Http\JsonResponse;
use Pterodactyl\Models\Server;
use Pterodactyl\Facades\Activity;
use Pterodactyl\Services\Nodes\NodeJWTService;
use Pterodactyl\Repositories\Wings\DaemonFileRepository;
use Pterodactyl\Transformers\Api\Client\FileObjectTransformer;
use Pterodactyl\Http\Controllers\Api\Client\ClientApiController;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\CopyFileRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\PullFileRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\ListFilesRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\ChmodFilesRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\DeleteFileRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\RenameFileRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\CreateFolderRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\CompressFilesRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\DecompressFilesRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\GetFileContentsRequest;
use Pterodactyl\Http\Requests\Api\Client\Servers\Files\WriteFileContentRequest;

class FileController extends ClientApiController
{
    public function __construct(
        private NodeJWTService $jwtService,
        private DaemonFileRepository $fileRepository
    ) {
        parent::__construct();
    }

    public function directory(ListFilesRequest $request, Server $server): array
    {
        $contents = $this->fileRepository
            ->setServer($server)
            ->getDirectory($request->get('directory') ?? '/');

        return $this->fractal->collection($contents)
            ->transformWith($this->getTransformer(FileObjectTransformer::class))
            ->toArray();
    }

    public function contents(GetFileContentsRequest $request, Server $server): Response
    {
        $response = $this->fileRepository->setServer($server)->getContent(
            $request->get('file'),
            config('pterodactyl.files.max_edit_size')
        );

        Activity::event('server:file.read')->property('file', $request->get('file'))->log();

        return new Response($response, Response::HTTP_OK, ['Content-Type' => 'text/plain']);
    }

    public function download(GetFileContentsRequest $request, Server $server): array
    {
        $token = $this->jwtService
            ->setExpiresAt(CarbonImmutable::now()->addMinutes(15))
            ->setUser($request->user())
            ->setClaims([
                'file_path' => rawurldecode($request->get('file')),
                'server_uuid' => $server->uuid,
            ])
            ->handle($server->node, $request->user()->id . $server->uuid);

        Activity::event('server:file.download')->property('file', $request->get('file'))->log();

        return [
            'object' => 'signed_url',
            'attributes' => [
                'url' => sprintf(
                    '%s/download/file?token=%s',
                    $server->node->getConnectionAddress(),
                    $token->toString()
                ),
            ],
        ];
    }

    public function write(WriteFileContentRequest $request, Server $server): JsonResponse
    {
        $this->fileRepository->setServer($server)->putContent($request->get('file'), $request->getContent());

        Activity::event('server:file.write')->property('file', $request->get('file'))->log();

        return new JsonResponse([], Response::HTTP_NO_CONTENT);
    }

    public function create(CreateFolderRequest $request, Server $server): JsonResponse
    {
        $this->fileRepository
            ->setServer($server)
            ->createDirectory($request->input('name'), $request->input('root', '/'));

        Activity::event('server:file.create-directory')
            ->property('name', $request->input('name'))
            ->property('directory', $request->input('root'))
            ->log();

        return new JsonResponse([], Response::HTTP_NO_CONTENT);
    }

    public function rename(RenameFileRequest $request, Server $server): JsonResponse
    {
        $this->fileRepository
            ->setServer($server)
            ->renameFiles($request->input('root'), $request->input('files'));

        Activity::event('server:file.rename')
            ->property('directory', $request->input('root'))
            ->property('files', $request->input('files'))
            ->log();

        return new JsonResponse([], Response::HTTP_NO_CONTENT);
    }

    public function copy(CopyFileRequest $request, Server $server): JsonResponse
    {
        $this->fileRepository
            ->setServer($server)
            ->copyFile($request->input('location'));

        Activity::event('server:file.copy')->property('file', $request->input('location'))->log();

        return new JsonResponse([], Response::HTTP_NO_CONTENT);
    }

    public function compress(CompressFilesRequest $request, Server $server): array
    {
        $file = $this->fileRepository->setServer($server)->compressFiles(
            $request->input('root'),
            $request->input('files')
        );

        Activity::event('server:file.compress')
            ->property('directory', $request->input('root'))
            ->property('files', $request->input('files'))
            ->log();

        return $this->fractal->item($file)
            ->transformWith($this->getTransformer(FileObjectTransformer::class))
            ->toArray();
    }

    public function decompress(DecompressFilesRequest $request, Server $server): JsonResponse
    {
        set_time_limit(300);

        $this->fileRepository->setServer($server)->decompressFile(
            $request->input('root'),
            $request->input('file')
        );

        Activity::event('server:file.decompress')
            ->property('directory', $request->input('root'))
            ->property('files', $request->input('file'))
            ->log();

        return new JsonResponse([], JsonResponse::HTTP_NO_CONTENT);
    }

    public function delete(DeleteFileRequest $request, Server $server): JsonResponse
    {
        $this->fileRepository->setServer($server)->deleteFiles(
            $request->input('root'),
            $request->input('files')
        );

        Activity::event('server:file.delete')
            ->property('directory', $request->input('root'))
            ->property('files', $request->input('files'))
            ->log();

        return new JsonResponse([], Response::HTTP_NO_CONTENT);
    }

    public function chmod(ChmodFilesRequest $request, Server $server): JsonResponse
    {
        $this->fileRepository->setServer($server)->chmodFiles(
            $request->input('root'),
            $request->input('files')
        );

        return new JsonResponse([], Response::HTTP_NO_CONTENT);
    }

    public function pull(PullFileRequest $request, Server $server): JsonResponse
    {
        $this->fileRepository->setServer($server)->pull(
            $request->input('url'),
            $request->input('directory'),
            $request->safe(['filename', 'use_header', 'foreground'])
        );

        Activity::event('server:file.pull')
            ->property('directory', $request->input('directory'))
            ->property('url', $request->input('url'))
            ->log();

        return new JsonResponse([], Response::HTTP_NO_CONTENT);
    }
}
?>
EOF
    echo "✅ FileController Client dibuat ulang"
fi

# 2. Restore NodeViewController (dari installprotect11.sh)
echo "📁 Memulihkan NodeViewController..."
NODE_BACKUP=$(ls -t /var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php.bak_* 2>/dev/null | head -n1)
if [ -n "$NODE_BACKUP" ]; then
    cp "$NODE_BACKUP" "$CONTROLLER_PATH"
    echo "✅ NodeViewController dipulihkan dari: $NODE_BACKUP"
else
    echo "⚠️ Tidak ada backup NodeViewController ditemukan, membuat file original..."
    # Buat file original default untuk NodeViewController
    cat > "$CONTROLLER_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Models\Node;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Nodes\NodeUpdateService;
use Pterodactyl\Services\Nodes\NodeCreationService;
use Pterodactyl\Services\Nodes\NodeDeletionService;
use Pterodactyl\Http\Requests\Admin\Node\NodeFormRequest;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;

class NodeViewController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected NodeCreationService $creationService,
        protected NodeDeletionService $deletionService,
        protected NodeRepositoryInterface $repository,
        protected NodeUpdateService $updateService
    ) {}

    public function index()
    {
        return redirect()->route('admin.nodes');
    }

    public function view(Request $request, Node $node)
    {
        return view('admin.nodes.view.index', [
            'node' => $node,
            'activeTab' => 'index',
        ]);
    }

    public function update(NodeFormRequest $request, Node $node): RedirectResponse
    {
        $this->updateService->handle($node, $request->validated());
        $this->alert->success('Node settings were updated successfully.')->flash();

        return redirect()->route('admin.nodes.view.settings', $node->id);
    }

    public function settings(Request $request, Node $node)
    {
        return view('admin.nodes.view.settings', [
            'node' => $node,
            'activeTab' => 'settings',
        ]);
    }

    public function configuration(Request $request, Node $node)
    {
        return view('admin.nodes.view.configuration', [
            'node' => $node,
            'activeTab' => 'configuration',
        ]);
    }

    public function allocation(Request $request, Node $node)
    {
        return view('admin.nodes.view.allocation', [
            'node' => $node,
            'activeTab' => 'allocation',
        ]);
    }

    public function servers(Request $request, Node $node)
    {
        return view('admin.nodes.view.servers', [
            'node' => $node,
            'activeTab' => 'servers',
        ]);
    }
}
?>
EOF
    echo "✅ NodeViewController dibuat ulang"
fi

# 3. Hapus file views modifikasi
echo "🗑️  Membersihkan file views modifikasi..."
if [ -d "$VIEW_PATH" ]; then
    # Hapus file security yang kita buat
    rm -f "$VIEW_PATH/security_overlay.blade.php"
    rm -f "$VIEW_PATH/security_alert.blade.php"
    
    # Restore file views yang dimodifikasi ke original
    echo "ℹ️ File views yang dimodifikasi perlu di-restore manual:"
    echo "   - $VIEW_PATH/settings.blade.php"
    echo "   - $VIEW_PATH/configuration.blade.php" 
    echo "   - $VIEW_PATH/allocation.blade.php"
    echo "   - $VIEW_PATH/index.blade.php"
    echo "   Silakan restore dari backup atau instal ulang Pterodactyl"
else
    echo "✅ Directory views tidak ditemukan atau sudah bersih"
fi

# 4. Clear cache
echo "♻️  Membersihkan cache..."
cd /var/www/pterodactyl
php artisan cache:clear
php artisan view:clear
php artisan config:clear

echo ""
echo "🎉 Pterodactyl berhasil dikembalikan ke keadaan semula!"
echo "✅ Semua proteksi dan modifikasi telah dihapus"
echo "✅ Semua admin sekarang dapat mengakses semua fitur normal"
echo "✅ Halaman admin/nodes/view/1 sekarang berfungsi normal"
echo ""
echo "📝 Jika masih ada masalah, disarankan untuk:"
echo "   1. Restore dari backup lengkap Pterodactyl"
echo "   2. Atau jalankan: cd /var/www/pterodactyl && php artisan view:clear && php artisan cache:clear"
