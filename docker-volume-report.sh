#!/bin/bash

echo "=========================================="
echo " Docker Volume Usage Report"
echo "Generated: $(date)"
echo "=========================================="

# Get all volume names
volumes=$(docker volume ls -q)

if [ -z "$volumes" ]; then
  echo "No Docker volumes found."
  exit 0
fi

total_size_bytes=0
unused_volumes=()

printf "%-30s %-10s %-10s\n" "VOLUME NAME" "SIZE" "STATUS"
echo "--------------------------------------------------------------"

for vol in $volumes; do
  mountpoint=$(docker volume inspect "$vol" -f '{{.Mountpoint}}')
  size=$(du -sb "$mountpoint" 2>/dev/null | awk '{print $1}')
  human_size=$(du -sh "$mountpoint" 2>/dev/null | awk '{print $1}')

  # Check if volume is used by any container
  used_by=$(docker ps -a --filter volume="$vol" -q)

  if [ -z "$used_by" ]; then
    status="NOT-IN-USE"
    unused_volumes+=("$vol")
  else
    status="IN-USE"
  fi

  total_size_bytes=$((total_size_bytes + size))
  printf "%-30s %-10s %-10s\n" "$vol" "${human_size:-0B}" "$status"
done

echo "--------------------------------------------------------------"

# Convert bytes → human-readable total
if [ "$total_size_bytes" -lt 1024 ]; then
  total_hr="${total_size_bytes}B"
elif [ "$total_size_bytes" -lt 1048576 ]; then
  total_hr="$(awk "BEGIN {printf \"%.2f KB\", $total_size_bytes/1024}")"
elif [ "$total_size_bytes" -lt 1073741824 ]; then
  total_hr="$(awk "BEGIN {printf \"%.2f MB\", $total_size_bytes/1048576}")"
else
  total_hr="$(awk "BEGIN {printf \"%.2f GB\", $total_size_bytes/1073741824}")"
fi

echo " Total Volume Size: $total_hr"
echo "=========================================="

# Show unused volumes (potential reclaim)
if [ ${#unused_volumes[@]} -gt 0 ]; then
  echo "️  Volumes NOT currently in use (safe to remove):"
  for v in "${unused_volumes[@]}"; do
    echo "  - $v"
  done
  echo "------------------------------------------"
  echo "To reclaim space, run:"
  echo "  docker volume rm ${unused_volumes[@]}"
else
  echo "✅ All volumes are currently in use."
fi

echo "=========================================="
