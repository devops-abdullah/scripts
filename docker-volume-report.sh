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

MYSQL_CONTAINER="mysql"
MYSQL_DIR=$(docker inspect "$MYSQL_CONTAINER" \
  --format '{{range .Mounts}}{{if eq .Destination "/var/lib/mysql"}}{{.Source}}{{end}}{{end}}' 2>/dev/null)

if [ -n "$MYSQL_DIR" ] && [ -d "$MYSQL_DIR" ]; then
  mysql_size=$(du -sb "$MYSQL_DIR" 2>/dev/null | awk '{print $1}')
  mysql_hr=$(numfmt --to=iec "${mysql_size:-0}")
  total_size_bytes=$((total_size_bytes + ${mysql_size:-0}))
  printf "%-30s %-10s %-10s\n" "mysql-datadir" "$mysql_hr" "BIND-MOUNT"
else
  printf "%-30s %-10s %-10s\n" "mysql-datadir" "N/A" "NOT-FOUND"
fi

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

# ==========================================================
#  Container Logs Usage
# ==========================================================
echo ""
echo "=========================================="
echo " Container Logs Usage"
echo "=========================================="

containers=$(docker ps -aq)
total_logs_bytes=0

if [ -z "$containers" ]; then
  echo "No containers found."
else
  printf "%-35s %-10s %-10s %-10s\n" "CONTAINER" "LOG SIZE" "DRIVER" "STATE"
  echo "--------------------------------------------------------------"

  log_rows=()
  while IFS='|' read -r cid cname logpath driver state; do
    cname=${cname#/}           # docker prefixes names with '/'
    log_bytes=0

    case "$driver" in
      json-file)
        # include rotated files: <id>-json.log, .1, .2 ...
        [ -n "$logpath" ] && log_bytes=$(du -cb "${logpath}"* 2>/dev/null | awk 'END{print $1}')
        ;;
      local)
        log_bytes=$(du -sb "/var/lib/docker/containers/${cid}/local-logs" 2>/dev/null | awk '{print $1}')
        ;;
      *)
        log_bytes=-1           # journald/syslog/etc: not stored as files under docker
        ;;
    esac

    if [ "$log_bytes" -ge 0 ] 2>/dev/null; then
      total_logs_bytes=$((total_logs_bytes + ${log_bytes:-0}))
      log_rows+=("${log_bytes:-0}|${cname}|$(numfmt --to=iec "${log_bytes:-0}")|${driver}|${state}")
    else
      log_rows+=("0|${cname}|N/A|${driver}|${state}")
    fi
  done < <(docker inspect --format '{{.Id}}|{{.Name}}|{{.LogPath}}|{{.HostConfig.LogConfig.Type}}|{{.State.Status}}' $containers)

  # largest first
  printf '%s\n' "${log_rows[@]}" | sort -t'|' -k1,1nr | \
    while IFS='|' read -r _ name hr drv st; do
      printf "%-35s %-10s %-10s %-10s\n" "$name" "$hr" "$drv" "$st"
    done

  echo "--------------------------------------------------------------"
  echo " Total Logs Size: $(numfmt --to=iec "$total_logs_bytes")"
fi

echo "--------------------------------------------------------------"
echo " Total Volume Size: $total_hr"
echo " Total Logs Size: $(numfmt --to=iec "$total_logs_bytes")"

echo " Grand Total (Volumes + Logs): $(numfmt --to=iec $((total_size_bytes + total_logs_bytes)))"
echo "--------------------------------------------------------------"
