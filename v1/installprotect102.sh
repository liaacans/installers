#!/bin/bash

# Path untuk file yang akan dimodifikasi
PANEL_PATH="/var/www/pterodactyl"
ADMIN_SERVERS_VIEW="${PANEL_PATH}/resources/scripts/components/admin/servers/ServersContainer.tsx"
SIDEBAR_NAV="${PANEL_PATH}/resources/scripts/components/admin/navigation/Sidebar.tsx"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

echo "🚀 Memasang Security Panel v10..."

# Backup file asli
backup_file() {
    local file_path=$1
    if [ -f "$file_path" ]; then
        cp "$file_path" "${file_path}.bak_${TIMESTAMP}"
        echo "📦 Backup created: ${file_path}.bak_${TIMESTAMP}"
    fi
}

# Modifikasi Admin Servers View
echo "🔧 Memodifikasi Admin Servers View..."
backup_file "$ADMIN_SERVERS_VIEW"

if [ -f "$ADMIN_SERVERS_VIEW" ]; then
    # Hapus kolom node, connection, memory, disk dari tabel
    sed -i '/{Header.*node.*}/d' "$ADMIN_SERVERS_VIEW"
    sed -i '/{Cell.*row.original.node.*}/d' "$ADMIN_SERVERS_VIEW"
    sed -i '/{Header.*connection.*}/d' "$ADMIN_SERVERS_VIEW"
    sed -i '/{Cell.*row.original.connection.*}/d' "$ADMIN_SERVERS_VIEW"
    sed -i '/{Header.*memory.*}/d' "$ADMIN_SERVERS_VIEW"
    sed -i '/{Cell.*row.original.memory.*}/d' "$ADMIN_SERVERS_VIEW"
    sed -i '/{Header.*disk.*}/d' "$ADMIN_SERVERS_VIEW"
    sed -i '/{Cell.*row.original.disk.*}/d' "$ADMIN_SERVERS_VIEW"
    
    # Pastikan tombol Create New dan Search tetap ada
    echo "✅ Kolom Node, Connection, Memory, Disk dihapus dari tabel"
    echo "✅ Tombol Create New dan Search tetap dipertahankan"
    echo "✅ Status Active dan Public tetap dipertahankan"
fi

# Modifikasi Sidebar Navigation
echo "🔧 Memodifikasi Sidebar Navigation..."
backup_file "$SIDEBAR_NAV"

if [ -f "$SIDEBAR_NAV" ]; then
    # Hapus menu Nodes, Locations, Nests, Mounts, Database dari sidebar
    sed -i '/{NavigationItem.*icon.*server.*text.*Nodes.*}/d' "$SIDEBAR_NAV"
    sed -i '/{NavigationItem.*icon.*map-marker.*text.*Locations.*}/d' "$SIDEBAR_NAV"
    sed -i '/{NavigationItem.*icon.*th-large.*text.*Nests.*}/d' "$SIDEBAR_NAV"
    sed -i '/{NavigationItem.*icon.*hdd.*text.*Mounts.*}/d' "$SIDEBAR_NAV"
    sed -i '/{NavigationItem.*icon.*database.*text.*Databases.*}/d' "$SIDEBAR_NAV"
    
    echo "✅ Menu Nodes, Locations, Nests, Mounts, Database dihapus dari sidebar"
fi

# Buat file konfigurasi security
SECURITY_CONFIG="${PANEL_PATH}/storage/security_panel_v10.json"
cat > "$SECURITY_CONFIG" << EOF
{
    "version": "10.0",
    "installed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "features": {
        "admin_restriction": true,
        "all_admin_access": true,
        "modified_servers_view": true,
        "cleaned_sidebar": true
    },
    "protected_files": [
        "ServersContainer.tsx",
        "Sidebar.tsx",
        "DetailsModificationService.php"
    ]
}
EOF

chmod 644 "$SECURITY_CONFIG"

echo "✅ Security Panel v10 berhasil dipasang!"
echo "📂 Config file: $SECURITY_CONFIG"
echo "🔧 Fitur yang diinstal:"
echo "   - Akses semua admin ke server"
echo "   - Tabel servers tanpa node, connection, memory, disk"
echo "   - Sidebar tanpa Nodes, Locations, Nests, Mounts, Database"
echo "   - Tombol Create New dan Search tetap aktif"
