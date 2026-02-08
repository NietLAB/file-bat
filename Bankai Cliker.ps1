# Config
$ProcessName = "SPACEPLAN"

$code = @' 
using System; 
using System.Runtime.InteropServices; 
 
public static class BankaiKeyboard { 
    [DllImport("user32.dll", CharSet = CharSet.Auto, ExactSpelling = true, CallingConvention = CallingConvention.Winapi)] 
    public static extern short GetKeyState(int keyCode); 
     
    public static bool CapsLock { 
        get { return (((ushort)GetKeyState(0x14)) & 0xffff) != 0; }
    }
    
    public static bool ScrollLock {
        get { return (((ushort)GetKeyState(0x91)) & 0xffff) != 0; }
    }
}
'@

$signature = @"
	[DllImport("user32.dll")]  
	public static extern IntPtr GetForegroundWindow(); 
"@

# Registro de tipos
try {
    Add-Type $code -ErrorAction SilentlyContinue
    Add-Type -MemberDefinition $signature -Name BankaiWin -Namespace Bankai.API -ErrorAction SilentlyContinue
} catch {}

add-type -AssemblyName System.Windows.Forms

# --- Interfaz ---
Clear-Host
Write-Output "Bankai Clicker Online"

if (Get-process | Where-Object {$_.ProcessName -eq $ProcessName} -ErrorAction SilentlyContinue) {
    Write-Output "$ProcessName detectado. Esperando Scroll Lock..."
} else {
    Write-Output "Esperando a que $ProcessName se inicie..."
}

Write-Output "Caps Lock para salir."

$quittime = $false

# --- Bucle ---
do {
    $proc = Get-process | Where-Object {$_.ProcessName -eq $ProcessName} -ErrorAction SilentlyContinue
    
    if ($proc) {
        $foreground = [Bankai.API.BankaiWin]::GetForegroundWindow()
        if ($proc.MainWindowHandle -eq $foreground) {
            if ([BankaiKeyboard]::ScrollLock) {
                [System.Windows.Forms.SendKeys]::SendWait(" ")
                Start-Sleep -Milliseconds 10
            }
        }
    }

    if ([BankaiKeyboard]::CapsLock) {
        $quittime = $true
        Write-Output "Cerrando Bankai Clicker."
    }
} while ($quittime -eq $false)