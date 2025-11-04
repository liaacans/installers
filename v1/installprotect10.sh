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
    # Method 1: Hapus dengan pattern matching
    sed -i '/{header: .Node., accessor: .node.},/d' "$SERVER_LIST"
    sed -i '/{header: .Connection., accessor: .connection.},/d' "$SERVER_LIST"
    sed -i '/{header: .Memory., accessor: .memory.},/d' "$SERVER_LIST"
    sed -i '/{header: .Disk., accessor: .disk.},/d' "$SERVER_LIST"
    
    # Method 2: Hapus dengan regex
    perl -i -pe 's/\s*\{[^}]*header\s*:\s*["'"'"']Node["'"'"'][^}]*\},?\s*//g' "$SERVER_LIST"
    perl -i -pe 's/\s*\{[^}]*header\s*:\s*["'"'"']Connection["'"'"'][^}]*\},?\s*//g' "$SERVER_LIST"
    perl -i -pe 's/\s*\{[^}]*header\s*:\s*["'"'"']Memory["'"'"'][^}]*\},?\s*//g' "$SERVER_LIST"
    perl -i -pe 's/\s*\{[^}]*header\s*:\s*["'"'"']Disk["'"'"'][^}]*\},?\s*//g' "$SERVER_LIST"
    
    echo "✅ Kolom Node, Connection, Memory, Disk dihilangkan dari tabel"
fi

# 3. Modifikasi Sidebar Navigation - MENGHAPUS TOTAL MENU
echo "🔧 Menghapus Menu Sidebar Navigation..."
backup_file "$SIDEBAR_NAV"

if [ -f "$SIDEBAR_NAV" ]; then
    # Method 1: Comment out seluruh section menu yang tidak diinginkan
    perl -i -pe 's/(<Can action=.?database\.[^>]*>[\s\S]*?<\/Can>)/{\/* \$1 *\/}/g' "$SIDEBAR_NAV"
    perl -i -pe 's/(<Can action=.?location\.[^>]*>[\s\S]*?<\/Can>)/{\/* \$1 *\/}/g' "$SIDEBAR_NAV"
    perl -i -pe 's/(<Can action=.?node\.[^>]*>[\s\S]*?<\/Can>)/{\/* \$1 *\/}/g' "$SIDEBAR_NAV"
    perl -i -pe 's/(<Can action=.?mount\.[^>]*>[\s\S]*?<\/Can>)/{\/* \$1 *\/}/g' "$SIDEBAR_NAV"
    perl -i -pe 's/(<Can action=.?nest\.[^>]*>[\s\S]*?<\/Can>)/{\/* \$1 *\/}/g' "$SIDEBAR_NAV"
    
    # Method 2: Hapus langsung seluruh line yang mengandung menu tersebut
    sed -i '/databases/Id' "$SIDEBAR_NAV"
    sed -i '/locations/Id' "$SIDEBAR_NAV"
    sed -i '/nodes/Id' "$SIDEBAR_NAV"
    sed -i '/mounts/Id' "$SIDEBAR_NAV"
    sed -i '/nests/Id' "$SIDEBAR_NAV"
    
    # Method 3: Hapus berdasarkan icon atau text
    sed -i '/fa-database/Id' "$SIDEBAR_NAV"
    sed -i '/fa-globe/Id' "$SIDEBAR_NAV"
    sed -i '/fa-server/Id' "$SIDEBAR_NAV"
    sed -i '/fa-hdd/Id' "$SIDEBAR_NAV"
    sed -i '/fa-cube/Id' "$SIDEBAR_NAV"
    
    echo "✅ Menu Databases, Locations, Nodes, Mounts, Nests DIHAPUS TOTAL dari sidebar"
fi

# 4. Clear cache dan rebuild assets
echo "🔄 Membersihkan cache dan rebuild assets..."
cd /var/www/pterodactyl

# Clear cache
php artisan cache:clear
php artisan view:clear

# Build assets jika yarn tersedia
if command -v yarn &> /dev/null; then
    yarn build:production
    echo "✅ Assets rebuilt dengan yarn"
else
    echo "⚠️  Yarn tidak tersedia, skip build assets"
fi

echo "✅ Security Panel Protection berhasil dipasang!"
echo "📋 Fitur yang diaktifkan:"
echo "   - Akses Console untuk semua admin"
echo "   - Tabel server tanpa kolom Node, Connection, Memory, Disk"
echo "   - Sidebar TANPA menu: Databases, Locations, Nodes, Mounts, Nests"
echo "   - Tombol Create New dan Search tetap aktif"
echo "   - Filter Active dan Public tetap aktif"
echo "   - Cache cleared dan assets rebuilt"
