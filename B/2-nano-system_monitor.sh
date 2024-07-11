  GNU nano 7.2                                                          system_monitor.sh                                                                   #!/bin/bash

# Funktionen zum Abrufen von Systeminformationen
get_uptime() {
    uptime -p
}

get_datetime() {
    date '+%Y-%m-%d %H:%M:%S'
}

get_disk_usage() {
    df -h --total | grep 'total' | awk '{print $3 " used, " $4 " free"}'
}

get_hostname() {
    hostname
}

get_ip_address() {
    hostname -I | awk '{print $1}'
}

get_os_info() {
    uname -srm
}

get_cpu_info() {
    echo "Model: $(lscpu | grep 'Model name:' | sed 's/Model name: *//')"
    echo "Cores: $(nproc)"
}

get_memory_info() {
    free -h | awk '/Mem:/ {print $3 " used, " $4 " free"}'
}

print_table() {
    printf "%-30s %-30s\n" "Parameter" "Value"
    printf "%-30s %-30s\n" "------------------------------" "------------------------------"
    printf "%-30s %-30s\n" "System Uptime:" "$(get_uptime)"
    printf "%-30s %-30s\n" "Current Date/Time:" "$(get_datetime)"
    printf "%-30s %-30s\n" "Disk Usage:" "$(get_disk_usage)"
    printf "%-30s %-30s\n" "Hostname:" "$(get_hostname)"
    printf "%-30s %-30s\n" "IP Address:" "$(get_ip_address)"
    printf "%-30s %-30s\n" "Operating System:" "$(get_os_info)"
    printf "%-30s %-30s\n" "CPU Info:" "$(get_cpu_info)"
    printf "%-30s %-30s\n" "Memory Usage:" "$(get_memory_info)"
    printf "%-30s %-30s\n" "------------------------------" "------------------------------"
}

# Ausgabeoptionen
output_to_file=false
while getopts "f" opt; do
    case $opt in
        f)
            output_to_file=true
            ;;
        *)
            ;;
    esac
done

# Log-Dateiname
logfile="$(date '+%Y-%m')-sys-$(hostname).log"

# Tabellen-Ausgabe
print_table

# Ausgabe in die Log-Datei, wenn -f Option angegeben
if $output_to_file; then
    print_table >> $logfile
fi
