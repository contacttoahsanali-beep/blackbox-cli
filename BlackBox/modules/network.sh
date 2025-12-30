#!/bin/bash
source core/colors.sh

network_scan() {
  echo -e "${BLUE}[ Local Network Scanner ]${RESET}"

  # Local IP detect
  LOCAL_IP=$(ip route get 1 | awk '{print $7; exit}')
  if [ -z "$LOCAL_IP" ]; then
    echo -e "${RED}Local IP detect nahi ho saka${RESET}"
    return
  fi

  SUBNET=$(echo "$LOCAL_IP" | awk -F. '{print $1"."$2"."$3".0/24"}')
  OUT="reports/network-$(echo $SUBNET | tr '/' '-')"
  mkdir -p "$OUT"

  SUMMARY="$OUT/summary.txt"
  {
    echo "Tool   : BlackBox"
    echo "Author : Ahsan"
    echo "Date   : $(date)"
    echo "Subnet : $SUBNET"
    echo "----------------------"
  } > "$SUMMARY"

  echo -e "${CYAN}[*] Discovering live hosts...${RESET}"
nmap -sn "$SUBNET" -oG - > "$OUT/.hosts.gnmap" 2>/dev/null

# Extract only alive IPs
grep "Up" "$OUT/.hosts.gnmap" | awk '{print $2}' > "$OUT/live_hosts.txt"

HOST_COUNT=$(wc -l < "$OUT/live_hosts.txt")
echo "Hosts  : $HOST_COUNT alive" >> "$SUMMARY"

echo -e "${CYAN}[*] Found $HOST_COUNT live hosts${RESET}"

if [ "$HOST_COUNT" -eq 0 ]; then
  echo -e "${YELLOW}[!] No live hosts found${RESET}"
  return
fi

echo -e "${CYAN}[*] Scanning open ports (fast)...${RESET}"
nmap -F -iL "$OUT/live_hosts.txt" -oG - > "$OUT/.ports.gnmap" 2>/dev/null

# Extract open ports only
grep "/open/" "$OUT/.ports.gnmap" | \
awk '{print $2 " -> " $4}' > "$OUT/open_ports.txt"

PORT_LINES=$(wc -l < "$OUT/open_ports.txt")
echo "Ports  : $PORT_LINES open entries" >> "$SUMMARY"

}
