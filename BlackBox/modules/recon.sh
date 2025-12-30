#!/bin/bash
source core/colors.sh

is_private_ip() {
  [[ $1 =~ ^10\. ]] ||
  [[ $1 =~ ^192\.168\. ]] ||
  [[ $1 =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]]
}

recon_menu() {
  echo -e "${BLUE}[ Recon Module ]${RESET}"
  read -p "Target (domain/IP): " TARGET

  if [ -z "$TARGET" ]; then
    echo -e "${RED}Target missing${RESET}"
    return
  fi

  OUT="reports/$TARGET"
  mkdir -p "$OUT"

  echo -e "${CYAN}[*] Pinging...${RESET}"
  ping -c 3 "$TARGET" > "$OUT/ping.txt" 2>/dev/null

  echo -e "${CYAN}[*] DNS info...${RESET}"
  dig "$TARGET" > "$OUT/dns.txt" 2>/dev/null

  # WHOIS logic
  if is_private_ip "$TARGET"; then
    echo -e "${YELLOW}[!] Private IP detected — WHOIS skipped${RESET}"
    echo "Private IP (RFC1918) — WHOIS not applicable" > "$OUT/whois.txt"
  else
    echo -e "${CYAN}[*] WHOIS info...${RESET}"
    whois "$TARGET" > "$OUT/whois.txt" 2>/dev/null
  fi

  echo -e "${CYAN}[*] Nmap fast scan...${RESET}"
  nmap -F "$TARGET" > "$OUT/nmap.txt" 2>/dev/null

  echo -e "${GREEN}[✓] Recon done. Clean results saved in $OUT${RESET}"
}
echo "Author : Ahsan"        >> "$summary.txt"
echo "Tool   : BlackBox"     >> "$summary.txt"
echo "Date   : $(date)"      >> "$summary.txt"
