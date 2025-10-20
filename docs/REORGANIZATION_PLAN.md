# Directory Reorganization Plan

## Current Structure (Cluttered)
```
dectation/
├── CLAUDE.md
├── README.md
├── README_V2.md
├── TESTING.md
├── V2_PLAN.md
├── V2_SUMMARY.md
├── dictation-mode-screenshot.png
├── install.sh
├── uninstall.sh
├── test-install.sh
├── toggle-dictation.desktop
├── .gitignore
├── scripts/
│   ├── claude-session-manager.sh
│   ├── setup-talon-eula.sh
│   ├── start-talon.sh
│   ├── steam-keyboard-control.sh
│   └── toggle-talon.sh
└── talon/
    ├── claude_commands.talon
    ├── claude_integration.py
    ├── claude_templates.py
    ├── keyboard_commands.talon
    ├── keyboard_manager.py
    └── toggle_sleep.py
```

## Proposed Structure (Organized)
```
dectation/
├── README.md                       # Main README (update to point to docs/)
├── install.sh                      # Installer (root for easy access)
├── uninstall.sh                    # Uninstaller (root for easy access)
├── .gitignore
│
├── docs/                           # 📚 All documentation
│   ├── README_V2.md               # V2 feature guide
│   ├── V2_PLAN.md                 # V2 implementation plan
│   ├── V2_SUMMARY.md              # V2 quick reference
│   ├── CLAUDE.md                  # Claude Code integration guide
│   ├── TESTING.md                 # Testing guide
│   └── screenshots/
│       └── dictation-mode.png     # Renamed for clarity
│
├── scripts/                        # 🔧 All executable scripts
│   ├── core/                      # Core functionality
│   │   ├── start-talon.sh
│   │   ├── toggle-talon.sh
│   │   └── setup-talon-eula.sh
│   ├── keyboard/                  # V2: Keyboard management
│   │   └── steam-keyboard-control.sh
│   └── claude/                    # V2: Claude integration
│       └── claude-session-manager.sh
│
├── talon/                          # 🎤 Talon modules and commands
│   ├── core/                      # Core Talon modules
│   │   └── toggle_sleep.py
│   ├── keyboard/                  # V2: Keyboard modules
│   │   ├── keyboard_manager.py
│   │   └── keyboard_commands.talon
│   └── claude/                    # V2: Claude modules
│       ├── claude_integration.py
│       ├── claude_templates.py
│       └── claude_commands.talon
│
├── desktop/                        # 🖥️ Desktop integration files
│   └── toggle-dictation.desktop
│
└── tests/                          # 🧪 Testing scripts
    └── test-install.sh
```

## Benefits

1. **Clearer organization**: Related files grouped together
2. **Easy navigation**: Find docs in docs/, scripts in scripts/
3. **Scalability**: Easy to add more features (V3, V4, etc.)
4. **Logical grouping**: Core vs V2 features clearly separated
5. **Documentation separation**: Docs don't clutter root directory

## Migration Impact

### Files that need path updates:
- `install.sh` - Update paths to new locations
- `uninstall.sh` - Update paths to new locations
- `scripts/core/toggle-talon.sh` - Update path to start-talon.sh
- `talon/*/keyboard_manager.py` - Update script paths
- `talon/*/claude_integration.py` - Update script paths
- `desktop/toggle-dictation.desktop` - Update Exec path

### No impact on users:
- Files are copied to `~/.talon/user/` during install
- Once installed, Talon doesn't care about source structure
- Scripts use absolute paths or relative to known locations

## Alternative (Simpler) Structure

If the above is too complex, we could do:

```
dectation/
├── README.md
├── install.sh
├── uninstall.sh
├── .gitignore
│
├── docs/                           # Move all .md files except README
│   ├── screenshots/               # Move all images
│
├── scripts/                        # Keep flat, just scripts
│
├── talon/                          # Keep flat, just Talon files
│
└── desktop/                        # Desktop files
```

## Recommendation

Start with the **simpler structure** first:
1. Create `docs/` and `docs/screenshots/`
2. Move all documentation markdown files to `docs/`
3. Move screenshot to `docs/screenshots/`
4. Create `desktop/` and move .desktop file
5. Create `tests/` and move test scripts
6. Keep scripts/ and talon/ flat for now

This gives us ~80% of the benefit with minimal disruption.

## Implementation Steps

1. Create new directories
2. Git mv files to new locations (preserves history)
3. Update path references in scripts
4. Update README to reference new locations
5. Test install.sh and uninstall.sh
6. Commit with descriptive message
