## Question
Duplicate destructible_object.gd files exist: one at `scripts/destructible_object.gd` and another at `assets/scripts/destructible_object.gd`. This creates confusion about which is the authoritative version and could cause export or runtime issues. Need to determine the canonical location and either remove the duplicate or ensure both stay in sync.

## Question
Scene tree consistency: Need to verify all scene hierarchies are consistent. Check that all nodes referenced in scripts exist in their respective scenes (e.g., main_scene.gd references player, room, hud, game_manager; player_body.gd references CameraOffset, ShootTimer, RayCast3D; HUD references TimerLabel, CurrencyLabel, etc.).

## Question
Signal connection completeness: Verify all signal connections are properly defined and connected. Check for signals connected to non-existent methods or nodes, particularly: currency flow signals (object_destroyed → GameManager.add_currency), timer timeout signals, weapon swap signals, and player shoot signals.

## Question
Godot export configuration for Windows Desktop: Verify the export preset is configured for Windows executable export with Godot 4.7.2. Check for missing export templates, DLL dependencies, or configuration issues that would prevent `godot --export "Windows Desktop"` from working.

## Question
Audio assets validity: Verify all .wav files in `assets/audio/` are properly exported and referenceable. Check for missing audio streams or players that could cause export failures. Currently: gunshot, beep, alarm, explosion.

## Question
Save/load system path validation: Verify the `user://game_save.json` path works correctly for saving and loading game state (currency, weapon level, weapon type). Check for any references to deleted resources in the save file format.