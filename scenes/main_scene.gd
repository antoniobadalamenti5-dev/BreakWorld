extends Node3D

@onready var player = null
@onready var room = null
@onready var hud = null
@onready var game_manager = null

var session_time_limit = 60.0  # 60 seconds per session
var timer = Timer.new()

func _ready():
    # Load and add player
    var player_scene = preload("res://scenes/player/player_body.gd").instance()
    add_child(player_scene)
    player = player_scene

    # Load and add room
    var room_scene = preload("res://scenes/room/room_grid.gd").instance()
    add_child(room_scene)
    room = room_scene

    # Load and add HUD
    var hud_scene = preload("res://scenes/gui/hud.gd").instance()
    add_child(hud_scene)
    hud = hud_scene

    # Load game manager
    game_manager = $GameManager  # Will be auto-loaded or add manually
    if game_manager == null:
        var gm_scene = preload("res://scripts/game_manager.gd").instance()
        add_child(gm_scene)
        game_manager = gm_scene

    # Connect signals between room and game manager
    room.connect("object_destroyed", game_manager, "add_currency")

    # Setup timer
    timer.wait_time = 1.0
    timer.one_shot = false
    timer.timeout.connect(_on_session_timeout)
    add_child(timer)
    timer.start()

    print("Main scene ready! Session time limit: " + str(session_time_limit) + "s")

func _process(delta):
    session_time_limit -= delta
    if hud:
        hud.set_time_remaining(max(0, session_time_limit))
    if session_time_limit <= 0:
        _end_session()

func _on_session_timeout():
    print("Session time expired!")
    _end_session()

func _end_session():
    timer.stop()
    print("=== SESSION ENDED ===")
    print("Total currency earned: " + str(game_manager.get_total_currency()))
    print("Final weapon level: " + str(game_manager.get_current_weapon_level()))

    # Show end-of-session stats
    var final_score = "Final Score:\n"
    final_score += "Currency: " + str(game_manager.get_total_currency()) + "€\n"
    final_score += "Time survived: 60 seconds\n"
    final_score += "Weapon level reached: " + str(game_manager.get_current_weapon_level()) + "\n"
    print(final_score)

    # Could show a UI dialog here
    get_tree().quit = true  # For now, just exit

func on_player_shoot():
    # Handle shooting input from player
    if player:
        player.shoot()