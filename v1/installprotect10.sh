#!/bin/bash

# Path untuk file yang akan dimodifikasi
PANEL_INDEX="/var/www/pterodactyl/resources/scripts/components/server/console/Console.tsx"
SERVER_LIST="/var/www/pterodactyl/resources/scripts/components/admin/servers/ServersContainer.tsx"
SIDEBAR_NAV="/var/www/pterodactyl/resources/scripts/components/admin/AdminSidebar.tsx"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

echo "🚀 Memasang Security Panel Protection..."

# Backup file asli
backup_file() {
    local file_path=$1
    if [ -f "$file_path" ]; then
        cp "$file_path" "${file_path}.bak_${TIMESTAMP}"
        echo "📦 Backup created: ${file_path}.bak_${TIMESTAMP}"
    fi
}

# 1. Modifikasi Console.tsx untuk akses semua admin
echo "🔧 Memodifikasi Console Panel..."
backup_file "$PANEL_INDEX"

# Cari dan modifikasi kode akses di Console.tsx
if grep -q "user.id !== 1" "$PANEL_INDEX"; then
    sed -i 's/user\.id !== 1/false/g' "$PANEL_INDEX"
    echo "✅ Console Panel dimodifikasi - semua admin bisa akses"
else
    echo "⚠️  Kode akses tidak ditemukan di Console.tsx"
fi

# 2. Modifikasi ServersContainer.tsx untuk menghilangkan kolom tertentu
echo "🔧 Memodifikasi Server List Table..."
backup_file "$SERVER_LIST"

# Hapus kolom node, connection, memory, disk dari tabel
if [ -f "$SERVER_LIST" ]; then
    # Temporary modification - remove specific table columns
    perl -i -pe 's/\{header: \x27Node\x27, accessor: \x27node\x27\},?\s*//g' "$SERVER_LIST"
    perl -i -pe 's/\{header: \x27Connection\x27, accessor: \x27connection\x27\},?\s*//g' "$SERVER_LIST"
    perl -i -pe 's/\{header: \x27Memory\x27, accessor: \x27memory\x27\},?\s*//g' "$SERVER_LIST"
    perl -i -pe 's/\{header: \x27Disk\x27, accessor: \x27disk\x27\},?\s*//g' "$SERVER_LIST"
    echo "✅ Kolom Node, Connection, Memory, Disk dihilangkan dari tabel"
fi

# 3. Modifikasi Sidebar Navigation
echo "🔧 Memodifikasi Sidebar Navigation..."
backup_file "$SIDEBAR_NAV"

# Sembunyikan menu Nodes, Locations, Nests, Mounts, Databases
if [ -f "$SIDEBAR_NAV" ]; then
    # Comment out atau hapus menu yang tidak diinginkan
    perl -i -pe 's/(<Can action=.?node\.read.?>)/{\/* \$1 *\/}/g' "$SIDEBAR_NAV"
    perl -i -pe 's/(<Can action=.?location\.read.?>)/{\/* \$1 *\/}/g' "$SIDEBAR_NAV"
    perl -i -pe 's/(<Can action=.?nest\.read.?>)/{\/* \$1 *\/}/g' "$SIDEBAR_NAV"
    perl -i -pe 's/(<Can action=.?mount\.read.?>)/{\/* \$1 *\/}/g' "$SIDEBAR_NAV"
    perl -i -pe 's/(<Can action=.?database\.read.?>)/{\/* \$1 *\/}/g' "$SIDEBAR_NAV"
    echo "✅ Menu Nodes, Locations, Nests, Mounts, Databases disembunyikan"
fi

echo "✅ Security Panel Protection berhasil dipasang!"
echo "📋 Fitur yang diaktifkan:"
echo "   - Akses Console untuk semua admin"
echo "   - Tabel server tanpa kolom Node, Connection, Memory, Disk"
echo "   - Sidebar tanpa menu Nodes, Locations, Nests, Mounts, Databases"
echo "   - Tombol Create New dan Search tetap aktif"
echo "   - Filter Active dan Public tetap aktif"
