# Godot CLI Export Template Installation Guide

## Prerequisites
- Godot 4.7.2 installed (for Windows)
- Godot export templates installed

## Export Template Installation

1. Download Godot 4.7.2 Windows Editor:
   ```
   https://godotengine.org/download/4.7
   ```

2. Extract to a permanent directory (e.g., `C:\Games\Godot\4.7`)

3. Install export templates:
   - Run Godot Editor to initialize
   - Go to: That Godot Icon (bottom left) → Export → Templates → (None)
   - Godot will prompt to download templates (Windows Desktop)

4. Verify installation:
   - In Godot Editor, check: That Godot Icon → Export → Templates
   - Should show Windows Desktop template: `4.7.2.stable.windows_editor.win64` with size shown (typically ~200-300 MB)

## Export Script Usage

Run `export_game.bat` from the project root:
```batch
cd /d C:\path\to\project
export_game.bat
```

The script will:
1. Check if Godot is in PATH
2. Export project to `bin/DestroyTheRoom.exe`
3. Report success or error

## Manual Export Command

If not using the script, run manually:
```bash
cd /d C:\path\to\project
godot --export "Windows Desktop" bin/
```

## Windows Desktop Preset Configuration (Export Presets)

See `.godot/export_presets.cfg` in project root:
- Binary format: x86_64
- Texture compression: BPTC/S3TC/ETC2 enabled
- Export path: `./bin/DestroyTheRoom.exe`
- No encryption enabled

## Troubleshooting

**Error: "Godot CLI not found in PATH"**
- Install Godot to a standard path (e.g., `C:\Program Files\Godot 4.7`)
- Or add Godot directory to PATH
- Or modify `export_game.bat` to use full Godot path

**Error: "Missing export template"**
- Install Windows Desktop export templates in Godot Editor (see step 3)
- Verify template installation via That Godot Icon → Export → Templates

**Export fails with shader compilation errors**
- Check that all `.gd` and `.csd` files don't have syntax errors
- Try running project in Godot Editor first to catch errors
- Review console output for specific error messages

## Standalone .exe Packaging

After successful export:
- Executable: `bin/DestroyTheRoom.exe`
- No dependency on Godot runtime (includes engine)
- Size: ~50-150 MB depending on content embedded