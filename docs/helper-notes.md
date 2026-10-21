# Helper notes

Use **Start-Setup.cmd** and the [main guide](../README.md) for normal setup.
Use the commands below if you want to download the files ahead of time or
choose your own USB tools.

## What it changes

The helper downloads four upstream files into the repo's ignored `downloads`
folder. It checks the GameNative APK, Proton package and Google USB tools by
size and SHA-256. Nexon serves different bytes on repeated downloads of version
2.4.0.0, so that installer is checked with Windows Authenticode. Its signature
must be valid, its signer must be NEXON Korea Corporation, and its file version
must be exactly 2.4.0.0. The downloaded file's SHA-256 is recorded locally.

Once the downloads pass, the helper extracts the pinned Google USB tools and
uses ADB to talk to the selected device. With no device argument, it requires
exactly one attached device, authorized and online. Only connect the Thor.

If GameNative isn't installed, it installs the APK and reads back its version.
If 1.3.0, version code 24, is already installed, it keeps the app. Any other
installed version stops the run. There is no uninstall, downgrade or data-clear
command in the helper.

It copies these three files onto the Thor:

- `/sdcard/Download/NexonLauncher/NexonLauncherSetup.exe`
- `/sdcard/Download/ThorSetup/proton-11.0-2-arm64ec.wcp`
- `/sdcard/Download/ThorSetup/MapleStory-Thor.icp`

The controller profile comes from this repo's `controls` folder. Importing it
through GameNative is a separate step in [controller setup](controller-setup.md).

Existing matching files are reused. Different existing files stop the run.
New copies use a `.partial` path first and are checked on the device before
being renamed. The final file is checked again. A failed copy can be retried
by running setup again. It doesn't edit GameNative's library, configuration,
containers or login state.

## Commands

From the extracted repo folder, using Windows PowerShell 5.1 or PowerShell 7:

```powershell
# Normal setup
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-thor.ps1

# Download and verify files, without contacting any device
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup-thor.ps1 -DownloadOnly

# Use an existing ADB or choose one device explicitly
.\scripts\setup-thor.ps1 -AdbPath 'C:\Android\platform-tools\adb.exe' -Serial 'YOUR_DEVICE_SERIAL'

# Use downloads already stored somewhere else
.\scripts\setup-thor.ps1 -DownloadOnly -DownloadDirectory 'D:\Thor downloads'
```

The helper expects the download filenames listed in the manifest. Existing
downloads can be reused with `-DownloadDirectory`. It checks them before use.
A bad cached file is replaced only after its new download passes verification.
Partial downloads restart rather than resume.

`Start-Setup.cmd` uses a process-only execution-policy setting. It doesn't change
the computer's saved PowerShell policy. The helper needs internet and uses
Windows' normal certificate trust checks. Managed computers may block scripts
or USB access. Use the manual guide if those settings aren't yours to change.
