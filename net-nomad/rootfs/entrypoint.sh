#!/usr/bin/env sh
set -euo pipefail

# -------- Config por ENV --------
FW_DNS="${FW_DNS:-}"                 # "DNS SERVER IP[,DNS SERVER IP2,...]" omitir = no permitir DNS
FW_EGRESS="${FW_EGRESS:-false}"      # "true"|"false" omitir = false
FW_ALLOW_IN="${FW_ALLOW_IN:-}"       # "SRC:PROTO[:PORT]" PORT: 443 | 8000-9000 | omitir = todo
FW_ALLOW_OUT="${FW_ALLOW_OUT:-}"     # "DST:PROTO[:PORT]" PORT: 443 | 8000-9000 | omitir = todo

# -------- Helpers --------
trim() { awk '{$1=$1};1'; }

# -------- Interfaz --------
IFACE="$(ip -4 -o addr show | awk '!/ lo /{print $2; exit}')"
ALLOC_IP="$(ip -4 -o addr show dev "$IFACE" | awk '{print $4}' | cut -d/ -f1 || true)"

# -------- iptables (nf_tables) --------
# Limpieza
iptables -F INPUT || true
iptables -F OUTPUT || true
iptables -F FORWARD || true
iptables -X || true

# Políticas base
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Estado / loopback / ICMP / hairpin intra-group
iptables -A INPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT  -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT  -d "$ALLOC_IP" -s "$ALLOC_IP" -j ACCEPT
iptables -A OUTPUT -s "$ALLOC_IP" -d "$ALLOC_IP" -j ACCEPT

# DNS (UDP/TCP 53)
IFS=','; for d in $FW_DNS; do
  d="$(echo "$d" | trim)"; [ -n "$d" ] || continue
  iptables -A OUTPUT -p udp -d "$d" --dport 53 -j ACCEPT
  iptables -A OUTPUT -p tcp -d "$d" --dport 53 -j ACCEPT
done; unset IFS

# EGRESS total si se pide
[ "${FW_EGRESS}" = "true" ] && iptables -A OUTPUT -j ACCEPT

# Allow IN
IFS=','; for r in $FW_ALLOW_IN; do
  r="$(echo "$r" | trim)"; [ -n "$r" ] || continue
  SRC="$(echo "$r" | cut -d: -f1)"
  PROTO="$(echo "$r" | cut -d: -f2)"; [ -n "$PROTO" ] || PROTO="tcp"
  PORT="$(echo "$r" | cut -d: -f3 | tr '-' ':')"
  if [ -n "$PORT" ]; then
    iptables -A INPUT -p "$PROTO" -s "$SRC" --dport "$PORT" -j ACCEPT
  else
    iptables -A INPUT -p "$PROTO" -s "$SRC" -j ACCEPT
  fi
done; unset IFS

# Allow OUT
IFS=','; for r in $FW_ALLOW_OUT; do
  r="$(echo "$r" | trim)"; [ -n "$r" ] || continue
  DST="$(echo "$r" | cut -d: -f1)"
  PROTO="$(echo "$r" | cut -d: -f2)"; [ -n "$PROTO" ] || PROTO="tcp"
  PORT="$(echo "$r" | cut -d: -f3 | tr '-' ':')"
  if [ -n "$PORT" ]; then
    iptables -A OUTPUT -p "$PROTO" -d "$DST" --dport "$PORT" -j ACCEPT
  else
    iptables -A OUTPUT -p "$PROTO" -d "$DST" -j ACCEPT
  fi
done; unset IFS

echo "[fw] iface=$IFACE ip=$ALLOC_IP egress=$FW_EGRESS"
echo "[fw] DNS=$FW_DNS"
echo "[fw] allow_in=$FW_ALLOW_IN"
echo "[fw] allow_out=$FW_ALLOW_OUT"

iptables -S || true

sleep infinity
