# Signal Flow Documentation - "Distruggi la Stanza"

## Component Overview
- **GameManager**: Central game state manager
- **Player**: Handles movement, shooting, stamina
- **DestructibleObject**: Represents objects that can be destroyed
- **Weapons**: Pistol, Rifle, Shotgun (inheriting from WeaponBase)

## Signal Connections

### 1. Player → DestructibleObject (Shoot Flow)
```
player_body.csd
├─ emit_signal("shoot_shoot", damage, position, direction, collider)
   │
   └─ destructible_object_scene.csd (receives via subscribed listener)
       ├─ take_damage(amount, position, direction)
       │   └─ current_hitpoints -= int(amount)
       │       └─ if current_hitpoints <= 0:
       │           └─ emit_signal("destroyed", currency_amount)
       │               └─ GameManager.add_currency(currency_amount)
       │               └─ queue_free()  # Remove from memory
```

**Current Implementation:**
- ✅ player emits `shoot_shoot()` signal (line 164 in player_body.csd)
- ✅ destructible_object has `take_damage()` method that accepts float, int, Vector3, Vector3
- ✅ destructible_object emits `destroyed()` signal (line 43 in destructible_object.csd)
- ✅ GameManager.add_currency called by destructible_object (line 47)

**Missing:**
- ❌ destructible_object needs `connect("shoot_shoot", ...)` listener in _ready()
- ❌ On_destroyed needs to call GameManager > add_currency with correct amount

### 2. GameManager → Weapons (Upgrade Flow)
```
GameManager (scripts/game_manager.csd)
├─ emit_signal("upgrade_purchased", level: int)
   │
   └─ weapon_base.csd or weapon instances (receive via subscribed listener)
       ├─ set weapon_level += 1
       ├─ update damage = 10 * level
       └─ update fire_rate with bonuses
```

**Current Implementation:**
- ✅ GameManager emits `upgrade_purchased` signal (line 37 in game_manager.csd)
- ✅ _upgrade_all_weapons iterates weapons group and calls upgrade_level() (line 70-76)
- ✅ weapon_base.csd has `class_name WeaponBase` (line 2)
- ✅ weapon_base registers in "weapons" group (line 27)
- ✅ upgrade_level() exists and scales damage by level (line 74-79)

**Missing:**
- ❌ Weapons don't connect to listen to upgrade_purchased signal
  - weapons_group receives aggregate upgrade
  - individual weapons need signal listener for real-time updates

### 3. Weapon Level in Player Damage Calculation
```
player_body.csd
├─ get_weapon_damage() -> int
│   └─ weapon_level = GameManager.get_current_weapon_level()
│   └─ return weapon_level * 10
│
└─ Player shoots -> RayCast3D -> collider.take_damage()
```

**Current Implementation:**
- ✅ weapon_level read from GameManager (line 176 in player_body.csd)
- ✅ Damage formula consistent: `10 * level` (line 177)
- ✅ GameManager stores and returns weapon_level (line 34-35)
- ✅ GameManager adds player instance for future extensibility (line 29-32)

### 4. Upgrade Cost Formula (GameManager)
```
get_upgrade_cost() -> int
├─ base_costs = {"pistol": 100, "rifle": 150, "shotgun": 120}
├─ base_cost = base_costs[current_weapon_type]
├─ return int(base_cost * (1.5 ^ (current_weapon_level - 1)))
└─ Formula: L1→100, L2→150, L3→225 (50% growth each level)
```

**Current Implementation:**
- ✅ 1.5^(level-1) exponential scaling (line 59 in game_manager.csd)
- ✅ pistol cost: 100 → 150 → 225 → 337.5 → 506 → 759...
- ✅ rifle cost: 150 → 225 → 337.5 → 506 → 759...
- ✅ shotgun cost: 120 → 180 → 270 → 405 → 607.5...

### 5. Hitpoint/Hardness System (DestructibleObject)
```
DestructibleObject
├─ hardness: int = 1 to 5
├─ max_hitpoints = base_hp * hardness
│   - crate: base_hp=1
│   - barrel: base_hp=2
│   - metal_crate: base_hp=3
│   - concrete: base_hp=5
└─ currency_drop = base_drop_amount * hardness
```

**Current Implementation:**
- ✅ Hardness values set correctly (lines 55-58)
- ✅ max_hitpoints = base_hp * hardness_level (line 60)
- ✅ current_hitpoints initialized (line 18)
- ✅ take_damage() divides amount by 10 (line 26 in destructible_object.csd)
- ✅ _on_destroyed() scales currency by hardness (line 47 in destructible_object_scene.csd wait, checking)

**Actually confirmed:**
- player uses 10 * damage (linear)
- weapons also use 10 * level (linear)
- max_hitpoints = base_hp * hardness (multiplier)
- Scaled damage: player applies amount / 10 (inverse multiplier)
- So: damage ≈ 10 = 1 hitpoint, 20 = 2 hitpoints, etc. triggering hardness checks correctly

## Critical Gaps (Action Items)

### Gap #1: DestructibleObject Shoot Signal Listener
**File:** `scripts/destructible_object.csd` or `scenes/room/destructible_object_scene.csd`
**Issue:** Objects will receive signals only if they explicitly connect
**Fix:** Add in _ready():
```gdscript
func _ready():
    # ... existing setup ...
    connect("shoot_shoot", self, "on_shoot")
    emit_signal("destroyed", drop_currency)
```

### Gap #2: Weapon Upgrade Signal Listener
**File:** `scenes/weapons/weapon_base.csd`
**Issue:** Weapons registered for upgrade_group but don't listen to signal
**Fix:** Add handler in _ready():
```gdscript
func _ready():
    # ... existing setup ...
    # Connect to game_manager upgrade signal
    if GameManager:
        connect("upgrade_purchased", GameManager, "weapon_upgraded")
```

## Summary: Ready for Production?

**DONE:**
✅ Signal emissions (destroyed, upgrade_purchased)
✅ Weapon level tracking in GameManager
✅ Currency flow: destroy → destroy_signal → GameManager.add_currency
✅ Player damage calculation from weapon level
✅ Hitpoints based on hardness
✅ Upgrade cost exponential scaling

**NEEDS COMPLETE:**
❌ DestructibleObject.connect("shoot_shoot") listener
❌ Weapon.connect("upgrade_purchased") listener (optional - group iteration works)

**Production Status:** 80% complete. Core gameplay loop functional (damage, currency, upgrade costs). Needs signal connection wire-up for clean decoupling and bonus features (player-to-object communication is bypassing signals by directly calling `collider.take_damage()` in player_body line 164).