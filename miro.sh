#!/bin/bash

set -e

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
RESET='\033[0m'
BOLD='\033[1m'

APT_ROOT="/etc/apt"
SOURCES_FILE="$APT_ROOT/sources.list"
BACKUP_DIR_PREFIX="${APT_ROOT}/sources-cleanup-backup-"
TMPDIR="/tmp/miro_mirrors_$$"
TOP_N=3
MAX_PING=20
TEST_PATH_TEMPLATE="dists/%s/Release"

MIRRORS=(
  "https://mirrors.pardisco.co/ubuntu/"
  "http://mirror.aminidc.com/ubuntu/"
  "http://mirror.faraso.org/ubuntu/"
  "https://ir.ubuntu.sindad.cloud/ubuntu/"
  "https://ubuntu-mirror.kimiahost.com/"
  "https://archive.ubuntu.petiak.ir/ubuntu/"
  "https://ubuntu.hostiran.ir/ubuntuarchive/"
  "https://ubuntu.bardia.tech/"
  "https://mirror.iranserver.com/ubuntu/"
  "https://ir.archive.ubuntu.com/ubuntu/"
  "https://mirror.0-1.cloud/ubuntu/"
  "http://linuxmirrors.ir/pub/ubuntu/"
  "http://repo.iut.ac.ir/repo/Ubuntu/"
  "https://ubuntu.shatel.ir/ubuntu/"
  "http://ubuntu.byteiran.com/ubuntu/"
  "https://mirror.rasanegar.com/ubuntu/"
  "http://mirrors.sharif.ir/ubuntu/"
  "http://mirror.ut.ac.ir/ubuntu/"
  "http://repo.iut.ac.ir/repo/ubuntu/"
  "http://mirror.asiatech.ir/ubuntu/"
  "https://mirror.mci.ir/ubuntu/"
  "https://mirror.mobinnet.ir/ubuntu/"
  "https://mirror.rayansaba.com/ubuntu/"
  "https://mirror.bananhost.com/ubuntu/"
  "https://mirror.takserver.ir/ubuntu/"
  "https://mirror.telewebion.com/ubuntu/"
  "https://mirror.hostdl.com/ubuntu/"
  "https://ubuntu.iranhost.com/ubuntu/"
  "http://archive.ubuntu.com/ubuntu/"
  "http://security.ubuntu.com/ubuntu/"
  "https://mirrors.edge.kernel.org/ubuntu/"
  "https://ftp.yzu.edu.tw/Linux/ubuntu/"
  "https://ftp.jaist.ac.jp/pub/Linux/ubuntu/"
  "https://mirror.nju.edu.cn/ubuntu/"
  "https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
  "https://ubuntu.mirror.lrz.de/ubuntu/"
  "https://ftp.halifax.rwth-aachen.de/ubuntu/"
  "https://mirror.kku.ac.th/ubuntu/"
  "https://mirror.aarnet.edu.au/pub/ubuntu/"
  "https://mirror.sjtu.edu.cn/ubuntu/"
  "https://mirror.pregi.net/pub/linux/ubuntu/"
  "https://ftp.acc.umu.se/mirror/ubuntu.com/ubuntu/"
  "https://mirror.nus.edu.sg/ubuntu/"
  "https://mirror.us.leaseweb.net/ubuntu/"
  "https://ftp.heanet.ie/mirrors/ubuntu.com/ubuntu/"
  "https://ubuntu.mirrors.proxad.net/ubuntu/"
  "https://ubuntu-releases.tuxcloud.net/ubuntu/"
  "https://mirror.lzu.edu.cn/ubuntu/"
  "https://mirror.netcologne.de/ubuntu/"
  "https://mirrors.ocf.berkeley.edu/ubuntu/"
  "https://mirror.math.princeton.edu/pub/ubuntu/"
  "https://mirror.umd.edu/ubuntu/"
  "https://mirrors.rit.edu/ubuntu/"
  "https://mirrors.xtom.com/ubuntu/"
  "https://mirror.cedia.org.ec/ubuntu/"
  "https://mirrors.dotsrc.org/ubuntu/"
  "https://mirror.kku.ac.th/ubuntu/"
  "https://mirror.vcu.edu/pub/ubuntu/"
)

logo() {
  echo -e "${BOLD}${MAGENTA}"
  cat <<'EOF'
 __  __ _       _       
|  \/  (_)_ __ (_) ___  
| |\/| | | '_ \| |/ _ \ 
| |  | | | | | | | (_) |
|_|  |_|_|_| |_|_|\___/ 
EOF
  echo -e "${CYAN}${BOLD}APT Servers Optimal by Shellgate${RESET}\n"
}

detect_codename() {
  if command -v lsb_release &> /dev/null; then
    lsb_release -cs
  elif [ -f /etc/os-release ]; then
    grep "^VERSION_CODENAME=" /etc/os-release | cut -d= -f2
  elif [ -f /etc/lsb-release ]; then
    grep "^DISTRIB_CODENAME=" /etc/lsb-release | cut -d= -f2
  else
    echo "unknown"
  fi
}

optimize_sources() {
  logo
  UBUNTU_CODENAME=$(detect_codename)
  if [ "$UBUNTU_CODENAME" = "unknown" ] || [ -z "$UBUNTU_CODENAME" ]; then
    echo -e "${RED}❌ Could not detect Ubuntu codename!${RESET}"
    exit 1
  fi

  BACKUP_DATE="$(date -u +%Y%m%d-%H%M%S)"
  BACKUP_DIR="${APT_ROOT}/sources-cleanup-backup-$BACKUP_DATE"

  echo -e "${YELLOW}Detected Ubuntu codename: ${BOLD}${UBUNTU_CODENAME}${RESET}"
  echo -e "${CYAN}Backing up sources and keys to $BACKUP_DIR ...${RESET}"
  sudo mkdir -p "$BACKUP_DIR"
  sudo cp -a $APT_ROOT/sources.list* "$BACKUP_DIR/" 2>/dev/null || true
  sudo cp -a $APT_ROOT/sources.list.d "$BACKUP_DIR/" 2>/dev/null || true
  sudo cp -a $APT_ROOT/trusted.gpg* "$BACKUP_DIR/" 2>/dev/null || true
  sudo cp -a $APT_ROOT/trusted.gpg.d "$BACKUP_DIR/" 2>/dev/null || true

  UBUNTU_SOURCES="$APT_ROOT/sources.list.d/ubuntu.sources"
  if [ -f "$UBUNTU_SOURCES" ]; then
    echo -e "${RED}Removing $UBUNTU_SOURCES${RESET}"
    sudo rm -f "$UBUNTU_SOURCES"
  fi

  sudo cp "$SOURCES_FILE" "$SOURCES_FILE.bak-$BACKUP_DATE"

  echo -e "${BLUE}Step 1: Pinging all mirrors...${RESET}"

  mkdir -p "$TMPDIR"
  > "$TMPDIR/ping.txt"
  > "$TMPDIR/speed.txt"

  for MIRROR in "${MIRRORS[@]}"; do
    host=$(echo "$MIRROR" | awk -F/ '{print $3}')
    [ -z "$host" ] && continue
    PING_MS=$(ping -c 1 -W 1 "$host" 2>/dev/null | awk -F'time=' '/time=/{print $2}' | awk '{print int($1)}')
    if [ -n "$PING_MS" ] && [ "$PING_MS" -le "$MAX_PING" ]; then
      echo -e "${GREEN}$host OK (${PING_MS} ms)${RESET}"
      echo -e "${PING_MS}\t${MIRROR}" >> "$TMPDIR/ping.txt"
    else
      echo -e "${YELLOW}$host skipped${RESET}"
    fi
  done

  echo ""
  echo -e "${MAGENTA}Selecting mirrors with lowest ping...${RESET}"
  sort -n "$TMPDIR/ping.txt" | awk '!seen[$2]++' | head -n $((TOP_N*3)) > "$TMPDIR/ping_selected.txt"

  echo ""
  echo -e "${BLUE}Step 2: Measuring download speed for selected mirrors...${RESET}"

  while read -r line; do
    MIRROR=$(echo "$line" | cut -f2)
    TEST_URL="${MIRROR}$(printf "$TEST_PATH_TEMPLATE" "$UBUNTU_CODENAME")"
    echo -ne "${YELLOW}Testing $MIRROR ... ${RESET}"
    SPEED=$(curl -m 8 --range 0-262143 -L --output /dev/null --write-out '%{speed_download}' --silent --fail "$TEST_URL" 2>/dev/null)
    if [[ "$SPEED" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
      SPEEDKB=$(awk "BEGIN {printf \"%.2f\", $SPEED/1024}")
      echo -e "${CYAN}Speed: $SPEEDKB KB/s${RESET}"
      echo -e "$SPEED\t$MIRROR" >> "$TMPDIR/speed.txt"
    else
      echo -e "${RED}Failed${RESET}"
    fi
  done < "$TMPDIR/ping_selected.txt"

  echo ""
  echo -e "${MAGENTA}Sorting results, selecting top $TOP_N fastest mirrors...${RESET}"

  sort -rn "$TMPDIR/speed.txt" | awk '!seen[$2]++' | head -n $TOP_N > "$TMPDIR/top.txt"

  echo "# Cleaned and rebuilt on $(date -u) by miro.sh" | sudo tee "$SOURCES_FILE" > /dev/null

  while read -r line; do
    MIRROR=$(echo "$line" | cut -f2)
    SPEED=$(echo "$line" | cut -f1)
    echo -e "${GREEN}Adding $MIRROR (Speed: $(awk "BEGIN {printf \"%.2f\", $SPEED/1024}") KB/s)${RESET}"
    for suite in "" "-updates" "-backports" "-security"; do
      echo "deb ${MIRROR} ${UBUNTU_CODENAME}${suite} main restricted universe multiverse" | sudo tee -a "$SOURCES_FILE" > /dev/null
    done
  done < "$TMPDIR/top.txt"

  echo -e "${CYAN}Refreshing apt keys...${RESET}"
  if command -v apt-key &>/dev/null; then
    sudo apt-key update || true
    sudo apt-key net-update || true
  fi

  if [ -d /etc/apt/trusted.gpg.d ]; then
    for keyring in /etc/apt/trusted.gpg.d/*.gpg; do
      [ -f "$keyring" ] || continue
      sudo apt-key add "$keyring" 2>/dev/null || true
    done
  fi

  echo ""
  echo -e "${GREEN}${BOLD}sources.list rebuilt with top $TOP_N fastest mirrors for $UBUNTU_CODENAME.${RESET}"
  echo -e "${YELLOW}Backups saved at $BACKUP_DIR and /etc/apt/sources.list.bak-$BACKUP_DATE${RESET}"
  echo ""
  echo -e "${BLUE}You can now run: sudo apt update${RESET}"
  echo ""
  echo -e "${MAGENTA}Top mirrors by speed (KB/s):${RESET}"
  awk '{printf "  - %s ('"${CYAN}"'%.2f KB/s'"${RESET}"')\n", $2, $1/1024}' "$TMPDIR/speed.txt" | head -n $TOP_N

  rm -rf "$TMPDIR"
}

restore_backup() {
  logo
  LAST_BACKUP=$(ls -dt ${BACKUP_DIR_PREFIX}* 2>/dev/null | head -n1)
  if [ -z "$LAST_BACKUP" ]; then
    echo -e "${RED}No backup found!${RESET}"
    exit 1
  fi
  echo -e "${CYAN}Restoring from backup: ${YELLOW}$LAST_BACKUP${RESET}"
  sudo cp -a "$LAST_BACKUP/sources.list"* "$APT_ROOT/" 2>/dev/null || true
  sudo cp -a "$LAST_BACKUP/sources.list.d" "$APT_ROOT/" 2>/dev/null || true
  sudo cp -a "$LAST_BACKUP/trusted.gpg"* "$APT_ROOT/" 2>/dev/null || true
  sudo cp -a "$LAST_BACKUP/trusted.gpg.d" "$APT_ROOT/" 2>/dev/null || true
  echo -e "${GREEN}Restore complete! You can now run: sudo apt update${RESET}"
}

show_backups() {
  logo
  echo -e "${CYAN}Available backups:${RESET}"
  ls -dt ${BACKUP_DIR_PREFIX}* 2>/dev/null | while read -r dir; do
    echo -e "${YELLOW}  - $dir${RESET}"
  done
}

main_menu() {
  while true; do
    clear
    logo
    echo -e "${BOLD}${BLUE}============== MIRO MENU ==============${RESET}"
    echo -e "${CYAN}1)${RESET} ${GREEN}Optimize Ubuntu mirrors (recommended)${RESET}"
    echo -e "${CYAN}2)${RESET} ${YELLOW}Restore last backup${RESET}"
    echo -e "${CYAN}3)${RESET} ${MAGENTA}Show backup info${RESET}"
    echo -e "${CYAN}4)${RESET} ${RED}Exit${RESET}"
    echo -e "${BOLD}${BLUE}=======================================${RESET}"
    read -p "$(echo -e "${BOLD}Select an option [1/2/3/4]: ${RESET}")" choice

    case "$choice" in
      1) optimize_sources; read -p "$(echo -e "${YELLOW}Press enter to return to menu...${RESET}")" ;;
      2) restore_backup;  read -p "$(echo -e "${YELLOW}Press enter to return to menu...${RESET}")" ;;
      3) show_backups;   read -p "$(echo -e "${YELLOW}Press enter to return to menu...${RESET}")" ;;
      4) echo -e "${BOLD}${GREEN}Goodbye!${RESET}"; exit 0 ;;
      *) echo -e "${RED}Invalid option! Try again.${RESET}"; sleep 1 ;;
    esac
  done
}

if [ "$#" -gt 0 ]; then
  case "$1" in
    1) optimize_sources ;;
    2) restore_backup ;;
    3) show_backups ;;
    4) echo -e "${BOLD}${GREEN}Goodbye!${RESET}"; exit 0 ;;
    *) echo -e "${RED}Usage: $0 [1|2|3|4]${RESET}"; exit 1 ;;
  esac
else
  main_menu
fi
