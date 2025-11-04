#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/resources/scripts/admin/nodes/view/1"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_uninstall_${TIMESTAMP}"

echo "🔄 Memulai proses uninstall proteksi..."

if [ -d "$REMOTE_PATH" ]; then
    # Buat backup sebelum uninstall
    cp -r "$REMOTE_PATH" "$BACKUP_PATH"
    echo "📦 Backup dibuat di: $BACKUP_PATH"
    
    # Hapus file-file proteksi
    rm -f "$REMOTE_PATH/index.php"
    rm -f "$REMOTE_PATH/.htaccess"
    
    # Cek jika folder kosong, hapus folder
    if [ -z "$(ls -A "$REMOTE_PATH")" ]; then
        rmdir "$REMOTE_PATH"
        echo "🗑️ Folder kosong berhasil dihapus"
    fi
    
    echo "✅ Proteksi berhasil diuninstall!"
    echo "📂 Folder yang diuninstall: $REMOTE_PATH"
    echo "🗂️ Backup tersedia di: $BACKUP_PATH"
else
    echo "❌ Folder proteksi tidak ditemukan di: $REMOTE_PATH"
    echo "ℹ️  Mungkin proteksi sudah diuninstall sebelumnya"
fi

# Tampilkan konfirmasi HTML
cat << 'EOF'

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uninstall Complete - Node View Protection</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
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
            color: #fff;
        }
        .success {
            background: rgba(255, 255, 255, 0.2);
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            border-left: 4px solid #4ecdc4;
        }
        .button {
            background: #4ecdc4;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 25px;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
            margin: 5px;
        }
        .button:hover {
            background: #3dbab3;
            transform: translateY(-2px);
        }
        .button.warning {
            background: #ff6b6b;
        }
        .button.warning:hover {
            background: #ff5252;
        }
        .info-box {
            background: rgba(255, 255, 255, 0.1);
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
            text-align: left;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon">✅</div>
        <h1>Uninstall Complete</h1>
        
        <div class="success">
            <strong>Proteksi Node View berhasil diuninstall!</strong>
        </div>
        
        <div class="info-box">
            <strong>Detail Uninstall:</strong><br>
            • Folder: /admin/nodes/view/1<br>
            • Backup dibuat: <?php echo $TIMESTAMP; ?><br>
            • Status: Proteksi dihapus
        </div>
        
        <p>Sekarang semua admin dapat mengakses halaman node view.</p>
        
        <div>
            <a href="/admin" class="button">Kembali ke Dashboard</a>
            <a href="installprotect10.sh" class="button warning">Install Kembali</a>
        </div>
        
        <div style="margin-top: 20px; font-size: 12px; opacity: 0.7;">
            Copyright © 2015 - 2025 Pterodactyl Software<br>
            Security System by @ginaabaikhati
        </div>
    </div>
</body>
</html>

EOF
