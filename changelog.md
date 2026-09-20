# Changelog

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
