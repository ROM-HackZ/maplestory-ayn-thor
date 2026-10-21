# Controller setup

The game's Controller tab didn't respond to the Thor's buttons in this setup.
Mapping the controller to the game's keyboard controls worked. This uses
GameNative's own control profile. There is no extra app or background helper.

## Import the layout

1. On the Thor, check **Download/ThorSetup** for **MapleStory-Thor.icp**. The
   current setup helper copies it there alongside the runtime. If it's already
   there, continue below. If you used an older setup ZIP, see **Copy the profile
   file** below.
2. Launch Classic World through your existing **NexonLauncher** entry.
3. Press **Android Back** to open **Quick Menu**, then open **Controller**.
4. Scroll down inside that panel and tap **Control Profiles**.
5. Tap the **down-arrow import icon** at the top right, beside **+**.
6. In the file picker, open **Download → ThorSetup → MapleStory-Thor.icp**.
   The preview should show **MapleStory Classic World - Thor**, **24** physical
   bindings and **8** radial-menu slots. Tap **Add to library**.
7. Find **MapleStory Classic World - Thor** in the profile list. Tap its **Apply**
   button. Leave **Physical controller** and **Radial Menu** checked, then tap
   **Apply** in the popup. These settings apply to the current game entry.
8. Close Control Profiles and Quick Menu. Tap the center **Play** control if
   the game is paused.

## Copy the profile file

1. Download and extract the current setup ZIP from the main guide.
2. On your computer, open its **controls** folder. Find **MapleStory-Thor.icp**.
3. Connect the Thor by USB, unlock it and choose **File transfer** on the Thor
   if asked.
4. In Windows File Explorer, open **This PC → AYN Thor → Internal shared
   storage → Download → ThorSetup**. The storage label may just say internal
   storage. Copy **MapleStory-Thor.icp** into that folder.
5. Start at item 2 under **Import the layout** above. You don't need to run the
   launcher installer again.

The same [profile file is in this repo](../controls/MapleStory-Thor.icp).
For manual setup on another computer, copy it to **Download/ThorSetup** and
use the same import steps.

## Buttons

These are the printed button letters confirmed on the Thor.

| Thor control | Action | Keyboard or mouse input |
|---|---|---|
| Left stick or D-pad | Move, climb and enter portals | Arrow keys |
| A | Jump | Left Alt |
| X | Attack | Left Ctrl |
| Y | Pick up items | Z |
| B | Talk to an NPC | Space |
| Select | Inventory | I |
| Start | Game menu or close a window | Escape |
| Click left stick | Mini map | N |
| Right stick | Move the mouse pointer | Mouse movement |
| Click right stick | Click at the pointer | Left mouse button |
| LB / RB / LT | Quick slots Q / W / E | Q / W / E |
| Hold RT | Open the menu wheel | GameNative radial menu |

Hold **RT**, point the stick toward a wheel entry, then release **RT** to choose
it. The wheel has Inventory, Equipment, Skills, Stats, Quests, Map, Confirm and
Keyboard. The right stick moves the pointer without clicking anything by itself.

Quick slots start empty. Drag your chosen skills or items into **Q**, **W** and
**E** in the game's quick-slot panel before using the shoulder buttons for them.
Keep the game's normal keyboard bindings for the other actions in the table.

On October 21, 2026, A and X were physically checked for jump and attack. After
the full profile was applied, movement, NPC talk, inventory and the RT wheel
were also confirmed on the Thor. Skill and item assignments depend on your
character and weren't changed by this setup.
