#!/bin/bash

# File paths untuk uninstall proteksi
PATHS=(
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Servers/ServerViewController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/NodesController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/NodeController.php"
    "/var/www/pterodactyl/resources/views/admin/servers/view.blade.php"
    "/var/www/pterodactyl/resources/views/admin/nodes/index.blade.php"
)

TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
RESTORE_DIR="/root/pterodactyl-backups/restore_${TIMESTAMP}"

echo "🔄 Memulai proses uninstall proteksi Admin Panel v10..."

# Buat direktori restore
mkdir -p "$RESTORE_DIR"
echo "📁 Direktori restore: $RESTORE_DIR"

for REMOTE_PATH in "${PATHS[@]}"; do
    if [ -f "$REMOTE_PATH" ]; then
        # Cari backup file terbaru
        BACKUP_FILE=$(ls -t "${REMOTE_PATH}".bak_* 2>/dev/null | head -n1)
        
        if [ -n "$BACKUP_FILE" ] && [ -f "$BACKUP_FILE" ]; then
            # Backup file modifikasi saat ini
            cp "$REMOTE_PATH" "$RESTORE_DIR/$(basename $REMOTE_PATH).current_${TIMESTAMP}"
            
            # Restore dari backup
            cp "$BACKUP_FILE" "$REMOTE_PATH"
            echo "✅ Berhasil restore: $(basename $REMOTE_PATH)"
            echo "   dari backup: $(basename $BACKUP_FILE)"
        else
            # Jika tidak ada backup, simpan file current ke restore dir
            cp "$REMOTE_PATH" "$RESTORE_DIR/$(basename $REMOTE_PATH).current_${TIMESTAMP}"
            echo "⚠️  Tidak ada backup ditemukan untuk: $(basename $REMOTE_PATH)"
            echo "   File current disimpan di restore directory"
        fi
    else
        echo "❌ File tidak ditemukan: $REMOTE_PATH"
    fi
done

# Clear view cache
echo "🧹 Membersihkan cache view..."
php /var/www/pterodactyl/artisan view:clear 2>/dev/null || echo "⚠️ Gagal clear view cache"
php /var/www/pterodactyl/artisan cache:clear 2>/dev/null || echo "⚠️ Gagal clear cache"

echo ""
echo "🎉 Uninstall proteksi berhasil dilakukan!"
echo "📂 File original telah di-restore dari backup"
echo "📁 File modifikasi disimpan di: $RESTORE_DIR"
echo ""
echo "📋 Status restore:"
for REMOTE_PATH in "${PATHS[@]}"; do
    if [ -f "$REMOTE_PATH" ]; then
        BACKUP_FILE=$(ls -t "${REMOTE_PATH}".bak_* 2>/dev/null | head -n1)
        if [ -n "$BACKUP_FILE" ]; then
            echo "   ✅ $(basename $REMOTE_PATH) - RESTORED"
        else
            echo "   ⚠️  $(basename $REMOTE_PATH) - NO BACKUP (current saved)"
        fi
    else
        echo "   ❌ $(basename $REMOTE_PATH) - NOT FOUND"
    fi
done
echo ""
echo "🔓 Akses Admin Panel sekarang sudah kembali normal"
