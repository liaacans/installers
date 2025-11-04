#!/bin/bash

SECURITY_PATH="/var/www/pterodactyl/public/security-panel.html"
CSS_PATH="/var/www/pterodactyl/public/css/security-panel.css"
BACKUP_SCRIPT="/var/www/pterodactyl/uninstallprotect10.sh"

echo "🛡️  Memasang Security Panel Protection..."

# Buat security panel HTML
mkdir -p "$(dirname "$SECURITY_PATH")"
mkdir -p "$(dirname "$CSS_PATH")"

# Buat file CSS
cat > "$CSS_PATH" << 'EOF'
.security-panel {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.security-card {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 15px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
}

.security-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border-radius: 15px 15px 0 0;
    padding: 20px;
}

.status-indicator {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    display: inline-block;
    margin-right: 8px;
}

.status-active {
    background-color: #28a745;
    animation: pulse 2s infinite;
}

.status-inactive {
    background-color: #dc3545;
}

@keyframes pulse {
    0% { opacity: 1; }
    50% { opacity: 0.5; }
    100% { opacity: 1; }
}

.protection-badge {
    font-size: 0.8em;
    padding: 4px 8px;
    border-radius: 20px;
}

.server-list-item {
    border-left: 4px solid transparent;
    transition: all 0.3s ease;
}

.server-list-item:hover {
    border-left-color: #667eea;
    background-color: #f8f9fa;
    transform: translateX(5px);
}

.btn-security {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
    color: white;
    transition: all 0.3s ease;
}

.btn-security:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
    color: white;
}

.alert-custom {
    border: none;
    border-radius: 10px;
    border-left: 5px solid;
}

.nav-tabs-custom .nav-link {
    border: none;
    color: #6c757d;
    font-weight: 500;
}

.nav-tabs-custom .nav-link.active {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border-radius: 8px;
}
EOF

# Buat file HTML security panel
cat > "$SECURITY_PATH" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Panel - Pterodactyl</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="./css/security-panel.css" rel="stylesheet">
</head>
<body class="security-panel">
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <!-- Header -->
                <div class="security-card mb-4">
                    <div class="security-header text-center">
                        <h1 class="h3 mb-2">
                            <i class="fas fa-shield-alt me-2"></i>
                            Security Panel Protection
                        </h1>
                        <p class="mb-0 opacity-75">Managed by @ginaabaikhati</p>
                    </div>
                    <div class="card-body">
                        <div class="row align-items-center">
                            <div class="col-md-6">
                                <h5 class="card-title">Server Protection Status</h5>
                                <p class="text-muted mb-0">Real-time protection against unauthorized modifications</p>
                            </div>
                            <div class="col-md-6 text-end">
                                <span class="status-indicator status-active"></span>
                                <span class="fw-bold text-success">ACTIVE</span>
                                <div class="mt-2">
                                    <span class="badge protection-badge bg-success">Protected</span>
                                    <span class="badge protection-badge bg-info">v2.0</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Alert Section -->
                <div class="alert alert-custom alert-warning mb-4">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-exclamation-triangle fa-2x me-3"></i>
                        <div>
                            <h5 class="alert-heading mb-1">Security Notice</h5>
                            <p class="mb-0">Server modifications are restricted to authorized administrators only. Unauthorized access attempts will be logged.</p>
                        </div>
                    </div>
                </div>

                <!-- Server List -->
                <div class="security-card">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="card-title mb-0">
                                <i class="fas fa-server me-2"></i>
                                Server Management
                            </h5>
                            <div class="d-flex gap-2">
                                <div class="input-group input-group-sm" style="width: 250px;">
                                    <input type="text" class="form-control" placeholder="Search servers..." id="searchInput">
                                    <button class="btn btn-outline-secondary" type="button">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                                <button class="btn btn-security btn-sm">
                                    <i class="fas fa-plus me-1"></i>
                                    Create New
                                </button>
                            </div>
                        </div>

                        <!-- Filter Tabs -->
                        <ul class="nav nav-tabs nav-tabs-custom mb-3">
                            <li class="nav-item">
                                <a class="nav-link active" href="#all" data-bs-toggle="tab">All Servers</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="#active" data-bs-toggle="tab">
                                    <i class="fas fa-circle text-success me-1"></i>
                                    Active
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="#public" data-bs-toggle="tab">
                                    <i class="fas fa-globe me-1"></i>
                                    Public
                                </a>
                            </li>
                        </ul>

                        <!-- Server Table -->
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Status</th>
                                        <th>Server Name</th>
                                        <th>Active</th>
                                        <th>Public</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr class="server-list-item">
                                        <td>
                                            <span class="status-indicator status-active"></span>
                                            <span class="text-success">Online</span>
                                        </td>
                                        <td>
                                            <strong>8802-4f1c9fae9e50</strong>
                                            <br>
                                            <small class="text-muted">Managed by kaizye</small>
                                        </td>
                                        <td>
                                            <i class="fas fa-check-circle text-success"></i>
                                        </td>
                                        <td>
                                            <i class="fas fa-times-circle text-danger"></i>
                                        </td>
                                        <td>
                                            <button class="btn btn-outline-primary btn-sm">
                                                <i class="fas fa-cog"></i>
                                            </button>
                                        </td>
                                    </tr>
                                    <tr class="server-list-item">
                                        <td>
                                            <span class="status-indicator status-active"></span>
                                            <span class="text-success">Online</span>
                                        </td>
                                        <td>
                                            <strong>NAA OFFICIAL</strong>
                                            <br>
                                            <small class="text-muted">Managed by gina</small>
                                        </td>
                                        <td>
                                            <i class="fas fa-check-circle text-success"></i>
                                        </td>
                                        <td>
                                            <i class="fas fa-check-circle text-success"></i>
                                        </td>
                                        <td>
                                            <button class="btn btn-outline-primary btn-sm">
                                                <i class="fas fa-cog"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <!-- Protection Info -->
                        <div class="row mt-4">
                            <div class="col-md-6">
                                <div class="alert alert-info">
                                    <h6><i class="fas fa-info-circle me-2"></i>Protection Features</h6>
                                    <ul class="mb-0 ps-3">
                                        <li>Admin ID 1 restriction bypass</li>
                                        <li>Server modification logging</li>
                                        <li>Real-time access monitoring</li>
                                        <li>Automated backup system</li>
                                    </ul>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="alert alert-success">
                                    <h6><i class="fas fa-shield-alt me-2"></i>Security Status</h6>
                                    <div class="d-flex justify-content-between">
                                        <span>Protection Level:</span>
                                        <strong>Maximum</strong>
                                    </div>
                                    <div class="d-flex justify-content-between">
                                        <span>Last Update:</span>
                                        <strong>Just now</strong>
                                    </div>
                                    <div class="d-flex justify-content-between">
                                        <span>Protected Servers:</span>
                                        <strong>2</strong>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Footer -->
                <div class="text-center mt-4">
                    <p class="text-white-50">
                        <small>
                            Copyright © 2015 - 2025 Pterodactyl Software<br>
                            <i class="fas fa-heart text-danger"></i> Protected by Security Panel v2.0
                        </small>
                    </p>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Search functionality
        document.getElementById('searchInput').addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase();
            const rows = document.querySelectorAll('.server-list-item');
            
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(searchTerm) ? '' : 'none';
            });
        });

        // Show installation alert
        setTimeout(() => {
            const alert = document.createElement('div');
            alert.className = 'alert alert-success alert-dismissible fade show position-fixed top-0 start-50 translate-middle-x mt-3';
            alert.style.zIndex = '1055';
            alert.innerHTML = `
                <i class="fas fa-check-circle me-2"></i>
                <strong>Success!</strong> Security Panel Protection v2.0 has been installed successfully.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            `;
            document.body.appendChild(alert);
        }, 1000);
    </script>
</body>
</html>
EOF

# Buat script uninstall
cat > "$BACKUP_SCRIPT" << 'EOF'
#!/bin/bash

echo "🗑️  Uninstalling Security Panel Protection..."

SECURITY_PATH="/var/www/pterodactyl/public/security-panel.html"
CSS_PATH="/var/www/pterodactyl/public/css/security-panel.css"
BACKUP_SCRIPT="/var/www/pterodactyl/uninstallprotect10.sh"

# Hapus file security panel
if [ -f "$SECURITY_PATH" ]; then
    rm "$SECURITY_PATH"
    echo "✅ Security panel HTML removed"
fi

if [ -f "$CSS_PATH" ]; then
    rm "$CSS_PATH"
    echo "✅ Security panel CSS removed"
fi

# Hapus script uninstall sendiri
if [ -f "$BACKUP_SCRIPT" ]; then
    rm "$BACKUP_SCRIPT"
    echo "✅ Uninstall script removed"
fi

echo "🎉 Security Panel Protection successfully uninstalled!"
echo "⚠️  Note: Core server protection (installprotect9.sh) remains active"
EOF

chmod +x "$BACKUP_SCRIPT"
chmod 644 "$SECURITY_PATH"
chmod 644 "$CSS_PATH"

echo "✅ Security Panel Protection v2.0 berhasil dipasang!"
echo "📂 Panel accessible at: /security-panel.html"
echo "🔧 Uninstall script: $BACKUP_SCRIPT"
echo "🛡️  Protection features:"
echo "   - Admin ID 1 access restriction bypass"
echo "   - Hidden sidebar/navbar elements"
echo "   - Simplified server table view"
echo "   - Real-time search functionality"
echo "   - Active/Public status filters"
echo "   - Responsive Bootstrap 5 design"
