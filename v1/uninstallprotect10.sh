#!/bin/bash

echo "🗑️ Menghapus proteksi Admin Nodes View..."

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/NodesViewController.php"
BACKUP_FILES=($(ls -t /var/www/pterodactyl/app/Http/Controllers/Admin/NodesViewController.php.bak_* 2>/dev/null))

if [ ${#BACKUP_FILES[@]} -eq 0 ]; then
  echo "❌ Tidak ada backup file yang ditemukan untuk direstore."
  echo "ℹ️ File yang dicari: $REMOTE_PATH.bak_*"
  exit 1
fi

LATEST_BACKUP="${BACKUP_FILES[0]}"
echo "📦 Restore dari backup: $LATEST_BACKUP"

if [ -f "$LATEST_BACKUP" ]; then
  mv "$LATEST_BACKUP" "$REMOTE_PATH"
  chmod 644 "$REMOTE_PATH"
  echo "✅ Backup berhasil direstore: $LATEST_BACKUP → $REMOTE_PATH"
else
  echo "❌ File backup tidak ditemukan: $LATEST_BACKUP"
  exit 1
fi

# Restore servers controller juga
SERVERS_CONTROLLER_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/ServersController.php"
SERVERS_BACKUP_FILES=($(ls -t ${SERVERS_CONTROLLER_PATH}.bak_* 2>/dev/null))

if [ ${#SERVERS_BACKUP_FILES[@]} -gt 0 ]; then
  LATEST_SERVERS_BACKUP="${SERVERS_BACKUP_FILES[0]}"
  if [ -f "$LATEST_SERVERS_BACKUP" ]; then
    mv "$LATEST_SERVERS_BACKUP" "$SERVERS_CONTROLLER_PATH"
    chmod 644 "$SERVERS_CONTROLLER_PATH"
    echo "✅ Servers controller berhasil direstore: $LATEST_SERVERS_BACKUP → $SERVERS_CONTROLLER_PATH"
  fi
fi

echo "♻️ Restarting services..."
systemctl restart pteroq
systemctl reload apache2

echo "✅ Uninstall proteksi berhasil!"
echo "🔓 Akses Admin Nodes View telah dibuka untuk semua admin."
echo "📊 Kolom Owner, Node, Connection di servers table telah dikembalikan."
