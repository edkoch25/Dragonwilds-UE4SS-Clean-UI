# Clean UI for RuneScape: Dragonwilds

A lightweight **UE4SS Lua mod** that removes persistent gameplay HUD clutter while preserving the inventory quick-access bar and fully functional radial selector.

## What it removes

During normal gameplay, Clean UI hides:

- the 8-slot quick-access/hotbar row
- the boxed keyboard **R** radial prompt
- the circular/mouse-wheel radial graphic
- the small white radial indicator arrow
- the normal bottom-right input legend

The quick-access bar automatically returns while the inventory is open and hides again when the inventory closes. Clean UI also prevents the game from restoring the gameplay hotbar after selecting or equipping inventory items.

The actual quick-access radial selector remains fully functional.

## Performance

Clean UI is event-driven and designed for minimal runtime overhead:

- no Tick hook
- no per-frame widget scanning
- no watchdog
- no continuous polling after initialization
- widget discovery stops after successful initialization
- inventory transitions use two short delayed state updates
- a targeted opacity hook ignores all widgets except the already-cached quick-access bar and only corrects it when the game attempts to restore it during gameplay

## Requirements

- RuneScape: Dragonwilds on PC
- a working UE4SS installation for RuneScape: Dragonwilds

RSDWTools / RSDW Dev Kit is **not required**.

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
        └── scripts
            └── main.lua
```

The included `enabled.txt` enables Clean UI without requiring a manual `mods.txt` edit. If your UE4SS setup does not load the mod automatically, add `cleanui : 1` to `ue4ss\Mods\mods.txt` and restart the game.

## Uninstall

Delete `ue4ss\Mods\cleanui` and restart the game.

## Compatibility

Clean UI changes only the HUD widgets described above. It does not hide or collapse the actual quick-access radial selector.

Because the mod targets game UI widget names, a future RuneScape: Dragonwilds update that changes those widgets may require an update to Clean UI.

## Controller support

The cleanup is not tied to a keyboard hotkey. The radial selector continues to work with controllers, including PlayStation-style controllers used on PC.

## Version

Current release: **1.0.0**

See [changelog.md](changelog.md) for release notes.

## License

The original Clean UI source code in this repository is released under the MIT License. See [license](license).

RuneScape: Dragonwilds and Jagex intellectual property remain subject to Jagex's applicable terms and policies. The MIT License applies only to the original Clean UI source code and does not grant rights to Jagex-owned intellectual property.

## Jagex attribution

Created using intellectual property belonging to Jagex Limited under the terms of Jagex's Fan Content Policy. This content is not endorsed by or affiliated with Jagex.
