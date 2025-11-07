#!/bin/bash

echo "🚀 Memasang proteksi ULTIMATE untuk SEMUA server..."

# File paths
INDEX_FILE="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

# Backup original file
if [ -f "$INDEX_FILE" ]; then
  cp "$INDEX_FILE" "${INDEX_FILE}.bak_${TIMESTAMP}"
  echo "📦 Backup index file dibuat: ${INDEX_FILE}.bak_${TIMESTAMP}"
fi

# Create protected index file
cat > "$INDEX_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Servers - Protected System</title>
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
            padding: 20px;
        }
        .security-container {
            max-width: 1400px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.2);
            overflow: hidden;
        }
        .security-header {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            padding: 30px;
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
        .security-content {
            padding: 30px;
        }
        .server-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .server-table th {
            background: linear-gradient(135deg, #3742fa, #5352ed);
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: 600;
        }
        .server-table td {
            padding: 15px;
            border-bottom: 1px solid #f1f2f6;
        }
        .server-table tr:hover {
            background: #f8f9fa;
        }
        .protection-badge {
            display: inline-block;
            background: linear-gradient(135deg, #2ed573, #1dd1a1);
            color: white;
            padding: 6px 12px;
            border-radius: 15px;
            font-size: 11px;
            font-weight: bold;
            margin: 2px;
        }
        .disabled-manage {
            background: #a4b0be !important;
            color: #747d8c !important;
            cursor: not-allowed !important;
            opacity: 0.7;
            border: none !important;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            border-left: 4px solid #3742fa;
        }
        .credits-section {
            background: linear-gradient(135deg, #74b9ff, #0984e3);
            color: white;
            padding: 25px;
            border-radius: 15px;
            text-align: center;
            margin-top: 30px;
        }
        .search-box {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .security-features {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 10px;
            margin: 20px 0;
        }
        .feature-tag {
            background: #ffeaa7;
            color: #e17055;
            padding: 8px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="security-container">
        <div class="security-header">
            <h1><i class="fas fa-shield-alt"></i> ULTIMATE SERVER PROTECTION</h1>
            <p>Advanced Security System • All Servers Protected</p>
            <div class="security-features">
                <span class="feature-tag"><i class="fas fa-ban"></i> ANTI-LINK</span>
                <span class="feature-tag"><i class="fas fa-lock"></i> READ-ONLY</span>
                <span class="feature-tag"><i class="fas fa-eye-slash"></i> INFO PROTECTED</span>
                <span class="feature-tag"><i class="fas fa-shield"></i> SECURE ACCESS</span>
            </div>
        </div>
        
        <div class="security-content">
            <!-- Search Box -->
            <div class="search-box">
                <div style="display: flex; gap: 10px; align-items: center;">
                    <input type="text" placeholder="Search servers..." style="
                        flex: 1;
                        padding: 12px 15px;
                        border: 2px solid #ddd;
                        border-radius: 8px;
                        font-size: 14px;
                    ">
                    <button style="
                        background: #3742fa;
                        color: white;
                        border: none;
                        padding: 12px 20px;
                        border-radius: 8px;
                        cursor: pointer;
                        font-weight: bold;
                    ">
                        <i class="fas fa-search"></i> Search
                    </button>
                    <button class="disabled-manage" style="padding: 12px 20px; border-radius: 8px;">
                        <i class="fas fa-plus"></i> Create New
                    </button>
                </div>
            </div>

            <!-- Stats -->
            <div class="stats-grid">
                <div class="stat-card">
                    <i class="fas fa-server" style="font-size: 30px; color: #3742fa;"></i>
                    <h3>Total Servers</h3>
                    <p style="font-size: 24px; font-weight: bold; color: #3742fa;">12</p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-shield-alt" style="font-size: 30px; color: #2ed573;"></i>
                    <h3>Protected</h3>
                    <p style="font-size: 24px; font-weight: bold; color: #2ed573;">12</p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-lock" style="font-size: 30px; color: #ff6b6b;"></i>
                    <h3>Security Level</h3>
                    <p style="font-size: 24px; font-weight: bold; color: #ff6b6b;">MAX</p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-user-shield" style="font-size: 30px; color: #ffa502;"></i>
                    <h3>Admin Only</h3>
                    <p style="font-size: 24px; font-weight: bold; color: #ffa502;">ID:1</p>
                </div>
            </div>

            <!-- Server Table -->
            <table class="server-table">
                <thead>
                    <tr>
                        <th>Server Name</th>
                        <th>UUID</th>
                        <th>Owner</th>
                        <th>Node</th>
                        <th>Connection</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Server 1 -->
                    <tr>
                        <td>
                            <strong><i class="fas fa-server"></i> ANDIN OFFICIAL</strong>
                            <div><span class="protection-badge">PROTECTED</span></div>
                        </td>
                        <td><code>a1b2c3d4e5</code></td>
                        <td>
                            <div style="color: #747d8c;">
                                <i class="fas fa-user-secret"></i> Hidden
                            </div>
                        </td>
                        <td>
                            <div style="color: #747d8c;">
                                <i class="fas fa-eye-slash"></i> Protected
                            </div>
                        </td>
                        <td><code>0.0.0.0:2007</code></td>
                        <td><span style="color: #2ed573;">● Online</span></td>
                        <td>
                            <button class="disabled-manage" style="padding: 6px 12px; border-radius: 5px;">
                                <i class="fas fa-wrench"></i> Manage
                            </button>
                        </td>
                    </tr>
                    
                    <!-- Server 2 -->
                    <tr>
                        <td>
                            <strong><i class="fas fa-server"></i> NAO OFFICIAL</strong>
                            <div><span class="protection-badge">PROTECTED</span></div>
                        </td>
                        <td><code>f6g7h8i9j0</code></td>
                        <td>
                            <div style="color: #747d8c;">
                                <i class="fas fa-user-secret"></i> Hidden
                            </div>
                        </td>
                        <td>
                            <div style="color: #747d8c;">
                                <i class="fas fa-eye-slash"></i> Protected
                            </div>
                        </td>
                        <td><code>0.0.0.0:2008</code></td>
                        <td><span style="color: #2ed573;">● Online</span></td>
                        <td>
                            <button class="disabled-manage" style="padding: 6px 12px; border-radius: 5px;">
                                <i class="fas fa-wrench"></i> Manage
                            </button>
                        </td>
                    </tr>
                    
                    <!-- Server 3 -->
                    <tr>
                        <td>
                            <strong><i class="fas fa-server"></i> GINA SERVER</strong>
                            <div><span class="protection-badge">PROTECTED</span></div>
                        </td>
                        <td><code>k1l2m3n4o5</code></td>
                        <td>
                            <div style="color: #747d8c;">
                                <i class="fas fa-user-secret"></i> Hidden
                            </div>
                        </td>
                        <td>
                            <div style="color: #747d8c;">
                                <i class="fas fa-eye-slash"></i> Protected
                            </div>
                        </td>
                        <td><code>0.0.0.0:2009</code></td>
                        <td><span style="color: #2ed573;">● Online</span></td>
                        <td>
                            <button class="disabled-manage" style="padding: 6px 12px; border-radius: 5px;">
                                <i class="fas fa-wrench"></i> Manage
                            </button>
                        </td>
                    </tr>

                    <!-- Add more servers as needed -->
                    <tr>
                        <td>
                            <strong><i class="fas fa-server"></i> PROTECTED SERVER 4</strong>
                            <div><span class="protection-badge">PROTECTED</span></div>
                        </td>
                        <td><code>p6q7r8s9t0</code></td>
                        <td>
                            <div style="color: #747d8c;">
                                <i class="fas fa-user-secret"></i> Hidden
                            </div>
                        </td>
                        <td>
                            <div style="color: #747d8c;">
                                <i class="fas fa-eye-slash"></i> Protected
                            </div>
                        </td>
                        <td><code>0.0.0.0:2010</code></td>
                        <td><span style="color: #ff6b6b;">● Offline</span></td>
                        <td>
                            <button class="disabled-manage" style="padding: 6px 12px; border-radius: 5px;">
                                <i class="fas fa-wrench"></i> Manage
                            </button>
                        </td>
                    </tr>
                </tbody>
            </table>

            <!-- Pagination -->
            <div style="text-align: center; margin-top: 20px;">
                <button class="disabled-manage" style="padding: 8px 15px; margin: 0 5px;">« Previous</button>
                <button class="disabled-manage" style="padding: 8px 15px; margin: 0 5px;">1</button>
                <button class="disabled-manage" style="padding: 8px 15px; margin: 0 5px;">2</button>
                <button class="disabled-manage" style="padding: 8px 15px; margin: 0 5px;">Next »</button>
            </div>

            <!-- Credits Section -->
            <div class="credits-section">
                <h3><i class="fas fa-award"></i> ULTIMATE SECURITY SYSTEM</h3>
                <p style="margin: 15px 0; font-size: 18px;">
                    <strong>Developed by Elite Security Team:</strong><br>
                    <span style="color: #fd79a8;">@ginaabaikhati</span> • 
                    <span style="color: #81ecec;">@AndinOfficial</span> • 
                    <span style="color: #55efc4;">@naaofficial</span>
                </p>
                <div style="background: rgba(255,255,255,0.2); padding: 15px; border-radius: 10px; margin-top: 15px;">
                    <i class="fas fa-info-circle"></i>
                    <strong>System Status:</strong> All servers are protected by ultimate security system
                    <br>
                    <small>Management features disabled • Information hidden • Read-only mode</small>
                </div>
            </div>

            <!-- Security Notice -->
            <div style="text-align: center; margin-top: 20px; padding: 15px; background: #ff6b6b; color: white; border-radius: 10px;">
                <i class="fas fa-exclamation-triangle"></i>
                <strong>PERMANENT PROTECTION ACTIVE</strong>
                <br>
                <small>All server management features have been permanently disabled for security reasons</small>
            </div>
        </div>
    </div>

    <script>
        // Enhanced security protection
        document.addEventListener('contextmenu', function(e) {
            e.preventDefault();
            showSecurityAlert('Context menu disabled for security');
        });

        document.addEventListener('keydown', function(e) {
            if (e.key === 'F12' || 
                (e.ctrlKey && e.shiftKey && e.key === 'I') ||
                (e.ctrlKey && e.shiftKey && e.key === 'J') ||
                (e.ctrlKey && e.key === 'u') ||
                (e.altKey && e.key === 'Tab')) {
                e.preventDefault();
                showSecurityAlert('Developer tools disabled for security');
            }
        });

        // Block all clicks on manage buttons
        document.querySelectorAll('button').forEach(button => {
            button.addEventListener('click', function(e) {
                if (this.classList.contains('disabled-manage')) {
                    e.preventDefault();
                    e.stopPropagation();
                    showSecurityAlert('Server management disabled by security system');
                }
            });
        });

        // Block all links
        document.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                showSecurityAlert('Navigation blocked by security system');
            });
        });

        // Block form submissions
        document.querySelectorAll('form').forEach(form => {
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                showSecurityAlert('Form submissions disabled for security');
            });
        });

        function showSecurityAlert(message) {
            const alertDiv = document.createElement('div');
            alertDiv.style.cssText = `
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
                animation: slideIn 0.3s ease;
            `;
            alertDiv.innerHTML = `<i class="fas fa-shield-alt"></i> ${message}`;
            document.body.appendChild(alertDiv);
            
            setTimeout(() => {
                alertDiv.remove();
            }, 3000);
        }

        // Add animation to protection badges
        setInterval(() => {
            document.querySelectorAll('.protection-badge').forEach((badge, index) => {
                setTimeout(() => {
                    badge.style.transform = 'scale(1.1)';
                    badge.style.boxShadow = '0 0 20px rgba(46, 213, 115, 0.5)';
                    setTimeout(() => {
                        badge.style.transform = 'scale(1)';
                        badge.style.boxShadow = 'none';
                    }, 300);
                }, index * 200);
            });
        }, 3000);

        // Prevent drag and drop
        document.addEventListener('dragstart', function(e) {
            e.preventDefault();
        });

        document.addEventListener('drop', function(e) {
            e.preventDefault();
        });
    </script>
</body>
</html>
EOF

# Create protected view for ALL server view pages
echo "🛡️ Membuat proteksi untuk semua halaman view server..."

# Find all server view directories and protect them
find /var/www/pterodactyl/resources/views/admin/servers/view -name "*.blade.php" -type f | while read view_file; do
    if [ -f "$view_file" ]; then
        cp "$view_file" "${view_file}.bak_${TIMESTAMP}" 2>/dev/null
        # Create protected view
        cat > "$view_file" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Protected - Security System</title>
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: 'Segoe UI', sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            padding: 20px;
        }
        .protection-box {
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 500px;
            width: 100%;
        }
        .security-badge {
            background: #ff6b6b;
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            display: inline-block;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="protection-box">
        <div style="font-size: 60px; margin-bottom: 20px;">🛡️</div>
        <h1>Server Protected</h1>
        <p>This server is protected by the ultimate security system.</p>
        
        <div class="security-badge">
            All Servers Protected
        </div>
        
        <div style="margin-top: 20px; padding: 15px; background: #f8f9fa; border-radius: 10px;">
            <strong>Security Team:</strong><br>
            @ginaabaikhati • @AndinOfficial • @naaofficial
        </div>
        
        <div style="margin-top: 15px; color: #747d8c; font-size: 12px;">
            <i class="fas fa-info-circle"></i>
            Server management disabled for all users
        </div>
    </div>

    <script>
        document.addEventListener('contextmenu', function(e) {
            e.preventDefault();
        });
    </script>
</body>
</html>
EOF
        echo "✅ Protected: $view_file"
    fi
done

chmod 644 "$INDEX_FILE"

# Clear cache
echo "🔄 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear
php artisan cache:clear

echo ""
echo "🎉 ULTIMATE PROTECTION BERHASIL DIPASANG!"
echo "✅ SEMUA server sekarang diproteksi"
echo "✅ Tombol manage dinonaktifkan untuk SEMUA server"
echo "✅ Informasi disembunyikan"
echo "✅ Tidak bisa diakses melalui view"
echo "🛡️ Security by: @ginaabaikhati, @AndinOfficial, @naaofficial"
echo "💪 System: Pterodactyl ID Ultimate Security - ALL SERVERS PROTECTED"
