#!/bin/bash
# CPU usage (%)
cpu_idle_1=$(awk '/^cpu / {print $5}' /proc/stat)
cpu_total_1=$(awk '/^cpu / {for(i=2;i<=NF;i++) sum+=$i; print sum}' /proc/stat)
sleep 0.1
cpu_idle_2=$(awk '/^cpu / {print $5}' /proc/stat)
cpu_total_2=$(awk '/^cpu / {for(i=2;i<=NF;i++) sum+=$i; print sum}' /proc/stat)
cpu_delta=$((cpu_total_2 - cpu_total_1))
idle_delta=$((cpu_idle_2 - cpu_idle_1))
cpu_pct=$(( (cpu_delta - idle_delta) * 100 / cpu_delta ))

# RAM usage (%)
meminfo=$(grep -E '^(MemTotal|MemAvailable):' /proc/meminfo | awk '{print $2}')
mem_total=$(echo "$meminfo" | sed -n '1p')
mem_avail=$(echo "$meminfo" | sed -n '2p')
ram_pct=$(( (mem_total - mem_avail) * 100 / mem_total ))

echo "CPU ${cpu_pct}% RAM ${ram_pct}%"
