extends WeaponBase

func _ready():
    super._ready()
    weapon_name = "Shotgun"
    damage = 20.0
    fire_rate = 0.5  # Slower fire rate
    range = 50.0
    crit_chance = 0.05  # Lower crit chance but higher base damage
    ammo_type = "infinite"
    print("Shotgun loaded! Damage: " + str(damage) + " Fire rate: " + str(fire_rate))

func on_upgrade():
    super.upgrade_level()
    print("Shotgun upgraded! New damage: " + str(damage) + " Level: " + str(weapon_level))