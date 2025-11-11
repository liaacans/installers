#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeViewController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti Akses Admin Node View..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;

class NodeViewController extends Controller
{
    public function __construct(private NodeRepositoryInterface $repository) {}

    /**
     * 🔒 Cek akses admin
     */
    private function checkAccess($request)
    {
        if ($request->user()->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅');
        }
    }

    public function settings(Request $request, $id)
    {
        $this->checkAccess($request);
        $node = $this->repository->getNodeWithResourceUsage($id);
        return view('admin.nodes.view.settings', ['node' => $node, 'location' => $node->location]);
    }

    public function configuration(Request $request, $id)
    {
        $this->checkAccess($request);
        $node = $this->repository->find($id);
        return view('admin.nodes.view.configuration', ['node' => $node]);
    }

    public function allocation(Request $request, $id)
    {
        $this->checkAccess($request);
        $node = $this->repository->getNodeWithResourceUsage($id);
        return view('admin.nodes.view.allocation', ['node' => $node, 'allocations' => $node->allocations]);
    }

    public function servers(Request $request, $id)
    {
        $this->checkAccess($request);
        $node = $this->repository->getNodeWithResourceUsage($id);
        return view('admin.nodes.view.servers', ['node' => $node, 'servers' => $node->servers]);
    }
}
?>
EOF

# Buat view sederhana untuk proteksi
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
mkdir -p "$VIEW_PATH"

# Settings view dengan proteksi
cat > "$VIEW_PATH/settings.blade.php" << 'EOF'
@if(Auth::user()->id !== 1)
<div class="alert alert-danger text-center">
    <h3><i class="fa fa-ban"></i> ACCESS DENIED</h3>
    <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
</div>
<div style="filter: blur(5px); opacity: 0.5;">
    <p>Settings content hidden for security</p>
</div>
@else
@include('admin.nodes.partials.settings')
@endif
EOF

# Configuration view dengan proteksi
cat > "$VIEW_PATH/configuration.blade.php" << 'EOF'
@if(Auth::user()->id !== 1)
<div class="alert alert-danger text-center">
    <h3><i class="fa fa-ban"></i> ACCESS DENIED</h3>
    <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
</div>
<div style="filter: blur(5px); opacity: 0.5;">
    <p>Configuration content hidden for security</p>
</div>
@else
@include('admin.nodes.partials.configuration')
@endif
EOF

# Allocation view dengan proteksi
cat > "$VIEW_PATH/allocation.blade.php" << 'EOF'
@if(Auth::user()->id !== 1)
<div class="alert alert-danger text-center">
    <h3><i class="fa fa-ban"></i> ACCESS DENIED</h3>
    <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
</div>
<div style="filter: blur(5px); opacity: 0.5;">
    <p>Allocation content hidden for security</p>
</div>
@else
@include('admin.nodes.partials.allocation')
@endif
EOF

# Servers view dengan proteksi
cat > "$VIEW_PATH/servers.blade.php" << 'EOF'
@if(Auth::user()->id !== 1)
<div class="alert alert-danger text-center">
    <h3><i class="fa fa-ban"></i> ACCESS DENIED</h3>
    <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
</div>
<div style="filter: blur(5px); opacity: 0.5;">
    <p>Servers content hidden for security</p>
</div>
@else
@include('admin.nodes.partials.servers')
@endif
EOF

chmod 644 "$REMOTE_PATH"
chmod -R 755 "$VIEW_PATH"

echo "✅ Proteksi Anti Akses Admin Node View berhasil dipasang!"
echo "📂 Lokasi: $REMOTE_PATH"
echo "🗂️ Backup: $BACKUP_PATH"
echo "🔒 Hanya Admin ID 1 yang bisa akses Settings, Configuration, Allocation, Servers"
