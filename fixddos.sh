#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to display banner
show_banner() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║        PTERODACTYL ERROR FIXER       ║"
    echo "║              AUTO FIX v1.0           ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to fix all issues
fix_all_issues() {
    show_banner
    echo -e "${YELLOW}[+] Starting Auto Fix for Pterodactyl...${NC}"
    echo -e "${YELLOW}[!] IP: ipmudisini | Ports: 8080, 2022${NC}"
    echo ""
    
    # Step 1: Stop services
    echo -e "${BLUE}[1/8] Stopping services...${NC}"
    systemctl stop wings
    systemctl stop docker
    sleep 2
    
    # Step 2: Reset iptables
    echo -e "${BLUE}[2/8] Resetting iptables rules...${NC}"
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    
    # Step 3: Clean Docker
    echo -e "${BLUE}[3/8] Cleaning Docker networks and containers...${NC}"
    docker stop $(docker ps -aq) 2>/dev/null || true
    docker rm $(docker ps -aq) 2>/dev/null || true
    docker network prune -f
    docker network rm pterodactyl0 2>/dev/null || true
    sleep 3
    
    # Step 4: Start Docker
    echo -e "${BLUE}[4/8] Starting Docker...${NC}"
    systemctl start docker
    sleep 5
    
    # Step 5: Create pterodactyl0 network
    echo -e "${BLUE}[5/8] Creating pterodactyl0 network...${NC}"
    docker network create \
        --driver bridge \
        --subnet=172.18.0.0/16 \
        --gateway=172.18.0.1 \
        --opt com.docker.network.bridge.name=pterodactyl0 \
        --opt com.docker.network.bridge.enable_icc=true \
        pterodactyl0
    
    # Step 6: Apply proper firewall rules
    echo -e "${BLUE}[6/8] Applying firewall rules for Pterodactyl...${NC}"
    
    # Basic firewall rules
    iptables -P INPUT DROP
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    
    # Allow essential services
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    
    # Pterodactyl ports
    iptables -A INPUT -p tcp --dport 8080 -j ACCEPT    # Wings API
    iptables -A INPUT -p tcp --dport 2022 -j ACCEPT    # SFTP
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT      # Web
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT     # HTTPS
    
    # Game server ports
    iptables -A INPUT -p tcp --dport 25565:26000 -j ACCEPT
    iptables -A INPUT -p udp --dport 25565:26000 -j ACCEPT
    
    # Docker networking rules
    iptables -A FORWARD -i pterodactyl0 -j ACCEPT
    iptables -A FORWARD -o pterodactyl0 -j ACCEPT
    
    # Step 7: Start Wings
    echo -e "${BLUE}[7/8] Starting Wings...${NC}"
    systemctl start wings
    sleep 8
    
    # Step 8: Verify fixes
    echo -e "${BLUE}[8/8] Verifying fixes...${NC}"
    
    # Check services
    echo ""
    echo -e "${YELLOW}=== SERVICE STATUS ===${NC}"
    if systemctl is-active --quiet wings; then
        echo -e "Wings: ${GREEN}RUNNING${NC}"
    else
        echo -e "Wings: ${RED}FAILED${NC}"
    fi
    
    if systemctl is-active --quiet docker; then
        echo -e "Docker: ${GREEN}RUNNING${NC}"
    else
        echo -e "Docker: ${RED}FAILED${NC}"
    fi
    
    # Check network
    if docker network ls | grep -q pterodactyl0; then
        echo -e "Network: ${GREEN}CREATED${NC}"
    else
        echo -e "Network: ${RED}MISSING${NC}"
    fi
    
    # Check containers
    container_count=$(docker ps -q | wc -l)
    echo -e "Containers: ${GREEN}$container_count running${NC}"
    
    echo ""
    echo -e "${GREEN}[✓] AUTO FIX COMPLETED!${NC}"
    echo -e "${YELLOW}[!] Try starting your server from Pterodactyl Panel now.${NC}"
    echo ""
    
    # Show recent logs
    echo -e "${YELLOW}=== RECENT WINGS LOGS ===${NC}"
    journalctl -u wings --no-pager -n 10 --since "1 minute ago" | tail -10
    
    echo ""
    read -p "Press Enter to continue..."
}

# Main menu
while true; do
    show_banner
    echo -e "${GREEN}Select an option:${NC}"
    echo -e "1. ${BLUE}Fixed All${NC} (Auto repair Pterodactyl errors)"
    echo -e "2. ${RED}Exit${NC}"
    echo ""
    read -p "Enter your choice [1-2]: " choice

    case $choice in
        1)
            fix_all_issues
            ;;
        2)
            echo -e "${GREEN}[+] Thank you for using Pterodactyl Fixer!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}[!] Invalid option! Please choose 1 or 2${NC}"
            sleep 2
            ;;
    esac
done
