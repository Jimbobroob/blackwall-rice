#!/bin/sh
# Prints one line every 5 s for the Quickshell SysStats service:
#   disk_used_b disk_total_b vram_used_b vram_total_b uptime_s
while true; do
    disk=$(df -B1 --output=used,size / | tail -n1)
    vram="0 0"
    for f in /sys/class/drm/card*/device/mem_info_vram_used; do
        [ -r "$f" ] && { vram="$(cat "$f") $(cat "${f%used}total")"; break; }
    done
    echo $disk $vram $(cut -d' ' -f1 /proc/uptime)
    sleep 5
done
