
# General Pinto 3D Maze - Generador de Screensaver (.scr)
# Uso: doble click en GENERAR-SCR.bat
# Requiere: Windows 10/11 con .NET Framework (ya viene instalado)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "GENERAL PINTO 3D MAZE - Screensaver Generator" -ForegroundColor Green
Write-Host "----------------------------------------------" -ForegroundColor DarkGreen
Write-Host ""

# Verificar que maze95.html existe
$htmlFile = Join-Path $PSScriptRoot "maze95.html"
if (-not (Test-Path $htmlFile)) {
    Write-Host "ERROR: No se encontro maze95.html en:" -ForegroundColor Red
    Write-Host "   $PSScriptRoot" -ForegroundColor Red
    Write-Host ""
    Write-Host "Ejecuta este script desde la misma carpeta que maze95.html" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host "[OK] maze95.html encontrado" -ForegroundColor Cyan
Write-Host "[..] Compilando screensaver..." -ForegroundColor Yellow
Write-Host ""

# Codigo fuente C# del screensaver
$csSource = @'
using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

class GeneralPintoMaze {

    [DllImport("user32.dll")] static extern bool ShowCursor(bool show);
    [DllImport("user32.dll")] static extern bool GetCursorPos(out POINT p);
    [DllImport("user32.dll")] static extern short GetAsyncKeyState(int key);

    [StructLayout(LayoutKind.Sequential)]
    struct POINT { public int X, Y; }

    static Process browserProc = null;

    [STAThread]
    static void Main(string[] args) {
        string mode = "s";
        string previewHandle = null;

        if (args.Length > 0) {
            mode = args[0].ToLower().TrimStart('/').TrimStart('-');
            if (args.Length > 1) previewHandle = args[1];
        }

        if (mode.StartsWith("c")) { ShowConfig(); return; }
        if (mode.StartsWith("p")) { ShowPreview(previewHandle); return; }

        RunScreensaver();
    }

    static void ShowConfig() {
        MessageBox.Show(
            "General Pinto - 3D Maze Screensaver\nVersion 1.0\n\n" +
            "Recorres el laberinto de calles reales de\n" +
            "General Pinto, Buenos Aires, Argentina.\n\n" +
            "* Mueve el mouse para salir\n" +
            "* maze95.html debe estar en la misma carpeta que este .scr",
            "General Pinto 3D Maze - Configuracion",
            MessageBoxButtons.OK,
            MessageBoxIcon.Information
        );
    }

    static void ShowPreview(string hwndStr) {
        if (hwndStr == null) return;
        long hwnd;
        if (!long.TryParse(hwndStr, out hwnd)) return;

        Form f = new Form {
            FormBorderStyle = FormBorderStyle.None,
            BackColor = System.Drawing.Color.Black
        };
        Label lbl = new Label {
            Text = "GENERAL PINTO\n3D MAZE",
            ForeColor = System.Drawing.Color.FromArgb(31, 199, 31),
            BackColor = System.Drawing.Color.Black,
            Font = new System.Drawing.Font("Courier New", 6f, System.Drawing.FontStyle.Bold),
            Dock = DockStyle.Fill,
            TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        };
        f.Controls.Add(lbl);

        NativeWindow parent = new NativeWindow();
        parent.AssignHandle(new IntPtr(hwnd));
        f.Show(parent);
        Application.Run(f);
    }

    static void RunScreensaver() {
        string exeDir   = Path.GetDirectoryName(Application.ExecutablePath);
        string htmlPath = Path.Combine(exeDir, "maze95.html");

        if (!File.Exists(htmlPath)) {
            MessageBox.Show(
                "No se encontro maze95.html en:\n" + exeDir +
                "\n\nEl archivo .scr y maze95.html deben estar en la misma carpeta.",
                "General Pinto 3D Maze - Error",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error
            );
            return;
        }

        string url = "file:///" + htmlPath.Replace("\\", "/").Replace(" ", "%20");

        ShowCursor(false);

        // Intentar Edge, Chrome o Firefox
        string[][] browsers = new string[][] {
            new string[] { "msedge.exe",  "--kiosk \"" + url + "\" --edge-kiosk-type=fullscreen --no-first-run --disable-features=Translate --noerrdialogs --disable-infobars" },
            new string[] { "chrome.exe",  "--kiosk \"" + url + "\" --no-first-run --disable-infobars --noerrdialogs" },
            new string[] { "firefox.exe", "-kiosk \"" + url + "\"" }
        };

        foreach (string[] b in browsers) {
            try {
                browserProc = Process.Start(new ProcessStartInfo {
                    FileName        = b[0],
                    Arguments       = b[1],
                    UseShellExecute = true,
                    WindowStyle     = ProcessWindowStyle.Maximized
                });
                break;
            } catch { }
        }

        if (browserProc == null) {
            ShowCursor(true);
            MessageBox.Show(
                "No se encontro Edge, Chrome ni Firefox.\nInstala Microsoft Edge para usar el screensaver.",
                "General Pinto 3D Maze - Sin navegador",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning
            );
            return;
        }

        // Esperar arranque y registrar posicion inicial del mouse
        Thread.Sleep(2200);
        POINT last;
        GetCursorPos(out last);
        Thread.Sleep(600);
        GetCursorPos(out last);

        // Loop: salir si mueve el mouse o presiona tecla
        while (true) {
            Thread.Sleep(70);

            POINT cur;
            GetCursorPos(out cur);
            if (Math.Abs(cur.X - last.X) > 8 || Math.Abs(cur.Y - last.Y) > 8)
                break;

            for (int k = 8; k < 256; k++) {
                if ((GetAsyncKeyState(k) & 0x8000) != 0) goto exit_loop;
            }
        }
        exit_loop:

        ShowCursor(true);
        try {
            Process.Start(new ProcessStartInfo {
                FileName        = "taskkill.exe",
                Arguments       = "/PID " + browserProc.Id + " /T /F",
                UseShellExecute = false,
                CreateNoWindow  = true
            });
        } catch { }
    }
}
'@

# Compilar C# con el compilador incluido en .NET Framework
$provider = New-Object Microsoft.CSharp.CSharpCodeProvider
$params   = New-Object System.CodeDom.Compiler.CompilerParameters

$outPath  = Join-Path $PSScriptRoot "GeneralPinto-Maze.scr"
$params.OutputAssembly     = $outPath
$params.GenerateExecutable = $true
$params.CompilerOptions    = "/target:winexe /platform:anycpu /optimize+"
$params.ReferencedAssemblies.Add("System.dll")               | Out-Null
$params.ReferencedAssemblies.Add("System.Windows.Forms.dll") | Out-Null
$params.ReferencedAssemblies.Add("System.Drawing.dll")       | Out-Null

$result = $provider.CompileAssemblyFromSource($params, $csSource)

if ($result.Errors.HasErrors) {
    Write-Host "ERROR de compilacion:" -ForegroundColor Red
    foreach ($err in $result.Errors) {
        if (-not $err.IsWarning) {
            Write-Host "   Linea $($err.Line): $($err.ErrorText)" -ForegroundColor Red
        }
    }
    Write-Host ""
    Read-Host "Presiona Enter para salir"
    exit 1
}

$size = [math]::Round((Get-Item $outPath).Length / 1KB, 1)

Write-Host "[OK] Screensaver generado!" -ForegroundColor Green
Write-Host ""
Write-Host "  Archivo: $outPath" -ForegroundColor White
Write-Host "  Tamano:  ${size} KB" -ForegroundColor Gray
Write-Host ""
Write-Host "----------------------------------------------" -ForegroundColor DarkGray
Write-Host "COMO INSTALARLO:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  OPCION A (mas simple):" -ForegroundColor Yellow
Write-Host "    Click derecho en GeneralPinto-Maze.scr -> Instalar" -ForegroundColor White
Write-Host "    Luego copia maze95.html a C:\Windows\System32\" -ForegroundColor White
Write-Host ""
Write-Host "  OPCION B (sin copiar archivos):" -ForegroundColor Yellow
Write-Host "    Configuracion -> Personalizacion -> Pantalla de bloqueo" -ForegroundColor White
Write-Host "    -> Protector de pantalla -> Examinar -> seleccionar el .scr" -ForegroundColor White
Write-Host ""
Write-Host "  TEST RAPIDO:" -ForegroundColor Yellow
Write-Host "    Doble click en GeneralPinto-Maze.scr" -ForegroundColor White
Write-Host "    Mueve el mouse para salir." -ForegroundColor White
Write-Host "----------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

Start-Process explorer.exe -ArgumentList $PSScriptRoot
