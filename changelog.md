# Changelog

## 1.0.4 - 2026-09-25

- adds configurable HUD settings through config.txt
- adds optional Mod Menu integration for in-game toggle access; Mod Menu v1.0.9 or compatible is required only for menu-based configuration
- adds an optional Hide Compass setting
- adds configurable hotbar visibility while inventory is open
- adds configurable hotbar visibility while storage/chest interfaces are open
- adds Hide Other Player Markers (BETA - needs testing), OFF by default, for community multiplayer/PvP testing
- beta player-marker mode records targeted map-icon metadata in UE4SS.log to help validate and refine map/compass coverage
- settings are loaded once at startup and require a game restart; no continuous settings polling is used
- tested core 1.0.4 HUD, compass, inventory, and storage behavior with RuneScape: Dragonwilds 1.0.0.5

## 1.0.4 - 2026-09-25

- adds configurable Clean UI settings through `config.txt`
- adds optional Mod Menu integration; Mod Menu is not required
- adds an optional Hide Compass setting
- adds configurable Show Hotbar in Inventory behavior
- adds Show Hotbar in Storage so the quick-access bar can remain visible while using chest/storage interfaces
- settings are loaded once at startup and changes require a game restart
- preserves the lightweight event-driven design with no Tick hook, watchdog, per-frame scanning, or continuous configuration polling
- tested successfully with RuneScape: Dragonwilds patch 1.0.0.5


## 1.0.3 - 2026-09-22

- fixes the bottom-right input legend reappearing after opening and closing the map with a controller
- keeps the input legend permanently hidden even if the game restores its visibility during later UI transitions
- preserves the existing event-driven design with no additional hooks, polling, watchdog, or per-frame processing

## 1.0.2 - 2026-09-22

- fixes the gameplay 8-slot quick-access bar remaining visible after selecting an inventory quick-access item with a controller and closing the inventory with B / Circle
- adds event-driven handling for the game's controller/back inventory close path
- uses stable Unreal object-path identity for targeted quick-bar opacity protection
- retains the lightweight design with no Tick hook, watchdog, per-frame scanning, or continuous polling after initialization

## 1.0.1 - 2026-09-21

- general performance and efficiency enhancements
- refined event handling to reduce unnecessary UI processing
- improved internal quick-access bar state handling for smoother HUD behavior
- minor code cleanup and reliability improvements

## 1.0.0 - 2026-09-20

Initial public release.

- hides the gameplay 8-slot quick-access/hotbar row
- keeps the quick-access row visible while inventory is open
- prevents the gameplay hotbar from being restored after inventory item selection/equipping
- hides the boxed R radial prompt
- hides the circular/mouse-wheel radial graphic
- hides the small white radial indicator arrow
- hides the normal bottom-right input legend
- preserves the functional quick-access radial selector
- supports keyboard/mouse and controllers
- uses an event-driven design with no Tick hook, watchdog, per-frame scanning, or continuous polling after initialization
