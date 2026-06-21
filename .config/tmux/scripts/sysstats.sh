#!/bin/bash

OS="$(uname)"

if [[ "$OS" == "Linux" ]]; then
  osrelease=$(</proc/sys/kernel/osrelease)

  if [[ "$osrelease" == *Microsoft* ]] && command -v powershell.exe &>/dev/null; then
    cpu_pct=$(powershell.exe -NoProfile -NonInteractive -Command "Get-CimInstance Win32_Processor | Select-Object -ExpandProperty LoadPercentage" 2>/dev/null | tail -1 | tr -d '\r')
    mem_total=$(powershell.exe -NoProfile -NonInteractive -Command "Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty TotalVisibleMemorySize" 2>/dev/null | tail -1 | tr -d '\r')
    mem_free=$(powershell.exe -NoProfile -NonInteractive -Command "Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty FreePhysicalMemory" 2>/dev/null | tail -1 | tr -d '\r')
    mem_used=$((mem_total - mem_free))
    ram_pct=$((mem_used * 100 / mem_total))
  else
    cpu_idle_1=$(awk '/^cpu / {print $5}' /proc/stat)
    cpu_total_1=$(awk '/^cpu / {sum=0; for(i=2;i<=NF;i++) sum+=$i; print sum}' /proc/stat)
    sleep 0.1
    cpu_idle_2=$(awk '/^cpu / {print $5}' /proc/stat)
    cpu_total_2=$(awk '/^cpu / {sum=0; for(i=2;i<=NF;i++) sum+=$i; print sum}' /proc/stat)

    cpu_delta=$((cpu_total_2 - cpu_total_1))
    idle_delta=$((cpu_idle_2 - cpu_idle_1))

    if [[ $cpu_delta -eq 0 ]]; then
      cpu_pct=0
    else
      cpu_pct=$(( (cpu_delta - idle_delta) * 100 / cpu_delta ))
    fi

    meminfo=$(grep -E '^(MemTotal|MemAvailable):' /proc/meminfo | awk '{print $2}')
    mem_total=$(echo "$meminfo" | sed -n '1p')
    mem_avail=$(echo "$meminfo" | sed -n '2p')

    if [[ $mem_total -eq 0 ]]; then
      ram_pct=0
    else
      ram_pct=$(( (mem_total - mem_avail) * 100 / mem_total ))
    fi
  fi

elif [[ "$OS" == "Darwin" ]]; then
  # CPU usage (%) using top
  cpu_idle=$(top -l 1 | awk '/CPU usage/ {print $7}' | sed 's/%//')
  cpu_pct=$(printf "%.0f" "$(echo "100 - $cpu_idle" | bc)")

  # RAM usage (%)
  page_size=$(sysctl -n hw.pagesize)
  vm_stat_output=$(vm_stat)

  free_pages=$(echo "$vm_stat_output" | awk '/Pages free/ {print $3}' | tr -d '.')
  inactive_pages=$(echo "$vm_stat_output" | awk '/Pages inactive/ {print $3}' | tr -d '.')
  speculative_pages=$(echo "$vm_stat_output" | awk '/Pages speculative/ {print $3}' | tr -d '.')

  free_bytes=$(( (free_pages + inactive_pages + speculative_pages) * page_size ))
  total_bytes=$(sysctl -n hw.memsize)

  if [[ $total_bytes -eq 0 ]]; then
    ram_pct=0
  else
    ram_pct=$(( (total_bytes - free_bytes) * 100 / total_bytes ))
  fi

else
  echo "Unsupported OS: $OS"
  exit 1
fi

echo "CPU ${cpu_pct}% RAM ${ram_pct}%"
