# MapleStory Classic World on the AYN Thor

I wanted to get MapleStory Classic World running on my Thor. This is the setup
that worked through the official Nexon Launcher in GameNative, written down so
I can put it back after a reinstall.

**Checked on October 21, 2026:** the game installed, signed in through Nexon's
normal security checks, and reached **Select a Character** on Windia, channel 9.
Touch worked through login, world and channel selection. I haven't created a
character or checked gameplay yet.

You'll need GameNative, the official Nexon Launcher installer, internet and your
own Nexon account. The downloads below come from their upstream projects.
This repo holds the instructions, component versions and checksums.

## Get your files

| What you need | Version used | Where to get it |
|---|---|---|
| GameNative | **1.3.0**, versionCode **24**, target SDK **28** | [Official v1.3.0 APK](https://github.com/utkarshdalal/GameNative/releases/download/v1.3.0/gamenative-v1.3.0.apk) · [Release page](https://github.com/utkarshdalal/GameNative/releases/tag/v1.3.0) |
| Nexon Launcher installer | **2.4.0.0** | [Official download page](https://www.nexon.com/main/en/download/launcher) · [Nexon's download help](https://playersupport.nexon.com/hc/en-us/articles/204158099-Where-can-I-find-the-Nexon-Launcher) |
| Installer runtime | **Proton 9.0 x86_64**, `proton-9.0-x86_64` | GameNative's Wine/Proton Manager |
| Runtime for the installed launcher | **Proton 11.0-2 ARM64EC**, `proton-11.0-2-arm64ec-1` | [Official WCP package](https://downloads.gamenative.app/proton-11.0-2-arm64ec.wcp), or GameNative's Wine/Proton Manager |

Install GameNative on the Thor and finish its initial setup. Allow Android's
install permission for your file manager if asked. Make sure Proton 9.0 x86_64
is available, and import the Proton 11 package through the Wine/Proton Manager
if that exact component isn't already there. **FEX 2605** is included in the
tested GameNative APK.

The standard v1.3.0 APK linked above has the same size and SHA-256 as the copy
saved from the working Thor. Choose that APK when reproducing this setup.
Nexon's download page can serve a newer installer; the version I used was
2.4.0.0 and had a valid **NEXON Korea Corporation** signature.

[setup-manifest.json](setup-manifest.json) records the exact files and sources.
[SHA256SUMS.txt](SHA256SUMS.txt) has their hashes. The saved APK and installer
have descriptive backup filenames there; a download may have a different name.
On Windows, check a file with:

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath .\NexonLauncherSetup.exe
```

Compare the result with its entry in `SHA256SUMS.txt`. A different hash means it
isn't the same file used here, even if the version label looks the same.

## Install the launcher

### 1. Add the installer folder

On the Thor, make a folder called `NexonLauncher` inside Android's `Download`
folder. Copy the official installer into it as `NexonLauncherSetup.exe`.

In GameNative, add **that folder** as a custom game and name the entry
**NexonLauncher**. Use its installer executable for the first launch.

### 2. Set up the installer container

Edit the custom game's container and use:

| Setting | Value |
|---|---|
| Container variant | **bionic** |
| Wine/Proton | **Proton 9.0 x86_64** (`proton-9.0-x86_64`) |
| Graphics driver | **Wrapper / System** |
| Display renderer | **GL** |
| DirectX wrapper | **DXVK** |
| Resolution and DXVK subversion | Leave at their defaults; I didn't record the numeric values |

Press the **outer disk/Save icon**, then reopen the settings and check that they
stuck. Confirming an inner dialog with **OK** doesn't save the whole container.

### 3. Run the installer

Launch the installer from that entry. Set its destination to **`D:\Launcher`**.
On this setup, `D:` maps to Android's `Download` folder, so the installed
launcher ends up in `Download/Launcher`. Check the drive mapping if yours differs.

At the end, uncheck **Run Launcher** and the option to start it automatically
with Windows. The executable you need next is:

```text
D:/Launcher/nexon_launcher.exe
```

### 4. Point the same entry at the installed launcher

Edit **the same custom game and container**:

1. Open the executable path dropdown and choose **Custom path**.
2. Enter `D:/Launcher/nexon_launcher.exe`.
3. Confirm with the inner **OK**, hide the keyboard, then press the **outer
   disk/Save icon**.
4. Reopen the settings and check that the path is still there.

Keep the prefix you just installed into. That's the container's Windows
environment, including the launcher's installation registration.

## Switch to the runtime that worked

In that same container, change Wine/Proton to **Proton 11.0-2 ARM64EC**, component
ID **`proton-11.0-2-arm64ec-1`**. Save with the outer disk icon and reopen to check.

These were the final settings:

| Setting | Value |
|---|---|
| Container variant | **bionic** |
| Runtime | **Proton 11.0-2 ARM64EC**, `proton-11.0-2-arm64ec-1` |
| 64-bit emulator | **FEXCore**, version **2605** |
| 32-bit emulator | **Box64**, version **0.4.2**; last verified selection |
| Graphics driver | **Wrapper / System** |
| Display renderer | **GL** |
| DirectX wrapper | **DXVK** |
| Resolution and DXVK subversion | Defaults; exact numeric values weren't recorded |
| Extra launch arguments | Blank |
| Wine/Box debug logging | Off |
| Temporary `WINEDEBUG` override | None |

The actual Proton runtime was checked during the successful setup. The archived
runtime package has the matching component ID and version, but I haven't compared
its files byte for byte with the installed runtime.

## Sign in and install Classic World

1. Start **NexonLauncher** in GameNative.
2. Press **Android Back → Quick Menu → Controller**. Turn **Touchscreen Mode
   ON** and **Shooter Mode OFF**. Close the menu. If the game is paused, tap the
   center **Play/resume** control.
3. For text entry, use **Android Back → Quick Menu → Keyboard**, then tap the
   field you want to type in.
4. Sign into your own Nexon account and complete its email verification.
5. In Nexon Launcher, choose **MapleStory → Classic World → Play Now**.
6. Let the launcher download the game. The checked run downloaded about **2 GB**
   to the default **`C:\Nexon\Library\maplestorycw`** location.
7. Press **Play**, then **Log In**. Choose your world and channel.

I reached **Windia → channel 9 → Select a Character** after the service opened
at 2 PM Eastern on October 21, 2026. Those world and channel choices aren't
required settings. Character creation and gameplay still need checking.

## Next time you play

**GameNative → NexonLauncher → Play → MapleStory → Classic World → Play.**

Keep these on the Thor:

- **`Download/Launcher`**: this contains the installed launcher.
- **`Download/NexonLauncher`**, its original installer, `.gamenative` marker and
  icon: custom-library discovery may depend on that source folder.
- **The same container/prefix**: it holds the installation and login/session state.

## If something gets stuck

| What happens | What worked or what to check |
|---|---|
| A runtime or executable change disappears | Confirm the inner dialog, then use the outer disk/Save icon. Reopen settings before launching. |
| The launcher hangs after changing runtime | Stop and restart GameNative normally. Keep the existing prefix. |
| A blank panel appears after signing in | A clean GameNative restart let it render as **What's New**. Wait for it to render, then close the popup. |
| Touch doesn't click | Quick Menu → Controller: Touchscreen Mode ON, Shooter Mode OFF. Resume if paused. |
| You need the keyboard | Android Back → Quick Menu → Keyboard, then tap the field. |
| The installed executable can't be found | Check that `D:` maps to `Download`, and that `Download/Launcher/nexon_launcher.exe` exists. |
| Nexon shows maintenance | Retry when the service is open. Keep the working container settings. |

Don't clear GameNative's app data or delete the working prefix as a first fix.

## What I've checked

The official standalone Nexon Launcher route installed Classic World,
authenticated normally and reached character selection with touch input on an
AYN Thor. The separate modern MapleStory Steam attempt failed. Steam login,
Headless Steam, GE runtimes, Turnip and newer FEX experiments aren't part of
this recipe.

I haven't tested a fresh reinstall or factory reset, character creation,
in-game controls, controller bindings, performance or a longer session.
There is no unattended installer or supported container config export here.
Nexon's installer downloads more files, and future launcher, game or server
updates may change what works.

My local reinstall backup preserves the exact APK, launcher installer and
runtime package. This public repo contains no installers, runtime binaries,
game files, credentials, login sessions or container backups. Keep your own
copies of the tested downloads if you want to avoid version drift.

## Sources

- [GameNative](https://gamenative.app/) and its [source](https://github.com/utkarshdalal/GameNative).
- [GameNative v1.3.0 release](https://github.com/utkarshdalal/GameNative/releases/tag/v1.3.0), whose standard APK asset hash matches the saved APK.
- [Component manifest at the checked revision](https://raw.githubusercontent.com/utkarshdalal/GameNative/f3f954f54b98d75b79feb7b8cdff41c7d4d935a7/manifest.json) and [current manifest](https://raw.githubusercontent.com/utkarshdalal/GameNative/master/manifest.json), which identify the Proton ARM64EC package.
- [Nexon's official launcher download help](https://playersupport.nexon.com/hc/en-us/articles/204158099-Where-can-I-find-the-Nexon-Launcher).

The steps and results above come from the working Thor setup and the reinstall
notes saved on October 21, 2026. The upstream links establish where to get the
components; they aren't a claim of official support for this device setup.
