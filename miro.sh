#!/usr/bin/env bash
set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RESET='\033[0m'
BOLD='\033[1m'
BACKUP_DIR="/etc/apt/sources-cleanup-backup-$(date +%Y%m%d%H%M%S)"
APT_SOURCE_FILE="/etc/apt/sources.list"
MIRRORS=(
  "http://ir.archive.ubuntu.com/ubuntu/"
  "http://mirror.isiri.gov.ir/ubuntu/"
  "http://repo.iut.ac.ir/repo/ubuntu/"
  "http://ubuntu.mirrors.tds.net/ubuntu/"
  "http://mirror.sbu.ac.ir/ubuntu/"
  "http://mirror1.tunisia.tn/ubuntu/"
  "http://mirror.kntu.ac.ir/ubuntu/"
  "http://ubuntu.mirror.cambrium.nl/ubuntu/"
  "http://ubuntu.mirror.as43289.net/ubuntu/"
  "http://mirror.linuxservic.es/ubuntu/"
  "http://ftp.ubuntu.ir/ubuntu/"
  "http://mirror.abrainian.ir/ubuntu/"
  "http://mirror.rasanegar.com/ubuntu/"
  "http://ubuntu.mirror.rafed.net/ubuntu/"
  "http://mirror.technion.ac.il/ubuntu/"
  "http://ubuntu.trumpet.com.au/ubuntu/"
  "http://archive.ubuntu.com/ubuntu/"
  "http://ftp.ubuntu.com/ubuntu/"
  "http://de.archive.ubuntu.com/ubuntu/"
  "http://mirror.plusserver.com/ubuntu/"
  "http://gb.archive.ubuntu.com/ubuntu/"
  "http://us.archive.ubuntu.com/ubuntu/"
  "http://fr.archive.ubuntu.com/ubuntu/"
  "http://nl.archive.ubuntu.com/ubuntu/"
  "http://se.archive.ubuntu.com/ubuntu/"
  "http://mirror.yandex.ru/ubuntu/"
  "http://mirror.pnl.gov/ubuntu/"
  "http://ftp.heanet.ie/pub/ubuntu/"
  "http://mirror.enzu.com/ubuntu/"
  "http://ubuntu.mirrors.estointernet.in/ubuntu/"
  "http://ftp.cuhk.edu.hk/pub/Linux/ubuntu/"
  "http://ftp.jaist.ac.jp/pub/Linux/ubuntu/"
  "http://ftp.tsukuba.wide.ad.jp/Linux/ubuntu/"
  "http://ftp.yz.yamagata-u.ac.jp/pub/linux/ubuntu/"
  "http://mirror.nus.edu.sg/ubuntu/"
  "http://ubuntu.mirror.serversaustralia.com.au/ubuntu/"
)
detect_ubuntu_codename() {
  if command -v lsb_release >/dev/null 2>&1; then
    CODENAME=$(lsb_release -sc)
    VERSION=$(lsb_release -sr)
    echo -e "${GREEN}✔️ Ubuntu detected: $CODENAME ($VERSION)${RESET}"
  elif [ -f /etc/os-release ]; then
    . /etc/os-release
    CODENAME=$VERSION_CODENAME
    VERSION=$VERSION_ID
    if [[ -n $CODENAME ]]; then
      echo -e "${GREEN}✔️ Ubuntu detected: $CODENAME ($VERSION)${RESET}"
    else
      echo -e "${RED}❌ Could not detect Ubuntu codename from /etc/os-release.${RESET}"
      exit 1
    fi
  else
    echo -e "${RED}❌ Could not detect Ubuntu version/codename on this system.${RESET}"
    exit 1
  fi
}
backup_sources() {
  echo -e "${CYAN}🔒 Backing up your APT sources and keys...${RESET}"
  if sudo mkdir -p "$BACKUP_DIR" && \
     sudo cp -a /etc/apt/sources.list* "$BACKUP_DIR/" 2>/dev/null && \
     sudo cp -a /etc/apt/trusted.gpg* "$BACKUP_DIR/" 2>/dev/null && \
     sudo cp -a /etc/apt/trusted.gpg.d "$BACKUP_DIR/" 2>/dev/null; then
    echo -e "${GREEN}✔️ Backup completed successfully! Path: $BACKUP_DIR${RESET}"
  else
    echo -e "${RED}⚠️ Backup failed! Please check your permissions.${RESET}"
  fi
}
ping_mirrors() {
  echo -e "${CYAN}🌐 Checking mirrors latency (ping < 50ms)...${RESET}"
  declare -A PING_RESULTS
  local found_fast=0
  for mirror in "${MIRRORS[@]}"; do
    HOST=$(echo $mirror | awk -F/ '{print $3}')
    PING=$(ping -c 2 -q "$HOST" | awk -F'/' '/^rtt/ {print int($5)}')
    if [[ -n "$PING" && "$PING" -lt 50 ]]; then
      PING_RESULTS["$mirror"]=$PING
      found_fast=1
      echo -e "${GREEN}✔️ $mirror: ${PING}ms${RESET}"
    else
      echo -e "${YELLOW}⏩ $mirror: Slow or unreachable (${PING:-N/A}ms)${RESET}"
    fi
  done
  if [[ $found_fast -eq 0 ]]; then
    echo -e "${RED}⚠️ No fast mirror found under 50ms. All mirrors will be considered for speed test.${RESET}"
  fi
  for k in "${!PING_RESULTS[@]}"; do
    echo "${PING_RESULTS[$k]} $k"
  done | sort -n
}
speed_test_mirrors() {
  local candidates=("$@")
  echo -e "${CYAN}🚀 Testing download speeds...${RESET}"
  declare -A SPEED_RESULTS
  local found_fast=0
  for mirror in "${candidates[@]}"; do
    TEST_URL="${mirror}dists/$CODENAME/Release"
    SPEED=$(curl -r 0-1048576 -s -w '%{speed_download}' -o /dev/null "$TEST_URL" || echo 0)
    SPEED_INT=$(printf "%.0f" "$SPEED")
    if [[ "$SPEED_INT" -gt 0 ]]; then
      SPEED_RESULTS["$mirror"]=$SPEED_INT
      found_fast=1
      echo -e "${GREEN}✔️ $mirror: $((SPEED_INT/1024)) KB/s${RESET}"
    else
      echo -e "${YELLOW}⏩ $mirror: Slow or failed${RESET}"
    fi
  done
  if [[ $found_fast -eq 0 ]]; then
    echo -e "${RED}⚠️ No mirror responded to speed test. All mirrors will be used as fallback.${RESET}"
  fi
  for k in "${!SPEED_RESULTS[@]}"; do
    echo "${SPEED_RESULTS[$k]} $k"
  done | sort -nr | head -n 4
}
update_sources_list() {
  local mirrors=("$@")
  echo -e "${CYAN}📝 Writing new sources.list...${RESET}"
  if sudo cp "$APT_SOURCE_FILE" "$APT_SOURCE_FILE.bak-$(date +%Y%m%d%H%M%S)" && echo "" | sudo tee "$APT_SOURCE_FILE" >/dev/null; then
    for m in "${mirrors[@]}"; do
      echo "deb $m $CODENAME main restricted universe multiverse" | sudo tee -a "$APT_SOURCE_FILE" >/dev/null
      echo "deb $m $CODENAME-updates main restricted universe multiverse" | sudo tee -a "$APT_SOURCE_FILE" >/dev/null
      echo "deb $m $CODENAME-backports main restricted universe multiverse" | sudo tee -a "$APT_SOURCE_FILE" >/dev/null
      echo "deb $m $CODENAME-security main restricted universe multiverse" | sudo tee -a "$APT_SOURCE_FILE" >/dev/null
    done
    echo -e "${GREEN}✔️ sources.list updated successfully! You can now run: sudo apt update${RESET}"
  else
    echo -e "${RED}❌ Failed to update sources.list!${RESET}"
  fi
}
main_menu() {
  while true; do
    clear
    echo -e "${BOLD}${BLUE}============== MIRO MENU ==============${RESET}"
    echo -e "${CYAN}1)${RESET} ${GREEN}Optimize Ubuntu mirrors (recommended)${RESET}"
    echo -e "${CYAN}2)${RESET} ${YELLOW}Restore last backup${RESET}"
    echo -e "${CYAN}3)${RESET} ${MAGENTA}Show backup info${RESET}"
    echo -e "${CYAN}4)${RESET} ${RED}Uninstall miro & all backups${RESET}"
    echo -e "${CYAN}5)${RESET} ${RED}Exit${RESET}"
    echo -e "${BOLD}${BLUE}=======================================${RESET}"
    read -p "$(echo -e "${BOLD}Select an option [1/2/3/4/5]: ${RESET}")" choice
    case "$choice" in
      1) optimize_sources; read -p "$(echo -e "${YELLOW}Press enter to return to menu...${RESET}")" ;;
      2) restore_backup;  read -p "$(echo -e "${YELLOW}Press enter to return to menu...${RESET}")" ;;
      3) show_backups;   read -p "$(echo -e "${YELLOW}Press enter to return to menu...${RESET}")" ;;
      4) uninstall_project ;;
      5) exit 0 ;;
      *) echo -e "${RED}Invalid choice! Try again.${RESET}" ;;
    esac
  done
}
optimize_sources() {
  detect_ubuntu_codename
  backup_sources
  local fast_mirrors=()
  while read -r line; do
    mirror=$(echo "$line" | cut -d' ' -f2-)
    fast_mirrors+=("$mirror")
  done < <(ping_mirrors)
  if [[ ${#fast_mirrors[@]} -eq 0 ]]; then
    echo -e "${YELLOW}⏩ No fast mirrors found. Using all available mirrors for speed test.${RESET}"
    fast_mirrors=("${MIRRORS[@]}")
  fi
  local best_mirrors=()
  while read -r line; do
    mirror=$(echo "$line" | cut -d' ' -f2-)
    best_mirrors+=("$mirror")
  done < <(speed_test_mirrors "${fast_mirrors[@]}")
  if [[ ${#best_mirrors[@]} -eq 0 ]]; then
    echo -e "${YELLOW}⏩ No fast downloads. Using all available mirrors.${RESET}"
    best_mirrors=("${MIRRORS[@]}")
  fi
  update_sources_list "${best_mirrors[@]}"
}
restore_backup() {
  echo -e "${CYAN}📂 Available backups:${RESET}"
  local found=0
  ls -dt /etc/apt/sources-cleanup-backup-* 2>/dev/null | while read -r dir; do
    found=1
    echo -e "${YELLOW}  - $dir${RESET}"
  done
  if [[ $found -eq 0 ]]; then
    echo -e "${RED}⚠️ No backup found.${RESET}"
    return
  fi
  read -p "Enter backup directory to restore: " backup_dir
  if [[ -d "$backup_dir" ]]; then
    sudo cp -a "$backup_dir/"sources.list* /etc/apt/
    sudo cp -a "$backup_dir/"trusted.gpg* /etc/apt/
    sudo cp -a "$backup_dir/"trusted.gpg.d /etc/apt/
    echo -e "${GREEN}✔️ Restore complete! Run: sudo apt update${RESET}"
  else
    echo -e "${RED}❌ Backup directory not found!${RESET}"
  fi
}
show_backups() {
  echo -e "${CYAN}📂 Available backups:${RESET}"
  local found=0
  ls -dt /etc/apt/sources-cleanup-backup-* 2>/dev/null | while read -r dir; do
    found=1
    echo -e "${YELLOW}  - $dir${RESET}"
  done
  if [[ $found -eq 0 ]]; then
    echo -e "${RED}⚠️ No backup found.${RESET}"
  fi
}
uninstall_project() {
  echo -e "${RED}${BOLD}⚠️  This will completely remove all miro backups and the script itself!${RESET}"
  read -p "$(echo -e "${YELLOW}Are you sure you want to uninstall everything? (y/N): ${RESET}")" confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Uninstall cancelled.${RESET}"
    return
  fi
  sudo rm -rf /etc/apt/sources-cleanup-backup-* 2>/dev/null || true
  sudo rm -f /usr/local/bin/miro 2>/dev/null || true
  SCRIPT_PATH="$(realpath "$0")"
  rm -f "$SCRIPT_PATH" 2>/dev/null || true
  echo -e "${GREEN}${BOLD}✔️ miro and all backups have been removed from this system.${RESET}"
  exit 0
}
main_menu
