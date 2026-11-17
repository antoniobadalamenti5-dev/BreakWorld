extends Area3D

signal destroyed(currency_amount)

var max_hitpoints: int = 1
var current_hitpoints: int = 0
var object_type: String = "crate"
var hardness: int = 1
var drop_currency: int = 10

@onready var mesh_instance: MeshInstance3D = null
@onready var collision_shape: CollisionShape3D = null

func _ready():
    mesh_instance = get_node("MeshInstance3D")
    collision_shape = get_node("CollisionShape3D")

    # Add to destructible group for raycast detection
    add_to_group("destructible")

    current_hitpoints = max_hitpoints

    # Set hardness based on object type
    set_hardness(hardness)

    print("Destructible " + object_type + " created with hardness " + str(hardness) + ", max HP: " + str(max_hitpoints))

func take_damage(amount: float, position: Vector3, direction: Vector3):
    # Damage calculation: 1 hitpoint per 10 damage at weapon level 1
    current_hitpoints -= int(amount / 10.0)

    # Visual feedback - quick flash
    if mesh_instance:
        var mat = mesh_instance.material_override
        if mat == null:
            mat = StandardMaterial3D.new()
            mesh_instance.material_override = mat
        mat.albedo_color = Color(1, 0.5, 0)  # Orange flash

    print("Object took " + str(int(amount / 10.0)) + " damage (raw: " + str(amount) + "). HP: " + str(current_hitpoints) + "/" + str(max_hitpoints))

    if current_hitpoints <= 0:
        _on_destroyed()

func _on_destroyed():
    # Drop currency based on hardness (higher hardness = more valuable)
    var final_currency = drop_currency * hardness
    # Emit signal first for currency collection
    emit_signal("destroyed", final_currency)

    # Drop currency through game manager
    if GameManager.is_class("GameManager"):
        GameManager.add_currency(final_currency)

    print(object_type + " destroyed! Dropped €" + str(final_currency) + " (base: " + str(drop_currency) + ", x" + str(hardness) + " hardness)")
    queue_free()

func set_hardness(hardness_level: int):
    hardness = hardness_level
    # Scale max hitpoints
    var base_hp = 1
    if object_type == "barrel": base_hp = 2
    if object_type == "metal_crate": base_hp = 3
    if object_type == "concrete_block": base_hp = 5

    max_hitpoints = base_hp * hardness_level
    current_hitpoints = max_hitpoints