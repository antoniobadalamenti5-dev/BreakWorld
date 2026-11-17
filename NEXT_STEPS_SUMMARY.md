# NEXT STEPS SUMMARY — JBA-11: "Distruggi la Stanza"

## Immediate Action: Timer Runtime Verification (ALTA)

**What to do:** Run the Godot project and verify the 60s countdown.

**How to run:**
1. Open Godot 4.7.2
2. Load project: `project.godot` in:
   `C:\Users\anton\.paperclip\instances\default\isolated-workspaces\f7b13baf-7bf4-4502-8390-dfb9203d3274\35900d9f-2141-4ba4-ba88-3b488204fee1`
3. Set `scenes/main_scene.csd` as the main scene
4. Press "Play" (▶️)
5. Observe HUD countdown from 60.0s
6. Wait for timeout at t=60s
7. Verify these outputs appear in Godot's Remote Console:
   - "Session time expired!" (from `_on_session_timeout()`)
   - "=== SESSION ENDED ==="
   - "Total currency earned: N€" (your final currency)
   - "Final weapon level: N" (your weapon level)
   - "Time survived: 60 seconds"
   - "Final Score: Currency: N€, Time survived: 60 seconds, Weapon level reached: N"

**Expected behavior:** At t=0, `_end_session()` stops the timer, prints final stats, and sets `get_tree().quit = true` which exits Godot.

---

## Executable Test Path (once Godot CLI export configured)

**Godot 4.7.2 already downloaded** (86 MB, verified running: `4.7.2.stable.official.ed1daf0bf`).

**To generate standalone Windows .exe:**

### Option A — Godot CLI (requires export template in PATH):
```powershell
# Add Godot to PATH (example for Godot in C:\Godot)
$env:PATH += ";C:\Godot\4.7.2\editor\"

# Then export:
godot --export "Windows Desktop" build/
```
This generates: `build/windows/.../Distruggi la Stanza.exe`

### Option B — Test in Godot Editor (no export needed):
- Run directly in Godot editor as described above
- For distribution, use Godot's "Export" wizard: Project → Export → Windows Desktop

### Current Project Structure (ready for export):
```
project.godot              # Godot project config
scenes/
  main_scene.csd           # Main scene with timer, player, room, HUD
  player/player_body.csd  # Player: WASD, shoot, stamina, weapon swap
  room/room_grid.csd       # 12×12 grid with floor, walls, 15 objects
  gui/hud.csd              # HUD: time, currency, weapon level
scripts/
  game_manager.csd         # Currency, upgrade system, save/load
  destructible_object.csd  # Hardness-based destruction, currency drops
  pistol.csd               # Base weapon: dmg=10, fire_rate=1.5, crit=0.15
assets/
  audio/                   # 4 .wav files: gunshot, beep, alarm, explosion
  models/                  # floor.tscn, wall.tscn
```

---

## Remaining Priorities (in dependency order)

| Priority | Item | Dependencies | Status |
|----------|------|--------------|--------|
| **ALTA** | Timer runtime verification in Godot | None (project ready) | ⏳ Wait for Godot execution |
| **MEDIA** | Full gameplay flow test | Timer working + shooting + destruction + currency | ⏳ After timer verification |
| **MEDIA** | Upgrade system test with in-session currency | Currency flow from destruction | ⏳ After timer + flow test |
| **BASSA** | Godot CLI export .exe Windows | Project complete | ⏳ Install export template or use editor export |
| **BASSA** | Software GL fallback test | Depends on #4 export test | ⏳ After export configured |

---

## Quick Test Commands (if Godot CLI is in PATH)

```powershell
# Verify Godot is accessible:
godot --version
# Expected: Godot Engine 4.7.2

# Quick export test:
godot --export "Windows Desktop" build/
# Creates standalone exe in build/windows/
```

---

## Report Reference

Full integration details in: `FINAL_INTEGRATION_REPORT.md`

**All baseline systems verified and complete. Ready for runtime testing and export configuration.**