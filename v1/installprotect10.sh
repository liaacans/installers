#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesViewController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Admin Nodes View..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\View\View;
use Pterodactyl\Models\Node;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;

class NodesViewController extends Controller
{
    /**
     * Display node view index.
     *
     * @param \Pterodactyl\Models\Node $node
     * @return \Illuminate\View\View
     */
    public function index(Node $node): View
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Access Denied - Pterodactyl</title>
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }
                    
                    body {
                        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        min-height: 100vh;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    }
                    
                    .error-container {
                        background: rgba(255, 255, 255, 0.95);
                        padding: 3rem;
                        border-radius: 20px;
                        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
                        text-align: center;
                        max-width: 500px;
                        width: 90%;
                        backdrop-filter: blur(10px);
                        border: 1px solid rgba(255, 255, 255, 0.2);
                    }
                    
                    .error-icon {
                        font-size: 4rem;
                        margin-bottom: 1.5rem;
                        color: #e74c3c;
                    }
                    
                    .error-title {
                        font-size: 2rem;
                        font-weight: 700;
                        color: #2d3748;
                        margin-bottom: 1rem;
                    }
                    
                    .error-message {
                        font-size: 1.1rem;
                        color: #4a5568;
                        margin-bottom: 2rem;
                        line-height: 1.6;
                    }
                    
                    .error-code {
                        background: #edf2f7;
                        padding: 0.5rem 1rem;
                        border-radius: 10px;
                        font-family: "Monaco", "Consolas", monospace;
                        color: #2d3748;
                        display: inline-block;
                        margin-bottom: 2rem;
                    }
                    
                    .admin-info {
                        background: #fff5f5;
                        border: 1px solid #fed7d7;
                        border-radius: 10px;
                        padding: 1rem;
                        margin-bottom: 2rem;
                    }
                    
                    .admin-info h3 {
                        color: #c53030;
                        margin-bottom: 0.5rem;
                    }
                    
                    .button {
                        display: inline-block;
                        padding: 12px 30px;
                        background: linear-gradient(135deg, #667eea, #764ba2);
                        color: white;
                        text-decoration: none;
                        border-radius: 10px;
                        font-weight: 600;
                        transition: all 0.3s ease;
                        border: none;
                        cursor: pointer;
                        font-size: 1rem;
                    }
                    
                    .button:hover {
                        transform: translateY(-2px);
                        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
                    }
                    
                    .footer {
                        margin-top: 2rem;
                        font-size: 0.9rem;
                        color: #718096;
                    }
                </style>
            </head>
            <body>
                <div class="error-container">
                    <div class="error-icon">🚫</div>
                    <h1 class="error-title">Access Denied</h1>
                    <p class="error-message">
                        You do not have permission to access this node view. 
                        This area is restricted to system administrators only.
                    </p>
                    <div class="error-code">Error 403 - Forbidden</div>
                    
                    <div class="admin-info">
                        <h3>🔒 Security Notice</h3>
                        <p>This action has been logged for security purposes. 
                        Unauthorized access attempts may result in account suspension.</p>
                    </div>
                    
                    <button class="button" onclick="window.history.back()">← Go Back</button>
                    
                    <div class="footer">
                        <p>Protected by @ginaabaikhati Security System</p>
                    </div>
                </div>
            </body>
            </html>
            ');
        }

        return view('admin.nodes.view.index', [
            'node' => $node,
        ]);
    }

    /**
     * Display node view settings.
     *
     * @param \Pterodactyl\Models\Node $node
     * @return \Illuminate\View\View
     */
    public function settings(Node $node): View
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝗇𝗈𝖽𝖾 𝗌𝖾𝗍𝗍𝗂𝗇𝗀𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.nodes.view.settings', [
            'node' => $node,
        ]);
    }

    /**
     * Display node view configuration.
     *
     * @param \Pterodactyl\Models\Node $node
     * @return \Illuminate\View\View
     */
    public function configuration(Node $node): View
    {
        // 🚫 Batasi akses hanya untuk user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, '𝖺𝗄𝗌𝖾𝗌 𝗇𝗈𝖽𝖾 𝖼𝗈𝗇𝖿𝗂𝗀𝗎𝗋𝖺𝗍𝗂𝗈𝗇 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati');
        }

        return view('admin.nodes.view.configuration', [
            'node' => $node,
        ]);
    }
}
?>
EOF

chmod 644 "$REMOTE_PATH"

# Juga proteksi untuk servers controller
SERVERS_CONTROLLER_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/ServersController.php"
SERVERS_BACKUP_PATH="${SERVERS_CONTROLLER_PATH}.bak_${TIMESTAMP}"

if [ -f "$SERVERS_CONTROLLER_PATH" ]; then
  cp "$SERVERS_CONTROLLER_PATH" "$SERVERS_BACKUP_PATH"
  echo "📦 Backup servers controller dibuat di $SERVERS_BACKUP_PATH"
  
  # Modifikasi servers controller untuk menghilangkan kolom tertentu
  sed -i 's/<th>Owner<\/th>/\<th class="hidden-column">Owner<\/th>/g' "$SERVERS_CONTROLLER_PATH"
  sed -i 's/<th>Node<\/th>/\<th class="hidden-column">Node<\/th>/g' "$SERVERS_CONTROLLER_PATH"
  sed -i 's/<th>Connection<\/th>/\<th class="hidden-column">Connection<\/th>/g' "$SERVERS_CONTROLLER_PATH"
  sed -i 's/{{\$server->user->username}}/\<span class="hidden-column">{{\$server->user->username}}<\/span>/g' "$SERVERS_CONTROLLER_PATH"
  sed -i 's/{{\$server->node->name}}/\<span class="hidden-column">{{\$server->node->name}}<\/span>/g' "$SERVERS_CONTROLLER_PATH"
  
  # Tambahkan CSS untuk menyembunyikan kolom
  echo '<style>.hidden-column { display: none; }</style>' >> "$SERVERS_CONTROLLER_PATH"
fi

echo "✅ Proteksi Admin Nodes View berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH"
echo "🔒 Hanya Admin (ID 1) yang bisa akses Nodes View."
echo "📊 Kolom Owner, Node, Connection di servers table telah disembunyikan."
