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

# Tampilkan alert HTML untuk konfirmasi uninstall
cat << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Uninstall Complete - Security Panel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .uninstall-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="uninstall-card p-5 text-center">
                    <div class="mb-4">
                        <i class="fas fa-trash-alt fa-4x text-danger mb-3"></i>
                        <h2 class="text-danger">Uninstall Complete</h2>
                    </div>
                    
                    <div class="alert alert-success mb-4">
                        <i class="fas fa-check-circle me-2"></i>
                        <strong>Security Panel Protection v2.0</strong> has been successfully uninstalled
                    </div>
                    
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        <strong>Note:</strong> Core server protection (installprotect9.sh) remains active
                    </div>
                    
                    <div class="mt-4">
                        <a href="/admin" class="btn btn-primary">
                            <i class="fas fa-arrow-left me-2"></i>
                            Back to Admin Panel
                        </a>
                    </div>
                    
                    <div class="mt-4 text-muted">
                        <small>
                            <i class="fas fa-shield-alt me-1"></i>
                            Protected by @ginaabaikhati
                        </small>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
EOF
