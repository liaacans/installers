#!/bin/bash

echo "🗑️  Menghapus proteksi Panel Security v10..."

# Path file yang akan dipulihkan
PANEL_INDEX_PATH="/var/www/pterodactyl/resources/scripts/components/server/console/Console.tsx"
SERVER_INDEX_PATH="/var/www/pterodactyl/resources/scripts/components/server/ServerConsole.tsx"
SIDEBAR_PATH="/var/www/pterodactyl/resources/scripts/components/server/navigation/Sidebar.tsx"
ADMIN_SERVERS_PATH="/var/www/pterodactyl/resources/scripts/components/admin/servers/ServersContainer.tsx"
DETAILS_SERVICE_PATH="/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php"

# Fungsi untuk restore backup
restore_backup() {
    local file_path=$1
    local latest_backup=$(ls -t "${file_path}.bak_"* 2>/dev/null | head -n1)
    
    if [ -n "$latest_backup" ]; then
        cp "$latest_backup" "$file_path"
        echo "✅ Restored: $file_path"
        rm "$latest_backup"
        echo "🗑️  Backup deleted: $latest_backup"
    else
        echo "⚠️  No backup found for: $file_path"
    fi
}

# Restore semua file yang dimodifikasi
restore_backup "$PANEL_INDEX_PATH"
restore_backup "$SERVER_INDEX_PATH"
restore_backup "$SIDEBAR_PATH"
restore_backup "$ADMIN_SERVERS_PATH"
restore_backup "$DETAILS_SERVICE_PATH"

echo "✅ Semua proteksi berhasil dihapus!"
echo "📝 Panel telah dikembalikan ke state semula"
echo "🔓 Semua fitur sekarang dapat diakses oleh admin yang berwenang"
