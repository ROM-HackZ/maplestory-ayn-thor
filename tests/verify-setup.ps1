#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
. (Join-Path $repo 'scripts\setup-thor.ps1')
$testRoot = Join-Path $repo ('.local\setup-tests-' + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $testRoot
$env:THOR_SETUP_TEST_STATE = Join-Path $testRoot 'device.json'
$env:THOR_SETUP_TEST_CALLS = Join-Path $testRoot 'calls.jsonl'
$adb = Join-Path $testRoot 'fake-adb.cmd'
$fake = Join-Path $PSScriptRoot 'fake-adb.ps1'
Set-Content -LiteralPath $adb -Encoding ascii -Value ('@echo off' + "`r`n" + 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + $fake + '" %*' + "`r`n")
$fixture = Join-Path $testRoot 'small file.wcp'
Set-Content -LiteralPath $fixture -Value 'A small fixture, not a runtime.' -Encoding ascii
$hash = (Get-FileHash -LiteralPath $fixture -Algorithm SHA256).Hash.ToLowerInvariant()
$artifact = [pscustomobject]@{
    name = 'Fixture'; verification = 'sha256'; bytes = (Get-Item -LiteralPath $fixture).Length
    sha256 = $hash; download_filename = 'small file.wcp'; url = 'https://invalid.example/never-needed'
}
$app = [pscustomobject]@{ version = '1.3.0'; version_code = 24 }
$remote = '/sdcard/Download/ThorSetup/proton-11.0-2-arm64ec.wcp'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}
function Assert-Fails {
    param([scriptblock]$Action, [string]$Pattern)
    $failed = $false
    try { & $Action | Out-Null }
    catch {
        $failed = $true
        if ($_.Exception.Message -notmatch $Pattern) { throw }
    }
    Assert-True $failed ('Expected failure: ' + $Pattern)
}
function Set-Device {
    param([string[]]$Devices = @("TEST-THOR`tdevice"), [int]$Version = 24, [bool]$BadTransfer = $false)
    [pscustomobject]@{
        devices = @($Devices); version = $Version; files = [pscustomobject]@{}
        badTransfer = $BadTransfer; startupNotice = $false
    } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $env:THOR_SETUP_TEST_STATE -Encoding utf8
    Set-Content -LiteralPath $env:THOR_SETUP_TEST_CALLS -Value '' -Encoding ascii
}
function Get-Calls { Get-Content -LiteralPath $env:THOR_SETUP_TEST_CALLS -Raw }

Assert-True (Test-SetupFile $fixture $artifact) 'Valid fixture was rejected.'
Assert-True ((Get-SetupDownload $artifact $testRoot) -eq $fixture) 'A verified cached file was not reused.'
$artifact.sha256 = '0' * 64
Assert-True (-not (Test-SetupFile $fixture $artifact)) 'Corrupt hash was accepted.'
$artifact.sha256 = $hash
$nexon = [pscustomobject]@{ verification = 'nexon_signature_and_version'; version = '2.4.0.0' }
Assert-True (-not (Test-SetupFile $fixture $nexon)) 'An unsigned file was accepted as Nexon.'

Set-Device -Devices @()
Assert-Fails { Get-SetupDevice $adb '' } 'No Thor found'
Set-Device -Devices @("TEST-THOR`tunauthorized")
Assert-Fails { Get-SetupDevice $adb '' } 'not allowed'
Set-Device -Devices @("TEST-THOR`tdevice", "OTHER-PHONE`tdevice")
Assert-Fails { Get-SetupDevice $adb '' } 'More than one'
Assert-True ((Get-SetupDevice $adb 'TEST-THOR') -eq 'TEST-THOR') 'Explicit device selection failed.'
Set-Device
$state = Get-Content -LiteralPath $env:THOR_SETUP_TEST_STATE -Raw | ConvertFrom-Json
$state.startupNotice = $true
$state | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $env:THOR_SETUP_TEST_STATE -Encoding utf8
Assert-True ((Get-SetupDevice $adb '') -eq 'TEST-THOR') 'ADB stderr startup notice broke device detection.'

Set-Device -Version 25
Assert-Fails { Install-SetupGameNative $adb 'TEST-THOR' $fixture $app } 'different GameNative version'
Assert-True ((Get-Calls) -notmatch '\["-s","TEST-THOR","install"') 'Setup replaced a different app version.'
Set-Device
Install-SetupGameNative $adb 'TEST-THOR' $fixture $app
Assert-True ((Get-Calls) -notmatch '\["-s","TEST-THOR","install"') 'Setup reinstalled the tested existing app.'
Set-Device -Version 0
Install-SetupGameNative $adb 'TEST-THOR' $fixture $app
$state = Get-Content -LiteralPath $env:THOR_SETUP_TEST_STATE -Raw | ConvertFrom-Json
Assert-True ($state.version -eq 24) 'New app was not installed and verified.'

Set-Device
Copy-SetupFile $adb 'TEST-THOR' $fixture $remote
Copy-SetupFile $adb 'TEST-THOR' $fixture $remote
$pushes = [regex]::Matches((Get-Calls), '\["-s","TEST-THOR","push"').Count
Assert-True ($pushes -eq 1) 'Repeating the copy pushed the file again.'
$state = Get-Content -LiteralPath $env:THOR_SETUP_TEST_STATE -Raw | ConvertFrom-Json
Assert-True ($state.files.PSObject.Properties[$remote].Value -eq $hash) 'Final copied bytes were not checked.'
$state.files.PSObject.Properties[$remote].Value = '1' * 64
$state | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $env:THOR_SETUP_TEST_STATE -Encoding utf8
Assert-Fails { Copy-SetupFile $adb 'TEST-THOR' $fixture $remote } 'different file already exists'
Assert-True ([regex]::Matches((Get-Calls), '\["-s","TEST-THOR","push"').Count -eq 1) 'A conflicting file was overwritten.'
Set-Device -BadTransfer $true
Assert-Fails { Copy-SetupFile $adb 'TEST-THOR' $fixture $remote } 'did not copy correctly'
Assert-True ((Get-Calls) -notmatch '"mv"') 'Failed transfer was promoted to the final file.'
Assert-Fails { Copy-SetupFile $adb 'TEST-THOR' $fixture '/sdcard/Download/../other' } 'Invalid destination'
Assert-Fails { Invoke-SetupAdb $adb @('-s', 'TEST-THOR', 'unsupported') } 'USB command failed'

'All helper checks passed. No real device was contacted.'
