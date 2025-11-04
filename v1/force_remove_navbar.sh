#!/bin/bash

echo "🔥 FORCE REMOVE NAVBAR MENU"

SIDEBAR_NAV="/var/www/pterodactyl/resources/scripts/components/admin/AdminSidebar.tsx"

if [ -f "$SIDEBAR_NAV" ]; then
    echo "🗑️  Menghapus menu navbar secara paksa..."
    
    # Backup dulu
    TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
    cp "$SIDEBAR_NAV" "${SIDEBAR_NAV}.force_backup_${TIMESTAMP}"
    
    # Hapus semua mention dari menu yang tidak diinginkan
    # Method extreme: Hapus seluruh section management kecuali servers dan users
    perl -i -pe 's/{[^{}]*databases[^{}]*}/{}/g' "$SIDEBAR_NAV"
    perl -i -pe 's/{[^{}]*locations[^{}]*}/{}/g' "$SIDEBAR_NAV"
    perl -i -pe 's/{[^{}]*nodes[^{}]*}/{}/g' "$SIDEBAR_NAV"
    perl -i -pe 's/{[^{}]*mounts[^{}]*}/{}/g' "$SIDEBAR_NAV"
    perl -i -pe 's/{[^{}]*nests[^{}]*}/{}/g' "$SIDEBAR_NAV"
    
    # Hapus empty lines berlebihan
    sed -i '/^[[:space:]]*$/d' "$SIDEBAR_NAV"
    
    echo "✅ Force remove completed!"
    echo "📂 Backup: ${SIDEBAR_NAV}.force_backup_${TIMESTAMP}"
else
    echo "❌ File sidebar tidak ditemukan: $SIDEBAR_NAV"
fi
