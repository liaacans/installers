#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/resources/scripts/admin/nodes/view/1"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Akses Node View..."

if [ -d "$REMOTE_PATH" ]; then
  cp -r "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup folder lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$REMOTE_PATH"
chmod 755 "$REMOTE_PATH"

# Buat file index.php dengan proteksi
cat > "$REMOTE_PATH/index.php" << 'EOF'
<?php

use Illuminate\Support\Facades\Auth;

$user = Auth::user();
if (!$user || $user->id !== 1) {
    http_response_code(403);
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Access Denied - Node View</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                margin: 0;
                padding: 0;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                color: white;
            }
            .container {
                background: rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(10px);
                padding: 40px;
                border-radius: 15px;
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
                text-align: center;
                max-width: 500px;
                width: 90%;
            }
            .icon {
                font-size: 64px;
                margin-bottom: 20px;
            }
            h1 {
                font-size: 28px;
                margin-bottom: 15px;
                color: #ff6b6b;
            }
            p {
                font-size: 16px;
                line-height: 1.6;
                margin-bottom: 25px;
                opacity: 0.9;
            }
            .admin-info {
                background: rgba(255, 255, 255, 0.2);
                padding: 15px;
                border-radius: 8px;
                margin: 20px 0;
                border-left: 4px solid #4ecdc4;
            }
            .button {
                background: #ff6b6b;
                color: white;
                padding: 12px 30px;
                border: none;
                border-radius: 25px;
                font-size: 16px;
                cursor: pointer;
                transition: all 0.3s ease;
                text-decoration: none;
                display: inline-block;
            }
            .button:hover {
                background: #ff5252;
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(255, 107, 107, 0.4);
            }
            .footer {
                margin-top: 20px;
                font-size: 12px;
                opacity: 0.7;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="icon">🔒</div>
            <h1>Access Denied</h1>
            <p>𝖺𝗄𝗌𝖾𝗌 𝗇𝗈𝖽𝖾 𝗏𝗂𝖾𝗐 𝖽𝗂𝗍𝗈𝗅𝖺𝗄</p>
            
            <div class="admin-info">
                <strong>Hanya Admin ID 1 yang dapat mengakses halaman ini</strong><br>
                User ID Anda: <?php echo $user ? $user->id : 'Not logged in'; ?>
            </div>
            
            <p>Fitur ini diproteksi oleh sistem keamanan @ginaabaikhati</p>
            
            <a href="/admin" class="button">Kembali ke Dashboard</a>
            
            <div class="footer">
                Copyright © 2015 - 2025 Pterodactyl Software<br>
                Protected by Security System
            </div>
        </div>
    </body>
    </html>
    <?php
    exit();
}

// Jika user adalah admin ID 1, redirect ke nodes list
header('Location: /admin/nodes');
exit();
?>
EOF

chmod 644 "$REMOTE_PATH/index.php"

# Buat file .htaccess tambahan untuk extra security
cat > "$REMOTE_PATH/.htaccess" << 'EOF'
RewriteEngine On
RewriteRule ^(.*)$ index.php [L]
EOF

chmod 644 "$REMOTE_PATH/.htaccess"

echo "✅ Proteksi Akses Node View berhasil dipasang!"
echo "📂 Lokasi folder: $REMOTE_PATH"
echo "🗂️ Backup folder lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Hanya Admin (ID 1) yang bisa akses Node View ID 1"
echo "👥 Admin lain akan melihat halaman akses ditolak"
