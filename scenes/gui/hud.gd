extends Node2D

@onready var timer_label = $TimerLabel
@onready var currency_label = $CurrencyLabel
@onready var weapon_label = $WeaponLabel
@onready var stamina_bar = $StaminaBar

# Timer managed by main_scene — no independent countdown
# HUD receives time updates via set_time_remaining() callback

func _ready():
    update_labels()

func _process(delta):
    # No longer decrementing independent timer —
    # main_scene is the authoritative timer source
    update_labels()

func update_labels():
    # Time display would be set by main_scene via set_time_remaining()
    # But we still show what's available from GameManager
    timer_label.text = "Time: --s"  # Placeholder — main_scene sets real value
    currency_label.text = "€: " + str(GameManager.get_total_currency())
    weapon_label.text = "Weapon Lvl: " + str(GameManager.get_current_weapon_level())

func set_time_remaining(seconds: float):
    # Called by main_scene to update HUD timer from authoritative source
    # This replaces the independent countdown
    timer_label.text = "Time: " + str(seconds) + "s"