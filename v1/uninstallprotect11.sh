#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeViewController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

echo "🗑️ Menghapus proteksi Admin Nodes Security Panel..."

# Cari backup file terbaru
LATEST_BACKUP=$(ls -t $BACKUP_PATTERN 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "📦 Restore backup dari: $LATEST_BACKUP"
    mv "$LATEST_BACKUP" "$REMOTE_PATH"
    chmod 644 "$REMOTE_PATH"
    echo "✅ File controller berhasil di-restore!"
else
    echo "⚠️ Tidak ditemukan backup file, menghapus file modifikasi..."
    if [ -f "$REMOTE_PATH" ]; then
        rm -f "$REMOTE_PATH"
        echo "✅ File modifikasi dihapus!"
    else
        echo "ℹ️ File tidak ditemukan, mungkin sudah dihapus."
    fi
fi

# Hapus CSS security
SECURITY_CSS_PATH="/var/www/pterodactyl/public/themes/pterodactyl/css/security-panel.css"
if [ -f "$SECURITY_CSS_PATH" ]; then
    rm -f "$SECURITY_CSS_PATH"
    echo "✅ Security CSS dihapus!"
fi

# Hapus reference CSS dari layout
LAYOUT_PATH="/var/www/pterodactyl/resources/views/layouts/admin.blade.php"
if [ -f "$LAYOUT_PATH" ]; then
    sed -i '/security-panel.css/d' "$LAYOUT_PATH"
    echo "✅ Security CSS reference dihapus dari layout!"
fi

# Restore view nodes original (opsional - perlu manual restore jika ingin original)
NODES_VIEW_DIR="/var/www/pterodactyl/resources/views/admin/nodes/view"
if [ -d "$NODES_VIEW_DIR" ]; then
    echo "⚠️ View nodes modified perlu di-restore manual dari backup"
    echo "📍 Lokasi: $NODES_VIEW_DIR"
fi

echo "♻️ Uninstall proteksi nodes selesai!"
echo "🔓 Semua fitur nodes sekarang dapat diakses normal oleh admin yang berwenang"
