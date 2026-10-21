# MapleStory Classic World on the AYN Thor

I wanted to get MapleStory Classic World running on my Thor. This is the setup
that worked through the official Nexon Launcher in GameNative. I've written it
down so I can put it back after a reinstall, and so you can follow it too.

The Windows helper downloads the files, checks them, installs GameNative and
copies the installer and runtime onto the Thor. Then you follow the steps below
to enter the settings and sign into Nexon. You don't need to write commands.

Checked on October 21, 2026: Classic World installed and reached **Select a
Character**. Touch worked through login, world and channel selection. I haven't
created a character or checked gameplay yet. The helper is new. Its computer
checks have been tested, but a fresh install on a Thor still needs testing.

## Before you start

You'll need:

- An AYN Thor with Wi-Fi and several GB of free space. The game download alone
  was about 2 GB. GameNative and its runtime need more room.
- A Windows 10 or 11 computer with internet.
- A USB cable that carries data. Some cables only charge.
- Your own Nexon account and access to its verification emails.

The helper downloads about 700 MB onto your computer. The game downloads later,
inside Nexon Launcher on the Thor. No Python, Android Studio or root needed.

If GameNative 1.3.0 is already installed, the helper keeps it and its data.
For another version, it stops so you can decide what to do with it.

Using a Mac, Linux or just the Thor? Follow [manual file preparation](docs/manual-setup.md),
then join this guide at step 4.

## 1. Download this setup on your computer

1. [Download the setup ZIP](https://github.com/ROM-HackZ/maplestory-ayn-thor/archive/refs/heads/main.zip).
2. Open your computer's Downloads folder.
3. Right-click the ZIP and choose **Extract All**, then **Extract**.
4. Open the extracted folder. Keep opening it until you can see
   `Start-Setup.cmd` and `README.md` together.

Leave this guide open while you work. Run the helper from the extracted folder,
not from inside the ZIP.

## 2. Let your computer talk to the Thor

1. On the Thor, open Android's **Settings**.
2. Open **About device** or the equivalent About page. Find **Build number**.
   Android's menu names vary. Use Settings search if you can't find it.
3. Tap **Build number seven times**. Enter the Thor's screen-lock PIN if asked.
   You should see a message saying developer options are enabled.
4. Return to Settings. Open **System**, then **Developer options**. If it isn't
   there, search Settings for `Developer options`.
5. Turn on **USB debugging** and accept its confirmation.
6. Connect the Thor to the computer with your USB data cable. Unlock the Thor.
   If it asks what to use USB for, choose **File transfer**.
7. Unplug other Android phones or handhelds from this computer for now.

Watch the Thor for an **Allow USB debugging?** message. It may appear when the
helper starts. Tap **Allow**. This permission lets the helper install the app
and copy the files.

## 3. Run the helper

1. On your computer, double-click **Start-Setup.cmd**. Windows may hide `.cmd`,
   so it may appear as **Start-Setup**.
2. Keep the window open. It downloads and checks GameNative, the Nexon installer,
   Proton and Google's USB tools. The GameNative download is the largest.
3. If the Thor shows **Allow USB debugging?**, tap **Allow**.
4. If the helper stops because permission wasn't allowed yet, run it again.
   It reuses downloads that pass their checks.
5. Wait until it says **Files ready on the Thor. Continue with step 4 in README.md.**

At that point you should have:

| On the Thor | What it is |
|---|---|
| GameNative in the app list | The Android app that runs the launcher |
| `Download/NexonLauncher/NexonLauncherSetup.exe` | The Windows installer you'll run inside GameNative |
| `Download/ThorSetup/proton-11.0-2-arm64ec.wcp` | The runtime you'll import in the next step |

You can unplug the USB cable now. Keep the Thor connected to Wi-Fi.

If the helper stops, leave its message open and check [troubleshooting](#if-something-gets-stuck).
Don't run the Nexon `.exe` on your computer. It belongs on the Thor for this setup.

## 4. Open GameNative and add the runtime

A runtime is the software GameNative uses to run Windows programs. This setup
uses one for installing Nexon Launcher and another for running it afterward.

1. On the Thor, open **GameNative** from the Android app list.
2. Finish its first-run setup and let any required files finish downloading.
   Allow storage access if requested. You don't need a Steam login for this route.
3. Open GameNative's **Settings**, then **Emulation**, then **Wine/Proton Manager**.
4. Look at the installed versions. If **Proton 11.0-2 ARM64EC**, version code **1**,
   is already installed, keep it and skip to item 8.
5. Tap **Import .wcp Package**.
6. In the Android file picker, open the Thor's internal storage, then
   **Download**, then **ThorSetup**. Select **proton-11.0-2-arm64ec.wcp**.
7. Wait for its details to appear. Check that they say **Proton**,
   **11.0-2-arm64ec**, version code **1**. Tap **Install Package** and wait for
   installation to finish.
8. Close the manager and return to the library. The installer uses GameNative's
   bundled **Proton 9.0 x86_64** option. You'll select it in step 6. If GameNative
   asks to download required files, let that finish. Don't substitute Proton 11
   for the installer step.

You should now have both runtimes available. The final Proton component ID is
`proton-11.0-2-arm64ec-1`. Avoid similarly named packages ending in `-6`.

## 5. Add the Nexon installer to the library

1. In GameNative's library, tap **Add Game** or the **+** control for adding a
   custom game. Choose **Add Custom Game** if a choice appears.
2. Read the folder prompt and tap **OK**.
3. In the folder picker, open internal storage, then **Download**, then
   **NexonLauncher**. Select this folder with **Use this folder** and allow access
   if asked. Select the folder, not the `.exe` file inside it.
4. If an import prompt offers **Remove original after import**, leave that
   unchecked so the source folder stays on the Thor.
5. The entry should appear as **NexonLauncher**. Use that name if asked to name it.
6. Tap the entry. Open its options menu and choose **Custom Game Settings**.

In these settings, GameNative may call the Windows environment a **container**.
Keep using this same entry and container throughout the guide.

## 6. Enter the installer settings

Open each named setting and choose the value below. Some fields are on other
tabs or farther down the settings page.

1. Set **Container variant** to **bionic**.
2. Set **Wine/Proton** to **Proton 9.0 x86_64**, shown as `proton-9.0-x86_64`.
3. Set **Graphics Driver** to **Wrapper**. For its driver version, choose **System**.
4. Set **Display renderer** to **GL**.
5. Set the DirectX wrapper to **DXVK**.
6. Leave the resolution and DXVK subversion at their defaults. I didn't record
   their numeric values, so there isn't a specific number to enter here.
7. Check the executable selection. For this first run, it should be
   **NexonLauncherSetup.exe** from the folder you added.
8. Tap the **disk-shaped Save icon on the main settings window**.
9. Open **Custom Game Settings** again. Check that the runtime still says
   **Proton 9.0 x86_64** and the graphics settings match items 3 to 5.

The small **OK** button inside a popup only closes that popup. You still need
that outer Save icon to save the container. Close settings after checking.

## 7. Install Nexon Launcher

1. On the NexonLauncher entry, tap **Play**. The Nexon setup window should open.
2. Follow its language and setup prompts until it asks where to install.
3. Change the destination to exactly **`D:\Launcher`**.
4. Continue the installation and wait for it to finish.
5. On the last screen, untick **Run Launcher** and the option to start the
   launcher automatically with Windows. Then click **Finish**.

On the working setup, `D:` points to Android's `Download` folder. That means the
installed launcher is now in **Download/Launcher**. Before continuing, use the
Thor's file manager to check that this folder contains **nexon_launcher.exe**.
If it doesn't, check the container's drive mapping before going further.

If you can't click in the installer, use the touch settings in step 9, then
return here. For typing, press **Android Back**, open **Quick Menu**, tap
**Keyboard**, then tap the field you want to type in.

## 8. Switch the same entry to the installed launcher

1. Return to the **same NexonLauncher entry** in GameNative. Open its options
   menu, then **Custom Game Settings**.
2. Open the **Executable Path** dropdown and choose **Custom path**.
3. Type exactly **`D:/Launcher/nexon_launcher.exe`**. This path uses forward
   slashes. It points to the program installed in step 7.
4. Tap the popup's **OK**, hide the keyboard, then tap the **outer disk Save icon**.
5. Reopen settings. Check that the path is still there.
6. Change **Wine/Proton** to **Proton 11.0-2 ARM64EC**, component
   **`proton-11.0-2-arm64ec-1`**.
7. Check the remaining settings against this table. Keep the graphics choices
   from step 6.

| Setting | Choose or enter |
|---|---|
| Container variant | bionic |
| 64-bit emulator | FEXCore, version 2605 |
| 32-bit emulator | Box64, version 0.4.2, the last verified selection |
| Graphics driver | Wrapper |
| Wrapper's graphics driver version | System |
| Display renderer | GL |
| DirectX wrapper | DXVK |
| Resolution and DXVK subversion | Leave the defaults |
| Extra launch arguments | Leave the field empty |
| Wine/Box debug logging | Off |
| Temporary `WINEDEBUG` setting, if you added one | Remove it |

8. Tap the **outer disk Save icon** again.
9. Reopen settings and check both the **Proton 11.0-2 ARM64EC** selection and
   **`D:/Launcher/nexon_launcher.exe`**. Then close settings and tap **Play**.

You should see Nexon Launcher now. Keep this container. Creating a second one
would leave the launcher's installed Windows files and registration behind.

## 9. Turn on touch and sign in

1. While Nexon Launcher is running, press **Android Back** to open GameNative's
   **Quick Menu**.
2. Open **Controller**.
3. Turn **Touchscreen Mode ON** and **Shooter Mode OFF**.
4. Close the menu. If the screen is paused, tap the center **Play/resume** control.
5. Tap the Nexon sign-in field. To open the keyboard, press **Android Back**,
   choose **Quick Menu**, then **Keyboard**, and tap the field again.
6. Sign into your own Nexon account and complete its email verification.

If a blank panel appears after login, stop and restart GameNative normally.
On my setup it then appeared as **What's New**, and I could close it. Keep your
app data and container.

## 10. Download Classic World

1. In Nexon Launcher, choose **MapleStory**.
2. Choose **Classic World**.
3. Click **Play Now** and let the launcher download the game. The successful run
   downloaded about **2 GB**. Leave the game install folder at its default,
   **`C:\Nexon\Library\maplestorycw`**.
4. When the download finishes, click **Play**, then **Log In**.
5. Choose your world and channel.

You should reach **Select a Character**. I checked Windia, channel 9, after the
service opened at 2 PM Eastern on October 21, 2026. You can choose your own world
and channel. Character creation and gameplay still need checking.

## Next time you play

Open **GameNative**, choose **NexonLauncher**, and tap **Play**. In Nexon Launcher,
choose **MapleStory**, then **Classic World**, then **Play**.

Keep **Download/Launcher**. Those are the installed launcher files. Also keep
**Download/NexonLauncher**, its original installer, `.gamenative` marker and
icon. GameNative's library discovery may depend on that source folder. Keep
the same container too, since it holds the installation and login state.

## If something gets stuck

### The helper can't find the Thor

Unlock the Thor and check that USB debugging is on. Unplug and reconnect the
cable, then look for **Allow USB debugging?** on the Thor. Try another data cable
or USB port. Unplug other Android devices and run **Start-Setup** again.
If Windows still can't see the Thor, check Windows Update for its USB driver,
or use [manual file preparation](docs/manual-setup.md).

### Download check failed

Run the helper again after checking your internet connection. It downloads a
new copy of any cached file that fails its check. If the error keeps happening,
the upstream download may have changed. Stop there and
[report the component name and error](https://github.com/ROM-HackZ/maplestory-ayn-thor/issues).
Nexon's installer must still be version **2.4.0.0** with a valid **NEXON Korea
Corporation** signature for the helper to accept it.

### Different GameNative version

The helper keeps your installed app and stops. Don't uninstall it just to get
past this message. Uninstalling can remove your containers and their data.
You can use [manual file preparation](docs/manual-setup.md) with your current
app, but the recorded recipe was tested with **1.3.0**, version code **24**.
Other versions still need testing.

### A different file already exists on the Thor

The helper won't overwrite it. Use the Thor's file manager to move that file
somewhere safe, then run **Start-Setup** again. Keep any working launcher and
container. The helper only needs the installer and runtime destinations listed
in step 3.

### A setting or executable path won't stick

Tap **OK** in the small popup, then the **disk Save icon on the main settings
window**. Reopen the settings and check the value before launching.

### Touch doesn't work, or the screen looks paused

Repeat step 9, items 1 to 4. Touchscreen Mode should be on and Shooter Mode off.
Close the menu and tap the center Play control if paused.

### Nexon Launcher hangs after switching runtime

Stop and restart GameNative normally. Keep its data and the same container.
For a missing executable, check **Download/Launcher/nexon_launcher.exe** and the
`D:` drive mapping described in step 7.

### Nexon shows maintenance

Wait until the service opens and try again. Keep the working container settings.

## What I've checked

The original setup installed Classic World, signed in through Nexon's normal
security checks and reached character selection with touch input on an AYN Thor.
The separate modern MapleStory Steam attempt failed. Steam login, Headless Steam,
GE runtimes, Turnip and newer FEX experiments aren't needed for this route.

The helper's download checks, repeat runs and USB command handling have been
checked on Windows with a simulated device. I haven't used it for a fresh Thor
reinstall yet. I also haven't checked character creation, gameplay, controller
bindings, performance or longer sessions.

The actual Proton runtime was checked during the working setup. The archived
runtime has the matching component ID and version. I haven't compared its files
byte for byte with the installed runtime. Future Nexon, game or server updates
may change what works.

## Files and sources

The repo includes the helper, guide, [component manifest](setup-manifest.json)
and [checksums of the saved originals](SHA256SUMS.txt). Downloads stay in the
local `downloads` folder. The helper uses exact SHA-256 checks for GameNative,
Proton and Google's USB tools. Nexon serves different bytes on repeated
installer downloads, so it checks the trusted Nexon signature and exact version
instead. It records that download's hash locally for reference.

My local reinstall backup keeps the tested downloads. No installers, runtime
binaries, game files, credentials, login sessions or container backups are
published in this repo.

- [GameNative](https://gamenative.app/) and [v1.3.0 release](https://github.com/utkarshdalal/GameNative/releases/tag/v1.3.0).
- [Runtime component manifest at the checked revision](https://raw.githubusercontent.com/utkarshdalal/GameNative/f3f954f54b98d75b79feb7b8cdff41c7d4d935a7/manifest.json).
- [Nexon's official launcher download help](https://playersupport.nexon.com/hc/en-us/articles/204158099-Where-can-I-find-the-Nexon-Launcher).
- [Google's Platform Tools](https://developer.android.com/tools/releases/platform-tools) and [USB debugging instructions](https://developer.android.com/studio/debug/dev-options).

The settings come from the working Thor setup and notes saved on October 21,
2026. The upstream links supply the components. This device setup isn't an
official Nexon or GameNative support claim.

For command-line options and the helper's checks, see [helper notes](docs/helper-notes.md).
