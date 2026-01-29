#!/bin/bash

set -euo pipefail

VOLUME_NAME="intellicon_mongo-volume"
BACKUP_FILE="intellicon_mongo-volume.tar.gz"
MONGO_VERSIONS=("4.2" "4.4" "5.0" "6.0" "7.0" "8.0")
DOCKER_REPO="prod-reg.contegris.com/mongo"

confirm() {
    read -rp "$1 [y/n]: " choice
    case "$choice" in
        y|Y ) return 0 ;;
        n|N ) echo "Aborted by user."; exit 1 ;;
        * ) echo "Invalid input. Aborted."; exit 1 ;;
    esac
}

run_mongo_cmd() {
    local CMD=$1
    docker exec mongo mongo --eval "$CMD"
}

run_mongo_cmd_sh() {
    local CMD=$1
    docker exec mongo mongosh --eval "$CMD"
}

echo "Stopping and removing existing mongo container if exists..."
docker stop mongo 2>/dev/null || true
docker rm mongo 2>/dev/null || true

echo "Checking Docker Volume Size..."
du -sh "/var/lib/docker/volumes/${VOLUME_NAME}"

confirm "Is there sufficient disk space available on the server to take the backup?"

echo "Starting Full Volume Backup..."
docker run --rm -v "${VOLUME_NAME}:/volume" -v "$(pwd):/backup" busybox tar czf "/backup/${BACKUP_FILE}" -C /volume .
if [[ -f "$BACKUP_FILE" ]]; then
    echo "Backup completed: $(pwd)/${BACKUP_FILE}"
else
    echo "Backup failed!"
    exit 1
fi

confirm "Proceed with MongoDB upgrade from 4.0.24 to 8.0?"

echo "Pulling all required MongoDB images..."
for version in "${MONGO_VERSIONS[@]}"; do
    echo "Pulling $DOCKER_REPO:$version"
    docker pull "$DOCKER_REPO:$version"
done

for version in "${MONGO_VERSIONS[@]}"; do
    echo "======================================================"
    echo "Starting MongoDB Upgrade to Version: $version"
    echo "======================================================"

    echo "Running container with MongoDB $version..."
    docker run -d --rm -v "${VOLUME_NAME}:/data/db" --name mongo "$DOCKER_REPO:$version"

    echo "Waiting for MongoDB to be ready..."
    sleep 10

    echo "Setting Feature Compatibility Version to $version..."
    if [[ "$version" == "7.0" || "$version" == "8.0" ]]; then
        run_mongo_cmd_sh "db.adminCommand({setFeatureCompatibilityVersion: \"$version\", confirm: true })"
    elif [[ "$version" == "6.0" ]]; then
        run_mongo_cmd_sh "db.adminCommand({setFeatureCompatibilityVersion: \"$version\" })"
    else
        run_mongo_cmd "db.adminCommand({setFeatureCompatibilityVersion: \"$version\" })"
    fi

    echo "Verifying Feature Compatibility Version..."
    if [[ "$version" == "6.0" || "$version" == "7.0" || "$version" == "8.0" ]]; then
        run_mongo_cmd_sh "db.adminCommand({ getParameter: 1, featureCompatibilityVersion: 2 })"
    else
        run_mongo_cmd "db.adminCommand({ getParameter: 1, featureCompatibilityVersion: 1 })"
    fi

    #confirm "Is MongoDB $version running fine and tested successfully?"
    echo "Stopping MongoDB container..."
    docker stop mongo
    sleep 5
done

echo "======================================================"
echo "MongoDB Upgrade to 8.0 Completed Successfully!"
echo "======================================================"

echo "All steps completed successfully!"
