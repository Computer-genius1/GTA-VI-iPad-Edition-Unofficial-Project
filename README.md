# Leonida iPad Prototype — Unofficial GTA VI-Inspired Fan Project

An open-source, original South-Florida-inspired city prototype targeting Apple Silicon iPads (M3 and newer). It is **not** GTA VI itself, not a Rockstar port, and does not contain Rockstar code, map files, models, textures, audio, or other proprietary assets.

## Test Build 0.1.0 — prototype feature set

- Procedural city blockout with downtown towers, low-rise blocks, beach edge, ocean, promenade, pier, palms, street grid, sidewalks and boulevard median.
- Original placeholder building facades and rooftop silhouettes.
- Third-person player with acceleration/braking, sprint, jump, mouse-look and touch-drag camera.
- First drivable placeholder car: acceleration, reverse, steering, brake/roll-off, enter/exit and chase camera.
- On-screen HUD with current test build and interaction hints.
- Mobile touch buttons for forward/back/left/right, sprint, jump and enter/exit.
- Landscape display setup and mobile renderer configuration.
- Deterministic map layout for repeatable testing.

## How to test

1. Install Godot 4.x (mobile renderer recommended).
2. Clone or download this repository and open the folder in Godot.
3. Run the main scene `scenes/main.tscn`.
4. Desktop controls: **W/A/S/D** move/drive; **Shift** sprint; **Space** jump; mouse drag/look; **E** enter/exit vehicle; **Esc** release cursor.
5. On a touch device, use the on-screen movement buttons; drag the screen to rotate the camera.

**Status:** source scaffold and feature implementation are committed, but this prototype has not yet been compiled or run in an installed Godot environment. It is not an installable iPad build yet. iPad deployment requires Godot's iOS export workflow and Xcode on a Mac, plus device testing.

## Roadmap

- Test/fix Godot parser and runtime issues; tune controls and mobile frame rate.
- Improve road markings, building variety, water/coast visuals, vegetation, props and material quality.
- Add vehicle collision, more vehicle models, road traffic and pedestrians.
- Expand map districts and transitions; add weather and time-of-day.
- Add proper iPad export and beta testing workflow.

## Legal note

“Grand Theft Auto”, “GTA”, “GTA VI”, “Vice City”, and related marks belong to their respective owners. This project is unofficial, non-affiliated and not endorsed by Rockstar Games or Take-Two Interactive. The map, scripts and placeholder geometry in this repository are original work; please do not add or redistribute copyrighted game assets without permission.

## License

MIT License for original source code. See [LICENSE](LICENSE).