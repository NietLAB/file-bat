# Config
## ProcessName
$ProcessName = "SPACEPLAN"


$code = @' 
using System; 
using System.Runtime.InteropServices; 
 
public static class Keyboard{ 
     
    [DllImport("user32.dll", CharSet = CharSet.Auto, ExactSpelling = true, CallingConvention = CallingConvention.Winapi)] 
    public static extern short GetKeyState(int keyCode); 
     
    public static bool Numlock{ 
        get{ 
            return (((ushort)GetKeyState(0x90)) & 0xffff) != 0; 
        } 
    } 
     
     public static bool CapsLock{ 
         get{
            return (((ushort)GetKeyState(0x14)) & 0xffff) != 0;
        }
     }
    
    public static bool ScrollLock{
        get{
            return (((ushort)GetKeyState(0x91)) & 0xffff) != 0;
        }
    }
}
'@

$signature = @"
	
	[DllImport("user32.dll")]  
	public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);  
	public static IntPtr FindWindow(string windowName){
		return FindWindow(null,windowName);
	}
	[DllImport("user32.dll")]
	public static extern bool SetWindowPos(IntPtr hWnd, 
	IntPtr hWndInsertAfter, int X,int Y, int cx, int cy, uint uFlags);
	[DllImport("user32.dll")]  
	public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow); 
	static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
	static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
	const UInt32 SWP_NOSIZE = 0x0001;
	const UInt32 SWP_NOMOVE = 0x0002;
	const UInt32 TOPMOST_FLAGS = SWP_NOMOVE | SWP_NOSIZE;
	public static void MakeTopMost (IntPtr fHandle)
	{
		SetWindowPos(fHandle, HWND_TOPMOST, 0, 0, 0, 0, TOPMOST_FLAGS);
	}
	public static void MakeNormal (IntPtr fHandle)
	{
		SetWindowPos(fHandle, HWND_NOTOPMOST, 0, 0, 0, 0, TOPMOST_FLAGS);
	}
"@

# Intentar cargar los tipos (usando try/catch para evitar errores si ya existen en la sesión)
try { Add-Type $code -ErrorAction SilentlyContinue } catch {}
try { $app = Add-Type -MemberDefinition $signature -Name Win32Window -Namespace ScriptFanatic.WinAPI -ReferencedAssemblies System.Windows.Forms -Using System.Windows.Forms -PassThru -ErrorAction SilentlyContinue } catch {}

try {
Add-Type @" 
  using System; 
  using System.Runtime.InteropServices; 
  public class UserWindows { 
    [DllImport("user32.dll")] 
    public static extern IntPtr GetForegroundWindow(); 
} 
"@ -ErrorAction SilentlyContinue
} catch {}

function Get-ForgroundWindow {
    return [UserWindows]::GetForegroundWindow()
}

function Get-WindowByTitle($WindowTitle = "*") {
    if ($WindowTitle -eq "*") {
        Get-Process | Where-Object {$_.MainWindowTitle} | Select-Object Id, Name, MainWindowHandle, MainWindowTitle
    }
    else {
        Get-Process | Where-Object {$_.MainWindowTitle -like "*$WindowTitle*"} | Select-Object Id, Name, MainWindowHandle, MainWindowTitle
    }
}

add-type -AssemblyName Microsoft.VisualBasic
add-type -AssemblyName System.Windows.Forms

# --- NUEVA INTERFAZ BANKAI CLICKER ---
Clear-Host
Write-Host "----------------------------------" -ForegroundColor Magenta
Write-Host "         BANKAI CLICKER           " -ForegroundColor Cyan -BackgroundColor Black
Write-Host "----------------------------------" -ForegroundColor Magenta
$quittime = $false

if (Get-process | Where-Object {$_.ProcessName -contains $ProcessName} -ErrorAction SilentlyContinue) {
    Write-Host "[!] $ProcessName detectado. Activación lista." -ForegroundColor Green
}
else {
    Write-Host "[?] $ProcessName no encontrado. Esperando ejecutable..." -ForegroundColor Yellow
}

Write-Host ">> Usa SCROLL LOCK para cliquear." -ForegroundColor White
Write-Host ">> Usa CAPS LOCK para cerrar." -ForegroundColor Red
Write-Host "----------------------------------"

# --- BUCLE ORIGINAL ---
do {

    $proc = Get-process | Where-Object {$_.ProcessName -contains $ProcessName} -ErrorAction SilentlyContinue
    if ($proc.MainWindowHandle -eq (Get-ForgroundWindow)) {
        if ([Keyboard]::ScrollLock) {
            [System.Windows.Forms.SendKeys]::SendWait(" ")
            Start-Sleep -Milliseconds 10
        }
    }
    # If CapsLock is on quit
    if ([Keyboard]::CapsLock) {
        $quittime = $true
        Write-Host "Liberando Bankai... Cerrando script." -ForegroundColor Magenta
    }
}while ($quittime -eq $false)
