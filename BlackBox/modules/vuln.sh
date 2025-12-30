#!/bin/bash

# ===== Colors =====
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

vuln_menu() {

  echo -e "${BLUE}[ Vulnerability Check (Live) ]${RESET}"

  read -p "Target IP / Domain (example: 192.168.100.106 or example.com): " TARGET

  if [ -z "$TARGET" ]; then
    echo -e "${RED}Target missing${RESET}"
    return
  fi

  # Safe folder name (replace special chars)
  SAFE_TARGET=$(echo "$TARGET" | sed 's#[^a-zA-Z0-9._-]#_#g')

  OUTDIR="reports/vuln-$SAFE_TARGET"
  mkdir -p "$OUTDIR"

  echo -e "${CYAN}[*] Running fast port scan on $TARGET ...${RESET}"
  nmap -F "$TARGET" -oG "$OUTDIR/scan.gnmap" 2>/dev/null

  grep "/open/" "$OUTDIR/scan.gnmap" > "$OUTDIR/open_ports.txt"

  if [ ! -s "$OUTDIR/open_ports.txt" ]; then
    echo -e "${YELLOW}[!] No open ports found${RESET}"
    return
  fi

  OUT="$OUTDIR/vuln_snapshot.txt"

  {
    echo "Vulnerability Snapshot (Live)"
    echo "Target   : $TARGET"
    echo "Scan Time: $(date)"
    echo "Author   : Ahsan"
    echo "----------------------------------"
  } > "$OUT"

  echo -e "${CYAN}[*] Analyzing services...${RESET}"

  while read -r LINE; do
    PORT=$(echo "$LINE" | grep -oE '[0-9]+/open' | cut -d'/' -f1)

    case "$PORT" in
      21)  SERVICE="FTP";     RISK="MEDIUM" ;;
      22)  SERVICE="SSH";     RISK="LOW" ;;
      23)  SERVICE="TELNET";  RISK="HIGH" ;;
      80)  SERVICE="HTTP";    RISK="LOW" ;;
      443) SERVICE="HTTPS";   RISK="LOW" ;;
      3306)SERVICE="MySQL";   RISK="MEDIUM" ;;
      3389)SERVICE="RDP";     RISK="HIGH" ;;
      *)   SERVICE="Unknown"; RISK="INFO" ;;
    esac

    echo "Port $PORT ($SERVICE) → Risk: $RISK" | tee -a "$OUT"
  done < "$OUTDIR/open_ports.txt"

  echo -e "${GREEN}[✓] Vulnerability check completed${RESET}"
  echo -e "${GREEN}[✓] Report saved:${RESET} $OUT"
}

