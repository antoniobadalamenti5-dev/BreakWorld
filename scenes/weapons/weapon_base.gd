extends Area3D
class_name WeaponBase

@export var weapon_name = "Base Weapon"
@export var damage = 10.0
@export var fire_rate = 1.0  # shots per second
@export var range = 100.0
@export var crit_chance = 0.1  # 10%
@export var ammo_type = "infinite"

@onready var shoot_timer = null
@onready var mesh = null
@onready var collision = null

var current_cooldown = 0.0
var is_equipped = false
var weapon_level = 1
var base_damage = 10.0
var base_fire_rate = 1.0

func _ready():
    shoot_timer = $ShootTimer
    mesh = get_node("Mesh")
    collision = get_node("CollisionShape3D")

    # Add to weapons group for upgrade system
    add_to_group("weapons")

    # Connect to game_manager upgrade signal - weapons will receive level updates
    # Note: GameManager is auto-loaded or instantiated via scene graph
    # This is a placeholder connection - actual connection made in setup

    # Setup collision layer
    collision.collision_layer = 1 << 2  # Player shot layer
    collision.collision_mask = 1 << 1  # Destructible objects layer

func _process(delta):
    if current_cooldown > 0:
        current_cooldown -= delta
        if current_cooldown < 0:
            current_cooldown = 0

func can_shoot() -> bool:
    return current_cooldown <= 0

func shoot(position: Vector3, direction: Vector3) -> bool:
    if not can_shoot():
        return false

    current_cooldown = 1.0 / fire_rate

    # Raycast to detect what we hit
    var ray_cast = RayCast3D.new()
    ray_cast.position = position
    ray_cast.direction = direction
    ray_cast.max_distance = range
    ray_cast.collide_with_areas = true
    add_child(ray_cast)

    # Check for destructible objects
    if ray_cast.is_colliding():
        var collider = ray_cast.get_collider()
        if collider.is_in_group("destructible"):
            # Multi-hit destruction: weapon damage = base 10 * level
            # Each shot applies damage based on hardness
            var hardness = collider.get("hardness", 1)
            # Base weapon damage scales with level: 10 * level
            # Each hitpoint requires one hit (hardness = number of hits needed)
            var weapon_damage = 10 * weapon_level
            var effective_damage = weapon_damage * (1 if randf() > crit_chance else (1 + crit_chance * 2))
            collider.take_damage(effective_damage, ray_cast.position, direction)

    # Muzzle flash effect
    print("Bang! Damage: " + str(damage) + " Level: " + str(weapon_level))

    return true

func upgrade_level():
    weapon_level += 1
    # Weapon damage scales linearly: 10 * level
    damage = 10 * weapon_level
    # Fire rate improves slightly with each level
    fire_rate = base_fire_rate * (1 + (weapon_level - 1) * 0.1)
    print("Weapon upgraded to level " + str(weapon_level) + "! Damage: " + str(damage) + " Fire Rate: " + str(fire_rate))

func get_level() -> int:
    return weapon_level

func get_damage() -> float:
    return damage