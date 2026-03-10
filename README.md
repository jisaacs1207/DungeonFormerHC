# DungeonFormer

WoW Classic Hardcore addon for forming dungeon groups: search /who by level and zone, whisper players from results, and track who you've whispered with optional auto-reply.

## Commands

- **/df** — Toggle the Dungeon Former window

## Usage

1. **Search** — Pick a dungeon (or level range), zone, and class filters. Click Search to run `/who`; results appear on the Results tab.
2. **Results** — Set your message and click a name to whisper and move them to the Whispered list.
3. **Whispered** — See everyone you've whispered. Set an auto-reply and toggle On/Off. Clear No-Reply removes people who haven't replied; Clear List clears everyone.

## Requirements

- WoW Classic Era / Hardcore (Interface: 11508)

## Structure (no Ace)

- **Core/Config.lua** — Class colors, dungeon list, zones
- **Core/WhoAPI.lua** — Who list API (Classic vs retail)
- **UI/Frame.lua** — Main window and tabs
- **UI/TabSearch.lua** — Search tab UI
- **UI/TabResults.lua** — Results tab UI
- **UI/TabWhispered.lua** — Whispered tab UI
- **DungeonFormer.lua** — Slash command, state, search/pull-who, whisper events

Saved data is in `DungeonFormerDB`; the addon migrates from the old `carelessWhispered` if present.
