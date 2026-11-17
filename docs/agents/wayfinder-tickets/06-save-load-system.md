## Question
Save/load system path validation: Verify the `user://game_save.json` path works correctly for saving and loading game state. Check:
- GameManager.save_game() opens "user://game_save.json" in WRITE mode
- GameManager.load_game() opens "user://game_save.json" in READ mode and parses JSON
- Saved data structure: {"currency": int, "weapon_level": int, "weapon_type": string}
- Loading handles missing save file gracefully (prints "No save file found, starting new game.")
- No references to deleted resources in the save file format

Does the save/load system work correctly? Are there any issues with the user:// path or JSON format?