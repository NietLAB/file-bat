# Config
$ProcessName = "SPACEPLAN"

# 1. Definiciones Core con nombres únicos para evitar errores de colisión
$codeBankai = @"
using System;
using System.Runtime.InteropServices;

public static class BankaiKey {
    [DllImport("user32.dll")]
    public static extern short GetKeyState(int keyCode);
    
    public static bool IsCapsLockOn => (GetKeyState(0x14) & 0xffff) != 0;
    public static bool IsScrollLockOn => (GetKeyState(0x91) & 0xffff) != 0;
}

public static class BankaiWin {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
}
"@

# Carga segura de tipos
try {
    Add-Type -TypeDefinition $codeBankai -ErrorAction SilentlyContinue
} catch {
    # Si falla es porque ya están cargados, lo cual está bien.
}

Add-Type -AssemblyName System.Windows.Forms

# --- INTERFAZ BANKAI CLICKER ---
Clear-Host
Write-Host "====================================" -ForegroundColor Magenta
Write-Host "         BANKAI CLICKER v2          " -ForegroundColor Cyan -BackgroundColor Black
Write-Host "====================================" -ForegroundColor Magenta
Write-Host ""

$quittime = $false

# Verificación de proceso inicial
$p = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
if ($p) {
    Write-Host "[!] $ProcessName detectado y vinculado." -ForegroundColor Green
} else {
    Write-Host "[?] Esperando a que abras $ProcessName..." -ForegroundColor Yellow
}

Write-Host "------------------------------------" -ForegroundColor Gray
Write-Host " > ACTIVAR:  Scroll Lock" -ForegroundColor White
Write-Host " > SALIR:    Caps Lock" -ForegroundColor Red
Write-Host "------------------------------------" -ForegroundColor Gray

# --- BUCLE DE EJECUCIÓN ---
do {
    # Buscar el proceso en cada ciclo
    $proc = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    
    if ($proc) {
        $activeWin = [BankaiWin]::GetForegroundWindow()
        
        # Solo clickea si el juego es la ventana activa
        if ($proc.MainWindowHandle -eq $activeWin) {
            if ([BankaiKey]::IsScrollLockOn) {
                [System.Windows.Forms.SendKeys]::SendWait(" ")
                Start-Sleep -Milliseconds 15
            }
        }
    }

    # Condición de salida
    if ([BankaiKey]::IsCapsLockOn) {
        $quittime = $true
        Write-Host "`n[SISTEMA] Bankai sellado. Saliendo..." -ForegroundColor Magenta
        Start-Sleep -Seconds 1
    }

    # Respiro para el CPU
    Start-Sleep -Milliseconds 10

} while (-not $quittime)
