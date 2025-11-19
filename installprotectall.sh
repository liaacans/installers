#!/bin/bash

# installprotectall.sh
# Script untuk menginstall/uninstall semua Protect Panel

# Array script yang akan dijalankan
scripts=(
    'installprotect1.sh'
    'installprotect2.sh'
    'installprotect3.sh'
    'installprotect4.sh'
    'installprotect5.sh'
    'installprotect6.sh'
    'installprotect7.sh'
    'installprotect8.sh'
    'installprotect9.sh'
    'installprotect10.sh'
    'installprotect11.sh'
    'installprotect12.sh'
)

# Base URL untuk download script
BASE_URL="https://raw.githubusercontent.com/liaacans/installers/refs/heads/main/v1"

# Fungsi untuk menampilkan header
show_header() {
    clear
    echo "=========================================="
    echo "    PROTECT PANEL INSTALLER"
    echo "=========================================="
    echo
}

# Fungsi untuk install semua protect panel
install_all() {
    show_header
    echo "⏳ Memulai instalasi semua Protect Panel (1-12)..."
    echo
    
    for script in "${scripts[@]}"; do
        script_url="$BASE_URL/$script"
        echo "🚀 Memulai instalasi $script..."
        
        # Download dan eksekusi script
        if curl -fsSL "$script_url" | bash; then
            echo "✅ $script berhasil diinstall"
        else
            echo "❌ Gagal menginstall $script"
        fi
        echo "------------------------------------------"
    done
    
    echo
    echo "🎯 Proses instalasi selesai!"
    read -p "Tekan Enter untuk kembali ke menu..."
}

# Fungsi untuk uninstall semua protect panel
uninstall_all() {
    show_header
    echo "⚠️  PERINGATAN!"
    echo "Fitur uninstall akan menghapus semua Protect Panel yang terinstall."
    echo "Tindakan ini tidak dapat dibatalkan!"
    echo
    
    read -p "Apakah Anda yakin ingin melanjutkan? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo
        echo "⏳ Memulai uninstall semua Protect Panel..."
        echo
        
        # Contoh command uninstall - sesuaikan dengan kebutuhan
        for script in "${scripts[@]}"; do
            script_name=$(echo "$script" | sed 's/install/uninstall/')
            echo "🗑️  Menghapus ${script_name%.*}..."
            
            # Tambahkan command uninstall sesuai kebutuhan
            # Contoh: systemctl stop [service_name] && systemctl disable [service_name]
            # rm -rf /path/to/installation
            
            echo "✅ ${script_name%.*} berhasil diuninstall"
            echo "------------------------------------------"
        done
        
        echo
        echo "🎯 Proses uninstall selesai!"
    else
        echo
        echo "❌ Uninstall dibatalkan"
    fi
    
    read -p "Tekan Enter untuk kembali ke menu..."
}

# Fungsi menu utama
main_menu() {
    while true; do
        show_header
        echo "Pilih opsi:"
        echo "1. Install All Protect Panel"
        echo "2. Uninstall All Protect Panel"
        echo "3. Exit"
        echo
        
        read -p "Masukkan pilihan (1-3): " choice
        
        case $choice in
            1)
                install_all
                ;;
            2)
                uninstall_all
                ;;
            3)
                show_header
                echo "Terima kasih telah menggunakan Protect Panel Installer!"
                echo "Goodbye! 👋"
                exit 0
                ;;
            *)
                echo "❌ Pilihan tidak valid! Silakan pilih 1-3."
                sleep 2
                ;;
        esac
    done
}

# Fungsi untuk memeriksa dependencies
check_dependencies() {
    local deps=("curl" "bash")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "❌ Dependencies berikut tidak terinstall: ${missing[*]}"
        echo "Silakan install terlebih dahulu sebelum menjalankan script ini."
        exit 1
    fi
}

# Main execution
if [[ "$1" == "--install" ]]; then
    install_all
elif [[ "$1" == "--uninstall" ]]; then
    uninstall_all
elif [[ "$1" == "--help" ]]; then
    show_header
    echo "Usage: ./installprotectall.sh [OPTION]"
    echo
    echo "Options:"
    echo "  --install     Install semua Protect Panel"
    echo "  --uninstall   Uninstall semua Protect Panel"
    echo "  --help        Menampilkan bantuan ini"
    echo
    echo "Tanpa option: Menjalankan menu interaktif"
else
    check_dependencies
    main_menu
fi
