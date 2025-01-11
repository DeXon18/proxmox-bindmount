#!/bin/bash
# Script para configurar bind mount en contenedores Proxmox / Script to configure bind mount in Proxmox containers

# Array con los IDs de los contenedores / Array with container IDs
containers=(102 103)

# Variables: directorio en el host y punto de montaje en el contenedor / Variables: host directory and mount point in the container
host_dir="/mnt/ssd/Multimedia"
container_dir="/mnt/Multimedia"

# Configuración del bind mount a agregar (o actualizar) / Bind mount configuration to add (or update)
mount_line="mp0: ${host_dir},mp=${container_dir},backup=0"

# Recorremos cada contenedor en el array / Iterate over each container in the array
for vmid in "${containers[@]}"
do
  echo "-----------------------------------------"
  echo "Configurando el contenedor $vmid... / Configuring container $vmid..."

  # Detener el contenedor (si está en ejecución) / Stop the container (if it's running)
  pct stop $vmid

  # Realizar un respaldo de la configuración actual / Backup the current configuration
  cp /etc/pve/lxc/${vmid}.conf /etc/pve/lxc/${vmid}.conf.bak
  echo "Archivo de configuración de $vmid respaldado en ${vmid}.conf.bak / Configuration file for $vmid backed up to ${vmid}.conf.bak"

  # Verificar si ya existe una línea con 'mp0:' / Check if a line with 'mp0:' already exists
  if grep -q "^mp0:" /etc/pve/lxc/${vmid}.conf; then
      echo "La entrada mp0 ya existe, se actualizará... / mp0 entry already exists, updating..."
      # Reemplazar la línea existente con la nueva configuración / Replace the existing line with the new configuration
      sed -i "s|^mp0:.*|$mount_line|" /etc/pve/lxc/${vmid}.conf
  else
      echo "La entrada mp0 no existe, se añadirá... / mp0 entry does not exist, adding..."
      # Añadir la línea al final del archivo / Append the line at the end of the file
      echo "$mount_line" >> /etc/pve/lxc/${vmid}.conf
  fi

  # Iniciar el contenedor / Start the container
  pct start $vmid
  sleep 5  # Pausa para asegurar que el contenedor inicie / Pause to ensure the container starts

  # Verificar desde el interior del contenedor que el montaje esté presente / Check from inside the container that the mount is present
  echo "Verificando el montaje en el contenedor $vmid... / Verifying mount in container $vmid..."
  pct exec $vmid -- df -h | grep "${container_dir}"

  echo "Configuración en el contenedor $vmid completada. / Configuration in container $vmid completed."
done

echo "-----------------------------------------"
echo "Script finalizado. Los contenedores 102 y 103 deberían tener configurado el bind mount. / Script completed. Containers 102 and 103 should have the bind mount configured."
