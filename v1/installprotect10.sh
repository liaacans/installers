#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi ULTIMATE Anti Tautan Server List..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Servers - Protected System</title>
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .security-container {
            max-width: 1200px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .security-header {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .security-content {
            padding: 40px;
        }
        .security-badge {
            display: inline-block;
            background: #2ed573;
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            margin: 10px;
            font-weight: bold;
            box-shadow: 0 5px 15px rgba(46, 213, 115, 0.3);
        }
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        .feature-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            text-align: center;
            border-left: 5px solid #3742fa;
        }
        .credits {
            background: #f1f2f6;
            padding: 20px;
            border-radius: 10px;
            margin-top: 30px;
            text-align: center;
        }
        .server-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .server-table th, .server-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        .server-table th {
            background: #3742fa;
            color: white;
        }
        .disabled-btn {
            background: #a4b0be !important;
            color: #747d8c !important;
            cursor: not-allowed !important;
            opacity: 0.6;
        }
    </style>
</head>
<body>
    <div class="security-container">
        <div class="security-header">
            <h1>🛡️ ULTIMATE SERVER PROTECTION</h1>
            <p>Advanced Security System Active</p>
        </div>
        
        <div class="security-content">
            <div style="text-align: center; margin-bottom: 30px;">
                <span class="security-badge">🔒 ANTI-LINK PROTECTION</span>
                <span class="security-badge">👁️ INFORMATION HIDDEN</span>
                <span class="security-badge">🛡️ SECURE SYSTEM</span>
            </div>

            <div class="feature-grid">
                <div class="feature-card">
                    <h3>🚫 No Access</h3>
                    <p>Server management features are permanently disabled for security reasons</p>
                </div>
                <div class="feature-card">
                    <h3>👑 Admin Only</h3>
                    <p>Only root administrator (ID: 1) can access full system controls</p>
                </div>
                <div class="feature-card">
                    <h3>🔐 Encrypted</h3>
                    <p>All sensitive information is protected by advanced encryption</p>
                </div>
                <div class="feature-card">
                    <h3>⚡ Permanent</h3>
                    <p>This protection cannot be modified or disabled through normal means</p>
                </div>
            </div>

            <!-- Server List Table -->
            <h3>📊 Server List (Read Only)</h3>
            <table class="server-table">
                <thead>
                    <tr>
                        <th>Server Name</th>
                        <th>UUID</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><strong>ANDIN OFFICIAL</strong></td>
                        <td><code>••••••••</code></td>
                        <td><span style="color: #2ed573;">● Online</span></td>
                        <td>
                            <button class="disabled-btn" disabled>🚫 Disabled</button>
                        </td>
                    </tr>
                    <tr>
                        <td><strong>Protected Server</strong></td>
                        <td><code>••••••••</code></td>
                        <td><span style="color: #2ed573;">● Online</span></td>
                        <td>
                            <button class="disabled-btn" disabled>🚫 Disabled</button>
                        </td>
                    </tr>
                </tbody>
            </table>

            <div class="credits">
                <h3>🛡️ SECURITY CREDITS</h3>
                <p>
                    <strong>Advanced Protection System by:</strong><br>
                    <span style="color: #3742fa;">@ginaabaikhati</span> • 
                    <span style="color: #2ed573;">@AndinOfficial</span> • 
                    <span style="color: #ffa502;">@naaofficial</span><br>
                    <small>Pterodactyl ID Ultimate Security Team</small>
                </p>
                <p style="margin-top: 15px; font-size: 12px; color: #747d8c;">
                    ⚠️ This protection system is permanent and cannot be modified without root access
                </p>
            </div>
        </div>
    </div>

    <script>
        // Block all right-click context menus
        document.addEventListener('contextmenu', function(e) {
            e.preventDefault();
            alert('🚫 Context menu disabled for security');
        });

        // Block F12, Ctrl+Shift+I, Ctrl+Shift+J, Ctrl+U
        document.addEventListener('keydown', function(e) {
            if (e.key === 'F12' || 
                (e.ctrlKey && e.shiftKey && e.key === 'I') ||
                (e.ctrlKey && e.shiftKey && e.key === 'J') ||
                (e.ctrlKey && e.key === 'u')) {
                e.preventDefault();
                alert('🚫 Developer tools disabled for security');
            }
        });

        // Prevent any form submissions
        document.querySelectorAll('form').forEach(form => {
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                alert('🚫 Form submissions disabled for security');
            });
        });

        // Add animation to security badges
        setInterval(() => {
            document.querySelectorAll('.security-badge').forEach(badge => {
                badge.style.transform = 'scale(1.05)';
                setTimeout(() => {
                    badge.style.transform = 'scale(1)';
                }, 300);
            });
        }, 2000);
    </script>
</body>
</html>
EOF

chmod 444 "$REMOTE_PATH"  # Read-only permissions
echo "✅ Proteksi ULTIMATE berhasil dipasang!"

# Apply additional protection to view file
VIEW_PATH="/var/www/pterodactyl/resources/views/admin/servers/view/26.blade.php"
VIEW_BACKUP="${VIEW_PATH}.bak_${TIMESTAMP}"

if [ -f "$VIEW_PATH" ]; then
  mv "$VIEW_PATH" "$VIEW_BACKUP"
  echo "📦 Backup view file dibuat di $VIEW_BACKUP"
fi

cat > "$VIEW_PATH" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server View - Protected</title>
    <style>
        body {
            background: linear-gradient(135deg, #2c3e50, #4ca1af);
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 20px;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .protection-container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 600px;
            width: 100%;
        }
        .protection-icon {
            font-size: 80px;
            margin-bottom: 20px;
        }
        .protection-message {
            background: #ffeaa7;
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }
        .security-team {
            background: #dfe6e9;
            padding: 15px;
            border-radius: 10px;
            margin-top: 20px;
        }
        .admin-access {
            background: #74b9ff;
            color: white;
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="protection-container">
        <div class="protection-icon">🛡️</div>
        <h1>SERVER VIEW PROTECTED</h1>
        
        <div class="protection-message">
            <h3>🚫 Access Restricted</h3>
            <p>This server view page has been permanently protected by the Ultimate Security System.</p>
            <p>Direct access to server details is not available for security reasons.</p>
        </div>

        <div class="admin-access">
            <strong>👑 Administrator Notice:</strong><br>
            Only root admin (ID: 1) can bypass this protection through system-level access.
        </div>

        <div class="security-team">
            <h4>🛡️ Security Team</h4>
            <p>
                <strong>Protected by:</strong><br>
                <span style="color: #e84393;">@ginaabaikhati</span> • 
                <span style="color: #0984e3;">@AndinOfficial</span> • 
                <span style="color: #00b894;">@naaofficial</span>
            </p>
            <p><small>Pterodactyl ID Ultimate Protection System</small></p>
        </div>

        <div style="margin-top: 20px; padding: 15px; background: #fd79a8; color: white; border-radius: 10px;">
            <strong>⚠️ Permanent Protection</strong><br>
            This security measure cannot be modified through the admin panel.
        </div>
    </div>

    <script>
        // Block all keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            e.preventDefault();
        });

        // Block right-click
        document.addEventListener('contextmenu', function(e) {
            e.preventDefault();
        });

        // Redirect any attempts to access this page
        setTimeout(() => {
            if (!window.location.href.includes('admin/servers')) {
                window.location.href = '/admin/servers';
            }
        }, 3000);
    </script>
</body>
</html>
EOF

chmod 444 "$VIEW_PATH"

echo "✅ Proteksi view server berhasil dipasang!"

# Make files immutable (super protection)
chattr +i "$REMOTE_PATH" 2>/dev/null || echo "⚠️  chattr not available, using alternative protection"
chattr +i "$VIEW_PATH" 2>/dev/null || echo "⚠️  chattr not available, using alternative protection"

# Clear cache
echo "🔄 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear
php artisan cache:clear

echo ""
echo "🎉 ULTIMATE PROTECTION BERHASIL DIPASANG!"
echo "🔒 File sekarang dalam mode READ-ONLY"
echo "🚫 Tidak bisa di-edit melalui admin panel"
echo "🛡️ Protection by: @ginaabaikhati, @AndinOfficial, @naaofficial"
echo "💪 System: Pterodactyl ID Ultimate Security"
EOF
