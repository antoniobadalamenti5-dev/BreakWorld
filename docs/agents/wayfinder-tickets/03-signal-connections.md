## Question
Signal connection completeness: Verify all signal connections are properly defined and connected across the project. Specifically check:
- room.connect("object_destroyed", game_manager, "add_currency") in main_scene.gd
- obj_instance.connect("destroyed", game_manager, "add_currency") in room_grid.gd  
- player.on_shoot_signal(damage, position, direction, collider) connected to destructible_object.take_damage
- destructible_object._on_destroyed() emitting "destroyed" signal received by GameManager
- GameManager.upgrade_purchased signal emission and any connections
- Any other signal connections that should exist but may be missing

Are all signals connected to existing methods and nodes? Are there any signals connected to non-existent methods?