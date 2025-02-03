#!/bin/bash
output=monitor.log
max=5
echo "$(date +"%Y-%m-%d %H:%M:%S") start_monitor" > $output

extract_data() {
    echo "$1" | awk '
    /%Cpu/ { cpu_idle = $8 }
    /MiB Mem/ { total_mem = $4 }
    /MiB Swap/ { free_mem = $9; percent_free = free_mem / total_mem * 100 }
    END {
        print cpu_idle, percent_free
    }'
}

save_top_output() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") warn_lagging freecpu($2) freemem($3)" >> $output
    echo "$1" >> $output
}

while true; do
    top_output="$(top -b -n1 -Em)"
    read cpu_idle free_mem < <(extract_data "$top_output")
    cpu_idle="${cpu_idle//,/.}"
    free_mem="${free_mem//,/.}"
    cpu_idle_check=$(echo "$cpu_idle < $max" | bc -l 2>&1)
    free_mem_check=$(echo "$free_mem < $max" | bc -l 2>&1)
    if [[ "$cpu_idle_check" == "1" || "$free_mem_check" == "1" ]]; then
        save_top_output "$top_output" "$cpu_idle" "$free_mem"
        period=1
    else
        period=5
    fi
    
    if [[ ("$cpu_idle_check" != "1" && "$cpu_idle_check" != "0" && "$cpu_idle" != "id." ) || ("$free_mem_check" != "1" && "$free_mem_check" != "0") ]]; then
        echo "debug_syntax freecpu($cpu_idle) freemem($free_mem) $cpu_idle_check $free_mem_check" >> $output
        echo "$top_output" >> $output
    fi
    
    sleep $period
done