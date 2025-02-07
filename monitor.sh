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

output_head() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") warn_lagging freecpu($2) freemem($3)" >> $output
    echo "$1" >> $output
}

output_tail_cpu() {
    detail_top_output="$(top -b -n1 -Em -o +%CPU | tail -n +6)"
    echo "$detail_top_output" >> $output
}

output_tail_mem() {
    detail_top_output="$(top -b -n1 -Em -o +%MEM | tail -n +6)"
    echo "$detail_top_output" >> $output
}


while true; do
    top_output="$(top -b -n1 -Em | head -n5)"
    read cpu_idle free_mem < <(extract_data "$top_output")
    cpu_idle="${cpu_idle//,/.}"
    free_mem="${free_mem//,/.}"
    cpu_idle_check=$(echo "$cpu_idle < $max" | bc -l 2>&1)
    free_mem_check=$(echo "$free_mem < $max" | bc -l 2>&1)
    if [[ "$cpu_idle_check" == "1" || "$free_mem_check" == "1" ]]; then
        output_head "$top_output" "$cpu_idle" "$free_mem"
        if [["$cpu_idle_check" == "1"]]; then
            output_tail_cpu
        else
            output_tail_mem
        fi
        period=1
    else
        period=5
    fi
    
    if [[ ("$cpu_idle_check" != "1" && "$cpu_idle_check" != "0" && "$cpu_idle" != "id." ) || ("$free_mem_check" != "1" && "$free_mem_check" != "0") ]]; then
        echo "debug freecpu($cpu_idle) freemem($free_mem) $cpu_idle_check $free_mem_check" >> $output
        echo "$top_output" >> $output
    fi
    
    sleep $period
done