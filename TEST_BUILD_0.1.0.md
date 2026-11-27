# Native Godot Test Build — prototype

The standalone browser game (`index.html`) has been removed. Development now targets the Godot native 3D project.

## Previously implemented baseline
- Original procedural coastal city, district areas, streets, waterfront, promenade, park, warehouse, gas-station props, marina-side landmark, palms and building blockout.
- Story and sandbox modes; five original location checkpoint missions in the Godot mission manager.
- Browser demo enhanced with five checkpoint objectives, cash rewards, collectible tokens, HUD district labels, mission checkpoint saves, pause/resume, restart, sprint stamina, simple block collision, vehicle mode and reset.
- Godot player sprint stamina.
- Godot vehicle collider placeholder, handbrake (H), reset (R), plus mobile brake and reset buttons.
- Save/load for Godot mission progress, wallet and player position.
- Native touch controls for movement, sprint, jump, vehicle toggle, brake and reset.

## Known limitations / not yet verified
- Godot project has not been imported, compiled or run in this environment; parse/runtime errors may remain.
- Build 0.2 browser-only systems (wanted level, police chase, GPS, safehouse, garage, settings) were not ported to Godot and the browser prototype has been removed.
- Police are simplified chase placeholders; they do not have road navigation or advanced search behavior.
- Garage upgrades are progression placeholders; they do not currently alter detailed vehicle physics or performance.
- Day/night is a visual tint and time display; no full lighting simulation.
- Godot native vehicle physics remain simplified; the added collider is a placeholder and needs in-editor collision testing.
- Native Godot project is not yet exported or tested on an iPad.

- NPCs and traffic are simple placeholder agents; no sophisticated navigation, traffic lights logic, or full pedestrian collision.
- Weather effects and day/night are visual prototypes, not complete particle/weather systems.
- Buildings remain mostly blockout geometry; enterable interiors, advanced vehicle damage, audio, haptic feedback, controller support, full customizable controls and iOS export are not in this build.

## Test checklist
- Open the Godot project, run the main scene, and test story/sandbox, touch controls, five missions, vehicle toggle, handbrake and reset.
- iOS export requires macOS/Xcode, Godot export templates, Apple signing credentials and device testing.

This is an early test prototype, not a complete game, not a GTA VI port, and not an installable iPad release yet.