extends WeaponBase

func _ready():
    super._ready()
    weapon_name = "Rifle"
    damage = 15.0
    fire_rate = 0.8
    range = 150.0
    crit_chance = 0.1
    ammo_type = "infinite"
    mesh.shape = preload("res://assets/models/rifle_mesh.gdmesh")

func on_upgrade():
    super.upgrade_level()
    print("Rifle upgraded! New damage: " + str(damage) + " Level: " + str(weapon_level))