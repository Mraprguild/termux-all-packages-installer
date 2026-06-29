#!/data/data/com.termux/files/usr/bin/bash
# =========================================================
# Mraprguild Termux All Essential Packages Installer
# Author : Mraprguild
# GitHub : https://github.com/Mraprguild
# Purpose: Safe Termux essential packages installer
# =========================================================

set -uo pipefail

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'

FAILED_PACKAGES=()
INSTALLED_GROUPS=0

sleep_fast() { sleep 0.03; }

line() {
  echo -e "${DIM}────────────────────────────────────────────────────────────${NC}"
}

slow_print() {
  local text="$1"
  local i
  for ((i=0; i<${#text}; i++)); do
    printf "%s" "${text:$i:1}"
    sleep_fast
  done
  printf "\n"
}

spinner() {
  local pid=$1
  local message="$2"
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i+1) % ${#spin} ))
    printf "\r${CYAN}%s${NC} %s" "${spin:$i:1}" "$message"
    sleep 0.1
  done
  printf "\r${GREEN}✓${NC} %s\n" "$message"
}

banner() {
  clear
  echo -e "${CYAN}"
  cat <<'EOF'
███╗   ███╗██████╗  █████╗ ██████╗ ██████╗  ██████╗ ██╗   ██╗██╗██╗     ██████╗
████╗ ████║██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝ ██║   ██║██║██║     ██╔══██╗
██╔████╔██║██████╔╝███████║██████╔╝██████╔╝██║  ███╗██║   ██║██║██║     ██║  ██║
██║╚██╔╝██║██╔══██╗██╔══██║██╔═══╝ ██╔══██╗██║   ██║██║   ██║██║██║     ██║  ██║
██║ ╚═╝ ██║██║  ██║██║  ██║██║     ██║  ██║╚██████╔╝╚██████╔╝██║███████╗██████╔╝
╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝
EOF
  echo -e "${NC}"
  echo -e "${GREEN}⚡ Termux All Essential Packages Installer${NC}"
  echo -e "${YELLOW}Safe package collection for coding, web, network, media and Linux tools${NC}"
  line
}

check_termux() {
  if [ ! -d "/data/data/com.termux/files/usr" ]; then
    echo -e "${RED}This script is designed for Termux only.${NC}"
    exit 1
  fi
}

run_step() {
  local title="$1"
  shift
  echo -e "\n${BLUE}▶ ${title}${NC}"
  "$@" &
  local pid=$!
  spinner "$pid" "$title"
  wait "$pid"
  return $?
}

safe_pkg_install() {
  local package="$1"
  printf "${CYAN}Installing:${NC} %-22s" "$package"
  if pkg install -y "$package" >/dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
  else
    echo -e "${YELLOW}SKIPPED${NC}"
    FAILED_PACKAGES+=("$package")
  fi
}

install_group() {
  local group_name="$1"
  shift
  local packages=("$@")
  echo -e "\n${MAGENTA}╭─ ${group_name}${NC}"
  echo -e "${MAGENTA}╰─ Packages: ${#packages[@]}${NC}"
  line
  local pkg_name
  for pkg_name in "${packages[@]}"; do
    safe_pkg_install "$pkg_name"
  done
  INSTALLED_GROUPS=$((INSTALLED_GROUPS + 1))
}

summary() {
  line
  echo -e "${GREEN}✅ Installation finished.${NC}"
  echo -e "${CYAN}Groups processed:${NC} ${INSTALLED_GROUPS}"
  if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
    echo -e "${YELLOW}Skipped/unavailable packages:${NC} ${FAILED_PACKAGES[*]}"
    echo -e "${DIM}Reason: package unavailable on mirror, repo not enabled, or temporary network issue.${NC}"
  else
    echo -e "${GREEN}All selected packages installed successfully.${NC}"
  fi
  echo
  echo -e "${WHITE}Test commands:${NC}"
  echo "  neofetch"
  echo "  python --version"
  echo "  node --version"
  echo "  php -v"
  echo "  nginx -v"
  echo "  proot-distro list"
  echo "  ffmpeg -version"
  echo
  echo -e "${YELLOW}Restart Termux for best result.${NC}"
}

main() {
  banner
  check_termux
  slow_print "Starting Mraprguild Termux setup..."

  run_step "Updating package index" pkg update -y || true
  run_step "Upgrading installed packages" pkg upgrade -y || true

  echo -e "\n${BLUE}▶ Storage permission${NC}"
  termux-setup-storage || echo -e "${YELLOW}Storage permission skipped. Run termux-setup-storage later if needed.${NC}"

  CORE_PACKAGES=(
    git wget curl nano vim micro less tree neofetch figlet toilet
    openssh openssl-tool termux-api jq bc htop tmux screen
  )

  DEVELOPMENT_PACKAGES=(
    python python-pip nodejs php ruby clang make cmake pkg-config
    autoconf automake libtool binutils gdb
  )

  WEB_PACKAGES=(
    apache2 nginx mariadb sqlite php-apache
  )

  NETWORK_PACKAGES=(
    nmap dnsutils whois traceroute net-tools iproute2 openssh
  )

  ARCHIVE_PACKAGES=(
    zip unzip tar gzip bzip2 xz-utils p7zip unrar
  )

  MEDIA_PACKAGES=(
    ffmpeg imagemagick exiftool
  )

  LINUX_PACKAGES=(
    proot proot-distro
  )

  OPTIONAL_REPOS=(
    root-repo x11-repo
  )

  install_group "Core Tools" "${CORE_PACKAGES[@]}"
  install_group "Developer Tools" "${DEVELOPMENT_PACKAGES[@]}"
  install_group "Web Server Tools" "${WEB_PACKAGES[@]}"
  install_group "Network Tools" "${NETWORK_PACKAGES[@]}"
  install_group "Archive Tools" "${ARCHIVE_PACKAGES[@]}"
  install_group "Media Tools" "${MEDIA_PACKAGES[@]}"
  install_group "Linux / Proot Tools" "${LINUX_PACKAGES[@]}"
  install_group "Optional Repositories" "${OPTIONAL_REPOS[@]}"

  echo -e "\n${BLUE}▶ Python tools${NC}"
  python -m pip install --upgrade pip setuptools wheel >/dev/null 2>&1 || true
  for pip_tool in requests flask rich colorama yt-dlp speedtest-cli; do
    printf "${CYAN}pip install:${NC} %-20s" "$pip_tool"
    if python -m pip install --upgrade "$pip_tool" >/dev/null 2>&1; then
      echo -e "${GREEN}OK${NC}"
    else
      echo -e "${YELLOW}SKIPPED${NC}"
    fi
  done

  summary
}

main "$@"
