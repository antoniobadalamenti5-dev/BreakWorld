extends Node

# Singleton-like manager for game state
signal upgrade_purchased(level: int)

var total_currency = 0
var current_weapon_level = 1
var current_weapon_type = "pistol" # pistol, rifle, shotgun

# Weapon upgrade costs (increase with level) - using 1.5^(level-1) formula
# Level 1: cost = base, Level 2: cost = base * 1.5, Level 3: cost = base * 2.25
const UPGRADE_COSTS = {"pistol": 100, "rifle": 150, "shotgun": 120}

# Player reference
var player_instance = null

# Singleton access (Godot auto-load or manual)
func get_total_currency() -> int:
    return total_currency

func add_currency(amount: int):
    total_currency += amount
    print("+€" + str(amount) + "! Total: " + str(total_currency))

func add_player(player):
    """Register player instance for game state access"""
    player_instance = player
    print("Player registered with GameManager")

func get_current_weapon_level() -> int:
    return current_weapon_level

func upgrade_weapon():
    global current_weapon_level, total_currency
    var cost = get_upgrade_cost()
    if total_currency >= cost:
        total_currency -= cost
        current_weapon_level += 1
        # Apply upgrade to all weapons
        _upgrade_all_weapons()
        # Emit upgrade signal
        emit_signal("upgrade_purchased", current_weapon_level)
        print("Weapon upgraded to level " + str(current_weapon_level) + "! Cost: " + str(cost) + " remaining: " + str(total_currency))
        return true
    else:
        print("Not enough currency! Need " + str(cost) + " have " + str(total_currency))
        return false

func get_upgrade_cost() -> int:
    # Scale cost with level using 1.5^(level-1) formula
    var base_costs = {"pistol": 100, "rifle": 150, "shotgun": 120}
    var base_cost = base_costs[current_weapon_type]
    # int(base_cost * (1.5 ^ (current_weapon_level - 1)))
    # Using multiplication to avoid float issues with Godot's ^ operator
    var scaled_cost = int(base_cost * pow(1.5, current_weapon_level - 1))
    return scaled_cost

func set_weapon_type(weapon_type: String):
    global current_weapon_type
    if weapon_type in ["pistol", "rifle", "shotgun"]:
        current_weapon_type = weapon_type
        print("Switched to " + current_weapon_type)
        return true
    return false

func _upgrade_all_weapons():
    # Iterate over all weapon instances and call their upgrade methods
    # Find weapons in the scene tree
    var weapons = get_tree().get_nodes_in_group("weapons")
    for weapon in weapons:
        if weapon.has_method("upgrade_level"):
            weapon.upgrade_level()
    print("_upgrade_all_weapons called - upgraded " + str(weapons.size()) + " weapons to level " + str(current_weapon_level))

func save_game():
    var save_data = {
        "currency": total_currency,
        "weapon_level": current_weapon_level,
        "weapon_type": current_weapon_type
    }
    var save_file = File.new()
    var err = save_file.open("user://game_save.json", File.WRITE)
    if err == OK:
        save_file.store_json(save_data)
        save_file.close()
        print("Game saved!")
    else:
        print("Error saving game!")

func load_game():
    var load_file = File.new()
    var err = load_file.open("user://game_save.json", File.READ)
    if err == OK:
        var data = load_file.get_parsed_json()
        total_currency = data["currency"]
        current_weapon_level = data["weapon_level"]
        current_weapon_type = data["weapon_type"]
        print("Game loaded! Currency: " + str(total_currency) + " Level: " + str(current_weapon_level))
        load_file.close()
    else:
        print("No save file found, starting new game.")