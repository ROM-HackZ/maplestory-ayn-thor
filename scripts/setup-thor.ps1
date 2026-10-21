#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$DownloadOnly,
    [string]$AdbPath,
    [string]$Serial,
    [string]$DownloadDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:RepoRoot = Split-Path -Parent $PSScriptRoot

function Test-SetupFile {
    param([string]$Path, $Artifact)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    if ($Artifact.verification -eq 'nexon_signature_and_version') {
        $signature = Get-AuthenticodeSignature -LiteralPath $Path
        if ($signature.Status -ne 'Valid' -or $null -eq $signature.SignerCertificate) { return $false }
        $signer = $signature.SignerCertificate.GetNameInfo(
            [Security.Cryptography.X509Certificates.X509NameType]::SimpleName, $false)
        $version = (Get-Item -LiteralPath $Path).VersionInfo.FileVersion
        return $signer -eq 'NEXON Korea Corporation' -and $version -eq $Artifact.version
    }
    return (Get-Item -LiteralPath $Path).Length -eq $Artifact.bytes -and
        (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash -eq $Artifact.sha256
}

function Get-SetupDownload {
    param($Artifact, [string]$Directory)

    $path = Join-Path $Directory $Artifact.download_filename
    if (Test-SetupFile $path $Artifact) {
        Write-Host ('Already checked: ' + $Artifact.name)
        return $path
    }

    Write-Host ('Downloading ' + $Artifact.name + '. Keep this window open.')
    $partial = $path + '.partial'
    $client = New-Object Net.WebClient
    try { $client.DownloadFile($Artifact.url, $partial) }
    finally { $client.Dispose() }
    if (-not (Test-SetupFile $partial $Artifact)) {
        throw ('Could not verify ' + $Artifact.name + '. Nothing from this download was installed. ' +
            'Check your connection and try again. If it still fails, see the guide under Download check failed.')
    }
    Move-Item -LiteralPath $partial -Destination $path -Force
    return $path
}

function Invoke-SetupAdb {
    param([string]$Adb, [string[]]$Arguments)

    # ADB writes startup notices to stderr even when the command succeeds.
    $ErrorActionPreference = 'Continue'
    $output = @(& $Adb @Arguments 2>&1 | ForEach-Object { "$_" })
    $code = $LASTEXITCODE
    if ($code -ne 0) {
        throw ('USB command failed. ' + ($output -join [Environment]::NewLine))
    }
    return $output -join [Environment]::NewLine
}

function Get-SetupDevice {
    param([string]$Adb, [string]$RequestedSerial)

    $listing = Invoke-SetupAdb $Adb @('devices')
    $devices = @()
    foreach ($line in ($listing -split '\r?\n')) {
        if ($line -match '^([^\s]+)\s+(device|unauthorized|offline)\s*$') {
            $devices += [pscustomobject]@{ Serial = $Matches[1]; State = $Matches[2] }
        }
    }
    if ($RequestedSerial) {
        $devices = @($devices | Where-Object Serial -eq $RequestedSerial)
    }
    if ($devices.Count -eq 0) {
        throw 'No Thor found. Unlock it, enable USB debugging, and reconnect with a USB data cable. See step 2 in the guide.'
    }
    if ($devices.Count -ne 1) {
        throw 'More than one device is connected. Unplug other phones and handhelds, then run Start-Setup again.'
    }
    if ($devices[0].State -ne 'device') {
        throw 'The Thor has not allowed this computer yet. Unlock it, accept Allow USB debugging, then run Start-Setup again.'
    }
    return $devices[0].Serial
}

function Install-SetupGameNative {
    param([string]$Adb, [string]$Device, [string]$Apk, $Artifact)

    $installed = Invoke-SetupAdb $Adb @('-s', $Device, 'shell', 'pm', 'list', 'packages', 'app.gamenative')
    if ($installed -match '(?m)^package:app\.gamenative\s*$') {
        $details = Invoke-SetupAdb $Adb @('-s', $Device, 'shell', 'dumpsys', 'package', 'app.gamenative')
        $codeMatches = $details -match ('\bversionCode=' + $Artifact.version_code + '\b')
        $nameMatches = $details -match ('\bversionName=' + [regex]::Escape($Artifact.version) + '(?:\s|$)')
        if (-not ($codeMatches -and $nameMatches)) {
            throw 'A different GameNative version is already installed. Setup stopped to keep your existing data. See the guide under Different GameNative version.'
        }
        Write-Host 'GameNative 1.3.0 is already installed. Keeping it and its data.'
        return
    }
    Write-Host 'Installing GameNative on the Thor. This large app can take a few minutes.'
    $result = Invoke-SetupAdb $Adb @('-s', $Device, 'install', $Apk)
    if ($result -notmatch '(?m)^Success\s*$') { throw ('GameNative did not report a successful install. ' + $result) }
    $details = Invoke-SetupAdb $Adb @('-s', $Device, 'shell', 'dumpsys', 'package', 'app.gamenative')
    if ($details -notmatch ('\bversionCode=' + $Artifact.version_code + '\b') -or
        $details -notmatch ('\bversionName=' + [regex]::Escape($Artifact.version) + '(?:\s|$)')) {
        throw 'The installed GameNative version could not be confirmed. See the guide before continuing.'
    }
}

function Copy-SetupFile {
    param([string]$Adb, [string]$Device, [string]$LocalPath, [string]$RemotePath)

    # Only fixed Download paths from this helper reach the Android shell.
    if ($RemotePath -notmatch '^/sdcard/Download/[A-Za-z0-9._/-]+$' -or $RemotePath.Contains('..')) {
        throw 'Invalid destination on the Thor.'
    }
    $expected = (Get-FileHash -LiteralPath $LocalPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $check = "if [ -e '$RemotePath' ]; then sha256sum '$RemotePath'; else echo MISSING; fi"
    $existing = Invoke-SetupAdb $Adb @('-s', $Device, 'shell', $check)
    if ($existing -match ('^' + $expected + '\s')) {
        Write-Host ('Already on the Thor: ' + (Split-Path $RemotePath -Leaf))
        return
    }
    if ($existing.Trim() -ne 'MISSING') {
        throw ('A different file already exists at ' + $RemotePath +
            '. Setup kept that file. Move it somewhere safe on the Thor, then run setup again.')
    }
    $parent = $RemotePath.Substring(0, $RemotePath.LastIndexOf('/'))
    $null = Invoke-SetupAdb $Adb @('-s', $Device, 'shell', 'mkdir', '-p', $parent)
    $temporary = $RemotePath + '.partial'
    Write-Host ('Copying to the Thor: ' + (Split-Path $RemotePath -Leaf))
    $null = Invoke-SetupAdb $Adb @('-s', $Device, 'push', $LocalPath, $temporary)
    $copied = Invoke-SetupAdb $Adb @('-s', $Device, 'shell', 'sha256sum', $temporary)
    if ($copied -notmatch ('^' + $expected + '\s')) {
        throw 'A file did not copy correctly. Check the cable and free space, then run setup again.'
    }
    $null = Invoke-SetupAdb $Adb @('-s', $Device, 'shell', 'mv', '-n', $temporary, $RemotePath)
    $final = Invoke-SetupAdb $Adb @('-s', $Device, 'shell', 'sha256sum', $RemotePath)
    if ($final -notmatch ('^' + $expected + '\s')) { throw 'The final file on the Thor could not be verified.' }
}

function Invoke-ThorSetup {
    param([switch]$DownloadOnly, [string]$AdbPath, [string]$Serial, [string]$DownloadDirectory)

    Write-Host 'MapleStory Classic World - Thor setup'
    Write-Host 'This gets the files ready. You will enter the GameNative settings using the guide.'
    Write-Host ''
    $manifest = Get-Content -LiteralPath (Join-Path $script:RepoRoot 'setup-manifest.json') -Raw | ConvertFrom-Json
    $artifacts = @($manifest.artifacts)
    $purposes = @('gamenative', 'nexon', 'runtime', 'usb_tools')
    foreach ($purpose in $purposes) {
        if (@($artifacts | Where-Object purpose -eq $purpose).Count -ne 1) { throw 'Setup manifest is incomplete. Download a fresh copy of this repo.' }
    }
    foreach ($artifact in $artifacts) {
        $uri = [uri]$artifact.url
        if ($artifact.download_filename -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]+$' -or
            $uri.Scheme -ne 'https' -or $uri.UserInfo -or
            $artifact.verification -notin @('sha256', 'nexon_signature_and_version') -or
            $artifact.sha256 -notmatch '^[a-f0-9]{64}$') {
            throw 'Setup manifest is invalid. Download a fresh copy of this repo.'
        }
    }
    if (-not $DownloadDirectory) { $DownloadDirectory = Join-Path $script:RepoRoot 'downloads' }
    $null = New-Item -ItemType Directory -Path $DownloadDirectory -Force
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $files = @{}
    foreach ($artifact in $artifacts) {
        $files[$artifact.purpose] = Get-SetupDownload $artifact $DownloadDirectory
    }
    $nexonHash = (Get-FileHash -LiteralPath $files.nexon -Algorithm SHA256).Hash.ToLowerInvariant()
    Set-Content -LiteralPath (Join-Path $DownloadDirectory 'NexonLauncherSetup.download.sha256.txt') -Value ($nexonHash + '  NexonLauncherSetup.exe') -Encoding ascii
    Write-Host 'All downloads checked. The Nexon installer has the tested version and a valid Nexon signature.'
    if ($DownloadOnly) {
        Write-Host 'Download-only run finished. No device was contacted.'
        return
    }

    if (-not $AdbPath) {
        $tools = Join-Path $DownloadDirectory 'usb-tools'
        $null = New-Item -ItemType Directory -Path $tools -Force
        Expand-Archive -LiteralPath $files.usb_tools -DestinationPath $tools -Force
        $AdbPath = Join-Path $tools 'platform-tools\adb.exe'
    }
    $AdbPath = (Resolve-Path -LiteralPath $AdbPath).Path
    Write-Host 'Checking the USB connection. Keep only the Thor connected.'
    $device = Get-SetupDevice $AdbPath $Serial
    $app = $artifacts | Where-Object purpose -eq 'gamenative'
    Install-SetupGameNative $AdbPath $device $files.gamenative $app
    Copy-SetupFile $AdbPath $device $files.nexon '/sdcard/Download/NexonLauncher/NexonLauncherSetup.exe'
    Copy-SetupFile $AdbPath $device $files.runtime '/sdcard/Download/ThorSetup/proton-11.0-2-arm64ec.wcp'
    Write-Host ''
    Write-Host 'Files ready on the Thor. Continue with step 4 in README.md.' -ForegroundColor Green
    Write-Host 'Open GameNative yourself. Import the runtime, add NexonLauncher, then follow the settings in the guide.'
}

if ($MyInvocation.InvocationName -ne '.') {
    try { Invoke-ThorSetup -DownloadOnly:$DownloadOnly -AdbPath $AdbPath -Serial $Serial -DownloadDirectory $DownloadDirectory }
    catch {
        Write-Host ''
        Write-Host ('Setup stopped: ' + $_.Exception.Message) -ForegroundColor Red
        Write-Host 'Keep this message open while checking the troubleshooting section in README.md.'
        exit 1
    }
}
