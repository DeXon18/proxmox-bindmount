#!/bin/bash
# Script para configurar bind mount en contenedores Proxmox 102 y 103

# Array con los IDs de los contenedores
containers=(102 103)

# Variables: directorio en el host y punto de montaje en el contenedor
host_dir="/mnt/ssd/Multimedia"
container_dir="/mnt/Multimedia"

# Configuración del bind mount a agregar (o actualizar)
mount_line="mp0: ${host_dir},mp=${container_dir},backup=0"

# Recorremos cada contenedor en el array
for vmid in "${containers[@]}"
do
  echo "-----------------------------------------"
  echo "Configurando el contenedor $vmid..."

  # Detener el contenedor (si está en ejecución)
  pct stop $vmid

  # Realizar un respaldo de la configuración actual
  cp /etc/pve/lxc/${vmid}.conf /etc/pve/lxc/${vmid}.conf.bak
  echo "Archivo de configuración de $vmid respaldado en ${vmid}.conf.bak"

  # Verificar si ya existe una línea con 'mp0:'
  if grep -q "^mp0:" /etc/pve/lxc/${vmid}.conf; then
      echo "La entrada mp0 ya existe, se actualizará..."
      # Reemplaza la línea existente con la nueva configuración
      sed -i "s|^mp0:.*|$mount_line|" /etc/pve/lxc/${vmid}.conf
  else
      echo "La entrada mp0 no existe, se añadirá..."
      # Añade la línea al final del archivo
      echo "$mount_line" >> /etc/pve/lxc/${vmid}.conf
  fi

  # Iniciar el contenedor
  pct start $vmid
  sleep 5  # Pausa para asegurar que el contenedor inicie

  # Verificar desde el interior del contenedor que el montaje esté presente
  echo "Verificando el montaje en el contenedor $vmid..."
  pct exec $vmid -- df -h | grep "${container_dir}"

  echo "Configuración en el contenedor $vmid completada."
done

echo "-----------------------------------------"
echo "Script finalizado. Los contenedores 102 y 103 deberían tener configurado el bind mount."
