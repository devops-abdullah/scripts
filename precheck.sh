#!/bin/bash

# Colors
GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"
BOLD="\e[1m"

line() {
    echo -e "${BLUE}------------------------------------------------------------${RESET}"
}

section() {
    echo -e "\n${BOLD}${CYAN}$1${RESET}"
    line
}

pass() {
    echo -e "${GREEN}PASS${RESET} - $1"
}

fail() {
    echo -e "${RED}FAIL${RESET} - $1"
}

warn() {
    echo -e "${YELLOW}WARN${RESET} - $1"
}

# Header
echo -e "${BOLD}${GREEN}"
echo "  SYSTEM PRECHECK VALIDATION REPORT"
echo "  Host: $(hostname)"
echo "  Date: $(date)"
echo -e "${RESET}"
line

##############################
# MEMORY CHECK
##############################
section "Memory Check"

total_ram_gb=$(free -g | awk '/Mem:/ {print $2}')

echo "Total RAM Detected: ${total_ram_gb} GB"

if [ "$total_ram_gb" -ge 8 ]; then
    pass "RAM is >= 8GB"
else
    fail "RAM is less than 8GB"
fi

##############################
# CPU CHECK
##############################
section "CPU Check"

vcpu=$(nproc)
cpu_model=$(lscpu | grep 'Model name' | cut -d ':' -f2 | xargs)

echo "vCPUs Detected: $vcpu"
echo "CPU Model    : $cpu_model"

if [ "$vcpu" -ge 4 ]; then
    pass "vCPU count is >= 4"
else
    fail "vCPU count is less than 4"
fi

##############################
# DISK SIZE CHECK
##############################
section "Disk Size Check"

total_disk=$(lsblk -b -d -o SIZE | awk '{sum+=$1} END {print sum}')
total_disk_gb=$((total_disk / 1024 / 1024 / 1024))

echo "Total Disk Size: ${total_disk_gb} GB"

if [ "$total_disk_gb" -ge 100 ]; then
    pass "Disk size is >= 100GB"
else
    fail "Disk size is less than 100GB"
fi

##############################
# MOUNT POINT CHECK
##############################
section "Mount Point Check"

required_mounts=("/" "/var" "/var/log")

for mp in "${required_mounts[@]}"; do
    if mount | grep -q "on $mp "; then
        pass "$mp exists"
    else
        fail "$mp is missing"
    fi
done

##############################
# LVM CHECK
##############################
section "LVM Check"

if lsblk | grep -q "lvm"; then
    pass "LVM detected"
else
    fail "LVM not detected"
fi

##############################
# MOUNT DETAILS (INFO)
##############################
section "Mount Details"

printf "%-25s %-10s %-10s %-10s %-10s\n" "Mount Point" "Size" "Used" "Avail" "Use%"
df -h --output=target,size,used,avail,pcent | tail -n +2 | while read mp size used avail usep; do
    printf "%-25s %-10s %-10s %-10s %-10s\n" "$mp" "$size" "$used" "$avail" "$usep"
done

##############################
# FOOTER
##############################
line
echo -e "${BOLD}${GREEN}Precheck validation completed.${RESET}"
