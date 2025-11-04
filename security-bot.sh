#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

info() {
    echo -e "${BLUE}[MENU]${NC} $1"
}

show_menu() {
    clear
    cat <<'EOF'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣦⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠒⠒⠉⣩⣽⣿⣿⣿⣿⣿⠿⢿⣶⣶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⣿⣿⣿⣿⣿⣿⣿⡷⠀⠈⠙⠻⢿⣿⣷⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⠿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠉⠻⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣤⣴⣶⣿⣿⣿⣿⣦⣄⣾⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⠏⠉⢹⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣁⡀⠀⢸⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣷⠀⢸⣿⣿⡇⠻⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣷⣼⣿⣿⡇⠀⠈⠻⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⡃⠙⣿⣿⣄⡀⠀⠈⠙⢷⣄⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠺⣿⣿⣿⣿⣿⣿⣿⡟⠁⠀⠘⣿⣿⣿⣷⣶⣤⣈⡟⢳⢄⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⢻⣿⣯⡉⠛⠻⢿⣿⣷⣧⡀⠀⠀⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⡿⠹⣿⣿⣿⣷⠀⠀⠀⢀⣿⣿⣷⣄⠀⠀⠈⠙⠿⣿⣄⠀⠀⠀⢠⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⠋⠀⣀⣻⣿⣿⣿⣀⣠⣶⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠈⢹⠇⠀⠀⣾⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣟⠛⠋⠉⠁⠀⠀⠀⠉⠻⢧⠀⠀⠀⠘⠃⠀⣼⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢢⡀⠀⠀⠀⠀⢿⣿⣿⠿⠟⠛⠉⠁⠈⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⢺⠀⠀⠀⠀⢀⣾⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠳⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠊⠀⠀⠀⣰⣿⣿⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢷⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣾⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⣷⣤⣀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⠀⠀⠀⠀⠀⠀⣀⣤⣶⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠿⣿⣶⣦⣤⣤⣀⣀⣀⣻⣿⣀⣀⣤⣴⣶⣿⣿⣿⣿⣿⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠻⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠟⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢿⣿⣯⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⡟⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
EOF

    echo
    echo "=========================================="
    echo "              SIMPLE OPTION               "
    echo "    CUSTOM SECURITY MIDDLEWARE INSTALLER  "
    echo "                 @ginaabaikhati                 "
    echo "=========================================="
    echo
    echo "Menu yang tersedia:"
    echo "1. Install Security Middleware"
    echo "2. Ganti Nama Credit di Middleware"
    echo "3. Custom Teks Error Message"
    echo "4. Clear Security (Uninstall)"
    echo "5. Keluar"
    echo
}

clear_security() {
    echo
    info "CLEAR SECURITY MIDDLEWARE"
    info "========================"
    echo
    warn "⚠️  PERINGATAN: Tindakan ini akan menghapus security middleware dan mengembalikan sistem ke kondisi normal!"
    read -p "Apakah Anda yakin ingin menghapus security middleware? (y/N): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log "❌ Penghapusan dibatalkan."
        return
    fi
    
    PTERO_DIR="/var/www/pterodactyl"
    
    if [ ! -d "$PTERO_DIR" ]; then
        error "Pterodactyl directory not found: $PTERO_DIR"
    fi
    
    log "🧹 Membersihkan security middleware..."
    
    # 1. Hapus file middleware
    if [ -f "$PTERO_DIR/app/Http/Middleware/CustomSecurityCheck.php" ]; then
        rm -f "$PTERO_DIR/app/Http/Middleware/CustomSecurityCheck.php"
        log "✅ File middleware dihapus"
    else
        warn "⚠️ File middleware tidak ditemukan"
    fi
    
    # 2. Hapus dari Kernel.php
    KERNEL_FILE="$PTERO_DIR/app/Http/Kernel.php"
    if [ -f "$KERNEL_FILE" ]; then
        if grep -q "custom.security" "$KERNEL_FILE"; then
            sed -i "/'custom.security' => \\\\Pterodactyl\\\\Http\\\\Middleware\\\\CustomSecurityCheck::class,/d" "$KERNEL_FILE"
            log "✅ Middleware dihapus dari Kernel"
        else
            warn "⚠️ Middleware tidak terdaftar di Kernel"
        fi
    fi
    
    # 3. Hapus middleware dari routes
    log "🔧 Membersihkan routes..."
    
    # api-client.php
    API_CLIENT_FILE="$PTERO_DIR/routes/api-client.php"
    if [ -f "$API_CLIENT_FILE" ]; then
        sed -i "s/'middleware' => \['custom.security'\]//g" "$API_CLIENT_FILE"
        sed -i "s/->middleware(\['custom.security'\])//g" "$API_CLIENT_FILE"
        log "✅ Middleware dihapus dari api-client.php"
    fi
    
    # admin.php - hapus middleware dari semua route
    ADMIN_FILE="$PTERO_DIR/routes/admin.php"
    if [ -f "$ADMIN_FILE" ]; then
        sed -i "s/'middleware' => \['custom.security'\]//g" "$ADMIN_FILE"
        sed -i "s/->middleware(\['custom.security'\])//g" "$ADMIN_FILE"
        log "✅ Middleware dihapus dari admin.php"
    fi
    
    # 4. Clear cache
    log "🧹 Membersihkan cache..."
    cd $PTERO_DIR
    sudo -u www-data php artisan config:clear
    sudo -u www-data php artisan route:clear
    sudo -u www-data php artisan view:clear
    sudo -u www-data php artisan cache:clear
    sudo -u www-data php artisan optimize
    
    log "✅ Cache dibersihkan"
    
    # 5. Restart services
    log "🔄 Restart services..."
    
    PHP_SERVICE=""
    if systemctl is-active --quiet php8.2-fpm; then
        PHP_SERVICE="php8.2-fpm"
    elif systemctl is-active --quiet php8.1-fpm; then
        PHP_SERVICE="php8.1-fpm"
    elif systemctl is-active --quiet php8.0-fpm; then
        PHP_SERVICE="php8.0-fpm"
    elif systemctl is-active --quiet php8.3-fpm; then
        PHP_SERVICE="php8.3-fpm"
    fi
    
    if [ -n "$PHP_SERVICE" ]; then
        systemctl restart $PHP_SERVICE
        log "✅ $PHP_SERVICE di-restart"
    fi
    
    if systemctl is-active --quiet pteroq-service; then
        systemctl restart pteroq-service
        log "✅ pterodactyl-service di-restart"
    fi
    
    if systemctl is-active --quiet nginx; then
        systemctl reload nginx
        log "✅ nginx di-reload"
    fi
    
    echo
    log "🎉 Security middleware berhasil dihapus!"
    log "📋 Yang telah dilakukan:"
    log "   ✅ File middleware dihapus"
    log "   ✅ Registrasi di Kernel dihapus"
    log "   ✅ Middleware dari routes dihapus"
    log "   ✅ Cache dibersihkan"
    log "   ✅ Services di-restart"
    echo
    warn "⚠️  Sistem sekarang dalam kondisi NORMAL tanpa proteksi security middleware"
}

replace_credit_name() {
    echo
    info "GANTI NAMA CREDIT"
    info "================="
    echo
    read -p "Masukkan nama baru untuk mengganti '@ginaabaikhati': " new_name
    
    if [ -z "$new_name" ]; then
        error "Nama tidak boleh kosong!"
    fi
    
    new_name=$(echo "$new_name" | sed 's/^@//')
    
    echo
    info "Mengganti '@ginaabaikhati' dengan '@$new_name'..."
    
    PTERO_DIR="/var/www/pterodactyl"
    if [ ! -f "$PTERO_DIR/app/Http/Middleware/CustomSecurityCheck.php" ]; then
        error "Middleware belum diinstall! Silakan install terlebih dahulu."
    fi
    
    sed -i "s/@ginaabaikhati/@$new_name/g" "$PTERO_DIR/app/Http/Middleware/CustomSecurityCheck.php"
    
    log "✅ Nama berhasil diganti dari '@ginaabaikhati' menjadi '@$new_name'"
    
    log "🧹 Membersihkan cache..."
    cd $PTERO_DIR
    sudo -u www-data php artisan config:clear
    sudo -u www-data php artisan route:clear
    sudo -u www-data php artisan cache:clear
    
    echo
    log "🎉 Nama credit berhasil diubah!"
    log "💬 Credit sekarang: @$new_name"
}

custom_error_message() {
    echo
    info "CUSTOM TEKS ERROR MESSAGE"
    info "========================"
    echo
    read -p "Masukkan teks error custom (contoh: 'Akses ditolak!'): " custom_error
    
    if [ -z "$custom_error" ]; then
        error "Teks error tidak boleh kosong!"
    fi
    
    echo
    info "Mengganti teks error dengan: '$custom_error'..."
    
    PTERO_DIR="/var/www/pterodactyl"
    if [ ! -f "$PTERO_DIR/app/Http/Middleware/CustomSecurityCheck.php" ]; then
        error "Middleware belum diinstall! Silakan install terlebih dahulu."
    fi
    
    sed -i "s/Mau ngapain loo? mau nyolong sc yaa??? - @ginaabaikhati/$custom_error/g" "$PTERO_DIR/app/Http/Middleware/CustomSecurityCheck.php"
    
    log "✅ Teks error berhasil diganti dengan: '$custom_error'"
    
    log "🧹 Membersihkan cache..."
    cd $PTERO_DIR
    sudo -u www-data php artisan config:clear
    sudo -u www-data php artisan route:clear
    sudo -u www-data php artisan cache:clear
    
    echo
    log "🎉 Teks error berhasil diubah!"
}

install_full_security_v3() {
    if [ "$EUID" -ne 0 ]; then
        error "Please run as root: sudo bash <(curl -s https://raw.githubusercontent.com/liaacans/installers/refs/heads/main/security.sh)"
    fi

    log "🚀 Starting Custom Security Middleware Full Installation v3..."
    
    # Define paths
    APP_DIR="/var/www/pterodactyl"
    MW_FILE="$APP_DIR/app/Http/Middleware/CustomSecurityCheck.php"
    KERNEL="$APP_DIR/app/Http/Kernel.php"
    API_CLIENT="$APP_DIR/routes/api-client.php"
    ADMIN_ROUTES="$APP_DIR/routes/admin.php"

    STAMP="$(date +%Y%m%d%H%M%S)"
    BACKUP_DIR="/root/pterodactyl-customsecurity-backup-$STAMP"
    mkdir -p "$BACKUP_DIR"

    # Backup function
    bk() { [ -f "$1" ] && cp -a "$1" "$BACKUP_DIR/$(basename "$1").bak.$STAMP" && echo "  backup: $1 -> $BACKUP_DIR"; }

    echo "== Custom Security: full installer v3 =="
    echo "App: $APP_DIR"
    echo "Backup: $BACKUP_DIR"

    # Check if Pterodactyl exists
    if [ ! -d "$APP_DIR" ]; then
        error "Pterodactyl directory not found: $APP_DIR"
    fi

    # --- 1) Create middleware file ---
    log "📝 Creating CustomSecurityCheck middleware..."
    mkdir -p "$(dirname "$MW_FILE")"
    bk "$MW_FILE"
    cat >"$MW_FILE" <<'PHP'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Pterodactyl\Models\Server;
use Pterodactyl\Models\User;
use Pterodactyl\Models\Node;
use Illuminate\Support\Facades\Log;

class CustomSecurityCheck
{
    public function handle(Request $request, Closure $next)
    {
        $user   = $request->user();
        $path   = strtolower($request->path());
        $method = strtoupper($request->method());
        $server = $request->route('server');
        $node   = $request->route('node');

        Log::debug('CustomSecurityCheck: incoming request', [
            'user_id'     => $user->id ?? null,
            'root_admin'  => $user->root_admin ?? false,
            'path'        => $path,
            'method'      => $method,
            'server_id'   => $server instanceof Server ? $server->id : null,
            'node_id'     => $node instanceof Node ? $node->id : null,
            'auth_header' => $request->hasHeader('Authorization'),
        ]);

        if (!$user) {
            return $next($request);
        }

        // Block all admin access to nodes management including view
        if ($user->root_admin && $this->isAdminAccessingNodes($path, $method)) {
            Log::warning('Blocked admin node access', [
                'user_id' => $user->id,
                'path'    => $path,
            ]);
            return $this->deny($request, 'Mau ngapain loo? mau nyolong sc yaa??? - @ginaabaikhati');
        }

        // Block all admin access to users management
        if ($user->root_admin && $this->isAdminAccessingUsers($path, $method)) {
            Log::warning('Blocked admin user access', [
                'user_id' => $user->id,
                'path'    => $path,
            ]);
            return $this->deny($request, 'Mau ngapain loo? mau nyolong sc yaa??? - @ginaabaikhati');
        }

        // Block all admin access to servers management
        if ($user->root_admin && $this->isAdminAccessingServers($path, $method)) {
            Log::warning('Blocked admin server access', [
                'user_id' => $user->id,
                'path'    => $path,
            ]);
            return $this->deny($request, 'Mau ngapain loo? mau nyolong sc yaa??? - @ginaabaikhati');
        }

        if ($server instanceof Server) {
            if ($user->id === $server->owner_id) {
                Log::info('Owner bypass', ['user_id' => $user->id, 'server_id' => $server->id]);
                return $next($request);
            }

            if ($this->isFilesListRoute($path, $method)) {
                return $next($request);
            }

            if ($this->isRestrictedFileAction($path, $method, $request)) {
                Log::warning('Blocked non-owner file action', [
                    'user_id'   => $user->id,
                    'server_id' => $server->id,
                    'path'      => $path,
                ]);
                return $this->deny($request, 'Mau ngapain loo? mau nyolong sc yaa??? - @ginaabaikhati');
            }
        }

        if ($this->isAdminDeletingUser($path, $method)) {
            return $this->deny($request, 'Mau ngapain loo? mau nyolong sc yaa??? - @ginaabaikhati');
        }

        if ($this->isAdminUpdatingUser($request, $path, $method)) {
            return $this->deny($request, 'Mau ngapain loo? mau nyolong sc yaa??? - @ginaabaikhati');
        }

        if ($this->isAdminDeletingServer($path, $method)) {
            return $this->deny($request, 'Mau ngapain loo? mau nyolong sc yaa??? - @ginaabaikhati');
        }

        if ($this->isAdminModifyingNode($path, $method)) {
            return $this->deny($request, 'Mau ngapain loo? mau nyolong sc yaa??? - @ginaabaikhati');
        }

        if ($request->hasHeader('Authorization') && $this->isRestrictedFileAction($path, $method, $request) && $server instanceof Server && $user->id !== $server->owner_id) {
            Log::warning('Blocked admin API key file action', [
                'user_id'   => $user->id,
                'server_id' => $server->id ?? null,
                'path'      => $path,
            ]);
            return $this->deny($request, 'Mau ngapain loo? mau nyolong sc yaa??? - @ginaabaikhati');
        }

        if (str_contains($path, 'admin/settings')) {
            return $this->deny($request, 'Mau ngapain loo? mau nyolong sc yaa??? - @ginaabaikhati');
        }

        if (!$user->root_admin) {
            $targetUser = $request->route('user');

            if ($targetUser instanceof User && $user->id !== $targetUser->id) {
                return $this->deny($request, 'Mau ngapain loo? mau nyolong sc yaa??? - @ginaabaikhati');
            }

            if ($this->isAccessingRestrictedList($path, $method, $targetUser)) {
                return $this->deny($request, 'Mau ngapain loo? mau nyolong sc yaa??? - @ginaabaikhati');
            }
        }

        return $next($request);
    }

    private function deny(Request $request, string $message)
    {
        if ($request->is('api/*') || $request->expectsJson()) {
            return response()->json(['error' => $message], 403);
        }
        if ($request->hasSession()) {
            $request->session()->flash('error', $message);
        }
        return redirect()->back();
    }

    private function isAdminAccessingNodes(string $path, string $method): bool
    {
        $nodePaths = [
            'admin/nodes',
            'application/nodes',
            'api/application/nodes'
        ];

        foreach ($nodePaths as $nodePath) {
            if (str_contains($path, $nodePath)) {
                return true;
            }
        }

        // Block specific node view routes like /admin/nodes/view/1
        if (preg_match('#admin/nodes/view/\d+#', $path)) {
            return true;
        }

        return false;
    }

    private function isAdminAccessingUsers(string $path, string $method): bool
    {
        $userPaths = [
            'admin/users',
            'application/users', 
            'api/application/users'
        ];

        foreach ($userPaths as $userPath) {
            if (str_contains($path, $userPath)) {
                return true;
            }
        }

        return false;
    }

    private function isAdminAccessingServers(string $path, string $method): bool
    {
        $serverPaths = [
            'admin/servers',
            'application/servers',
            'api/application/servers'
        ];

        foreach ($serverPaths as $serverPath) {
            if (str_contains($path, $serverPath)) {
                return true;
            }
        }

        return false;
    }

    private function isFilesListRoute(string $path, string $method): bool
    {
        return (
            preg_match('#^server/[^/]+/files$#', $path) && $method === 'GET'
        ) || (
            (str_contains($path, 'application/servers/') || str_contains($path, 'api/servers/'))
            && str_contains($path, '/files')
            && $method === 'GET'
        );
    }

    private function isRestrictedFileAction(string $path, string $method, Request $request): bool
    {
        $restricted = ['download','archive','compress','decompress','delete','chmod','upload'];
        foreach ($restricted as $kw) {
            if (str_contains($path, $kw)) {
                return true;
            }
        }

        if ((str_contains($path, 'application/servers/') || str_contains($path, 'api/servers/')) && str_contains($path, '/files') && $method === 'GET') {
            $q = strtolower($request->getQueryString() ?? '');
            return str_contains($q, 'download') || str_contains($q, 'file=');
        }

        return false;
    }

    private function isAdminDeletingUser(string $path, string $method): bool
    {
        return ($method === 'DELETE' && str_contains($path, 'admin/users'))
            || ($method === 'POST' && str_contains($path, 'admin/users') && str_contains($path, 'delete'));
    }

    private function isAdminUpdatingUser(Request $request, string $path, string $method): bool
    {
        if (in_array($method, ['PUT','PATCH']) && str_contains($path, 'admin/users')) {
            return true;
        }

        $override = strtoupper($request->input('_method', ''));
        if ($method === 'POST' && in_array($override, ['PUT','PATCH']) && str_contains($path, 'admin/users')) {
            return true;
        }

        return $method === 'POST' && preg_match('/admin\/users\/\d+$/', $path);
    }

    private function isAdminDeletingServer(string $path, string $method): bool
    {
        return ($method === 'DELETE' && str_contains($path, 'admin/servers'))
            || ($method === 'POST' && str_contains($path, 'admin/servers') && str_contains($path, 'delete'));
    }

    private function isAdminModifyingNode(string $path, string $method): bool
    {
        return str_contains($path, 'admin/nodes') && in_array($method, ['POST','PUT','PATCH','DELETE']);
    }

    private function isAccessingRestrictedList(string $path, string $method, $user): bool
    {
        if ($method !== 'GET' || $user) {
            return false;
        }
        foreach (['admin/users','admin/servers','admin/nodes'] as $restricted) {
            if (str_contains($path, $restricted)) {
                return true;
            }
        }
        return false;
    }
}
?>
PHP
    log "✅ Custom middleware created"

    # --- 2) Register middleware in Kernel ---
    log "📝 Registering middleware in Kernel..."
    if [ -f "$KERNEL" ]; then
        bk "$KERNEL"
        php <<'PHP'
<?php
$f = '/var/www/pterodactyl/app/Http/Kernel.php';
$s = file_get_contents($f);
$alias = "'custom.security' => \\Pterodactyl\\Http\\Middleware\\CustomSecurityCheck::class,";
if (strpos($s, "'custom.security'") !== false) { 
    echo "Kernel alias already present\n"; 
    exit; 
}

$patterns = [
    '/(\$middlewareAliases\s*=\s*\[)([\s\S]*?)(\n\s*\];)/',
    '/(\$routeMiddleware\s*=\s*\[)([\s\S]*?)(\n\s*\];)/',
];
$done = false;
foreach ($patterns as $p) {
    $s2 = preg_replace_callback($p, function($m) use ($alias){
        $body = rtrim($m[2]);
        if ($body !== '' && substr(trim($body), -1) !== ',') $body .= ',';
        $body .= "\n        " . $alias;
        return $m[1] . $body . $m[3];
    }, $s, 1, $cnt);
    if ($cnt > 0) { $s = $s2; $done = true; break; }
}
if (!$done) { 
    fwrite(STDERR, "ERROR: \$middlewareAliases / \$routeMiddleware not found\n"); 
    exit(1); 
}
file_put_contents($f, $s);
echo "Kernel alias inserted\n";
?>
PHP
        log "✅ Middleware registered in Kernel"
    else
        warn "⚠️ Kernel.php not found, skipped"
    fi

    # --- 3) Patch api-client.php ---
    log "🔧 Patching api-client.php..."
    if [ -f "$API_CLIENT" ]; then
        bk "$API_CLIENT"
        php <<'PHP'
<?php
$f = '/var/www/pterodactyl/routes/api-client.php';
$s = file_get_contents($f);
if (stripos($s, "custom.security") !== false) { 
    echo "api-client.php already has custom.security\n"; 
    exit; 
}

$changed = false;
$s = preg_replace_callback('/(middleware\s*=>\s*\[)([\s\S]*?)(\])/i', function($m) use (&$changed) {
    $body = $m[2];
    if (stripos($body, 'AuthenticateServerAccess::class') !== false) {
        if (stripos($body, 'custom.security') === false) {
            $b = rtrim($body);
            if ($b !== '' && substr(trim($b), -1) !== ',') $b .= ',';
            $b .= "\n        'custom.security'";
            $changed = true;
            return $m[1] . $b . $m[3];
        }
    }
    return $m[0];
}, $s, -1);

if ($changed) {
    file_put_contents($f, $s);
    echo "api-client.php patched\n";
} else {
    echo "NOTE: middleware array w/ AuthenticateServerAccess::class not found — no change\n";
}
?>
PHP
        log "✅ api-client.php patched"
    else
        warn "⚠️ api-client.php not found, skipped"
    fi

    # --- 4) Patch admin.php ---
    log "🔧 Patching admin.php..."
    if [ -f "$ADMIN_ROUTES" ]; then
        bk "$ADMIN_ROUTES"
        php <<'PHP'
<?php
$f = '/var/www/pterodactyl/routes/admin.php';
$s = file_get_contents($f);

/* 4a) Group 'users' & 'servers' & 'nodes' */
$prefixes = ["'users'", "'servers'", "'nodes'"];
foreach ($prefixes as $pfx) {
    $s = preg_replace_callback(
        '/Route::group\s*\(\s*\[([^\]]*prefix\s*=>\s*'.$pfx.'[^\]]*)\]\s*,\s*function\s*\(\)\s*\{/is',
        function($m){
            $head = $m[1];
            if (stripos($head, 'middleware') === false) {
                return str_replace($m[1], $head . ", 'middleware' => ['custom.security']", $m[0]);
            }
            $head2 = preg_replace_callback('/(middleware\s*=>\s*\[)([\s\S]*?)(\])/i', function($mm){
                if (stripos($mm[2], 'custom.security') !== false) return $mm[0];
                $b = rtrim($mm[2]);
                if ($b !== '' && substr(trim($b), -1) !== ',') $b .= ',';
                $b .= "\n        'custom.security'";
                return $mm[1] . $b . $mm[3];
            }, $head, 1);
            return str_replace($m[1], $head2, $m[0]);
        },
        $s
    );
}

/* 4b) Node routes: tambah ->middleware(['custom.security']) kalau belum ada */
$controllers = [
    'Admin\\\\NodesController::class',
    'Admin\\\\NodeAutoDeployController::class',
];
foreach ($controllers as $ctrl) {
    $s = preg_replace_callback(
        '/(Route::(post|patch|delete)\s*\([^;]*?\[\s*'.$ctrl.'[^\]]*\][^;]*)(;)/i',
        function($m){
            $chain = $m[1];
            if (stripos($chain, '->middleware([') !== false) return $m[0];
            // sisip sebelum ->name(...) jika ada, else sebelum ';'
            if (preg_match('/(.*?)(->name\s*\([^)]+\))(.*)/', $chain, $mm)) {
                $chain = $mm[1] . "->middleware(['custom.security'])" . $mm[2] . $mm[3];
            } else {
                $chain .= "->middleware(['custom.security'])";
            }
            return $chain . $m[3];
        },
        $s
    );
}

/* 4c) Settings route: block admin/settings */
$s = preg_replace_callback(
    '/(Route::(get|post|patch|delete)\s*\([^;]*?[\'"]admin\/settings[^;]*)(;)/i',
    function($m){
        $chain = $m[1];
        if (stripos($chain, '->middleware([') !== false) return $m[0];
        if (preg_match('/(.*?)(->name\s*\([^)]+\))(.*)/', $chain, $mm)) {
            $chain = $mm[1] . "->middleware(['custom.security'])" . $mm[2] . $mm[3];
        } else {
            $chain .= "->middleware(['custom.security'])";
        }
        return $chain . $m[3];
    },
    $s
);

file_put_contents($f, $s);
echo "admin.php patched\n";
?>
PHP
        log "✅ admin.php patched"
    else
        warn "⚠️ admin.php not found, skipped"
    fi

    # --- 5) Clear cache ---
    log "🧹 Clearing cache..."
    cd $APP_DIR
    sudo -u www-data php artisan config:clear
    sudo -u www-data php artisan route:clear
    sudo -u www-data php artisan view:clear
    sudo -u www-data php artisan cache:clear
    sudo -u www-data php artisan optimize

    # --- 6) Restart services ---
    log "🔄 Restarting services..."
    PHP_SERVICE=""
    if systemctl is-active --quiet php8.2-fpm; then
        PHP_SERVICE="php8.2-fpm"
    elif systemctl is-active --quiet php8.1-fpm; then
        PHP_SERVICE="php8.1-fpm"
    elif systemctl is-active --quiet php8.0-fpm; then
        PHP_SERVICE="php8.0-fpm"
    elif systemctl is-active --quiet php8.3-fpm; then
        PHP_SERVICE="php8.3-fpm"
    fi

    if [ -n "$PHP_SERVICE" ]; then
        systemctl restart $PHP_SERVICE
        log "✅ $PHP_SERVICE restarted"
    fi

    if systemctl is-active --quiet pteroq-service; then
        systemctl restart pteroq-service
        log "✅ pterodactyl-service restarted"
    fi

    if systemctl is-active --quiet nginx; then
        systemctl reload nginx
        log "✅ nginx reloaded"
    fi

    log "🎉 Custom Security Middleware v3 installation completed!"
    log "📋 What was done:"
    log "   ✅ Middleware file created"
    log "   ✅ Middleware registered in Kernel"
    log "   ✅ api-client.php patched"
    log "   ✅ admin.php patched"
    log "   ✅ Cache cleared"
    log "   ✅ Services restarted"
    log "🔒 Security features:"
    log "   ✅ Block admin access to nodes management"
    log "   ✅ Block admin access to users management"
    log "   ✅ Block admin access to servers management"
    log "   ✅ Block admin access to settings"
    log "   ✅ Restrict file actions to server owners only"
    log "   ✅ Block admin user/server deletion"
    log "   ✅ Block admin node modifications"
    log "   ✅ Protect against API key abuse"
    echo
    warn "⚠️ IMPORTANT: Test your panel functionality!"
    warn "⚠️ Backup created at: $BACKUP_DIR"
}

main_menu() {
    while true; do
        show_menu
        read -p "Pilih menu (1-5): " choice
        
        case $choice in
            1)
                install_full_security_v3
                ;;
            2)
                replace_credit_name
                ;;
            3)
                custom_error_message
                ;;
            4)
                clear_security
                ;;
            5)
                log "Keluar dari program."
                exit 0
                ;;
            *)
                error "Pilihan tidak valid!"
                ;;
        esac
        
        echo
        read -p "Tekan Enter untuk melanjutkan..." dummy
    done
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_menu
fi
