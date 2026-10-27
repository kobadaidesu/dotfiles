#Requires -Version 5.1
<#
.SYNOPSIS
    Sets up the Zed and herdr configurations on Windows.

.DESCRIPTION
    Installs Zed, FiraCode Nerd Font, and zenhan when they are missing, then
    links the configuration files in this repository into %APPDATA%. When WSL
    is available, the herdr configuration is also linked into the default
    distribution.

.PARAMETER SkipWsl
    Do not link the herdr configuration into WSL.
#>
[CmdletBinding()]
param(
    [switch]$SkipWsl
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$DotfilesDir = $PSScriptRoot
$Timestamp = Get-Date -Format 'yyyyMMddHHmmss'

$FontUrl = 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip'
$FontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$FontRegistryKey = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'

$ZenhanUrl = 'https://github.com/iuchim/zenhan/releases/download/v0.0.1/zenhan.zip'
$ZenhanSha256 = '057E4AD47163C31D530A695353958E989200381B048C1E4F1BD8B40A97C20E28'
$ZenhanDir = Join-Path $env:LOCALAPPDATA 'Programs\zenhan'

function Write-Step([string]$Message) {
    Write-Host "==> $Message"
}

function New-TemporaryDirectory([string]$Name) {
    $path = Join-Path ([System.IO.Path]::GetTempPath()) "dotfiles-$Name-$PID"
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    return $path
}

# mklink honors Developer Mode; New-Item -ItemType SymbolicLink in Windows
# PowerShell 5.1 does not, so links are created through cmd.exe.
function Invoke-Mklink([string]$Path, [string]$Target) {
    if ((Get-Item -LiteralPath $Target).PSIsContainer) {
        cmd.exe /d /c mklink /D $Path $Target | Out-Null
    } else {
        cmd.exe /d /c mklink $Path $Target | Out-Null
    }
    return $LASTEXITCODE -eq 0
}

function Assert-SymlinkSupport {
    $probeDir = New-TemporaryDirectory 'symlink'
    try {
        $target = Join-Path $probeDir 'target'
        Set-Content -LiteralPath $target -Value ''
        if (-not (Invoke-Mklink (Join-Path $probeDir 'link') $target)) {
            throw 'Creating symbolic links requires Developer Mode (Settings > System > For developers) or an elevated PowerShell.'
        }
    } finally {
        Remove-Item -LiteralPath $probeDir -Recurse -Force
    }
}

function Install-WingetPackage([string]$Id) {
    winget list --id $Id --exact --accept-source-agreements | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    ok      $Id"
        return
    }

    winget install --id $Id --exact --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "winget could not install $Id."
    }
}

function Install-NerdFont {
    $installed = @(Get-ChildItem -Path $FontDir, (Join-Path $env:WINDIR 'Fonts') -Filter 'FiraCodeNerdFontPropo-*.ttf' -ErrorAction SilentlyContinue)
    if ($installed.Count -gt 0) {
        Write-Host '    ok      FiraCode Nerd Font'
        return
    }

    $tempDir = New-TemporaryDirectory 'font'
    try {
        $zip = Join-Path $tempDir 'FiraCode.zip'
        Invoke-WebRequest -Uri $FontUrl -OutFile $zip -UseBasicParsing
        Expand-Archive -LiteralPath $zip -DestinationPath $tempDir

        New-Item -ItemType Directory -Path $FontDir -Force | Out-Null
        if (-not (Test-Path -LiteralPath $FontRegistryKey)) {
            New-Item -Path $FontRegistryKey -Force | Out-Null
        }

        foreach ($font in Get-ChildItem -LiteralPath $tempDir -Filter '*.ttf' -Recurse) {
            $destination = Join-Path $FontDir $font.Name
            Copy-Item -LiteralPath $font.FullName -Destination $destination -Force
            New-ItemProperty -Path $FontRegistryKey -Name "$($font.BaseName) (TrueType)" -Value $destination -PropertyType String -Force | Out-Null
        }
        Write-Host '    added   FiraCode Nerd Font'
    } finally {
        Remove-Item -LiteralPath $tempDir -Recurse -Force
    }
}

function Add-UserPath([string]$Directory) {
    # Read the raw value so entries such as %USERPROFILE% stay unexpanded.
    $environmentKey = Get-Item -LiteralPath 'HKCU:\Environment'
    $current = $environmentKey.GetValue('Path', '', 'DoNotExpandEnvironmentNames')
    $entries = @($current -split ';' | Where-Object { $_ })
    if ($entries -contains $Directory) {
        return
    }

    Set-ItemProperty -LiteralPath 'HKCU:\Environment' -Name 'Path' -Value (($entries + $Directory) -join ';') -Type ExpandString
    $env:Path = "$env:Path;$Directory"

    # Let Explorer pick up the new PATH so newly started apps see it.
    Add-Type -Namespace Dotfiles -Name NativeMethods -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint msg, UIntPtr wParam, string lParam, uint flags, uint timeout, out UIntPtr result);
'@
    $result = [UIntPtr]::Zero
    [Dotfiles.NativeMethods]::SendMessageTimeout([IntPtr]0xffff, 0x1A, [UIntPtr]::Zero, 'Environment', 2, 5000, [ref]$result) | Out-Null
    Write-Host "    added   $Directory to the user PATH"
}

# zenhan turns the IME off for Zed's Vim mode, replacing macism on macOS.
function Install-Zenhan {
    $exe = Join-Path $ZenhanDir 'zenhan.exe'
    if (Test-Path -LiteralPath $exe) {
        Write-Host '    ok      zenhan'
    } else {
        $tempDir = New-TemporaryDirectory 'zenhan'
        try {
            $zip = Join-Path $tempDir 'zenhan.zip'
            Invoke-WebRequest -Uri $ZenhanUrl -OutFile $zip -UseBasicParsing
            if ((Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash -ne $ZenhanSha256) {
                throw 'The zenhan download did not match the expected checksum.'
            }
            Expand-Archive -LiteralPath $zip -DestinationPath $tempDir

            New-Item -ItemType Directory -Path $ZenhanDir -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $tempDir 'zenhan\bin64\zenhan.exe') -Destination $exe
            Write-Host '    added   zenhan'
        } finally {
            Remove-Item -LiteralPath $tempDir -Recurse -Force
        }
    }

    Add-UserPath $ZenhanDir
}

function New-Link([string]$Path, [string]$Target) {
    if (-not (Test-Path -LiteralPath $Target)) {
        throw "Link target does not exist: $Target"
    }

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($item) {
        if ($item.LinkType -eq 'SymbolicLink') {
            if (@($item.Target)[0] -eq $Target) {
                Write-Host "    ok      $Path"
                return
            }
            # Delete() removes only the link; Remove-Item -Recurse in
            # Windows PowerShell 5.1 would also empty a linked directory.
            $item.Delete()
        } else {
            $backup = "$Path.backup-$Timestamp"
            Move-Item -LiteralPath $Path -Destination $backup
            Write-Host "    backup  $backup"
        }
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    if (-not (Invoke-Mklink $Path $Target)) {
        throw "Could not link $Path."
    }
    Write-Host "    linked  $Path -> $Target"
}

# Each step runs through --exec so paths reach WSL without shell quoting.
function New-WslLink([string]$Target) {
    if ($SkipWsl) {
        return
    }
    if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
        Write-Host '    skip    WSL is not installed'
        return
    }

    $wslTarget = wsl.exe --exec wslpath -a $Target
    if ($LASTEXITCODE -ne 0 -or -not $wslTarget) {
        Write-Host '    skip    no WSL distribution is available'
        return
    }

    $wslHome = wsl.exe --exec printenv HOME
    $path = "$wslHome/.config/herdr/config.toml"
    wsl.exe --exec mkdir -p "$wslHome/.config/herdr"

    wsl.exe --exec test -L $path
    $isLink = $LASTEXITCODE -eq 0
    wsl.exe --exec test -e $path
    if (-not $isLink -and $LASTEXITCODE -eq 0) {
        wsl.exe --exec mv $path "$path.backup-$Timestamp"
        Write-Host "    backup  (WSL) $path.backup-$Timestamp"
    }

    wsl.exe --exec ln -sfn $wslTarget $path
    if ($LASTEXITCODE -ne 0) {
        throw "Could not link $path in WSL."
    }
    Write-Host "    linked  (WSL) $path -> $wslTarget"
}

Write-Step 'Checking symbolic link support'
Assert-SymlinkSupport

Write-Step 'Installing packages'
Install-WingetPackage 'ZedIndustries.Zed'
Install-NerdFont
Install-Zenhan

Write-Step 'Linking Zed configuration'
$zedSource = Join-Path $DotfilesDir 'zed\.config\zed'
$zedConfig = Join-Path $env:APPDATA 'Zed'
New-Link (Join-Path $zedConfig 'settings.json') (Join-Path $zedSource 'settings.json')
New-Link (Join-Path $zedConfig 'keymap.json') (Join-Path $zedSource 'keymap.json')
New-Link (Join-Path $zedConfig 'themes') (Join-Path $zedSource 'themes')
New-Link (Join-Path $zedConfig 'tasks.json') (Join-Path $DotfilesDir 'windows\zed\tasks.json')

Write-Step 'Linking herdr configuration'
$herdrSource = Join-Path $DotfilesDir 'herdr\.config\herdr\config.toml'
New-Link (Join-Path $env:APPDATA 'herdr\config.toml') $herdrSource
New-WslLink $herdrSource

Write-Host 'Dotfiles linked successfully. Restart Zed to load the settings.'
