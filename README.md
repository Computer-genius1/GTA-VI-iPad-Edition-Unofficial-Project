# Leonida iPad Prototype — Unofficial GTA VI-Inspired Fan Project

An open-source, original South-Florida-inspired city prototype targeting Apple Silicon iPads (M3 and newer). It is **not** GTA VI itself, not a Rockstar port, and does not contain Rockstar code, map files, models, textures, audio, or other proprietary assets.

## Modes

- **Story Mode:** an original, small mission sequence with objective text and a destination marker. Complete five original checkpoint missions in order, earn mission rewards, and save checkpoint progress.
- **Sandbox Mode:** free roam with no active mission objectives.
- The mode-selection menu appears when the prototype starts. Missions currently use simple reach-the-location objectives; this is a prototype, not a complete narrative campaign.

## Native iPad project

The repository now focuses on the Godot native 3D prototype only. The separate browser game has been removed. The 3D project is still a prototype and has not yet been built or tested on iPad.

## Build 0.1 enhancement pass

- Godot story missions expanded to five and now save mission index, wallet, and player checkpoint.
- Godot player sprint now uses stamina. Vehicle gains a collider placeholder, handbrake, and reset hotkey (R); handbrake (H).

## Development update — Beta-preparation features

- Ambient loop-route traffic placeholders and strolling pedestrian placeholders.
- Road crosswalks, street lamps, promenade planters and additional environmental props.
- Toggleable night ambience (**N**) and cloudy ambience (**V**) for visual testing.
- Night-only streetlamp illumination at selected intersections.
- Original traffic-signal props added to selected downtown intersections.
- Additional separate scripts for traffic and pedestrians.

## Test Build 0.1.0 — prototype feature set

- Procedural city blockout with downtown towers, low-rise blocks, beach edge, ocean, promenade, pier, palms, street grid, sidewalks and boulevard median.
- Original placeholder building facades and rooftop silhouettes.
- Third-person player with acceleration/braking, sprint, jump, mouse-look and touch-drag camera.
- First drivable placeholder car: acceleration, reverse, steering, brake/roll-off, enter/exit and chase camera.
- On-screen HUD with current test build and interaction hints.
- Story/Sandbox selection menu and three sequential location-based story missions.
- Mobile touch buttons for forward/back/left/right, sprint, jump and enter/exit.
- Landscape display setup and mobile renderer configuration.
- Deterministic map layout for repeatable testing.

## Build 0.1 status

**Implemented, but not yet validated in a Godot runtime:** five story objectives and save/reward handling, sprint stamina, vehicle handbrake and reset hotkeys, plus touch brake/reset controls. See `TEST_BUILD_0.1.0.md` for limitations.

## How to test

1. Install Godot 4.x (mobile renderer recommended).
2. Clone or download this repository and open the folder in Godot.
3. Run the main scene `scenes/main.tscn`.
4. Desktop controls: **W/A/S/D** move/drive; **Shift** sprint; **Space** jump; mouse drag/look; **E** enter/exit vehicle; **Esc** release cursor.
5. On a touch device, use the on-screen movement buttons; drag the screen to rotate the camera.

**Status:** source scaffold and feature implementation are committed, but this prototype has not yet been compiled or run in an installed Godot environment. It is not an installable iPad build yet. iPad deployment requires Godot's iOS export workflow and Xcode on a Mac, plus device testing.

## iOS export

Use the **iOS export project** workflow from the GitHub Actions tab (or wait for it to run after a project change). It exports an Xcode project artifact for 14 days. This is an unsigned Xcode project—not an IPA. Open it in Xcode on a Mac, replace the placeholder Apple Team ID in the export preset with your own Team ID, and configure signing/provisioning to build an installable app.

## Roadmap

- Test/fix Godot parser and runtime issues; tune controls and mobile frame rate.
- Replace primitive NPC/traffic with animated models, navigation and collision-aware behavior.
- Implement real weather particles, wet road materials and proper time-of-day transitions.
- Improve road markings, building variety, water/coast visuals, vegetation, props and material quality.
- Add vehicle collision, more vehicle models, road traffic and pedestrians.
- Expand map districts and transitions; add weather and time-of-day.
- Add proper iPad export and beta testing workflow.

## Legal note

“Grand Theft Auto”, “GTA”, “GTA VI”, “Vice City”, and related marks belong to their respective owners. This project is unofficial, non-affiliated and not endorsed by Rockstar Games or Take-Two Interactive. The map, scripts and placeholder geometry in this repository are original work; please do not add or redistribute copyrighted game assets without permission.

## License

MIT License for original source code. See [LICENSE](LICENSE).