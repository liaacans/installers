#!/bin/bash

echo "🚀 Memasang proteksi Anti Tautan Server View..."

# File paths
VIEW_DIR="/var/www/pterodactyl/resources/views/admin/servers/view"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

# Create view directory if not exists
mkdir -p "$VIEW_DIR"

# Proteksi SEMUA file view yang ada dan buat yang baru
echo "🛡️ Memproteksi semua halaman view server..."

# Proteksi untuk server 26 (dari screenshot)
SERVER_26="$VIEW_DIR/26.blade.php"
if [ -f "$SERVER_26" ]; then
    cp "$SERVER_26" "${SERVER_26}.bak_${TIMESTAMP}"
    echo "📦 Backup server 26 dibuat: ${SERVER_26}.bak_${TIMESTAMP}"
fi

# Create protected view untuk server 26
cat > "$SERVER_26" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Protected - Security System</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .security-container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.2);
            overflow: hidden;
            max-width: 800px;
            width: 100%;
            animation: fadeIn 0.8s ease-in-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .security-header {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            padding: 40px 30px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .security-header::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: linear-gradient(45deg, transparent, rgba(255,255,255,0.1), transparent);
            transform: rotate(45deg);
            animation: shine 3s infinite;
        }
        @keyframes shine {
            0% { transform: translateX(-100%) translateY(-100%) rotate(45deg); }
            100% { transform: translateX(100%) translateY(100%) rotate(45deg); }
        }
        .security-icon {
            font-size: 80px;
            margin-bottom: 20px;
            display: block;
        }
        .security-content {
            padding: 40px;
        }
        .protection-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 20px;
            border-left: 5px solid #3742fa;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        .server-info {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        .credits-section {
            background: linear-gradient(135deg, #74b9ff, #0984e3);
            color: white;
            padding: 25px;
            border-radius: 15px;
            text-align: center;
            margin-top: 30px;
        }
        .security-badge {
            display: inline-block;
            background: #2ed573;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            margin: 5px;
            font-size: 12px;
            font-weight: bold;
        }
        .admin-notice {
            background: #ffeaa7;
            border: 2px dashed #fdcb6e;
            padding: 15px;
            border-radius: 10px;
            margin: 15px 0;
            text-align: center;
        }
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        .feature-item {
            text-align: center;
            padding: 15px;
            background: #f1f2f6;
            border-radius: 10px;
        }
        .connection-info {
            background: #2d3436;
            color: white;
            padding: 15px;
            border-radius: 10px;
            margin: 15px 0;
            font-family: 'Courier New', monospace;
        }
    </style>
</head>
<body>
    <div class="security-container">
        <div class="security-header">
            <i class="security-icon fas fa-shield-alt"></i>
            <h1>SERVER PROTECTION ACTIVE</h1>
            <p>Advanced Security System • Server ID: 26</p>
        </div>
        
        <div class="security-content">
            <div class="protection-card">
                <h3><i class="fas fa-ban" style="color: #e74c3c;"></i> Access Restricted</h3>
                <p>This server view is protected by the Ultimate Security System. Server management features have been permanently disabled.</p>
                
                <div class="admin-notice">
                    <i class="fas fa-crown" style="color: #f39c12;"></i>
                    <strong>Administrator Access Only</strong><br>
                    Only root administrator (ID: 1) can manage this server through system-level access.
                </div>
            </div>

            <div class="server-info">
                <h4><i class="fas fa-server"></i> Protected Server Information</h4>
                
                <!-- Connection Information from Screenshot -->
                <div class="connection-info">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                        <div>
                            <strong>Default Connection:</strong><br>
                            <code>0.0.0.0:2007</code>
                        </div>
                        <div>
                            <strong>Connection Alias:</strong><br>
                            <code>ANDIN OFFICIAL:2007</code>
                        </div>
                    </div>
                </div>

                <div class="feature-grid">
                    <div class="feature-item">
                        <i class="fas fa-hdd" style="color: #3498db; font-size: 24px;"></i>
                        <div style="margin-top: 10px;">
                            <strong>Disk Space</strong><br>
                            <span style="color: #27ae60;">Unlimited</span>
                        </div>
                    </div>
                    <div class="feature-item">
                        <i class="fas fa-network-wired" style="color: #9b59b6; font-size: 24px;"></i>
                        <div style="margin-top: 10px;">
                            <strong>Block IO Weight</strong><br>
                            <span style="color: #27ae60;">500</span>
                        </div>
                    </div>
                    <div class="feature-item">
                        <i class="fas fa-user-shield" style="color: #e74c3c; font-size: 24px;"></i>
                        <div style="margin-top: 10px;">
                            <strong>Server Owner</strong><br>
                            <span style="color: #747d8c;">Hidden</span>
                        </div>
                    </div>
                    <div class="feature-item">
                        <i class="fas fa-sitemap" style="color: #f39c12; font-size: 24px;"></i>
                        <div style="margin-top: 10px;">
                            <strong>Server Node</strong><br>
                            <span style="color: #747d8c;">Protected</span>
                        </div>
                    </div>
                </div>
            </div>

            <div style="text-align: center; margin: 20px 0;">
                <span class="security-badge"><i class="fas fa-shield-alt"></i> ANTI-LINK</span>
                <span class="security-badge"><i class="fas fa-eye-slash"></i> INFO PROTECTED</span>
                <span class="security-badge"><i class="fas fa-lock"></i> SECURE ACCESS</span>
                <span class="security-badge"><i class="fas fa-ban"></i> NO SETTINGS</span>
            </div>

            <div class="credits-section">
                <h3><i class="fas fa-award"></i> SECURITY CREDITS</h3>
                <p style="margin: 15px 0;">
                    <strong>Advanced Protection System Developed by:</strong><br>
                    <span style="font-size: 18px;">
                        <span style="color: #fd79a8;">@ginaabaikhati</span> • 
                        <span style="color: #81ecec;">@AndinOfficial</span> • 
                        <span style="color: #55efc4;">@naaofficial</span>
                    </span>
                </p>
                <p style="margin-bottom: 0; font-size: 14px;">
                    <i class="fas fa-star"></i> Pterodactyl ID Ultimate Security Team <i class="fas fa-star"></i>
                </p>
            </div>

            <div style="text-align: center; margin-top: 20px; padding: 15px; background: #fd79a8; color: white; border-radius: 10px;">
                <i class="fas fa-exclamation-triangle"></i>
                <strong>PERMANENT PROTECTION</strong><br>
                Server settings cannot be modified through this interface.
            </div>
        </div>
    </div>

    <script>
        // Enhanced security protection
        document.addEventListener('contextmenu', function(e) {
            e.preventDefault();
        });

        document.addEventListener('keydown', function(e) {
            if (e.key === 'F12' || 
                (e.ctrlKey && e.shiftKey && e.key === 'I') ||
                (e.ctrlKey && e.shiftKey && e.key === 'J') ||
                (e.ctrlKey && e.key === 'u')) {
                e.preventDefault();
                showAlert('Developer tools disabled for security');
            }
        });

        // Block any form submissions or button clicks
        document.addEventListener('submit', function(e) {
            e.preventDefault();
            showAlert('Form submissions disabled for security');
        });

        document.addEventListener('click', function(e) {
            if (e.target.tagName === 'BUTTON' || e.target.tagName === 'A') {
                e.preventDefault();
                showAlert('This action is disabled by security system');
            }
        });

        function showAlert(message) {
            const alert = document.createElement('div');
            alert.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                background: #ff6b6b;
                color: white;
                padding: 15px 20px;
                border-radius: 10px;
                box-shadow: 0 5px 15px rgba(0,0,0,0.3);
                z-index: 10000;
                font-weight: bold;
            `;
            alert.innerHTML = `<i class="fas fa-shield-alt"></i> ${message}`;
            document.body.appendChild(alert);
            
            setTimeout(() => {
                alert.remove();
            }, 3000);
        }

        // Add floating animation to badges
        setInterval(() => {
            const badges = document.querySelectorAll('.security-badge');
            badges.forEach((badge, index) => {
                setTimeout(() => {
                    badge.style.transform = 'translateY(-5px)';
                    setTimeout(() => {
                        badge.style.transform = 'translateY(0)';
                    }, 300);
                }, index * 200);
            });
        }, 3000);

        // Auto-redirect to server list after 10 seconds
        setTimeout(() => {
            window.location.href = '/admin/servers';
        }, 10000);
    </script>
</body>
</html>
EOF

echo "✅ Protected view untuk server 26 berhasil dibuat"

# Buat proteksi untuk SEMUA server view yang mungkin ada
echo "🛡️ Membuat proteksi universal untuk semua server view..."

# Template protected view untuk server lainnya
PROTECTED_TEMPLATE='<!DOCTYPE html>
<html>
<head>
    <title>Server Protected - Security System</title>
    <style>
        body {
            background: linear-gradient(135deg, #667eea, #764ba2);
            font-family: Arial, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }
        .protection-box {
            background: white;
            padding: 40px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            max-width: 500px;
            width: 100%;
        }
    </style>
</head>
<body>
    <div class="protection-box">
        <div style="font-size: 60px; margin-bottom: 20px;">🛡️</div>
        <h2>Server Protected</h2>
        <p>This server is protected by security system.</p>
        <div style="margin-top: 20px; padding: 15px; background: #f8f9fa; border-radius: 10px;">
            <strong>Security Team:</strong><br>
            @ginaabaikhati • @AndinOfficial • @naaofficial
        </div>
    </div>
    <script>
        document.addEventListener("contextmenu", e => e.preventDefault());
        setTimeout(() => window.location.href = "/admin/servers", 5000);
    </script>
</body>
</html>'

# Proteksi semua file view yang ada
find "$VIEW_DIR" -name "*.blade.php" | while read view_file; do
    if [ "$view_file" != "$SERVER_26" ]; then
        if [ -f "$view_file" ]; then
            cp "$view_file" "${view_file}.bak_${TIMESTAMP}" 2>/dev/null
        fi
        echo "$PROTECTED_TEMPLATE" > "$view_file"
        echo "✅ Protected: $(basename "$view_file")"
    fi
done

# Buat file catch-all untuk server ID apapun yang belum ada
cat > "$VIEW_DIR/default.blade.php" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Server Protected</title>
    <style>
        body {
            background: linear-gradient(135deg, #667eea, #764ba2);
            font-family: Arial, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }
        .protection-box {
            background: white;
            padding: 40px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            max-width: 500px;
            width: 100%;
        }
    </style>
</head>
<body>
    <div class="protection-box">
        <div style="font-size: 60px; margin-bottom: 20px;">🛡️</div>
        <h2>Server Protection Active</h2>
        <p>All servers are protected by the security system.</p>
        <div style="margin-top: 20px; padding: 15px; background: #f8f9fa; border-radius: 10px;">
            <strong>Protected by:</strong><br>
            @ginaabaikhati • @AndinOfficial • @naaofficial
        </div>
    </div>
    <script>
        setTimeout(() => window.location.href = "/admin/servers", 3000);
    </script>
</body>
</html>
EOF

# Set permissions
find "$VIEW_DIR" -name "*.blade.php" -exec chmod 644 {} \;

# Clear cache
echo "🔄 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear
php artisan cache:clear

echo ""
echo "🎉 PROTEKSI BERHASIL DIPASANG!"
echo "✅ Halaman admin/servers TIDAK diproteksi (normal)"
echo "✅ SEMUA tautan view server (/admin/servers/view/*) DIPROTEKSI"
echo "✅ Server 26 memiliki tampilan protected khusus"
echo "✅ Tidak bisa setting/server management melalui view"
echo "🛡️ Security by: @ginaabaikhati, @AndinOfficial, @naaofficial"
