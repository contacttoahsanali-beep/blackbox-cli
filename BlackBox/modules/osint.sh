#!/bin/bash
source core/colors.sh

osint_menu() {
  echo -e "${BLUE}[ OSINT – Username Finder ]${RESET}"
  read -p "Username: " USER

  if [ -z "$USER" ]; then
    echo -e "${RED}Username missing${RESET}"
    return
  fi

  OUT="reports/osint-$USER"
  mkdir -p "$OUT"

  SUMMARY="$OUT/summary.txt"
  {
    echo "Tool   : BlackBox"
    echo "Author : Ahsan"
    echo "Date   : $(date)"
    echo "Target : $USER"
    echo "----------------------"
  } > "$SUMMARY"

  check_site() {
    NAME=$1
    URL=$2

    if curl -s -o /dev/null -w "%{http_code}" "$URL" | grep -q "200"; then
      echo "[+] $NAME : FOUND"
      echo "$NAME : FOUND ($URL)" >> "$SUMMARY"
    else
      echo "[-] $NAME : Not found"
      echo "$NAME : Not found" >> "$SUMMARY"
    fi
  }

  echo -e "${CYAN}[*] Checking platforms...${RESET}"

  check_site "GitHub"     "https://github.com/$USER"
  check_site "Twitter(X)" "https://x.com/$USER"
  check_site "Instagram"  "https://www.instagram.com/$USER"
  check_site "Reddit"     "https://www.reddit.com/user/$USER"

  echo -e "${GREEN}[✓] OSINT check done. Saved in $OUT${RESET}"
}
