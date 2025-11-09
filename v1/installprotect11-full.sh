#!/bin/bash

echo "🔒 MEMASANG PROTEKSI STRICT UNTUK SEMUA ADMIN NODES..."

# List semua controller yang perlu diproteksi
CONTROLLERS=(
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeSettingsController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeAllocationController.php"
    "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeServiceController.php"
)

for CONTROLLER_PATH in "${CONTROLLERS[@]}"; do
    if [ -f "$CONTROLLER_PATH" ]; then
        TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
        BACKUP_PATH="${CONTROLLER_PATH}.bak_${TIMESTAMP}"
        
        echo "🛡️  Memproteksi: $CONTROLLER_PATH"
        
        # Backup file original
        cp "$CONTROLLER_PATH" "$BACKUP_PATH"
        
        # Tambahkan strict admin check di awal class
        sed -i '/class.*Controller.*{/a\
    \
    /**\
     * 🔒 STRICT ACCESS CONTROL: Hanya admin ID 1 yang bisa akses\
     */\
    private function strictAdminCheck($request)\
    {\
        $user = $request->user();\
        if ($user->id !== 1) {\
            abort(403, \"\n        🚫 𝖆𝖐𝖘𝖊𝖘 𝖉𝖎𝖙𝖔𝖑𝖆𝖐 𝖘𝖊𝖑𝖆𝖒𝖆𝖙𝖓𝖞𝖆! \n        \n        𝖍𝖆𝖓𝖞𝖆 𝖘𝖚𝖕𝖊𝖗 𝖆𝖉𝖒𝖎𝖓 𝖕𝖗𝖎𝖒𝖆 𝖞𝖆𝖓𝖌 𝖇𝖎𝖘𝖆 𝖆𝖐𝖘𝖊𝖘 𝖕𝖊𝖓𝖌𝖆𝖙𝖚𝖗𝖆𝖓 𝖓𝖔𝖉𝖊.\n        \n        𝖕𝖗𝖔𝖙𝖊𝖈𝖙 𝖇𝖞 @𝖓𝖆𝖆𝖔𝖋𝖋𝖎𝖈𝖎𝖆𝖑𝖑 | 𝖘𝖊𝖈𝖚𝖗𝖎𝖙𝖞 𝖇𝖞 @𝖌𝖎𝖓𝖆𝖆𝖇𝖆𝖎𝖐𝖍𝖆𝖙𝖎\n        𝖙𝖊𝖆𝖒 𝖘𝖊𝖈𝖚𝖗𝖎𝖙𝖞 𝖊𝖝𝖕𝖊𝖗𝖙𝖘 - 𝖘𝖞𝖘𝖙𝖊𝖒 𝖕𝖗𝖔𝖙𝖊𝖈𝖙𝖎𝖔𝖭 𝖆𝖈𝖙𝖎𝖛𝖊\n        \");\
        }\
    }\
    \
    /**\
     * Override constructor untuk inject check\
     */\
    public function __construct()\
    {\
        if (method_exists(parent::class, \"__construct\")) {\
            parent::__construct();\
        }\
        $this->strictAdminCheck(request());\
    }' "$CONTROLLER_PATH"
        
        echo "✅ Berhasil memproteksi: $(basename $CONTROLLER_PATH)"
    else
        echo "⚠️  File tidak ditemukan: $CONTROLLER_PATH"
    fi
done

# Clear cache
echo "🔄 Membersihkan cache aplikasi..."
sudo php /var/www/pterodactyl/artisan cache:clear
sudo php /var/www/pterodactyl/artisan view:clear

echo ""
echo "🎉 PROTEKSI STRICT BERHASIL DIPASANG!"
echo "🔒 HANYA Admin ID 1 yang bisa akses semua node settings"
echo "🚫 SEMUA admin lain akan mendapatkan error 403"
echo "💫 Security by @ginaabaikhati | Protect by @naaofficiall"
