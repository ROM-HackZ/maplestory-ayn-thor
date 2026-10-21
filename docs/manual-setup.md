# Put the files on the Thor yourself

Use these steps if you don't have a Windows computer, or if you'd rather copy
the files yourself. You will join the main guide at step 4 afterward.

## 1. Get GameNative

1. On the Thor or your computer, download the standard
   [GameNative v1.3.0 APK](https://github.com/utkarshdalal/GameNative/releases/download/v1.3.0/gamenative-v1.3.0.apk).
   If you use the release page, choose **gamenative-v1.3.0.apk**.
2. If you downloaded it on a computer, connect the Thor by USB, choose
   **File transfer** on the Thor, and copy the APK into its **Download** folder.
   On a Mac you may need an Android file-transfer app. You can also download
   directly on the Thor to avoid that step.
3. On the Thor, open its file manager, open **Download**, then tap the APK.
4. If Android asks to allow installs from this file manager, open its settings,
   turn on **Allow from this source**, go back, then tap **Install**.
5. Wait until Android says the app is installed.

If you already have a different GameNative version, keep its data. Don't
uninstall it to follow this guide. The tested version was **1.3.0**, version
code **24**. Another version may behave differently.

## 2. Get the Nexon installer

1. Open [Nexon's launcher download page](https://www.nexon.com/main/en/download/launcher).
2. Download the **Windows** installer, even if your computer is a Mac or Linux
   machine. You'll run it inside GameNative on the Thor.
3. On the Thor, use the file manager to make a folder named **NexonLauncher**
   inside **Download**.
4. Copy the installer into that folder and name it **NexonLauncherSetup.exe**.

You should now have **Download/NexonLauncher/NexonLauncherSetup.exe**.
The tested installer was version **2.4.0.0**. Nexon can change the version served
by its download page. If the page won't offer a Windows download in the Thor's
browser, enable the browser's **Desktop site** option, or download it on a
computer. Don't choose the macOS `.pkg` file.

## 3. Get the runtime

1. Download the official
   [proton-11.0-2-arm64ec.wcp](https://downloads.gamenative.app/proton-11.0-2-arm64ec.wcp)
   package. Save the file without renaming it.
2. On the Thor, make a folder named **ThorSetup** inside **Download**.
3. Put **proton-11.0-2-arm64ec.wcp** in that folder.

You should now have **Download/ThorSetup/proton-11.0-2-arm64ec.wcp**.
Downloading the package doesn't install it yet. You'll import it in GameNative.

For the optional controller layout, also copy this repo's
[MapleStory-Thor.icp](../controls/MapleStory-Thor.icp) into **Download/ThorSetup**.
Import it after launching the game, following [controller setup](controller-setup.md).

## 4. Continue with the settings

Go to [step 4 of the main guide](../README.md#4-open-gamenative-and-add-the-runtime).
You don't need the Windows USB tools or USB debugging for this manual route.

The helper checks downloads automatically. For manual file checks, the original
hashes and sizes are in [setup-manifest.json](../setup-manifest.json). The
GameNative APK should have SHA-256
`f8ce62471142dd152f322436ceecc791604ec114106c7706f5d1e7e07420d602`.
The Proton package should have SHA-256
`fffa467241bdae3eacd6ceb7e8096bb7793d617ce53a198dae8bc63a3453f595`.
On Windows, right-click the Start button, open PowerShell or Terminal, and run
`Get-FileHash -Algorithm SHA256 -LiteralPath 'path to your downloaded file'`,
replacing the quoted text with the file's path.

Nexon downloads of the same version can have different hashes. The Windows
helper checks for a valid Nexon signature and version **2.4.0.0** instead.
