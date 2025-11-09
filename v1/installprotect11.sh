#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti Akses Node Controller..."

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
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\Node\NodeFormRequest;
use Pterodactyl\Models\Node;

class NodeController extends Controller
{
    public function __construct(
        protected AlertsMessageBag $alert,
        protected NodeRepositoryInterface $repository
    ) {
    }

    /**
     * 🔒 Fungsi tambahan: Cek akses admin untuk node.
     */
    private function checkAdminAccess()
    {
        $user = auth()->user();

        // Hanya admin ID 1 yang bisa akses penuh
        if ($user->id === 1) {
            return true;
        }

        // Admin lain ditolak dengan efek security
        abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅');
    }

    /**
     * Display node index page.
     */
    public function index(): View
    {
        $this->checkAdminAccess();
        
        return view('admin.nodes.index', [
            'nodes' => $this->repository->getAllWithDetails(),
        ]);
    }

    /**
     * Display node create page.
     */
    public function create(): View
    {
        $this->checkAdminAccess();
        
        return view('admin.nodes.view');
    }

    /**
     * Display node view page.
     */
    public function view(int $id, string $section = 'settings'): View
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->find($id);
        
        // Blur atau sembunyikan data sensitif untuk admin selain ID 1
        $user = auth()->user();
        if ($user->id !== 1) {
            // Data yang dibatasi untuk admin lain
            $limitedData = [
                'node' => $node,
                'isLimited' => true,
                'section' => $section,
            ];
            
            return view('admin.nodes.view-limited', $limitedData);
        }

        return view('admin.nodes.view', [
            'node' => $node,
            'section' => $section,
            'isLimited' => false,
        ]);
    }

    /**
     * Handle node creation.
     */
    public function store(NodeFormRequest $request): RedirectResponse
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->create($request->validated());

        $this->alert->success('Node was successfully created.')->flash();

        return redirect()->route('admin.nodes.view', $node->id);
    }

    /**
     * Handle node update.
     */
    public function update(NodeFormRequest $request, int $id): RedirectResponse
    {
        $this->checkAdminAccess();
        
        $this->repository->update($id, $request->validated());

        $this->alert->success('Node was successfully updated.')->flash();

        return redirect()->route('admin.nodes.view', $id)->withInput();
    }

    /**
     * Handle node deletion.
     */
    public function delete(int $id): RedirectResponse
    {
        $this->checkAdminAccess();
        
        $this->repository->delete($id);

        $this->alert->success('Node was successfully deleted.')->flash();

        return redirect()->route('admin.nodes');
    }

    /**
     * Get allocations for a specific node.
     */
    public function allocations(int $id): View
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->find($id);

        return view('admin.nodes.allocation', [
            'node' => $node,
            'allocations' => $node->allocations,
        ]);
    }

    /**
     * Get servers for a specific node.
     */
    public function servers(int $id): View
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->find($id);

        return view('admin.nodes.servers', [
            'node' => $node,
            'servers' => $node->servers,
        ]);
    }

    /**
     * Get configuration for a specific node.
     */
    public function configuration(int $id): View
    {
        $this->checkAdminAccess();
        
        $node = $this->repository->find($id);

        return view('admin.nodes.configuration', [
            'node' => $node,
        ]);
    }
}
?>
EOF

# Membuat view limited untuk admin terbatas
LIMITED_VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view-limited.blade.php"
mkdir -p "$(dirname "$LIMITED_VIEW_PATH")"

cat > "$LIMITED_VIEW_PATH" << 'EOF'
@extends('layouts.admin')

@section('title')
    Node Security Protected
@endsection

@section('content-header')
    <h1>Node Security Protected<small>Restricted Access</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li class="active">Security Protected</li>
    </ol>
@endsection

@section('content')
<div class="row">
    <div class="col-xs-12">
        <div class="box box-danger">
            <div class="box-header with-border">
                <h3 class="box-title">🚫 Access Restricted</h3>
            </div>
            <div class="box-body">
                <div class="alert alert-danger security-alert" style="background: linear-gradient(45deg, #ff0000, #000000); color: white; padding: 20px; border-radius: 10px; text-align: center;">
                    <i class="fa fa-shield fa-4x"></i>
                    <h2 style="margin: 20px 0;">🔒 SECURITY PROTECTION ACTIVATED</h2>
                    <p style="font-size: 16px; margin-bottom: 20px;">
                        <strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong>
                    </p>
                    <div style="background: rgba(255,255,255,0.1); padding: 15px; border-radius: 5px; margin: 15px 0;">
                        <p>You do not have permission to access this node configuration.</p>
                        <p>Only Super Administrator can modify node settings.</p>
                    </div>
                    <div class="security-animation" style="font-size: 24px; margin: 20px 0;">
                        🛡️ ⚡ 🚫 🔐 🛡️
                    </div>
                </div>
                
                <!-- Navigation Tabs (Disabled) -->
                <div class="nav-tabs-custom nav-tabs-disabled">
                    <ul class="nav nav-tabs">
                        <li class="{{ $section === 'settings' ? 'active' : '' }} disabled">
                            <a href="javascript:void(0);" style="cursor: not-allowed; opacity: 0.5;">
                                <i class="fa fa-cogs"></i> Settings
                            </a>
                        </li>
                        <li class="{{ $section === 'configuration' ? 'active' : '' }} disabled">
                            <a href="javascript:void(0);" style="cursor: not-allowed; opacity: 0.5;">
                                <i class="fa fa-wrench"></i> Configuration
                            </a>
                        </li>
                        <li class="{{ $section === 'allocation' ? 'active' : '' }} disabled">
                            <a href="javascript:void(0);" style="cursor: not-allowed; opacity: 0.5;">
                                <i class="fa fa-sitemap"></i> Allocation
                            </a>
                        </li>
                        <li class="{{ $section === 'servers' ? 'active' : '' }} disabled">
                            <a href="javascript:void(0);" style="cursor: not-allowed; opacity: 0.5;">
                                <i class="fa fa-server"></i> Servers
                            </a>
                        </li>
                    </ul>
                    
                    <div class="tab-content" style="opacity: 0.3; filter: blur(2px); pointer-events: none;">
                        <div class="tab-pane active">
                            <!-- Content blurred for security -->
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="box">
                                        <div class="box-header with-border">
                                            <h3 class="box-title">Node Information</h3>
                                        </div>
                                        <div class="box-body">
                                            <p>Access restricted for security reasons.</p>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="box">
                                        <div class="box-header with-border">
                                            <h3 class="box-title">System Information</h3>
                                        </div>
                                        <div class="box-body">
                                            <p>Access restricted for security reasons.</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.security-alert {
    animation: pulse 2s infinite;
    border: 2px solid #ff0000;
    box-shadow: 0 0 20px rgba(255,0,0,0.5);
}

.security-animation {
    animation: bounce 1s infinite;
}

.nav-tabs-disabled .nav-tabs-custom > .nav-tabs > li.disabled > a {
    color: #999 !important;
    background-color: #f4f4f4 !important;
}

@keyframes pulse {
    0% { box-shadow: 0 0 10px rgba(255,0,0,0.5); }
    50% { box-shadow: 0 0 20px rgba(255,0,0,0.8); }
    100% { box-shadow: 0 0 10px rgba(255,0,0,0.5); }
}

@keyframes bounce {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-5px); }
}
</style>
@endsection
EOF

chmod 644 "$REMOTE_PATH"
chmod 644 "$LIMITED_VIEW_PATH"

# Clear view cache
php /var/www/pterodactyl/artisan view:clear
php /var/www/pterodactyl/artisan cache:clear

echo "✅ Proteksi Anti Akses Node Controller berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🎨 View terbatas: $LIMITED_VIEW_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Hanya Admin (ID 1) yang bisa Akses Node Settings, Configuration, Allocation, dan Servers."
echo "🚫 Admin lain akan melihat halaman security protection dengan efek khusus!"
