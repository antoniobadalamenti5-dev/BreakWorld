extends CharacterBody3D

@export @export_group("Player Settings") var speed = 5
@export @export_group("Player Settings") var stamina_max = 100
@export @export_group("Player Settings") var stamina_regen = 1
@export @export_group("Player Settings") var shoot_cooldown = 0.5

@onready var camera_offset = $CameraOffset
@onready var shoot_timer = $ShootTimer
@onready var ray_cast = $RayCast3D

var current_stamina : float = 100.0
var stamina_regen : float = 1.0
var speed : float = 5.0
var shoot_cooldown : float = 0.5
var stamina_drain_per_shot : float = 10.0

const MOVE_ACTION = "move_forward"
const SHOOT_ACTION = "shoot"

# Weapon swap indices (1-4)
var current_weapon_index = 1
var weapon_names = ["Pistol", "Rifle", "Shotgun"]

func _ready():
    current_stamina = stamina_max
    shoot_timer = 0.0
    set_physics_process(true)

    # Get game manager and register player
    GameManager.add_player(self)

    # Create CameraOffset if not in scene
    if not has_node("CameraOffset"):
        var cam_offset = Node3D.new()
        cam_offset.name = "CameraOffset"
        cam_offset.position = Vector3(0, 0, -8)
        add_child(cam_offset)

    # Add Shoot sound player if not in scene
    if not has_node("ShootSound"):
        var shoot_sound = AudioStreamPlayer3D.new()
        shoot_sound.name = "ShootSound"
        shoot_sound.autoplay = false
        # Load shooting sound - will be set in the scene
        shoot_sound.stream = preload("res://assets/audio/gunshot.wav")
        shoot_sound.max_distance = 50
        shoot_sound.default_min_distance = 10
        shoot_sound.volume_db = -5
        add_child(shoot_sound)

    # Setup raycast for shooting
    if not has_node("RayCast3D"):
        var ray_cast = RayCast3D.new()
        ray_cast.name = "RayCast3D"
        ray_cast.ignore = false
        ray_cast.max_distance = 100
        ray_cast.collide_with_areas = true
        add_child(ray_cast)

    # Setup input actions - WASD movement and weapon swap
    InputMap.add_action("move_forward")
    InputMap.action_add_event("move_forward", InputEventKey.new())
    Input.get_action("move_forward").keys.append(KEY_W)
    Input.get_action("move_forward").keys.append(KEY_S)
    Input.get_action("move_forward").keys.append(KEY_A)
    Input.get_action("move_forward").keys.append(KEY_D)

    # Number keys for weapon swap (1-4)
    for i in range(4):
        var action_name = "weapon_" + str(i+1)
        if !InputMap.has_action(action_name):
            InputMap.add_action(action_name)
        var key_event = InputEventKey.new()
        key_event.keys.append(i+1)
        InputMap.action_add_event(action_name, key_event)

    # Add to groups for raycast detection
    add_to_group("player")
    add_to_group("shooter")

    # Configure raycast
    $RayCast3D.ignore = false
    $RayCast3D.max_distance = 100
    $RayCast3D.collide_with_areas = true

func _physics_process(delta):
    # Stamina regeneration when not shooting
    if current_stamina < stamina_max and not is_key_pressed(KEY_LEFT_SHIFT):
        current_stamina = min(current_stamina + stamina_regen * get_physics_process_delta_time(), stamina_max)

    # Input handling - WASD movement
    var input_direction = Vector3.ZERO

    if Input.is_key_pressed(KEY_W):
        input_direction -= transform.basis.z
    if Input.is_key_pressed(KEY_S):
        input_direction += transform.basis.z
    if Input.is_key_pressed(KEY_A):
        input_direction -= transform.basis.x
    if Input.is_key_pressed(KEY_D):
        input_direction += transform.basis.x

    # Normalize direction
    if input_direction.length() > 0:
        input_direction = input_direction.normalized()

    velocity = input_direction * speed
    move_and_slide()

    # Shoot cooldown timer
    if shoot_timer > 0:
        shoot_timer -= get_physics_process_delta_time()
        if shoot_timer < 0:
            shoot_timer = 0

    # Weapon swap with number keys
    for i in range(4):
        if Input.is_action_just_pressed("weapon_" + str(i+1)):
            swap_weapon(i)

    # R-key weapon swap
    if Input.is_action_just_pressed("weapon_r"):
        swap_weapon(current_weapon_index)  # Will cycle based on index modulo
        # Cycle to next weapon
        current_weapon_index = (current_weapon_index % weapon_names.size()) + 1
        swap_weapon(current_weapon_index - 1)  # -1 because swap_weapon uses 0-indexed internally

func swap_weapon(index: int):
    current_weapon_index = index
    var weapon_name = weapon_names[index] if index < weapon_names.size() else "Weapon " + str(index+1)
    print("Switched to weapon " + str(index+1) + ": " + weapon_name)

func _input(event):
    if event.is_action("shoot") and current_stamina > 0 and shoot_timer <= 0:
        shoot()
        current_stamina -= stamina_drain_per_shot
        if current_stamina < 0:
            current_stamina = 0
        shoot_timer = shoot_cooldown

    # Regenerate stamina when not shooting
    if not event.is_action("shoot") and current_stamina < stamina_max:
        current_stamina = min(current_stamina + stamina_regen * get_physics_process_delta_time(), stamina_max)

func on_shoot_signal(damage: float, position: Vector3, direction: Vector3, collider: Node3D):
    # Destructible object receives this signal and takes damage
    if collider.has_method("take_damage"):
        collider.take_damage(damage, position, direction)

func shoot():
    # Update raycast origin at camera position + forward direction
    if $RayCast3D:
        $RayCast3D.global_position = camera_offset.global_position + Vector3(0, 1, 0)
        # Direction based on camera's forward (negative Z typically in Godot)
        $RayCast3D.target_position = -camera_offset.global_transform.basis.z * 100

    if $RayCast3D.is_colliding():
        var collider = $RayCast3D.get_collider()
        print("Raycast hit: " + collider.name + " group: " + collider.groups)

        # Check if it's a destructible object
        if collider.is_in_group("destructible"):
            var damage = get_weapon_damage()
            emit_signal("shoot_shoot", damage, $RayCast3D.global_position, $RayCast3D.global_direction, collider)
            print("Dealt " + str(damage) + " damage to " + collider.name)
        elif collider.is_in_group("player"):
            print("Hit player!")
        else:
            print("Hit something else: " + collider.name)

    # Reset for next shot
    $RayCast3D.collide_with_areas = true

    # Play shooting sound effect (if audio player exists)
    if has_node("ShootSound"):
        $ShootSound.play()

    # Visual muzzle flash
    print("Pew! Stamina: " + str(current_stamina) + "/" + str(stamina_max) + " | Weapon: " + get_current_weapon_name())

func get_weapon_damage() -> float:
    var weapon_level = GameManager.get_current_weapon_level()
    var base_damage = 10.0
    return base_damage * weapon_level

func get_current_weapon_name() -> String:
    return weapon_names[current_weapon_index] if current_weapon_index < weapon_names.size() else "Unknown"

func take_damage(amount: float):
    current_stamina = max(0, current_stamina - amount)
    print("Player stamina drained! Remaining: " + str(current_stamina))

func get_stamina_percent() -> float:
    return current_stamina / stamina_max