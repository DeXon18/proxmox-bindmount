# Configuración de Bind Mount en Contenedores Proxmox

Este script automatiza la configuración de un bind mount en contenedores Proxmox, específicamente para los contenedores con IDs **102** y **103**.

## Descripción

El script realiza las siguientes acciones:

1. Detiene el contenedor (si está en ejecución).
2. Realiza un respaldo de la configuración actual del contenedor.
3. Agrega o actualiza la configuración del bind mount (usando la opción `mp0`).
4. Inicia el contenedor.
5. Verifica que el bind mount se haya configurado correctamente, consultando el espacio en disco dentro del contenedor.

## Requisitos

- Proxmox VE con contenedores LXC.
- Permisos de administrador en el host de Proxmox.
- Shell Bash.

## Uso

1. Clona el repositorio:

   ```bash
   git clone https://github.com/tu_usuario/proxmox-bindmount.git
   cd proxmox-bindmount
