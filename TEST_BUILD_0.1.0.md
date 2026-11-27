# Test Build 0.1.0 — First Playable Enhancement Pass

## Implemented in the repository
- Original procedural coastal city, district areas, streets, waterfront, promenade, park, warehouse, gas-station props, marina-side landmark, palms and building blockout.
- Story and sandbox modes; five original location checkpoint missions in the Godot mission manager.
- Browser demo enhanced with five checkpoint objectives, cash rewards, collectible tokens, HUD district labels, mission checkpoint saves, pause/resume, restart, sprint stamina, simple block collision, vehicle mode and reset.
- Godot player sprint stamina.
- Godot vehicle collider placeholder, handbrake (H), reset (R), plus mobile brake and reset buttons.
- Save/load for Godot mission progress, wallet and player position.
- Browser demo touch buttons for movement, sprint, jump, vehicle toggle, weather, brake and reset.

## Known limitations / not yet verified
- Godot project has not been imported, compiled or run in this environment; parse/runtime errors may remain.
- Godot native vehicle physics remain simplified; the added collider is a placeholder and needs in-editor collision testing.
- The browser demo is a separate 2D prototype and does not automatically represent the Godot 3D game.
- Browser controls/collision/save logic require device/browser testing.
- NPCs and traffic are simple placeholder agents; no sophisticated navigation, traffic lights logic, or full pedestrian collision.
- Weather effects and day/night are visual prototypes, not complete particle/weather systems.
- Buildings remain mostly blockout geometry; enterable interiors, advanced vehicle damage, audio, haptic feedback, controller support, full customizable controls and iOS export are not in this build.

## Test checklist
- Open `index.html` in a modern desktop or mobile browser; select Story or Sandbox.
- Check movement, sprint, jump, driving, brake, vehicle reset, mission markers, pickups, cash and pause/resume.
- In Godot 4.x, open the project and test story/sandbox, touch controls, five missions, vehicle toggle, handbrake and reset.
- Test iPad export only after editor validation and Xcode setup.

This is an early test prototype, not a complete game, not a GTA VI port, and not an installable iPad release yet.