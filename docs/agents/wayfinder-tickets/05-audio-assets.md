## Question
Audio assets validity: Verify all .wav files in `assets/audio/` are properly exported and referenceable. Currently known files: gunshot, beep, alarm, explosion. Check:
- All .wav files are valid and not corrupted
- AudioStreamPlayer nodes can reference them
- No missing audio streams that would cause export failures
- Volume levels and properties are correctly set

Are all audio assets valid for export? Are there any missing or corrupted files?