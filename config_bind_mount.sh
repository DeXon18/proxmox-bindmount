#!/bin/bash

# Script to configure bind mount in Proxmox containers

# Configurable variables
CONTAINERS=(102 103)  # Puedes cambiar esto o pasar como argumento
HOST_DIR="/mnt/ssd/Multimedia"
CONTAINER_DIR="/mnt/Multimedia"
MOUNT_LINE="mp0: ${HOST_DIR},mp=${CONTAINER_DIR},backup=0"

# Function to display usage
usage() {
    echo "Usage: \$0 [-c container_id] [-h host_dir] [-m container_dir]"
    echo "  -c : Comma-separated list of container IDs (e.g., 102,103)"
    echo "  -h : Host directory to mount (default: /mnt/ssd/Multimedia)"
    echo "  -m : Mount point in the container (default: /mnt/Multimedia)"
    exit 1
}

# Parse arguments
while getopts ":c:h:m:" opt; do
  case ${opt} in
    c ) CONTAINERS=(${OPTARG//,/ }) ;;
    h ) HOST_DIR=${OPTARG} ;;
    m ) CONTAINER_DIR=${OPTARG} ;;
    \? ) usage ;;
    : ) echo "Invalid option: $OPTARG requires an argument" >&2; usage ;;
  esac
done

# Validate directories
if [[ ! -d "$HOST_DIR" ]]; then
    echo "Error: Host directory $HOST_DIR does not exist."
    exit 1
fi

# Function to configure a single container
configure_container() {
    local vmid=\$1
    echo "-----------------------------------------"
    echo "Configuring container $vmid..."

    # Check if container is running
    STATUS=$(pct status $vmid 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "Error: Container $vmid does not exist."
        return 1
    fi

    if [[ "$STATUS" == *"running"* ]]; then
        echo "Stopping container $vmid..."
        pct stop $vmid
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to stop container $vmid."
            return 1
        fi
    fi

    # Backup the current configuration
    CONFIG_FILE="/etc/pve/lxc/${vmid}.conf"
    BACKUP_FILE="${CONFIG_FILE}.bak_$(date +%F_%T)"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to backup configuration for container $vmid."
        return 1
    fi
    echo "Configuration file for $vmid backed up to ${BACKUP_FILE}"

    # Check and update mount configuration
    if grep -q "^mp0:" "$CONFIG_FILE"; then
        echo "The mp0 entry already exists, updating..."
        sed -i "s|^mp0:.*|$MOUNT_LINE|" "$CONFIG_FILE"
    else
        echo "The mp0 entry does not exist, adding..."
        echo "$MOUNT_LINE" >> "$CONFIG_FILE"
    fi

    # Start the container
    pct start $vmid
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to start container $vmid."
        return 1
    fi
    sleep 5  # Pause to ensure the container starts

    # Verify the mount inside the container
    echo "Verifying the mount in container $vmid..."
    pct exec $vmid -- df -h | grep "$CONTAINER_DIR"
    if [[ $? -ne 0 ]]; then
        echo "Error: Mount point $CONTAINER_DIR not found in container $vmid."
        return 1
    fi

    echo "Configuration for container $vmid completed."
}

# Loop through each container
for vmid in "${CONTAINERS[@]}"
do
    configure_container $vmid
    if [[ $? -ne 0 ]]; then
        echo "Failed to configure container $vmid. Exiting."
        exit 1
    fi
done

echo "-----------------------------------------"
echo "Script finished. Containers ${CONTAINERS[@]} should have the bind mount configured."
