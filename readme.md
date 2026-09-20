# Clean UI for RuneScape: Dragonwilds

A lightweight **UE4SS Lua mod** that removes persistent gameplay HUD clutter while preserving the normal inventory quick-access bar and fully functional radial selector.

## What it removes

During normal gameplay, Clean UI hides:

- the 8-slot quick-access/hotbar row
- the boxed keyboard **R** radial prompt
- the circular/mouse-wheel radial graphic
- the small white radial indicator arrow
- the normal bottom-right input legend

Opening the inventory restores the normal 8-slot quick-access row. Closing the inventory hides it again. The actual quick-access radial selector is not modified and remains functional.

## Performance

Clean UI is deliberately event-driven and minimal:

- no Tick hook
- no per-frame scanning
- no watchdog
- no continuously repeating timer
- widget discovery runs only during initialization and stops once the required widgets are found
- one inventory toggle hook performs two short delayed quick-bar state updates to account for the game's UI transition

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
        ├── install.txt
        ├── enabled.txt
        └── Scripts
            └── main.lua
```

## Uninstall

Delete `ue4ss\Mods\cleanui` and restart the game.

## Compatibility

Clean UI changes only the specific HUD widgets described above. It does not hide or collapse the actual quick-access radial selector.

Because the mod targets game UI widget names, a future RuneScape: Dragonwilds update that changes those widgets may require an update to Clean UI.

## Controller support

The cleanup is not tied to a keyboard hotkey. The radial selector continues to work with controllers, including PlayStation-style controllers used on PC.

## Version

Current release: **1.0.0**

See [changelog.md](changelog.md) for release notes.

## License

Released under the MIT License. See [license](license).
