## Question
Scene tree consistency: Verify all scene hierarchies are consistent across the project. Check that all nodes referenced in scripts exist in their respective scenes. Specifically:
- main_scene.gd references: player (player_body.gd), room (room_grid.gd), hud (hud.gd), game_manager
- player_body.gd references: CameraOffset, ShootTimer, RayCast3D
- HUD references: TimerLabel, CurrencyLabel, WeaponLabel, StaminaBar
- room_grid.gd has @onready var game_manager: GameManager

Are all these node references valid? Are there any missing nodes or incorrect path references in any scene?