# Clean UI for RuneScape: Dragonwilds

A lightweight **UE4SS Lua mod** that removes persistent gameplay HUD clutter while preserving the inventory quick-access bar and fully functional radial selector.

## What it removes

During normal gameplay, Clean UI hides:

- the 8-slot quick-access/hotbar row
- the boxed keyboard **R** radial prompt
- the circular/mouse-wheel radial graphic
- the small white radial indicator arrow
- the normal bottom-right input legend

The quick-access bar automatically returns while the inventory is open and can now also remain visible while storage/chest interfaces are open. Clean UI prevents the game from restoring the gameplay hotbar after returning to normal gameplay.

The actual quick-access radial selector remains fully functional.

## Configuration

Version 1.0.4 adds configurable HUD behavior. Defaults preserve the established Clean UI experience while adding hotbar visibility for storage/chest interfaces.

Available options include the gameplay hotbar, bottom-right input legend, radial prompts/indicator, compass, inventory hotbar, and storage hotbar.

**Hide Other Player Markers (BETA - needs testing)** is also included for community testing and is OFF by default. Multiplayer/PvP testers are encouraged to report whether remote-player markers disappear from the map/compass and include relevant `[CleanUI 1.0.4 Beta][MapIcon]` lines from `UE4SS.log`.

Clean UI intentionally loads configuration once at startup rather than continuously polling settings.

## Performance

Clean UI is event-driven and designed for minimal runtime overhead:

- no Tick hook
- no per-frame widget scanning
- no watchdog
- no continuous polling after initialization
- widget discovery stops after successful initialization
- inventory open/close transitions use two short delayed state updates, including the controller back/close path
- persistent HUD elements that the game may restore after menu transitions are also protected with one-time render-opacity state
- a targeted opacity hook ignores all widgets except the already-cached quick-access bar and only corrects it when the game attempts to restore it during gameplay

## Requirements

- RuneScape: Dragonwilds on PC
- a working UE4SS installation for RuneScape: Dragonwilds

RSDWTools / RSDW Dev Kit is **not required**.

**Mod Menu is optional.** Clean UI works without it using `config.txt`. Mod Menu v1.0.9 or compatible is required only if you want in-game menu toggle access. Settings changed through Mod Menu or `config.txt` take effect after restarting the game.

## Installation

Download the latest `cleanui-vX.X.X.zip` from **Releases**, extract it, and copy the included `cleanui` folder into:

```text
RSDragonwilds\Binaries\Win64\ue4ss\Mods\
```

The resulting structure should be:

```text
ue4ss
└── Mods
    └── cleanui
        ├── enabled.txt
        ├── install.txt
        ├── config.txt
        ├── modmenu.json
        └── scripts
            └── main.lua
```

The included `enabled.txt` enables Clean UI without requiring a manual `mods.txt` edit. If your UE4SS setup does not load the mod automatically, add `cleanui : 1` to `ue4ss\Mods\mods.txt` and restart the game.

## Configuration

Version 1.0.4 adds configurable HUD behavior. The default settings are:

- Hide Gameplay Hotbar: ON
- Hide Bottom-right Input Legend: ON
- Hide Radial Button Prompts: ON
- Hide Radial Indicator: ON
- Hide Compass: OFF
- Show Hotbar in Inventory: ON
- Show Hotbar in Storage: ON

Edit `config.txt` and restart the game to apply changes.

### Optional Mod Menu integration

Clean UI supports the optional Mod Menu for easier in-game configuration. Mod Menu is **not required**. Settings changed through Mod Menu take effect after restarting the game.

Clean UI intentionally does not continuously poll Mod Menu for configuration changes. This preserves the lightweight, event-driven runtime design.

## Uninstall

Delete `ue4ss\Mods\cleanui` and restart the game.

## Compatibility

Clean UI changes only the HUD widgets described above. It does not hide or collapse the actual quick-access radial selector.

Because the mod targets game UI widget names, a future RuneScape: Dragonwilds update that changes those widgets may require an update to Clean UI.

## Controller support

The cleanup is not tied to a keyboard hotkey. The radial selector continues to work with controllers, including PlayStation-style controllers used on PC.

## Version

Current release: **1.0.4**

See [changelog.md](changelog.md) for release notes.

## License

The original Clean UI source code in this repository is released under the MIT License. See [license](license).

RuneScape: Dragonwilds and Jagex intellectual property remain subject to Jagex's applicable terms and policies. The MIT License applies only to the original Clean UI source code and does not grant rights to Jagex-owned intellectual property.

## Jagex attribution

Created using intellectual property belonging to Jagex Limited under the terms of Jagex's Fan Content Policy. This content is not endorsed by or affiliated with Jagex.
