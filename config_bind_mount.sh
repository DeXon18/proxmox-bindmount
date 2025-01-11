#!/bin/bash
# Script to configure bind mount in Proxmox containers 102 and 103

# Array with container IDs
containers=(102 103)

# Variables: directory on the host and mount point in the container
host_dir="/mnt/ssd/Multimedia"
container_dir="/mnt/Multimedia"

# Bind mount configuration to add (or update)
mount_line="mp0: ${host_dir},mp=${container_dir},backup=0"

# Loop through each container in the array
for vmid in "${containers[@]}"
do
  echo "-----------------------------------------"
  echo "Configuring container $vmid..."
  
  # Stop the container (if it is running)
  pct stop $vmid
  
  # Backup the current configuration
  cp /etc/pve/lxc/${vmid}.conf /etc/pve/lxc/${vmid}.conf.bak
  echo "Configuration file for $vmid backed up to ${vmid}.conf.bak"
  
  # Check if a line with 'mp0:' already exists
  if grep -q "^mp0:" /etc/pve/lxc/${vmid}.conf; then
      echo "The mp0 entry already exists, updating..."
      # Replace the existing line with the new configuration
      sed -i "s|^mp0:.*|$mount_line|" /etc/pve/lxc/${vmid}.conf
  else
      echo "The mp0 entry does not exist, adding..."
      # Add the line to the end of the file
      echo "$mount_line" >> /etc/pve/lxc/${vmid}.conf
  fi
  
  # Start the container
  pct start $vmid
  sleep 5  # Pause to ensure the container starts
  
  # Verify from inside the container that the mount is present
  echo "Verifying the mount in container $vmid..."
  pct exec $vmid -- df -h | grep "${container_dir}"
  
  echo "Configuration for container $vmid completed."
done

echo "-----------------------------------------"
echo "Script finished. Containers 102 and 103 should have the bind mount configured."
