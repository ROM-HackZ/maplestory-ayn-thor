# A small fake USB device for verify-setup.ps1. Never calls real ADB.
$ErrorActionPreference = 'Stop'
$arguments = @($args)
$statePath = $env:THOR_SETUP_TEST_STATE
if (-not $statePath) { throw 'This fake requires the test runner.' }
$state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
Add-Content -LiteralPath $env:THOR_SETUP_TEST_CALLS -Value (ConvertTo-Json -InputObject $arguments -Compress)
if ($state.startupNotice) { [Console]::Error.WriteLine('daemon started successfully') }

if ($arguments[0] -eq 'devices') {
    'List of devices attached'
    foreach ($device in $state.devices) { $device }
    exit 0
}
if ($arguments[0] -ne '-s' -or $arguments[1] -ne 'TEST-THOR') { throw 'Expected an explicit test device.' }
$command = @($arguments | Select-Object -Skip 2)
$joined = $command -join ' '
if ($joined -eq 'shell pm list packages app.gamenative') {
    if ($state.version -gt 0) { 'package:app.gamenative' }
} elseif ($joined -eq 'shell dumpsys package app.gamenative') {
    'versionCode=' + $state.version + ' minSdk=28 targetSdk=28'
    if ($state.version -eq 24) { 'versionName=1.3.0' } else { 'versionName=9.9.9' }
} elseif ($command[0] -eq 'install') {
    if (-not (Test-Path -LiteralPath $command[1])) { throw 'Missing APK fixture.' }
    $state.version = 24
    'Success'
} elseif ($command[0] -eq 'shell' -and $command[1] -match "^if \[ -e '([^']+)' \]") {
    $path = $Matches[1]
    $property = $state.files.PSObject.Properties[$path]
    if ($null -eq $property) { 'MISSING' } else { $property.Value + '  ' + $path }
} elseif ($joined.StartsWith('shell mkdir -p ')) {
    # Virtual folders don't need to be stored.
} elseif ($command[0] -eq 'push') {
    $hash = (Get-FileHash -LiteralPath $command[1] -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($state.badTransfer) { $hash = '0' * 64 }
    $state.files | Add-Member -NotePropertyName $command[2] -NotePropertyValue $hash -Force
    '1 file pushed'
} elseif ($joined.StartsWith('shell sha256sum ')) {
    $path = $command[2]
    $property = $state.files.PSObject.Properties[$path]
    if ($null -eq $property) { [Console]::Error.WriteLine('File missing'); exit 1 }
    $property.Value + '  ' + $path
} elseif ($joined.StartsWith('shell mv -n ')) {
    $source = $command[3]
    $destination = $command[4]
    if ($null -eq $state.files.PSObject.Properties[$destination]) {
        $state.files | Add-Member -NotePropertyName $destination -NotePropertyValue $state.files.PSObject.Properties[$source].Value
        $state.files.PSObject.Properties.Remove($source)
    }
} else {
    [Console]::Error.WriteLine('Unexpected fake command: ' + $joined)
    exit 1
}
$state | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $statePath -Encoding utf8
exit 0
