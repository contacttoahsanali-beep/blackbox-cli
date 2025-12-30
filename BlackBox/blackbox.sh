#!/bin/bash

# =========================
# BlackBox Main Controller
# Author : Ahsan
# Version: v1.0
# =========================

VERSION="v1.0"

# Core files
source core/colors.sh
source core/banner.sh
source modules/recon.sh
source modules/network.sh
source modules/osint.sh
source modules/vuln.sh

# About flag
if [[ "$1" == "--about" ]]; then
  echo -e "${CYAN}BlackBox - Modular Bash CLI Framework${RESET}"
  echo -e "Author  : Ahsan"
  echo -e "Version : $VERSION"
  echo -e "Purpose : Recon, automation & learning"
  exit 0
fi

# Main loop
while true; do
  echo -e "${GREEN}[1] Recon${RESET}"
  echo -e "${GREEN}[2] Local Network Scan${RESET}"
  echo -e "${GREEN}[3] OSINT (Username)${RESET}"
  echo -e "${GREEN}[4] Vulnerability Snapshot${RESET}"
  echo -e "${GREEN}[5] Exit${RESET}"


  echo

  read -p "Select option: " CHOICE
  echo

  case $CHOICE in
  1) recon_menu ;;
  2) network_scan ;;
  4) vuln_menu ;;
  5) echo -e "${YELLOW}Bye 👋${RESET}"; exit 0 ;;
  *) echo -e "${RED}Invalid option${RESET}" ;;
esac


  echo
done
