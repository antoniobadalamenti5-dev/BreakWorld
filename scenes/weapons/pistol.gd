extends WeaponBase

func _ready():
    super._ready()
    weapon_name = "Pistol"
    damage = 10.0
    fire_rate = 1.5
    range = 80.0
    crit_chance = 0.15
    ammo_type = "infinite"
    mesh.shape = preload("res://assets/models/pistol_mesh.gdmesh")

func on_upgrade():
    super.upgrade_level()
    print("Pistol upgraded! New damage: " + str(damage) + " Level: " + str(weapon_level))