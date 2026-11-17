extends Node3D

const GRID_SIZE = 12
const CELL_SIZE = 2.0
const MAX_OBJECTS = 15

var grid_objects[GRID_SIZE][GRID_SIZE] = {}
var object_hardness = {"crate": 1, "barrel": 2, "wooden_box": 1, "metal_crate": 3, "concrete_block": 5}

# Reference to game manager for currency signals
@onready var game_manager: GameManager = null

func _ready():
    generate_room()
    # Try to find game manager if not set
    if game_manager == null:
        var parent = get_parent()
        if parent and parent.is_class("GameManager"):
            game_manager = parent
    print("Room generated with " + str(count_objects()) + " destructible objects")

func set_game_manager(gm: GameManager):
    game_manager = gm

func generate_room():
    # Create floor
    for x in range(GRID_SIZE):
        for z in range(GRID_SIZE):
            # Floor cell (using Y-up, so position at y=0)
            var floor_scene = load("res://assets/models/floor.tscn")
            if floor_scene:
                var floor_instance = floor_scene.instantiate()
                floor_instance.position = Vector3(x * CELL_SIZE, 0, z * CELL_SIZE)
                add_child(floor_instance)

    # Create perimeter walls
    for x in range(GRID_SIZE):
        # Wall at x=0
        var wall_scene = load("res://assets/models/wall.tscn")
        if wall_scene:
            var wall_instance = wall_scene.instantiate()
            wall_instance.position = Vector3(0, 1, x * CELL_SIZE)
            add_child(wall_instance)

            # Wall at x=GRID_SIZE-1
            var wall_instance2 = wall_scene.instantiate()
            wall_instance2.position = Vector3((GRID_SIZE-1) * CELL_SIZE, 1, x * CELL_SIZE)
            add_child(wall_instance2)

            # Wall at z=0
            var wall_instance3 = wall_scene.instantiate()
            wall_instance3.position = Vector3(x * CELL_SIZE, 1, 0)
            add_child(wall_instance3)

            # Wall at z=GRID_SIZE-1
            var wall_instance4 = wall_scene.instantiate()
            wall_instance4.position = Vector3(x * CELL_SIZE, 1, (GRID_SIZE-1) * CELL_SIZE)
            add_child(wall_instance4)

    # Place destructible objects randomly
    var placed = 0
    while placed < MAX_OBJECTS:
        var rand_x = randi() % GRID_SIZE
        var rand_z = randi() % GRID_SIZE

        # Don't place on top of walls or too close to player start
        if grid_objects[rand_x][rand_z] == null:
            var obj_type = pick_object_type()
            var obj_scene = preload("res://scenes/room/destructible_object_scene.gd")
            var obj_instance = obj_scene.instantiate()
            obj_instance.object_type = obj_type
            obj_instance.position = Vector3(rand_x * CELL_SIZE, 1, rand_z * CELL_SIZE)

            # Set hardness based on type
            var hardness_val = object_hardness[obj_type]
            obj_instance.set_hardness(hardness_val)

            # Set drop currency based on type
            var drop_amount = get_drop_currency(obj_type)
            obj_instance.drop_currency = drop_amount

            # Connect destroyed signal to game manager
            obj_instance.connect("destroyed", game_manager, "add_currency")

            add_child(obj_instance)

            # Store reference in grid
            grid_objects[rand_x][rand_z] = obj_instance

            placed += 1

func pick_object_type() -> String:
    var r = randf()
    if r < 0.5:
        return "crate"
    elif r < 0.75:
        return "barrel"
    elif r < 0.9:
        return "wooden_box"
    else:
        return "metal_crate"

func get_drop_currency(type: String) -> int:
    var drops = {"crate": 10, "barrel": 15, "wooden_box": 5, "metal_crate": 20}
    return drops.get(type, 10)

func count_objects() -> int:
    var count = 0
    for x in range(GRID_SIZE):
        for z in range(GRID_SIZE):
            if grid_objects[x][z] != null:
                count += 1
    return count

func _on_object_destroyed(drop_amount: int):
    if game_manager:
        game_manager.add_currency(drop_amount)
    print("Object destroyed! Drop: " + str(drop_amount) + " Total currency: " + str(game_manager.get_total_currency()))