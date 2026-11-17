# Piano di Implementazione: Gioco 3D "Distruggi la Stanza"

## Stack Tecnologico Approvato
- **Motore**: Godot 4.7.2 stable
- **Linguaggio**: GDScript
- **Packaging**: Executable standalone .exe per Windows
- **Rendering fallback**: Software GL opzionale

## Decisioni di Progettazione (basate sulle risposte utente)

1. **Meccanica distruzione**: Single-hit distruzione ma con variabilità basata "durezza" degli oggetti. alcuni oggetti richiedono più colpi in base alla loro categoria (es. crate = 1 hit, metallo = 2-3 hits, nemici = variano).

2. **Sistema upgrade armi**: Armi non si degradano. Upgrade con progressione. Swap armi con numeri tasti 1-4. Sistema di acquisto upgrade danno, velocità di fuoco, crit chance.

3. **Profilo gameplay**: Sessioni time-limited. Il giocatore ha una stamina che si ricarica col tempo. L'obiettivo è "clear the room" entro un limite di tempo (5-10 min circa). Le stanze sono fisse, non c'è progressione tra stanze diverse.

4. **Packaging**: Executable .exe standalone. Fallback software GL accettabile per PC senza GPU dedicata.

5. **Drops & HUD**: Oggetti distrutti danno soldi/currency. HUD minimal: mostra solo salute/stamina e countdown tempo. Numeri punti raccolti in angolo.

## Architettura Alta Livello

```
project/
├── project.godot
├── assets/
│   ├── textures/
│   ├── models/
│   └── audio/
├── scenes/
│   └── main_scene.tscn
│       ├── Player/
│       │   ├── player_body.csd
│       │   ├── player_camera.csd
│       │   └── player_hand.csd
│       ├── Room/
│       │   ├── room_grid.csd
│       │   ├── destructible_objects/
│       │   │   ├── crate.csd
│       │   │   ├── barrel.csd
│       │   │   └── box.csd
│       │   └── room_manager.csd
│       ├── Weapons/
│       │   ├── weapon_base.csd
│       │   ├── pistol.csd
│       │   ├── rifle.csd
│       │   └── shotgun.csd
│       ├── GUI/
│       │   ├── hud.csd
│       │   ├── upgrade_menu.csd
│       │   └── currency_label.csd
│       └── scripts/
│           └── game_manager.csd
└── addons/
```

## Micro-tasks Elencati per Priorità

### Macro 1 — Room Foundation (~2 micro-tasks)
- **M1.1**: Setup progetto Godot base + scena room grid
  - Inizializzare project.godot con configurazione rendering
  - Creare scena room con sistema a griglia (x,y,z)
  - Implementare tilemap 3D o array di nodi per le celle
- **M1.2**: Player基础 movimento e interazione
  - Node CharacterBody3D per il player
  - Movimento WASD con damping
  - Sistema raycast per rilevamento oggetti

### Macro 2—Weapons (~4 micro-tasks)
- **M2.1**: Weapon base class con sistema dmg/proximity/area/laser
  - Classe base weapon con proprietà: dmg, range, fire_rate, crit_chance
  - Sistema di tipi di attacco (proximity, area, laser)
- **M2.2**: Armi base (pistol, rifle, shotgun) con statistiche initiali
  - Diverse armi con parametri unici
  - Sistema di swap con tasti 1-4
- **M2.3**: Sistema upgrade armi (dmg scaling, fire_rate, crit chance)
  - Menu upgrade accessibile con tasto U
  - Acquisto upgrade con valuta guadagnata
  - Progress bars per ogni upgrade level
- **M2.4**: Sistema ricarica/cooldown tra gli spari
  - Timer per fuoco continuo
  - Visual feedback per ricarica

### Macro 3—GUI & Incremental (~3 micro-tasks)
- **M3.1**: HUD minimal - tempo residuo, valuta, livello arma
  - Label countdown timer (30-60 secondi per session)
  - Label € (currency) count
  - Indicatore livello arma corrente
- **M3.2**: Sistema valuta e progressione upgrade
  - Guadagnare € da distruzione oggetti
  - Costi upgrade che aumentano linearmente/esponenzialmente
  - Salvataggio progresso tra sessioni (config file)
- **M3.3**: Screen de fine sessione + statistiche
  - Schermata "Room Cleared" con total $ earned
  - Bottoni: Play Again, Exit

### Macro 4—Packaging (~1 micro-task)
- **M4.1**: Godot CLI export .exe Windows con config software GL
  - Configurazione export preset con fallback rendering
  - Test executabile su macchina senza GPU dedicata

## Stima Macro-fasi e Timeline

| Macro | Micro-tasks | Stimato Ore | Dipendenze |
|-------|-------------|-------------|------------|
| 1 | M1.1 + M1.2 | 8 ore | None (setup) |
| 2 | M2.1 + M2.2 + M2.3 + M2.4 | 16 ore | M1.2 (player must move) |
| 3 | M3.1 + M3.2 + M3.3 | 10 ore | M2.3 (needs upgrade system) |
| 4 | M4.1 | 4 ore | Tutte completate |

**Totale stimato**: ~38 ore di sviluppo

## Note Tecniche GDScript

### Player Script (esempio struttura)
```gdscript
extends CharacterBody3D

export var speed = 5.0
export var stamina_max = 100.0
export var stamina_regen = 1.0  # al secondo quando non sta agendo

var current_stamina: float = 100.0
var is_shooting: bool = false
var shoot_cooldown: float = 0.5
var shoot_timer: float = 0.0

const MOVE_ACTION = "ui_left"  # W, A, S, D
const SHOOT_ACTION = "ui_right"  # Mouse click

func _ready():
    current_stamina = stamina_max
    # Setup input actions

func _process(delta):
    # Rigenerazione stamina
    if not is_shooting:
        current_stamina = min(current_stamina + stamina_regen * delta, stamina_max)
    
    # Movimento
    var input_direction = Vector3.ZERO
    if Input.is_action_pressed(MOVE_ACTION):
        # calcolo direction basato sulla camera
        pass
    
    # Sparo
    if Input.is_action_just_pressed(SHOOT_ACTION) and current_stamina > 0 and shoot_timer <= 0:
        shoot()
        current_stamina -= 10  # costo stamina per shoot
        shoot_timer = shoot_cooldown
    
    if shoot_timer > 0:
        shoot_timer -= delta
    
    velocity = input_direction * speed
    move_and_slide()

func shoot():
    # Raycast from player position in direction of view
    # Hit destructible objects
    # Reduce object HP, destroy when 0
    pass
```

### Room Grid System (esempio)
```gdscript
extends Node3D

const GRID_SIZE = 10
const CELL_SIZE = 2.0

var grid[GRID_SIZE][GRID_SIZE][3]  # [x][y][type: 0=floor, 1=wall, 2=object]

func _ready():
    generate_room()

func generate_room():
    # Create floor, walls, and objects in grid
    for x in range(GRID_SIZE):
        for y in range(GRID_SIZE):
            # Floor
            create_cell(x, y, 0, "res://assets/models/floor.tscn")
            
            # Walls (perimeter)
            if x == 0 or x == GRID_SIZE - 1 or y == 0 or y == GRID_SIZE - 1:
                create_cell(x, y, 1, "res://assets/models/wall.tscn")
            
            # Objects (randomly placed)
            if randf() < 0.3:
                var obj_type = pick_object_type()
                create_cell(x, y, 2, "res://assets/models/" + obj_type + ".tscn", obj_type)
```

### Object Destructible (esempio)
```gdscript
extends Area3D

var max_hitpoints: int
var current_hitpoints: int
var object_type: string  # "crate", "barrel", "box", etc.
var drop_currency: int = 10

func _ready():
    current_hitpoints = max_hitpoints
    # Setup collision detection

func take_damage(amount: int):
    current_hitpoints -= amount
    # Visual feedback: particle explosion, flash
    if current_hitpoints <= 0:
        queue_free()
        # Drop currency
        emit_signal("destroyed", drop_currency)

func _on_body_entered(body):
    if body.is_in_group("projectiles"):
        take_damage(body.damage)
```

### Currency & Upgrade System (esempio)
```gdscript
extends Node

var total_currency: int = 0
var weapon_levels = {"pistol": 1, "rifle": 1, "shotgun": 1}
var upgrade_costs = {"pistol": 100, "rifle": 150, "shotgun": 120}

func earn_currency(amount: int):
    total_currency += amount
    update_hud_currency()

func buy_upgrade(weapon_type: string):
    var cost = upgrade_costs[weapon_type]
    if total_currency >= cost:
        total_currency -= cost
        weapon_levels[weapon_type] += 1
        upgrade_costs[weapon_type] = int(upgrade_costs[weapon_type] * 1.5)
        # Apply upgrade effect
        update_hud_weapon_level()
```

## Risultati Attesi (Phase 2 completion)

Al termine della Fase 2 avremo:
1. **Progetto Godot funzionante** con scena room base e player movement
2. **Sistema distruzione** con variabilità hardness su oggetti
3. **3 armi base** con swap tasti 1-4 e upgrade system
4. **HUD minimal** che mostra: tempo residuo, valuta, livello arma
5. **Sistema valuta** guadagnata da distruzione e spesa per upgrade
6. **Godot CLI export** .exe Windows testato (anche con software GL fallback)
7. **Sessione time-limited** con stamina che si ricarica e countdown timer

## Punti da Fare Successivi (dopo Phase 2)

- Multipli stanze/concorrenza
- Boss Rooms con armi speciali
- Power-up temporanei (danno x2, crit x3)
- Mapping/teletrasporto tra stanze (se decidiamo di cambiare il profilo gameplay)
- Statistiche dettagliate fine sessione
- Sound effects e musica di sottofondo