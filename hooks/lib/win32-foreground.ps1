# win32-foreground.ps1 — Shared module: bring terminal window to foreground
# Used by pre-tool-confirm.sh and task-complete-notify.sh
#
# Strategy:
#   1. Find terminal window handle (GetConsoleWindow / process tree / process search)
#   2. AttachThreadInput to share input queue with foreground thread (bypass lock)
#   3. SetForegroundWindow + BringWindowToTop
#   4. Fallback: Alt key trick + temporary TOPMOST
#   5. Always flash taskbar as visual hint

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool BringWindowToTop(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool IsIconic(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    [DllImport("kernel32.dll")]
    public static extern uint GetCurrentThreadId();

    [DllImport("user32.dll")]
    public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);

    [DllImport("user32.dll")]
    public static extern bool FlashWindow(IntPtr hWnd, bool bInvert);

    public static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
    public static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
    public const uint SWP_NOSIZE = 0x0001;
    public const uint SWP_NOMOVE = 0x0002;
    public const int SW_RESTORE = 9;
}
"@

function Find-TerminalWindowHandle {
    # Method 1: GetConsoleWindow (works in native Win32 console)
    $hwnd = [WinAPI]::GetConsoleWindow()
    if ($hwnd -ne [IntPtr]::Zero) {
        return $hwnd
    }

    # Method 2: Walk up process tree, collect all PIDs, then find the terminal window
    $terminalNames = @(
        'WindowsTerminal', 'WindowsTerminal.exe',
        'wt', 'wt.exe',
        'ConEmu64', 'ConEmu64.exe',
        'ConEmuC64', 'ConEmuC64.exe',
        'cmder', 'cmder.exe'
    )

    $currentPid = $PID
    $seen = @{}
    $ancestors = @()

    # Collect the full ancestor chain
    for ($i = 0; $i -lt 20; $i++) {
        try {
            $proc = Get-CimInstance Win32_Process -Filter "ProcessId = $currentPid" -ErrorAction SilentlyContinue
            if (-not $proc) { break }

            $parentPid = $proc.ParentProcessId
            if ($seen.ContainsKey($parentPid) -or $parentPid -eq $currentPid) { break }
            $seen[$parentPid] = $true

            $parentProc = Get-CimInstance Win32_Process -Filter "ProcessId = $parentPid" -ErrorAction SilentlyContinue
            if ($parentProc) {
                $ancestors += @{ Pid = $parentPid; Name = $parentProc.Name }
            }
            $currentPid = $parentPid
        } catch {
            break
        }
    }

    # Priority 1: Find a known terminal process in the ancestor chain
    foreach ($anc in $ancestors) {
        if ($terminalNames -contains $anc.Name) {
            try {
                $p = [System.Diagnostics.Process]::GetProcessById($anc.Pid)
                if ($p.MainWindowHandle -ne [IntPtr]::Zero) {
                    return $p.MainWindowHandle
                }
            } catch {}
        }
    }

    # Priority 2: Any ancestor with a main window (closest first)
    foreach ($anc in $ancestors) {
        try {
            $p = [System.Diagnostics.Process]::GetProcessById($anc.Pid)
            if ($p.MainWindowHandle -ne [IntPtr]::Zero) {
                return $p.MainWindowHandle
            }
        } catch {}
    }

    # Method 3: Search all processes for known terminal names
    foreach ($name in @('WindowsTerminal', 'ConEmu64', 'cmder')) {
        try {
            $procs = [System.Diagnostics.Process]::GetProcessesByName($name)
            foreach ($p in $procs) {
                if ($p.MainWindowHandle -ne [IntPtr]::Zero) {
                    return $p.MainWindowHandle
                }
            }
        } catch {}
    }

    return [IntPtr]::Zero
}

# --- Main logic ---
$windowHwnd = Find-TerminalWindowHandle
if ($windowHwnd -eq [IntPtr]::Zero) {
    exit 1
}

# If window is minimized, restore it first
if ([WinAPI]::IsIconic($windowHwnd)) {
    [WinAPI]::ShowWindow($windowHwnd, [WinAPI]::SW_RESTORE)
}

# --- Primary: AttachThreadInput (most reliable) ---
# Share input queue with the thread that owns the foreground window,
# so SetForegroundWindow bypasses Windows' foreground lock restriction.
$attached = $false
try {
    $fgHwnd = [WinAPI]::GetForegroundWindow()
    $dummyPid = [uint32]0
    $fgThread = [WinAPI]::GetWindowThreadProcessId($fgHwnd, [ref]$dummyPid)
    $myThread = [WinAPI]::GetCurrentThreadId()

    if ($fgThread -ne 0 -and $fgThread -ne $myThread) {
        $attached = [WinAPI]::AttachThreadInput($myThread, $fgThread, $true)
    }

    [WinAPI]::SetForegroundWindow($windowHwnd)
    [WinAPI]::BringWindowToTop($windowHwnd)
} catch {
    # AttachThreadInput failed, will try fallback
}

# Always detach if we attached
if ($attached) {
    try {
        [WinAPI]::AttachThreadInput($myThread, $fgThread, $false)
    } catch {}
}

# --- Fallback: Alt key trick (if AttachThreadInput didn't work) ---
if (-not $attached) {
    [WinAPI]::keybd_event(0x12, 0, 0, [UIntPtr]::Zero)
    [WinAPI]::SetForegroundWindow($windowHwnd)
    [WinAPI]::keybd_event(0x12, 0, 0x2, [UIntPtr]::Zero)
}

# --- Taskbar flash: visual hint even if focus wasn't stolen ---
[WinAPI]::FlashWindow($windowHwnd, $true)

# --- Temporary TOPMOST to ensure visibility ---
[WinAPI]::SetWindowPos($windowHwnd, [WinAPI]::HWND_TOPMOST, 0, 0, 0, 0,
    [WinAPI]::SWP_NOSIZE -bor [WinAPI]::SWP_NOMOVE)
Start-Sleep -Milliseconds 200
[WinAPI]::SetWindowPos($windowHwnd, [WinAPI]::HWND_NOTOPMOST, 0, 0, 0, 0,
    [WinAPI]::SWP_NOSIZE -bor [WinAPI]::SWP_NOMOVE)
