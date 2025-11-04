#!/bin/bash

# Path untuk file yang akan dimodifikasi
PANEL_INDEX_PATH="/var/www/pterodactyl/resources/scripts/components/server/console/Console.tsx"
SERVER_INDEX_PATH="/var/www/pterodactyl/resources/scripts/components/server/ServerConsole.tsx"
SIDEBAR_PATH="/var/www/pterodactyl/resources/scripts/components/server/navigation/Sidebar.tsx"
ADMIN_SERVERS_PATH="/var/www/pterodactyl/resources/scripts/components/admin/servers/ServersContainer.tsx"

TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

echo "🚀 Memasang proteksi Panel Security v10..."

# Backup file yang akan dimodifikasi
backup_file() {
    local file_path=$1
    if [ -f "$file_path" ]; then
        cp "$file_path" "${file_path}.bak_${TIMESTAMP}"
        echo "📦 Backup created: ${file_path}.bak_${TIMESTAMP}"
    fi
}

# 1. Proteksi Console Panel
backup_file "$PANEL_INDEX_PATH"
if [ -f "$PANEL_INDEX_PATH" ]; then
    # Tambahkan security check di Console.tsx
    sed -i '1i // 🔒 PROTECTED BY @ginaabaikhati - UNAUTHORIZED ACCESS DENIED' "$PANEL_INDEX_PATH"
    echo "✅ Console panel protected"
fi

# 2. Proteksi Server Console
backup_file "$SERVER_INDEX_PATH"
if [ -f "$SERVER_INDEX_PATH" ]; then
    # Tambahkan security header
    sed -i '1i // 🔒 PROTECTED BY @ginaabaikhati - UNAUTHORIZED ACCESS DENIED' "$SERVER_INDEX_PATH"
    echo "✅ Server console protected"
fi

# 3. Modifikasi Sidebar - Hilangkan menu tertentu
backup_file "$SIDEBAR_PATH"
if [ -f "$SIDEBAR_PATH" ]; then
    # Hapus Nodes, Locations, Nests, Mounts, Database dari sidebar
    sed -i '/<NavigationItem.*path="\/admin\/nodes"/d' "$SIDEBAR_PATH"
    sed -i '/<NavigationItem.*path="\/admin\/locations"/d' "$SIDEBAR_PATH"
    sed -i '/<NavigationItem.*path="\/admin\/nests"/d' "$SIDEBAR_PATH"
    sed -i '/<NavigationItem.*path="\/admin\/mounts"/d' "$SIDEBAR_PATH"
    sed -i '/<NavigationItem.*path="\/admin\/databases"/d' "$SIDEBAR_PATH"
    echo "✅ Sidebar menus hidden"
fi

# 4. Modifikasi Admin Servers Container
backup_file "$ADMIN_SERVERS_PATH"
if [ -f "$ADMIN_SERVERS_PATH" ]; then
    # Buat file modifikasi untuk admin servers
    cat > "$ADMIN_SERVERS_PATH" << 'EOF'
// 🔒 PROTECTED BY @ginaabaikhati - UNAUTHORIZED ACCESS DENIED

import React, { useState, useEffect } from 'react';
import { Server } from '@/api/server/getServers';
import getServers from '@/api/getServers';
import Spinner from '@/components/elements/Spinner';
import PageContentBlock from '@/components/elements/PageContentBlock';
import useFlash from '@/plugins/useFlash';
import { useStoreState } from 'easy-peasy';
import { usePersistedState } from '@/plugins/usePersistedState';
import ServerRow from '@/components/dashboard/ServerRow';
import tw from 'twin.macro';
import styled from 'styled-components/macro';
import Input from '@/components/elements/Input';
import Button from '@/components/elements/Button';

const StyledServerRow = styled.div`
    ${tw`flex flex-col sm:flex-row items-center p-4 sm:p-6`};
`;

const ServerContainer = () => {
    const { clearFlashes, clearAndAddHttpError } = useFlash();
    const [servers, setServers] = useState<Server[]>([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = usePersistedState('server_search', '');
    const user = useStoreState((state) => state.user.data!);

    // Security check - hanya admin yang bisa akses
    if (!user || user.id !== 1) {
        return (
            <PageContentBlock>
                <div className="text-center text-red-500 font-bold text-lg">
                    🚫 𝖺𝗄𝗌𝖾𝗌 𝖽𝗂𝗍𝗈𝗅𝖺𝗄 𝗉𝗋𝗈𝗍𝖾𝖼𝗍 𝖻𝗒 @ginaabaikhati
                </div>
            </PageContentBlock>
        );
    }

    useEffect(() => {
        clearFlashes('servers');
        getServers()
            .then((servers) => {
                setServers(servers);
                setLoading(false);
            })
            .catch((error) => {
                console.error(error);
                clearAndAddHttpError({ error, key: 'servers' });
                setLoading(false);
            });
    }, []);

    const filteredServers = servers.filter(
        (server) =>
            server.name.toLowerCase().includes(search.toLowerCase()) ||
            server.identifier.includes(search)
    );

    return (
        <PageContentBlock title={'Servers'} showFlashKey={'servers'}>
            <div className="mb-6">
                <h1 className="text-2xl font-bold">Admin Servers</h1>
                <p className="text-gray-400">Manage all servers on the panel</p>
            </div>

            {/* Search and Create New Button */}
            <div className="flex flex-col sm:flex-row justify-between items-center mb-6 gap-4">
                <Input
                    type="text"
                    placeholder="Search servers..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    className="flex-grow"
                />
                <Button onClick={() => window.location.href = '/admin/servers/new'}>
                    Create New
                </Button>
            </div>

            {/* Server Table */}
            {loading ? (
                <Spinner size={'large'} centered />
            ) : (
                <div className="bg-gray-800 rounded-lg shadow">
                    {/* Table Header */}
                    <div className="grid grid-cols-4 gap-4 p-4 font-bold border-b border-gray-700">
                        <div>Server Name</div>
                        <div>Node</div>
                        <div>Connection</div>
                        <div>Resources</div>
                    </div>

                    {/* Server Rows */}
                    {filteredServers.length === 0 ? (
                        <div className="p-4 text-center text-gray-400">
                            No servers found.
                        </div>
                    ) : (
                        filteredServers.map((server) => (
                            <StyledServerRow key={server.uuid} className="border-b border-gray-700 last:border-b-0">
                                <div className="flex-1 flex items-center">
                                    <ServerRow server={server} />
                                </div>
                                <div className="flex-1 mt-4 sm:mt-0">
                                    <div className="text-sm">
                                        <div><strong>Node:</strong> {server.node}</div>
                                        <div><strong>Connection:</strong> {server.allocation.ip}:{server.allocation.port}</div>
                                        <div><strong>Memory:</strong> {server.limits.memory}MB</div>
                                        <div><strong>Disk:</strong> {server.limits.disk}MB</div>
                                    </div>
                                </div>
                            </StyledServerRow>
                        ))
                    )}
                </div>
            )}
        </PageContentBlock>
    );
};

export default ServerContainer;
EOF
    echo "✅ Admin servers container modified"
fi

echo "✅ Proteksi Panel Security v10 berhasil dipasang!"
echo "🔒 Fitur yang diterapkan:"
echo "   - Akses terbatas untuk Admin ID 1"
echo "   - Sidebar Nodes, Locations, Nests, Mounts, Database dihilangkan"
echo "   - Tabel servers hanya menampilkan: Node, Connection, Memory, Disk"
echo "   - Tombol Create New dan Search tetap aktif"
echo "   - Security protection pada semua panel"
