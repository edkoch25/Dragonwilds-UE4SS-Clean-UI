# Nexus Mods Description

## Clean UI

A lightweight UE4SS HUD cleaner for **RuneScape: Dragonwilds**.

Clean UI removes several persistent gameplay HUD elements while keeping the inventory and quick-access radial selector working normally.

### Removes during gameplay

- 8-slot quick-access/hotbar row
- boxed R radial prompt
- circular/mouse-wheel radial graphic
- small white radial indicator arrow
- normal bottom-right input legend

The quick-access row automatically returns when the inventory is opened and hides again when the inventory closes.

The actual radial selector is left untouched and remains fully functional, including controller use.

### Lightweight by design

Clean UI does not use a Tick hook, per-frame widget scanning, a watchdog, or continuous polling after initialization. Widget discovery stops once initialization succeeds. Runtime behavior is event-driven.

### Requirements

A working UE4SS installation for RuneScape: Dragonwilds.

**RSDWTools / RSDW Dev Kit is not required.**

### Installation

Extract the included `CleanUI` folder to:

`RSDragonwilds\Binaries\Win64\ue4ss\Mods\`

Restart the game.

### Uninstall

Delete the `CleanUI` folder from `ue4ss\Mods` and restart the game.

### Source

Source code and release history are maintained on GitHub.
