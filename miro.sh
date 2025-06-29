#!/bin/bash

set -e

APT_ROOT="/etc/apt"
SOURCES_FILE="$APT_ROOT/sources.list"
BACKUP_DIR_PREFIX="${APT_ROOT}/sources-cleanup-backup-"
TMPDIR="/tmp/miro_mirrors_$$"
TOP_N=3 # Number of fastest mirrors to use
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
  "http://archive.ubuntu.com/ubuntu/"
  "http://security.ubuntu.com/ubuntu/"
)

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
  UBUNTU_CODENAME=$(detect_codename)
  if [ "$UBUNTU_CODENAME" = "unknown" ] || [ -z "$UBUNTU_CODENAME" ]; then
    echo "❌ Could not detect Ubuntu codename!"
    exit 1
  fi

  BACKUP_DATE="$(date -u +%Y%m%d-%H%M%S)"
  BACKUP_DIR="${APT_ROOT}/sources-cleanup-backup-$BACKUP_DATE"

  echo "🔎 Detected Ubuntu codename: $UBUNTU_CODENAME"
  echo "🔍 Backing up all sources and key files to $BACKUP_DIR ..."
  sudo mkdir -p "$BACKUP_DIR"
  sudo cp -a $APT_ROOT/sources.list* "$BACKUP_DIR/" 2>/dev/null || true
  sudo cp -a $APT_ROOT/sources.list.d "$BACKUP_DIR/" 2>/dev/null || true
  sudo cp -a $APT_ROOT/trusted.gpg* "$BACKUP_DIR/" 2>/dev/null || true
  sudo cp -a $APT_ROOT/trusted.gpg.d "$BACKUP_DIR/" 2>/dev/null || true

  # Remove ubuntu.sources if exists
  UBUNTU_SOURCES="$APT_ROOT/sources.list.d/ubuntu.sources"
  if [ -f "$UBUNTU_SOURCES" ]; then
    echo "⛔️ Removing $UBUNTU_SOURCES"
    sudo rm -f "$UBUNTU_SOURCES"
  fi

  sudo cp "$SOURCES_FILE" "$SOURCES_FILE.bak-$BACKUP_DATE"

  echo ""
  echo "🚀 Quickly testing mirrors: ping, HTTP, and minimal speed test..."
  mkdir -p "$TMPDIR"
  > "$TMPDIR/speed.txt"

  for MIRROR in "${MIRRORS[@]}"; do
    host=$(echo "$MIRROR" | awk -F/ '{print $3}')
    echo -n "⏳ Testing $host ... "
    if ping -c 1 -W 1 "$host" &>/dev/null; then
      echo -n "Ping OK, HTTP ... "
      TEST_URL="${MIRROR}$(printf "$TEST_PATH_TEMPLATE" "$UBUNTU_CODENAME")"
      if curl -s --head --max-time 3 "$TEST_URL" | grep -q "200 OK"; then
        echo -n "200 OK, speed ... "
        SPEED=$(curl -s -L --max-time 3 --output /dev/null --write-out '%{speed_download}' "$TEST_URL")
        if [[ "$SPEED" =~ ^[0-9]+$ || "$SPEED" =~ ^[0-9]+\.[0-9]+$ ]]; then
          SPEEDKB=$(awk "BEGIN {printf \"%.2f\", $SPEED/1024}")
          echo "Speed: $SPEEDKB KB/s"
          echo -e "$SPEED\t$MIRROR" >> "$TMPDIR/speed.txt"
        else
          echo "Speed Test Failed"
        fi
      else
        echo "❌ No HTTP 200"
      fi
    else
      echo "❌ No ping"
    fi
  done

  echo ""
  echo "🏁 Sorting results, picking top $TOP_N fastest mirrors..."

  sort -rn "$TMPDIR/speed.txt" | awk '!seen[$2]++' | head -n $TOP_N > "$TMPDIR/top.txt"

  echo "# Cleaned and rebuilt on $(date -u) by miro.sh" | sudo tee "$SOURCES_FILE" > /dev/null

  while read -r line; do
    MIRROR=$(echo "$line" | cut -f2)
    SPEED=$(echo "$line" | cut -f1)
    echo "✅ Adding $MIRROR (Speed: $(awk "BEGIN {printf \"%.2f\", $SPEED/1024}") KB/s)"
    for suite in "" "-updates" "-backports" "-security"; do
      echo "deb ${MIRROR} ${UBUNTU_CODENAME}${suite} main restricted universe multiverse" | sudo tee -a "$SOURCES_FILE" > /dev/null
    done
  done < "$TMPDIR/top.txt"

  # Update apt keys (just update, do NOT delete any keys)
  echo "🔑 Refreshing apt keys..."
  if command -v apt-key &>/dev/null; then
    sudo apt-key update || true
    sudo apt-key net-update || true
  fi

  # Refresh trusted.gpg.d (not removal, just reload)
  if [ -d /etc/apt/trusted.gpg.d ]; then
    for keyring in /etc/apt/trusted.gpg.d/*.gpg; do
      [ -f "$keyring" ] || continue
      sudo apt-key add "$keyring" 2>/dev/null || true
    done
  fi

  echo ""
  echo "✅ sources.list rebuilt with top $TOP_N fastest mirrors for $UBUNTU_CODENAME, apt keys updated/refreshed."
  echo "⚠️  Backups saved at $BACKUP_DIR and /etc/apt/sources.list.bak-$BACKUP_DATE"
  echo ""
  echo "📦 You can now run: sudo apt update"
  echo ""
  echo "Mirrors sorted by speed (KB/s):"
  awk '{printf "  - %s (%.2f KB/s)\n", $2, $1/1024}' "$TMPDIR/speed.txt" | head -n $TOP_N

  rm -rf "$TMPDIR"
}

restore_backup() {
  LAST_BACKUP=$(ls -dt ${BACKUP_DIR_PREFIX}* 2>/dev/null | head -n1)
  if [ -z "$LAST_BACKUP" ]; then
    echo "❌ No backup found!"
    exit 1
  fi
  echo "♻️ Restoring from backup: $LAST_BACKUP"
  sudo cp -a "$LAST_BACKUP/sources.list"* "$APT_ROOT/" 2>/dev/null || true
  sudo cp -a "$LAST_BACKUP/sources.list.d" "$APT_ROOT/" 2>/dev/null || true
  sudo cp -a "$LAST_BACKUP/trusted.gpg"* "$APT_ROOT/" 2>/dev/null || true
  sudo cp -a "$LAST_BACKUP/trusted.gpg.d" "$APT_ROOT/" 2>/dev/null || true
  echo "✅ Restore complete! You can now run: sudo apt update"
}

show_backups() {
  echo "📂 Available backups:"
  ls -dt ${BACKUP_DIR_PREFIX}* 2>/dev/null | while read -r dir; do
    echo "  - $dir"
  done
}

main_menu() {
  while true; do
    echo "============== MIRO MENU =============="
    echo "1) Optimize Ubuntu mirrors (recommended)"
    echo "2) Restore last backup"
    echo "3) Show backup info"
    echo "q) Quit"
    echo "======================================="
    read -p "Select an option [1/2/3/q]: " choice

    case "$choice" in
      1) optimize_sources ;;
      2) restore_backup ;;
      3) show_backups ;;
      q|Q) echo "Goodbye!"; exit 0 ;;
      *) echo "Invalid option! Try again." ;;
    esac
    echo
  done
}

# If script is called with arguments
if [ "$#" -gt 0 ]; then
  case "$1" in
    1) optimize_sources ;;
    2) restore_backup ;;
    3) show_backups ;;
    q|Q) echo "Goodbye!"; exit 0 ;;
    *) echo "Usage: $0 [1|2|3|q]"; exit 1 ;;
  esac
else
  main_menu
fi
