# Configuración de Bind Mount en Contenedores Proxmox

Este script automatiza la configuración de un bind mount en contenedores Proxmox, específicamente para los contenedores con IDs **102** y **103**. Es útil para montar directorios del host en los contenedores de manera eficiente y controlada.

## Descripción

El script realiza las siguientes acciones:

1. **Detiene el contenedor**: Si el contenedor está en ejecución, se detiene para aplicar los cambios de configuración.
2. **Respaldar la configuración actual**: Se crea un respaldo del archivo de configuración del contenedor para prevenir pérdida de datos.
3. **Agregar o actualizar el bind mount**: Se añade o actualiza la configuración del bind mount utilizando la opción `mp0`.
4. **Iniciar el contenedor**: Se inicia el contenedor para aplicar los cambios.
5. **Verificar el bind mount**: Se verifica que el bind mount se haya configurado correctamente consultando el espacio en disco dentro del contenedor.

## Características

- **Flexibilidad**: Permite especificar diferentes directorios del host y puntos de montaje en el contenedor.
- **Respaldo automático**: Realiza un respaldo de la configuración actual antes de realizar cambios.
- **Verificación de montaje**: Comprueba que el bind mount se haya aplicado correctamente.

## Requisitos

- **Proxmox VE**: Debe estar instalado y configurado en tu sistema.
- **Contenedores LXC**: Los contenedores deben ser de tipo LXC.
- **Permisos de administrador**: El script debe ejecutarse con permisos de root o mediante `sudo`.
- **Bash**: El script está escrito en Bash, por lo que debe estar instalado en el sistema.

## Uso

1. **Clonar el repositorio**:

   ```bash
   git clone https://github.com/tu-usuario/proxmox-bindmount.git
   cd proxmox-bindmount
