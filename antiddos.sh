#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Please run as root (sudo ./pterodactyl-antiddos.sh)${NC}"
    exit 1
fi

# Function to display banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║          PTERODACTYL ANTI-DDoS TOOLS         ║"
    echo "║              SPECIAL EDITION v2.0            ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to detect Pterodactyl installation
detect_pterodactyl() {
    echo -e "${CYAN}[*] Detecting Pterodactyl installation...${NC}"
    
    # Check Panel
    if [ -d "/var/www/pterodactyl" ]; then
        PANEL_DIR="/var/www/pterodactyl"
        PANEL_INSTALLED=true
    elif [ -d "/var/www/panel" ]; then
        PANEL_DIR="/var/www/panel"
        PANEL_INSTALLED=true
    else
        PANEL_INSTALLED=false
    fi
    
    # Check Wings
    if systemctl is-active --quiet wings; then
        WINGS_INSTALLED=true
    else
        WINGS_INSTALLED=false
    fi
    
    echo -e "Panel: $([ "$PANEL_INSTALLED" = true ] && echo -e "${GREEN}INSTALLED${NC}" || echo -e "${RED}NOT FOUND${NC}")"
    echo -e "Wings: $([ "$WINGS_INSTALLED" = true ] && echo -e "${GREEN}INSTALLED${NC}" || echo -e "${RED}NOT FOUND${NC}")"
    sleep 2
}

# Function to install DDoS protection
install_pterodactyl_protection() {
    show_banner
    detect_pterodactyl
    echo -e "${YELLOW}[+] Installing Pterodactyl DDoS Protection...${NC}"
    sleep 2

    # Update system
    echo -e "${BLUE}[*] Updating system packages...${NC}"
    apt update && apt upgrade -y

    # Install required packages
    echo -e "${BLUE}[*] Installing necessary packages...${NC}"
    apt install -y fail2ban iptables-persistent net-tools iftop htop nginx apache2-utils python3 python3-pip nodejs npm

    # Install Python dependencies for monitoring
    echo -e "${BLUE}[*] Installing Python dependencies...${NC}"
    pip3 install psutil requests flask

    # Install Node.js dependencies
    echo -e "${BLUE}[*] Installing Node.js dependencies...${NC}"
    npm install -g express socket.io os-utils

    # Configure Fail2Ban for Pterodactyl
    echo -e "${BLUE}[*] Configuring Fail2Ban for Pterodactyl...${NC}"
    cat > /etc/fail2ban/jail.d/pterodactyl.conf << 'EOF'
[DEFAULT]
bantime = 7200
findtime = 600
maxretry = 3
backend = auto

# Pterodactyl Panel Protection
[pterodactyl-panel]
enabled = true
port = http,https,8080,2022
filter = pterodactyl-panel
logpath = /var/www/pterodactyl/storage/logs/laravel.log
maxretry = 5
bantime = 3600

# Wings API Protection
[wings-api]
enabled = true
port = 8080,2022,25565-26000
filter = wings-api
logpath = /var/log/pterodactyl/wings.log
maxretry = 10
bantime = 7200

# SSH Protection
[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3

# Nginx Protection
[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log

[nginx-limit-req]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
EOF

    # Create Fail2Ban filters
    cat > /etc/fail2ban/filter.d/pterodactyl-panel.conf << 'EOF'
[Definition]
failregex = ^.*\.*authentication\.*failed.*remote_ip=\"<HOST>\"
            ^.*\.*too many attempts.*ip=<HOST>
            ^.*\"message\":\".*\",\"ip\":\"<HOST>\"
ignoreregex =
EOF

    cat > /etc/fail2ban/filter.d/wings-api.conf << 'EOF'
[Definition]
failregex = ^.*error.*client_ip=<HOST>.*
            ^.*authentication failed.*<HOST>
            ^.*too many requests.*<HOST>
ignoreregex =
EOF

    # Create DDoS protection directory
    mkdir -p /opt/pterodactyl-antiddos
    mkdir -p /opt/pterodactyl-antiddos/scripts
    mkdir -p /opt/pterodactyl-antiddos/logs

    # Create main protection script
    echo -e "${BLUE}[*] Creating Pterodactyl protection scripts...${NC}"
    
    # IPTables Protection Script
    cat > /opt/pterodactyl-antiddos/scripts/firewall-protect.sh << 'EOF'
#!/bin/bash

# Pterodactyl-specific DDoS Protection

# Flush existing rules
iptables -F
iptables -X

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH (limit connections)
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m limit --limit 3/min --limit-burst 3 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j DROP

# Pterodactyl Panel Ports
iptables -A INPUT -p tcp --dport 80 -m limit --limit 100/min --limit-burst 200 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m limit --limit 100/min --limit-burst 200 -j ACCEPT

# Pterodactyl Wings Ports
iptables -A INPUT -p tcp --dport 8080 -m limit --limit 50/min --limit-burst 100 -j ACCEPT  # Wings API
iptables -A INPUT -p tcp --dport 2022 -m limit --limit 20/min --limit-burst 50 -j ACCEPT   # Wings SFTP

# Game Server Ports (adjust range as needed)
for port in {25565..26000}; do
    iptables -A INPUT -p tcp --dport $port -m limit --limit 30/min --limit-burst 60 -j ACCEPT
    iptables -A INPUT -p udp --dport $port -m limit --limit 30/min --limit-burst 60 -j ACCEPT
done

# Protection against SYN floods
iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP

# Protection against ping floods
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT

# Drop invalid packets
iptables -A INPUT -m state --state INVALID -j DROP

# Log DDoS attempts
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "Pterodactyl DDoS: "

echo "Pterodactyl DDoS protection rules applied successfully!"
EOF

    # Python Monitoring Script
    cat > /opt/pterodactyl-antiddos/scripts/monitor.py << 'EOF'
#!/usr/bin/env python3
import psutil
import time
import logging
import requests
import subprocess
from datetime import datetime

# Configuration
LOG_FILE = "/opt/pterodactyl-antiddos/logs/monitor.log"
MAX_CONNECTIONS = 50
MAX_PANEL_REQUESTS = 100
MAX_WINGS_REQUESTS = 200

# Setup logging
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def check_connections():
    """Check for excessive connections"""
    try:
        result = subprocess.run(
            ["netstat", "-ntu"],
            capture_output=True,
            text=True
        )
        connections = result.stdout.split('\n')
        ip_count = {}
        
        for conn in connections:
            if 'ESTABLISHED' in conn:
                parts = conn.split()
                if len(parts) > 4:
                    ip = parts[4].split(':')[0]
                    ip_count[ip] = ip_count.get(ip, 0) + 1
        
        for ip, count in ip_count.items():
            if count > MAX_CONNECTIONS:
                logging.warning(f"DDoS Alert: IP {ip} has {count} connections")
                block_ip(ip)
                
    except Exception as e:
        logging.error(f"Error checking connections: {e}")

def check_system_resources():
    """Check system resource usage"""
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    network = psutil.net_io_counters()
    
    if cpu_percent > 90:
        logging.warning(f"High CPU usage: {cpu_percent}%")
    
    if memory.percent > 90:
        logging.warning(f"High memory usage: {memory.percent}%")
    
    # Log network stats every 10 cycles
    if int(time.time()) % 600 < 5:
        logging.info(f"Network - Bytes sent: {network.bytes_sent}, received: {network.bytes_recv}")

def block_ip(ip):
    """Block an IP address using iptables"""
    try:
        subprocess.run(["iptables", "-A", "INPUT", "-s", ip, "-j", "DROP"], check=True)
        logging.info(f"Blocked IP: {ip}")
        
        # Also add to Fail2Ban
        subprocess.run(["fail2ban-client", "set", "pterodactyl-panel", "banip", ip], check=False)
        
    except Exception as e:
        logging.error(f"Failed to block IP {ip}: {e}")

def main():
    logging.info("Pterodactyl DDoS Monitor started")
    
    while True:
        try:
            check_connections()
            check_system_resources()
            time.sleep(30)  # Check every 30 seconds
            
        except KeyboardInterrupt:
            logging.info("Monitor stopped by user")
            break
        except Exception as e:
            logging.error(f"Monitor error: {e}")
            time.sleep(60)

if __name__ == "__main__":
    main()
EOF

    # Node.js API Protection Script
    cat > /opt/pterodactyl-antiddos/scripts/api-protector.js << 'EOF'
const express = require('express');
const app = express();
const os = require('os-utils');

// Rate limiting storage
const requestCounts = new Map();
const BLOCK_DURATION = 3600000; // 1 hour
const MAX_REQUESTS_PER_MINUTE = 100;

// Clean up old entries every hour
setInterval(() => {
    const now = Date.now();
    for (const [ip, data] of requestCounts.entries()) {
        if (now - data.firstRequest > BLOCK_DURATION) {
            requestCounts.delete(ip);
        }
    }
}, 3600000);

// Rate limiting middleware
function rateLimit(req, res, next) {
    const ip = req.ip || req.connection.remoteAddress;
    const now = Date.now();
    
    if (!requestCounts.has(ip)) {
        requestCounts.set(ip, {
            count: 1,
            firstRequest: now,
            lastRequest: now
        });
    } else {
        const data = requestCounts.get(ip);
        const timeDiff = now - data.firstRequest;
        
        if (timeDiff < 60000 && data.count > MAX_REQUESTS_PER_MINUTE) {
            return res.status(429).json({
                error: 'Too many requests',
                retryAfter: Math.ceil((60000 - timeDiff) / 1000)
            });
        }
        
        if (timeDiff > 60000) {
            // Reset counter after 1 minute
            data.count = 1;
            data.firstRequest = now;
        } else {
            data.count++;
        }
        
        data.lastRequest = now;
    }
    
    next();
}

// Apply rate limiting to all routes
app.use(rateLimit);

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        load: os.loadavg()
    });
});

// Start server
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Pterodactyl API Protector running on port ${PORT}`);
});
EOF

    # Make scripts executable
    chmod +x /opt/pterodactyl-antiddos/scripts/firewall-protect.sh
    chmod +x /opt/pterodactyl-antiddos/scripts/monitor.py
    chmod +x /opt/pterodactyl-antiddos/scripts/api-protector.js

    # Create systemd services
    cat > /etc/systemd/system/pterodactyl-antiddos.service << 'EOF'
[Unit]
Description=Pterodactyl Anti-DDoS Protection Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /opt/pterodactyl-antiddos/scripts/monitor.py
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF

    cat > /etc/systemd/system/pterodactyl-api-protector.service << 'EOF'
[Unit]
Description=Pterodactyl API Protector Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/node /opt/pterodactyl-antiddos/scripts/api-protector.js
Restart=always
RestartSec=10
User=root
WorkingDirectory=/opt/pterodactyl-antiddos/scripts

[Install]
WantedBy=multi-user.target
EOF

    # Enable and start services
    systemctl daemon-reload
    systemctl enable fail2ban
    systemctl enable pterodactyl-antiddos
    systemctl enable pterodactyl-api-protector
    
    systemctl start fail2ban
    systemctl start pterodactyl-antiddos
    systemctl start pterodactyl-api-protector

    # Apply firewall rules
    /opt/pterodactyl-antiddos/scripts/firewall-protect.sh

    # Save iptables rules
    netfilter-persistent save

    echo -e "${GREEN}[✓] Pterodactyl DDoS protection installed successfully!${NC}"
    echo -e "${YELLOW}[!] Services enabled:${NC}"
    echo -e "  - ${GREEN}fail2ban${NC} (with Pterodactyl jails)"
    echo -e "  - ${GREEN}pterodactyl-antiddos${NC} (Python monitor)"
    echo -e "  - ${GREEN}pterodactyl-api-protector${NC} (Node.js API protector)"
    echo -e "${YELLOW}[!] Firewall rules applied for Pterodactyl ports${NC}"
    sleep 3
}

# Function to uninstall protection
uninstall_pterodactyl_protection() {
    show_banner
    echo -e "${RED}[!] UNINSTALLING Pterodactyl DDoS Protection...${NC}"
    read -p "Are you sure you want to remove DDoS protection? (y/N): " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[*] Uninstall cancelled${NC}"
        sleep 2
        return
    fi

    echo -e "${YELLOW}[+] Removing Pterodactyl DDoS protection...${NC}"

    # Stop and disable services
    systemctl stop pterodactyl-antiddos
    systemctl stop pterodactyl-api-protector
    systemctl stop fail2ban
    
    systemctl disable pterodactyl-antiddos
    systemctl disable pterodactyl-api-protector
    systemctl disable fail2ban

    # Remove services
    rm -f /etc/systemd/system/pterodactyl-antiddos.service
    rm -f /etc/systemd/system/pterodactyl-api-protector.service
    systemctl daemon-reload

    # Remove Fail2Ban configuration
    rm -f /etc/fail2ban/jail.d/pterodactyl.conf
    rm -f /etc/fail2ban/filter.d/pterodactyl-panel.conf
    rm -f /etc/fail2ban/filter.d/wings-api.conf

    # Reset iptables rules
    echo -e "${BLUE}[*] Resetting firewall rules...${NC}"
    iptables -F
    iptables -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT

    # Remove antiddos directory
    rm -rf /opt/pterodactyl-antiddos

    # Remove persistent rules
    rm -f /etc/iptables/rules.v4
    rm -f /etc/iptables/rules.v6

    echo -e "${GREEN}[✓] Pterodactyl DDoS protection completely removed!${NC}"
    echo -e "${YELLOW}[!] All firewall rules have been reset${NC}"
    sleep 3
}

# Function to show status
show_pterodactyl_status() {
    show_banner
    detect_pterodactyl
    echo -e "${CYAN}=== PTERODACTYL DDoS PROTECTION STATUS ===${NC}"
    echo ""
    
    # Check services status
    services=("fail2ban" "pterodactyl-antiddos" "pterodactyl-api-protector")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            echo -e "$service: ${GREEN}ACTIVE${NC}"
        else
            echo -e "$service: ${RED}INACTIVE${NC}"
        fi
    done
    
    echo ""
    
    # Show Fail2Ban status
    if systemctl is-active --quiet fail2ban; then
        echo -e "${YELLOW}Fail2Ban Jails:${NC}"
        fail2ban-client status | grep "Jail list" | sed 's/.*Jail list://' | tr ',' '\n' | while read jail; do
            if [ ! -z "$jail" ]; then
                banned=$(fail2ban-client status $jail | grep "Currently banned" | awk '{print $4}')
                echo -e "  - $jail: ${RED}$banned IPs${NC} banned"
            fi
        done
    fi
    
    echo ""
    
    # Show current connections to Pterodactyl ports
    echo -e "${YELLOW}Current Connections to Pterodactyl Ports:${NC}"
    netstat -ntu | grep -E ":80|:443|:8080|:2022|:25565" | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -10
    
    echo ""
    
    # Show system resources
    echo -e "${YELLOW}System Resources:${NC}"
    echo "CPU: $(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}')"
    echo "Memory: $(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}')"
    echo "Load: $(cat /proc/loadavg | awk '{print $1", "$2", "$3}')"
    
    echo ""
    read -p "Press Enter to continue..."
}

# Function to view logs
view_logs() {
    show_banner
    echo -e "${CYAN}=== DDoS PROTECTION LOGS ===${NC}"
    echo ""
    echo "1. Monitor Logs"
    echo "2. Fail2Ban Logs"
    echo "3. System Logs"
    echo "4. Back to Main Menu"
    echo ""
    read -p "Select log type [1-4]: " log_choice
    
    case $log_choice in
        1)
            tail -f /opt/pterodactyl-antiddos/logs/monitor.log
            ;;
        2)
            tail -f /var/log/fail2ban.log
            ;;
        3)
            journalctl -u pterodactyl-antiddos -f
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            sleep 2
            ;;
    esac
}

# Main menu
while true; do
    show_banner
    detect_pterodactyl
    echo -e "${GREEN}Pterodactyl Anti-DDoS Tools${NC}"
    echo -e "${YELLOW}=================================${NC}"
    echo -e "1. ${BLUE}Install Pterodactyl DDoS Protection${NC}"
    echo -e "2. ${RED}Uninstall DDoS Protection${NC}"
    echo -e "3. ${CYAN}Show Protection Status${NC}"
    echo -e "4. ${YELLOW}View Logs${NC}"
    echo -e "5. ${GREEN}Emergency Block IP${NC}"
    echo -e "6. ${PURPLE}Exit${NC}"
    echo ""
    read -p "Enter your choice [1-6]: " choice

    case $choice in
        1)
            install_pterodactyl_protection
            ;;
        2)
            uninstall_pterodactyl_protection
            ;;
        3)
            show_pterodactyl_status
            ;;
        4)
            view_logs
            ;;
        5)
            read -p "Enter IP to block: " ip_address
            iptables -A INPUT -s $ip_address -j DROP
            echo -e "${GREEN}IP $ip_address blocked successfully!${NC}"
            sleep 2
            ;;
        6)
            echo -e "${GREEN}[+] Thank you for using Pterodactyl Anti-DDoS Tools!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}[!] Invalid option! Please choose 1-6${NC}"
            sleep 2
            ;;
    esac
done
