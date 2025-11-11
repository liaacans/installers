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
use Illuminate\Http\Response;
use Illuminate\Http\JsonResponse;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\NodeRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\Node\NodeFormRequest;

class NodeViewController extends Controller
{
    public function __construct(
        private NodeRepositoryInterface $repository
    ) {}

    /**
     * 🔒 Fungsi tambahan: Cegah akses node view oleh admin lain.
     */
    private function checkAdminAccess($request)
    {
        $user = $request->user();

        // Hanya admin dengan ID 1 yang bisa akses
        if ($user->id !== 1) {
            // Effect security: Log aktivitas mencurigakan
            \Log::warning('Akses ditolak ke Node View oleh admin ID: ' . $user->id . ' - Name: ' . $user->name);
            
            // Tampilkan halaman error dengan efek security
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅 | 𝖴𝗇𝖺𝗎𝗍𝗁𝗈𝗋𝗂𝗓𝖾𝖽 𝖠𝖼𝖼𝖾𝗌𝗌 𝖣𝖾𝗍𝖾𝖼𝗍𝖾𝖽');
        }
    }

    /**
     * 🔒 View untuk halaman settings node - hanya admin ID 1
     */
    public function settings(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        // Untuk admin ID 1, akses normal ke semua data
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.settings', [
            'node' => $node,
            'location' => $node->location,
        ]);
    }

    /**
     * 🔒 View untuk halaman configuration node - hanya admin ID 1
     */
    public function configuration(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->find($id);
        
        return view('admin.nodes.view.configuration', [
            'node' => $node,
        ]);
    }

    /**
     * 🔒 View untuk halaman allocation node - hanya admin ID 1
     */
    public function allocation(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.allocation', [
            'node' => $node,
            'allocations' => $node->allocations,
        ]);
    }

    /**
     * 🔒 View untuk halaman servers node - hanya admin ID 1
     */
    public function servers(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.servers', [
            'node' => $node,
            'servers' => $node->servers,
        ]);
    }

    /**
     * 🔒 Update settings node - hanya admin ID 1
     */
    public function updateSettings(NodeFormRequest $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->update($id, $request->validated());
        
        return response()->json($node);
    }

    /**
     * 🔒 Update configuration node - hanya admin ID 1
     */
    public function updateConfiguration(NodeFormRequest $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->update($id, $request->validated());
        
        return response()->json($node);
    }

    /**
     * 🔒 About page - hanya admin ID 1
     */
    public function index(Request $request, $id)
    {
        $this->checkAdminAccess($request);
        
        $node = $this->repository->getNodeWithResourceUsage($id);
        
        return view('admin.nodes.view.index', [
            'node' => $node,
            'location' => $node->location,
        ]);
    }
}
?>
EOF

# Buat view templates untuk proteksi
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/nodes/view"
mkdir -p "$VIEW_PATH"

# Proteksi untuk settings view
cat > "$VIEW_PATH/settings.blade.php" << 'EOF'
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
    <!-- 🔒 SECURITY PROTECTION ACTIVATED -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box box-danger">
                <div class="box-header with-border">
                    <h3 class="box-title">
                        <i class="fa fa-shield"></i> Security Protection Active
                    </h3>
                </div>
                <div class="box-body">
                    <div class="alert alert-danger security-alert" style="background: linear-gradient(45deg, #ff0000, #8b0000); color: white; border: none;">
                        <div class="security-header">
                            <i class="fa fa-ban"></i>
                            <strong>ACCESS DENIED - PROTECTED AREA</strong>
                        </div>
                        <hr style="border-color: rgba(255,255,255,0.3)">
                        <p>⚠️ <strong>Unauthorized Access Detected</strong></p>
                        <p>This administrative section is restricted to System Owner only.</p>
                        <div class="security-details">
                            <small>Attempted by: {{ $user->name }} (ID: {{ $user->id }})</small><br>
                            <small>Timestamp: {{ now()->format('Y-m-d H:i:s') }}</small><br>
                            <small>Protection: @naaofficiall Security System</small>
                        </div>
                    </div>
                    
                    <!-- Blurred Content Preview -->
                    <div style="filter: blur(8px); pointer-events: none; opacity: 0.6;">
                        <div class="row">
                            <div class="col-sm-6">
                                <div class="box">
                                    <div class="box-header with-border">
                                        <h3 class="box-title">Settings Information</h3>
                                    </div>
                                    <div class="box-body">
                                        <p>Node configuration and settings would be displayed here.</p>
                                        <div class="form-group">
                                            <label>Node Name</label>
                                            <input type="text" class="form-control" value="Protected Content" readonly>
                                        </div>
                                        <div class="form-group">
                                            <label>Description</label>
                                            <textarea class="form-control" readonly>This content is protected by security system</textarea>
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
@else
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 - TAMPILAN NORMAL -->
    <div class="row">
        <div class="col-sm-6">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Settings Information</h3>
                </div>
                <div class="box-body">
                    <div class="form-group">
                        <label for="pName" class="form-label">Name</label>
                        <input type="text" name="name" id="pName" class="form-control" value="{{ old('name', $node->name) }}" />
                        <p class="text-muted small">A short identifier used to distinguish this node from others. Must be between 1 and 100 characters, for example <code>us.nyc.lvl3</code>.</p>
                    </div>
                    <div class="form-group">
                        <label for="pDescription" class="form-label">Description</label>
                        <textarea name="description" id="pDescription" rows="4" class="form-control">{{ old('description', $node->description) }}</textarea>
                        <p class="text-muted small">A longer description of this node. Maximum 255 characters.</p>
                    </div>
                    <div class="form-group">
                        <label for="pLocation" class="form-label">Location</label>
                        <select name="location_id" id="pLocation" class="form-control">
                            @foreach($locations as $location)
                                <option value="{{ $location->id }}" {{ $node->location_id === $location->id ? 'selected' : '' }}>{{ $location->short }}</option>
                            @endforeach
                        </select>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Configuration</h3>
                </div>
                <div class="box-body">
                    <div class="form-group">
                        <label for="pFQDN" class="form-label">FQDN</label>
                        <input type="text" name="fqdn" id="pFQDN" class="form-control" value="{{ old('fqdn', $node->fqdn) }}" />
                        <p class="text-muted small">Please enter the domain name (e.g <code>node.example.com</code>) that should be used to connect to the daemon. An IP address may only be used if you are not using SSL for this node.</p>
                    </div>
                    <div class="form-group">
                        <label for="pScheme" class="form-label">Communication Scheme</label>
                        <select name="scheme" id="pScheme" class="form-control">
                            <option value="https" {{ $node->scheme === 'https' ? 'selected' : '' }}>HTTPS</option>
                            <option value="http" {{ $node->scheme === 'http' ? 'selected' : '' }}>HTTP</option>
                        </select>
                        <p class="text-muted small">For most cases you should select HTTPS. Using HTTP assumes you have a SSL terminator in front of this web server.</p>
                    </div>
                    <div class="form-group">
                        <label for="pBehindProxy" class="form-label">Behind Proxy</label>
                        <div>
                            <input type="radio" id="pBehindProxy1" name="behind_proxy" value="1" {{ $node->behind_proxy ? 'checked' : '' }}>
                            <label for="pBehindProxy1" class="form-label">Yes</label>
                            <input type="radio" id="pBehindProxy0" name="behind_proxy" value="0" {{ !$node->behind_proxy ? 'checked' : '' }}>
                            <label for="pBehindProxy0" class="form-label">No</label>
                        </div>
                        <p class="text-muted small">If you are running the daemon behind a proxy such as Cloudflare, select this to have the daemon skip looking for SSL on every request.</p>
                    </div>
                    <div class="form-group">
                        <label for="pPublic" class="form-label">Public Node</label>
                        <div>
                            <input type="radio" id="pPublic1" name="public" value="1" {{ $node->public ? 'checked' : '' }}>
                            <label for="pPublic1" class="form-label">Yes</label>
                            <input type="radio" id="pPublic0" name="public" value="0" {{ !$node->public ? 'checked' : '' }}>
                            <label for="pPublic0" class="form-label">No</label>
                        </div>
                        <p class="text-muted small">Should servers on this node be shown on the front page of the panel?</p>
                    </div>
                </div>
                <div class="box-footer">
                    {!! csrf_field() !!}
                    <button type="submit" class="btn btn-primary pull-right">Save Changes</button>
                </div>
            </div>
        </div>
    </div>
@endif

<style>
.security-alert {
    border-left: 5px solid #dc3545;
    animation: pulse 2s infinite;
}
.security-header {
    font-size: 1.2em;
    margin-bottom: 10px;
}
.security-details {
    margin-top: 15px;
    opacity: 0.9;
}
@keyframes pulse {
    0% { box-shadow: 0 0 0 0 rgba(220, 53, 69, 0.7); }
    70% { box-shadow: 0 0 0 10px rgba(220, 53, 69, 0); }
    100% { box-shadow: 0 0 0 0 rgba(220, 53, 69, 0); }
}
</style>
EOF

# Proteksi untuk configuration view
cat > "$VIEW_PATH/configuration.blade.php" << 'EOF'
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
    <!-- 🔒 SECURITY PROTECTION ACTIVATED -->
    <div class="alert alert-danger security-alert" style="background: linear-gradient(135deg, #8b0000, #000000); color: white; border: none; text-align: center;">
        <h3><i class="fa fa-shield-alt"></i> PROTECTED CONFIGURATION AREA</h3>
        <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
        <small>Access restricted to System Owner only</small>
    </div>
    
    <!-- Blurred Configuration Content -->
    <div style="filter: blur(12px); opacity: 0.5; pointer-events: none;">
        <div class="box">
            <div class="box-body">
                <p>Configuration details are hidden for security reasons.</p>
            </div>
        </div>
    </div>
@else
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 - TAMPILAN NORMAL -->
    <div class="row">
        <div class="col-sm-6">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Configuration Settings</h3>
                </div>
                <div class="box-body">
                    <!-- Original Pterodactyl configuration form content -->
                    <div class="form-group">
                        <label for="pDaemonBase" class="form-label">Daemon Base Directory</label>
                        <input type="text" name="daemonBase" id="pDaemonBase" class="form-control" value="{{ old('daemonBase', $node->daemonBase) }}" />
                        <p class="text-muted small">This should be the base directory where the daemon is running. Defaults to <code>/var/lib/pterodactyl/volumes</code>.</p>
                    </div>
                    <div class="form-group">
                        <label for="pMemory" class="form-label">Total Memory</label>
                        <div class="input-group">
                            <input type="text" name="memory" id="pMemory" class="form-control" value="{{ old('memory', $node->memory) }}" />
                            <span class="input-group-addon">MB</span>
                        </div>
                        <p class="text-muted small">The total amount of memory available for this node to allocate to servers.</p>
                    </div>
                    <div class="form-group">
                        <label for="pMemoryOverallocate" class="form-label">Memory Overallocation</label>
                        <div class="input-group">
                            <input type="text" name="memory_overallocate" id="pMemoryOverallocate" class="form-control" value="{{ old('memory_overallocate', $node->memory_overallocate) }}" />
                            <span class="input-group-addon">%</span>
                        </div>
                        <p class="text-muted small">Enter the percentage of allowed memory overallocation. To disable, enter <code>-1</code>. To set no limit, enter <code>0</code>.</p>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Network Configuration</h3>
                </div>
                <div class="box-body">
                    <div class="form-group">
                        <label for="pDisk" class="form-label">Total Disk Space</label>
                        <div class="input-group">
                            <input type="text" name="disk" id="pDisk" class="form-control" value="{{ old('disk', $node->disk) }}" />
                            <span class="input-group-addon">MB</span>
                        </div>
                        <p class="text-muted small">The total amount of disk space available for this node.</p>
                    </div>
                    <div class="form-group">
                        <label for="pDiskOverallocate" class="form-label">Disk Overallocation</label>
                        <div class="input-group">
                            <input type="text" name="disk_overallocate" id="pDiskOverallocate" class="form-control" value="{{ old('disk_overallocate', $node->disk_overallocate) }}" />
                            <span class="input-group-addon">%</span>
                        </div>
                        <p class="text-muted small">Enter the percentage of allowed disk overallocation. To disable, enter <code>-1</code>. To set no limit, enter <code>0</code>.</p>
                    </div>
                    <div class="form-group">
                        <label for="pDaemonListen" class="form-label">Daemon Port</label>
                        <input type="text" name="daemonListen" id="pDaemonListen" class="form-control" value="{{ old('daemonListen', $node->daemonListen) }}" />
                        <p class="text-muted small">The port that the daemon should listen on. Usually <code>8080</code>.</p>
                    </div>
                    <div class="form-group">
                        <label for="pDaemonSFTP" class="form-label">SFTP Port</label>
                        <input type="text" name="daemonSFTP" id="pDaemonSFTP" class="form-control" value="{{ old('daemonSFTP', $node->daemonSFTP) }}" />
                        <p class="text-muted small">The port that the SFTP server should listen on. Usually <code>2022</code>.</p>
                    </div>
                </div>
                <div class="box-footer">
                    {!! csrf_field() !!}
                    <button type="submit" class="btn btn-primary pull-right">Save Changes</button>
                </div>
            </div>
        </div>
    </div>
@endif
EOF

# Proteksi untuk allocation view  
cat > "$VIEW_PATH/allocation.blade.php" << 'EOF'
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
    <!-- 🔒 SECURITY PROTECTION ACTIVATED -->
    <div class="alert alert-warning security-alert">
        <h4><i class="fa fa-exclamation-triangle"></i> Allocation Access Restricted</h4>
        <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
        <small>Allocation management is restricted to System Owner only</small>
    </div>
    
    <div style="filter: blur(5px); opacity: 0.7; pointer-events: none;">
        <div class="box">
            <div class="box-body">
                <p>Allocation management content is protected.</p>
            </div>
        </div>
    </div>
@else
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 - TAMPILAN NORMAL -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title">Allocation Management</h3>
                </div>
                <div class="box-body table-responsive no-padding">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>IP Address</th>
                                <th>Port</th>
                                <th>Assigned To</th>
                                <th>Notes</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($allocations as $allocation)
                                <tr>
                                    <td>{{ $allocation->ip }}</td>
                                    <td>{{ $allocation->port }}</td>
                                    <td>
                                        @if($allocation->server)
                                            <a href="{{ route('admin.servers.view', $allocation->server->id) }}">{{ $allocation->server->name }}</a>
                                        @else
                                            <span class="label label-default">Not Assigned</span>
                                        @endif
                                    </td>
                                    <td>{{ $allocation->notes ?? 'N/A' }}</td>
                                    <td class="text-center">
                                        @if(!$allocation->server)
                                            <button type="button" class="btn btn-xs btn-danger" data-action="delete-allocation" data-allocation="{{ $allocation->id }}">
                                                <i class="fa fa-trash"></i>
                                            </button>
                                        @endif
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    
    <div class="row">
        <div class="col-sm-6">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Add Allocation</h3>
                </div>
                <div class="box-body">
                    <div class="form-group">
                        <label for="pAllocationIP" class="form-label">IP Address</label>
                        <input type="text" name="allocation_ip" id="pAllocationIP" class="form-control" />
                    </div>
                    <div class="form-group">
                        <label for="pAllocationPorts" class="form-label">Ports</label>
                        <input type="text" name="allocation_ports" id="pAllocationPorts" class="form-control" placeholder="8080 or 8080-8090" />
                        <p class="text-muted small">Enter a single port or a range of ports to assign (e.g. <code>8080</code> or <code>8080-8090</code>).</p>
                    </div>
                </div>
                <div class="box-footer">
                    {!! csrf_field() !!}
                    <button type="submit" class="btn btn-success">Add Allocation</button>
                </div>
            </div>
        </div>
    </div>
@endif
EOF

# Proteksi untuk servers view
cat > "$VIEW_PATH/servers.blade.php" << 'EOF'
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
    <!-- 🔒 SECURITY PROTECTION ACTIVATED -->
    <div class="alert alert-info security-alert">
        <h4><i class="fa fa-server"></i> Server Management Protected</h4>
        <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
        <small>Server management is restricted to System Owner only</small>
    </div>
    
    <div style="filter: blur(6px); opacity: 0.6; pointer-events: none;">
        <div class="box">
            <div class="box-body">
                <p>Server management content is protected.</p>
            </div>
        </div>
    </div>
@else
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 - TAMPILAN NORMAL -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title">Servers on Node</h3>
                </div>
                <div class="box-body table-responsive no-padding">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Server Name</th>
                                <th>Owner</th>
                                <th>Memory</th>
                                <th>Disk</th>
                                <th>Status</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($servers as $server)
                                <tr>
                                    <td>
                                        <a href="{{ route('admin.servers.view', $server->id) }}">{{ $server->name }}</a>
                                    </td>
                                    <td>
                                        <a href="{{ route('admin.users.view', $server->owner_id) }}">{{ $server->user->username }}</a>
                                    </td>
                                    <td>{{ $server->memory }} MB</td>
                                    <td>{{ $server->disk }} MB</td>
                                    <td>
                                        @if($server->suspended)
                                            <span class="label label-warning">Suspended</span>
                                        @else
                                            <span class="label label-success">Active</span>
                                        @endif
                                    </td>
                                    <td class="text-center">
                                        <a href="{{ route('admin.servers.view', $server->id) }}" class="btn btn-xs btn-primary">
                                            <i class="fa fa-wrench"></i>
                                        </a>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
                @if($servers->hasPages())
                    <div class="box-footer with-border">
                        <div class="col-md-12 text-center">
                            {!! $servers->render() !!}
                        </div>
                    </div>
                @endif
            </div>
        </div>
    </div>
@endif
EOF

# Proteksi untuk about/index view
cat > "$VIEW_PATH/index.blade.php" << 'EOF'
@php
    $user = Auth::user();
@endphp

@if($user->id !== 1)
    <!-- 🔒 SECURITY PROTECTION ACTIVATED -->
    <div class="row">
        <div class="col-xs-12">
            <div class="box box-danger">
                <div class="box-body">
                    <div class="alert alert-danger security-alert" style="background: linear-gradient(45deg, #ff0000, #8b0000); color: white; border: none; text-align: center;">
                        <h3><i class="fa fa-shield-alt"></i> ACCESS DENIED</h3>
                        <p><strong>𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @𝗇𝖺𝖺𝗈𝖿𝖿𝗂𝖼𝗂𝖺𝗅𝗅</strong></p>
                        <small>Node overview access is restricted to System Owner only</small>
                        <div class="security-details">
                            <small>Attempted by: {{ $user->name }} (ID: {{ $user->id }})</small><br>
                            <small>Protection: @naaofficiall Security System</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@else
    <!-- 🔓 ORIGINAL CONTENT FOR ADMIN ID 1 - TAMPILAN NORMAL -->
    <div class="row">
        <div class="col-sm-6">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Information</h3>
                </div>
                <div class="box-body">
                    <dl>
                        <dt>Daemon Version</dt>
                        <dd>{{ $node->daemonVersion ?? 'Unknown' }}</dd>
                        
                        <dt>System Information</dt>
                        <dd>{{ $node->systemInfo ?? 'Unknown' }}</dd>
                        
                        <dt>Total CPU Threads</dt>
                        <dd>{{ $node->cpuThreads ?? 'Unknown' }}</dd>
                    </dl>
                </div>
            </div>
        </div>
        <div class="col-sm-6">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Resource Usage</h3>
                </div>
                <div class="box-body">
                    <dl>
                        <dt>Memory Usage</dt>
                        <dd>{{ $node->memoryUsage ?? 'Unknown' }}</dd>
                        
                        <dt>Disk Usage</dt>
                        <dd>{{ $node->diskUsage ?? 'Unknown' }}</dd>
                    </dl>
                </div>
            </div>
        </div>
    </div>
@endif
EOF

chmod 644 "$REMOTE_PATH"
chmod -R 755 "/var/www/pterodactyl/resources/views/admin/nodes/view"

# Clear cache
echo "🧹 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear 2>/dev/null || echo "⚠️ Gagal clear view cache"
php artisan cache:clear 2>/dev/null || echo "⚠️ Gagal clear cache"

echo "✅ Proteksi Anti Akses Admin Node View berhasil dipasang!"
echo "📂 Lokasi controller: $REMOTE_PATH"
echo "📂 Lokasi views: $VIEW_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo "🔒 Hanya Admin ID 1 yang bisa akses semua halaman node view"
echo "🔓 Admin ID 1: Akses normal seperti Pterodactyl original"
echo "🚫 Admin lain: Error 403 + efek security + content blur"
