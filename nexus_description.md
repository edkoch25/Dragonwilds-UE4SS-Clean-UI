# Nexus Mods Description

## Clean UI

A lightweight UE4SS HUD cleaner for **RuneScape: Dragonwilds**.

Clean UI removes persistent gameplay HUD clutter while preserving normal inventory behavior and the fully functional quick-access radial selector.

### Removes during gameplay

- 8-slot quick-access/hotbar row
- boxed R radial prompt
- circular/mouse-wheel radial graphic
- small white radial indicator arrow
- normal bottom-right input legend

The quick-access row automatically returns while the inventory is open and can now also remain visible while storage/chest interfaces are open. Clean UI prevents the game from restoring the gameplay hotbar after returning to normal gameplay.

The actual radial selector remains fully functional, including controller use.

### Version 1.0.4

Adds configurable HUD options through `config.txt` plus optional Mod Menu integration. You can independently control the gameplay hotbar, bottom-right input legend, radial button prompts, radial indicator, and compass, and choose whether the hotbar appears in inventory and storage/chest interfaces.

Mod Menu is optional. Settings are loaded once at startup and changes take effect after restarting the game, avoiding continuous configuration polling.

Tested with RuneScape: Dragonwilds patch 1.0.0.5.

### Version 1.0.3

Fixes an issue where the bottom-right input legend could reappear after opening and closing the map with a controller. The legend now remains hidden through map and UI transitions without adding polling, per-frame processing, or additional runtime hooks.

### Version 1.0.2

Fixes an issue where the 8-slot quick-access bar could remain visible in gameplay after selecting an item from the inventory quick-access row with a controller and closing the inventory with B / Circle. The fix remains fully event-driven with no continuous polling.

### Lightweight by design

Clean UI uses no Tick hook, per-frame widget scanning, watchdog, or continuous polling after initialization. Runtime behavior is event-driven, with a targeted opacity hook that ignores unrelated widgets.

### Requirements

- RuneScape: Dragonwilds on PC
- a working UE4SS installation for RuneScape: Dragonwilds

**RSDWTools / RSDW Dev Kit is not required.**

### Installation

Extract the included `cleanui` folder to:

`RSDragonwilds\Binaries\Win64\ue4ss\Mods\`

The included `enabled.txt` should enable the mod automatically. If your UE4SS setup does not load it, add:

`cleanui : 1`

to `ue4ss\Mods\mods.txt`, then restart the game.

Full instructions are included as `install.txt` in the download.

### Configuration

The included `config.txt` works without any additional mod. Version 1.0.4 also includes optional Mod Menu integration through `modmenu.json`.

Default settings keep the established Clean UI gameplay cleanup, keep the compass visible, show the hotbar in inventory, and show the hotbar while using storage/chests. Restart the game after changing settings.

### Uninstall

Delete `ue4ss\Mods\cleanui` and restart the game.

### Source Code

Clean UI's original source code is open source and licensed under the MIT License.

The MIT License applies to the original Clean UI source code only and does not grant rights to Jagex-owned intellectual property.

Source code:
https://github.com/edkoch25/Dragonwilds-UE4SS-Clean-UI

### Jagex Attribution

Created using intellectual property belonging to Jagex Limited under the terms of Jagex's Fan Content Policy. This content is not endorsed by or affiliated with Jagex.
