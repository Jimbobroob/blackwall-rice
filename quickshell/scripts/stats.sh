#!/bin/sh
# Prints one line per second for the Quickshell SysStats service:
#   cpu_total cpu_idle mem_used_kb mem_total_kb cpu_temp_mC gpu_temp_mC gpu_busy_pct rx_bytes tx_bytes
find_hwmon() {
    for h in /sys/class/hwmon/hwmon*; do
        [ "$(cat "$h/name" 2>/dev/null)" = "$1" ] && { echo "$h"; return; }
    done
}
cpu_h=$(find_hwmon coretemp)
gpu_h=$(find_hwmon amdgpu)
gpu_busy=$(ls "$gpu_h"/device/gpu_busy_percent 2>/dev/null | head -n1)

while true; do
    set -- $(head -n1 /proc/stat)
    total=0
    for v in "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"; do total=$((total + v)); done
    idle=$(($5 + $6))
    mem=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{print t-a, t}' /proc/meminfo)
    ct=$(cat "$cpu_h/temp1_input" 2>/dev/null || echo 0)
    gt=$(cat "$gpu_h/temp1_input" 2>/dev/null || echo 0)
    gb=$(cat "$gpu_busy" 2>/dev/null || echo 0)
    net=$(awk -F'[: ]+' 'NR>2 && $2!="lo" && $2 !~ /^(veth|docker|virbr|br-)/ {rx+=$3; tx+=$11} END{print rx+0, tx+0}' /proc/net/dev)
    echo "$total $idle $mem $ct $gt $gb $net"
    sleep 1
done
