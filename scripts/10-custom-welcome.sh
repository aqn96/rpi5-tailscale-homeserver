#!/bin/bash

# MOTD Script for Raspberry Pi Home Lab Server
# Purpose: Displays a customized welcome message with system information.
# Place in: /etc/update-motd.d/
# Make executable: sudo chmod +x /etc/update-motd.d/10-custom-welcome (or your chosen name)

# Prerequisites:
# 1. `figlet` package: sudo apt install figlet
# 2. User running MOTD (typically the logged-in user) needs to be in the 'video' group
#    for vcgencmd access (CPU Temp on Raspberry Pi): sudo usermod -aG video <username>
#    (A logout/login is required for group changes to take effect for the user)

# --- Color Definitions ---
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_MAGENTA='\033[0;35m'
C_CYAN='\033[0;36m'
C_WHITE='\033[0;37m'
C_BOLD='\033[1m'
C_RESET='\033[0m' # Resets all attributes

# --- Custom ASCII Art ---
echo -e "${C_CYAN}${C_BOLD}"
cat << "EOF"
   ('-.          .-')         .-') _             _  .-')      _ (`-.                           .-')    
  ( OO ).-.    .(  OO)       ( OO ) )           ( \( -O )    ( (OO  )                         ( OO ).  
  / . --. /   (_)---\_)  ,--./ ,--,'             ,------.   _.`     \   ,-.-')   .-'),-----. (_)---\_) 
  | \-.  \    '  .-.  '  |   \ |  |\     .-')    |   /`. ' (__...--''   |  |OO) ( OO'  .-.  '/    _ |  
.-'-'  |  |  ,|  | |  |  |    \|  | )  _(  OO)   |  /  | |  |  /  | |   |  |  \ /   |  | |  |\  :` `.  
 \| |_.'  | (_|  | |  |  |  .     |/  (,------.  |  |_.' |  |  |_.' |   |  |(_/ \_) |  |\|  | '..`''.) 
  |  .-.  |   |  | |  |  |  |\    |    '------'  |  .  '.'  |  .___.'  ,|  |_.'   \ |  | |  |.-._)   \ 
  |  | |  |   '  '-'  '-.|  | \   |              |  |\  \   |  |      (_|  |       `'  '-'  '\       / 
  `--' `--'    `-----'--'`--'  `--'              `--' '--'  `--'        `--'         `-----'  `-----'  
EOF
echo -e "${C_RESET}"

# --- "H O M E   L A B" Title using figlet ---
if command -v figlet &> /dev/null; then
    echo -e "${C_GREEN}${C_BOLD}"
    figlet -c -w 100 "H O M E   L A B" # -c centers, -w 100 sets width (adjust as needed)
    echo -e "${C_RESET}"
else
    # Fallback if figlet is not installed
    echo -e "${C_GREEN}${C_BOLD}"
    echo "H O M E   L A B"
    echo -e "${C_RESET}"
fi
echo "" # Extra line for spacing

# --- System Information Variables ---
HOSTNAME=$(hostname)
KERNEL_VERSION=$(uname -r)
OS_PRETTY_NAME=$(lsb_release -ds 2>/dev/null || cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Linux")
UPTIME=$(uptime -p)
CURRENT_DATE=$(date +"%A, %B %d, %Y %r %Z")
LOGGED_IN_USERS=$(who | wc -l)

# CPU Temperature (Raspberry Pi Specific, with fallback)
CPU_TEMP="N/A"
if command -v vcgencmd &> /dev/null; then
    CPU_TEMP=$(vcgencmd measure_temp | cut -d'=' -f2)
else
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        CPU_TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
        if [[ -n "$CPU_TEMP_RAW" ]]; then
            CPU_TEMP=$(printf "%.1f'C" "$(echo "$CPU_TEMP_RAW / 1000" | bc -l)")
        fi
    fi
fi

# Memory Usage (RAM)
MEM_INFO=$(free -h | awk '/^Mem:/ {print "Total: " $2 ", Used: " $3 ", Free: " $4}')

# Disk Usage (Root Filesystem)
DISK_INFO=$(df -h / | awk 'NR==2 {print "Total: " $2 ", Used: " $3 " (" $5 ")"}')

# IP Addresses
ETH0_IP=$(ip -4 addr show eth0 | grep -oP 'inet \K[\d.]+' 2>/dev/null)
WLAN0_IP=$(ip -4 addr show wlan0 | grep -oP 'inet \K[\d.]+' 2>/dev/null)
LOCAL_IPS_STR=""
if [[ -n "$ETH0_IP" ]]; then LOCAL_IPS_STR="$ETH0_IP (eth0) "; fi
if [[ -n "$WLAN0_IP" ]]; then LOCAL_IPS_STR="$LOCAL_IPS_STR$WLAN0_IP (wlan0)"; fi
LOCAL_IPS_STR=$(echo "$LOCAL_IPS_STR" | sed 's/ $//') # trim trailing space if any

TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "N/A") # Default to N/A if command fails

# Pending Updates (Revised method)
# Note: For the most accurate count, 'sudo apt update' should be run periodically (e.g., via a cron job).
UPGRADABLE_PACKAGES=$(apt list --upgradable 2>/dev/null | grep -vc "Listing...")

if [[ "$UPGRADABLE_PACKAGES" -gt 0 ]]; then
    PENDING_UPDATES="${UPGRADABLE_PACKAGES} package(s) can be upgraded."
else
    PENDING_UPDATES="System is up to date."
fi

# --- Output Formatted Information ---
echo -e "${C_GREEN}Welcome to ${C_BOLD}$HOSTNAME${C_RESET}${C_GREEN}!${C_RESET}"
echo -e "----------------------------------------------------------------------"
echo -e "${C_WHITE}Date:${C_RESET}           $CURRENT_DATE"
echo -e "${C_WHITE}OS Version:${C_RESET}     $OS_PRETTY_NAME ($KERNEL_VERSION)"
echo -e "${C_WHITE}Uptime:${C_RESET}         $UPTIME"
echo -e "----------------------------------------------------------------------"
echo -e "${C_MAGENTA}System Status:${C_RESET}"
echo -e "  ${C_WHITE}CPU Temp:${C_RESET}      $CPU_TEMP"
echo -e "  ${C_WHITE}Memory:${C_RESET}        $MEM_INFO"
echo -e "  ${C_WHITE}Disk (/):${C_RESET}      $DISK_INFO"
echo -e "  ${C_WHITE}Logged In Users:${C_RESET} $LOGGED_IN_USERS"
echo -e "  ${C_WHITE}Pending Updates:${C_RESET} $PENDING_UPDATES"
echo -e "----------------------------------------------------------------------"
echo -e "${C_BLUE}Network Info:${C_RESET}"
echo -e "  ${C_WHITE}Local IP(s):${C_RESET}   ${LOCAL_IPS_STR:-N/A}"
echo -e "  ${C_WHITE}Tailscale IP:${C_RESET}  $TAILSCALE_IP"
echo -e "----------------------------------------------------------------------"
echo "" # Extra line at the end

# --- Optional: Instructions for Client-Side Terminal Theme ---
# For the best visual experience with this MOTD (especially if using colors),
# configure your SSH client's terminal (e.g., macOS Terminal, iTerm2, PuTTY)
# to use a dark background theme (e.g., black or dark grey).
# This MOTD script itself does not set the overall terminal background color.
