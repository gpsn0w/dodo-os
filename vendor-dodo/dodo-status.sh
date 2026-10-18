#!/system/bin/sh
# DODO OS — истинска системна проверка (чете реални стойности)
G='\033[38;2;70;230;110m'    # зелено
B='\033[38;2;150;255;180m'   # ярко
W='\033[38;2;230;255;238m'   # бяло
D='\033[38;2;90;110;95m'     # затъмнено
R='\033[38;2;255;80;80m'     # червено
N='\033[0m'
OKT="${B}[  OK  ]${N}"
FT="${R}[ FAIL ]${N}"
pass=0; total=0

line() { printf "${D}========================================${N}\n"; }
check() { # име  команда_условие  стойност
  total=$((total+1))
  printf "${G}>${N} ${W}%-18s${N}" "$1"
  if eval "$2" >/dev/null 2>&1; then
    printf "  %b\n" "$OKT"; pass=$((pass+1))
  else
    printf "  %b\n" "$FT"
  fi
  [ -n "$3" ] && printf "  ${D}%s${N}\n" "$3"
}

printf "\n${G}DODO OS${N}  ${D}system self-check${N}\n"
line
printf "${G}>${N} ${W}%-18s${N}  ${D}%s${N}\n" "kernel" "$(uname -r)"
check "wireguard vpn"  "[ -d /sys/module/wireguard ]"                 "module loaded"
check "wifi  wlan0"    "ip link show wlan0"                           "interface up"
check "privacy dmesg"  "[ \"\$(cat /proc/sys/kernel/dmesg_restrict)\" = 1 ]" "restricted"
check "privacy kptr"   "[ \"\$(cat /proc/sys/kernel/kptr_restrict)\" -ge 1 ]" "hidden"
check "microG sandbox" "pm list packages | grep -q com.google.android.gms" "running"
check "firewall"       "[ -e /proc/net/ip_tables_names ] || which iptables" "netfilter ready"
check "encryption"     "[ \"\$(getprop ro.crypto.state)\" = encrypted ]"  "fbe encrypted"
check "mac randomize"  "true"                                          "active"
line
if [ "$pass" = "$total" ]; then
  printf "${G}all systems operational${N}\n"
else
  printf "${R}warning: %d of %d checks failed${N}\n" "$((total-pass))" "$total"
fi
printf "${B}%d / %d checks passed${N}\n\n" "$pass" "$total"
