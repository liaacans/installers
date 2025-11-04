#!/bin/bash

echo "🗑️  Menghapus Security Panel Protection..."

# Path file yang dimodifikasi
PANEL_INDEX="/var/www/pterodactyl/resources/scripts/components/server/console/Console.tsx"
SERVER_LIST="/var/www/pterodactyl/resources/scripts/components/admin/servers/ServersContainer.tsx"
SIDEBAR_NAV="/var/www/pterodactyl/resources/scripts/components/admin/AdminSidebar.tsx"
DETAILS_SERVICE="/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php"

# Fungsi untuk restore backup
restore_backup() {
    local file_path=$1
    local latest_backup=$(ls -t "${file_path}.bak_"* 2>/dev/null | head -1)
    
    if [ -n "$latest_backup" ] && [ -f "$latest_backup" ]; then
        cp "$latest_backup" "$file_path"
        echo "✅ Restored: $file_path"
        rm "$latest_backup"
    else
        echo "⚠️  No backup found for: $file_path"
    fi
}

# Restore semua file dari backup
echo "🔄 Mengembalikan file original..."
restore_backup "$PANEL_INDEX"
restore_backup "$SERVER_LIST"
restore_backup "$SIDEBAR_NAV"
restore_backup "$DETAILS_SERVICE"

# Hapus juga backup dari installprotect9.sh jika ada
if [ -f "${DETAILS_SERVICE}.bak_"* ]; then
    rm -f "${DETAILS_SERVICE}.bak_"*
    echo "✅ Backup installprotect9.sh dihapus"
fi

echo "🎉 Uninstall Security Panel Protection selesai!"
echo "📝 Semua modifikasi telah dikembalikan ke state original"
echo "🔓 Panel sekarang dalam mode normal tanpa proteksi"
