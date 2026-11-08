# EmoteBar

<img src="docs/assets/icons/icon-512.png" alt="EmoteBar icon" width="128">

A minimal, movable bar of emote buttons for World of Warcraft Forever. Click a button to perform an emote; configure everything in-game.

## Features

- Movable, lockable bar with up to many emote slots
- Custom icons per slot (bundled icon set in `Icons/`)
- Horizontal or vertical layout, multiple rows/columns
- Adjustable scale (50–150%)
- In-game config window and an entry under *Options > AddOns*
- Settings saved across sessions (`EmoteBarDB`)
- English and German (deDE) text

## Installation

1. Download or clone this repository.
2. Copy the folder into your AddOns directory, named `EmoteBar`:
   `World of Warcraft\_forever_\Interface\AddOns\EmoteBar`
3. Restart the game or reload the UI (`/reload`).

The `.toc` currently targets Interface `16001`.

## Usage

Open the config window with `/eb` or `/emotebar`.

| Command | Description |
| --- | --- |
| `/eb` or `/eb config` | Toggle the config window |
| `/eb set <slot> <EMOTE>` | Assign an emote token to a slot (e.g. `/eb set 1 WAVE`) |
| `/eb icon <slot> <icon>` | Set a custom icon for a slot |
| `/eb count <n>` | Number of visible slots |
| `/eb rows <n>` | Number of rows/columns |
| `/eb scale <50-150>` | Scale in percent (`0.8` also accepted) |
| `/eb horizontal` / `/eb vertical` | Bar orientation |
| `/eb lock` / `/eb unlock` | Lock or unlock dragging |
| `/eb show` / `/eb hide` | Show or hide the bar |
| `/eb reset` | Reset all settings to defaults |

## License

Copyright (c) 2026 neXter. All Rights Reserved. See [LICENSE](LICENSE).

You may download and use the addon unmodified for personal, non-commercial use. Any copying, modification, or redistribution requires written permission from the author.

## Author

neXter
