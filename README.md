# AspectRatio1610 — Brotato Mod

[![Steam Workshop](https://img.shields.io/badge/Steam_Workshop-AspectRatio1610-1b2838?style=for-the-badge&logo=steam&logoColor=white)](https://steamcommunity.com/sharedfiles/filedetails/?id=3785083246)
[![Game Version](https://img.shields.io/badge/Brotato-v1.1.15.4+-blue?style=for-the-badge)](https://store.steampowered.com/app/1942280/Brotato/)
[![Platform](https://img.shields.io/badge/Steam_Deck-Verified_16:10-success?style=for-the-badge&logo=steamdeck&logoColor=white)](https://steamcommunity.com/sharedfiles/filedetails/?id=3785083246)

Native 16:10 Fullscreen & Aspect Ratio mod for **Brotato** (v1.1.15.4+).

Designed for **Steam Deck (LCD & OLED, 1280x800)** and all **16:10 monitors / laptops (1920x1200, 2560x1600, etc.)**.

---

## Features

- **100% Full-Screen Gameplay:** Eliminates black letterbox bars during combat waves without stretching or pixel distortion.
- **Full-Screen Shop & Upgrade Menus:** Seamless full-screen experience across your entire run (combat, shop, level-ups, and end-run summary).
- **Top-Anchored HUD:** Health bar, gold, XP, and wave timer are docked directly to the true top edge of the 16:10 screen for maximum arena visibility.
- **Clean 16:9 Letterbox Menus:** The Title Screen and character selection remain perfectly centered in native 16:9, preserving the hand-crafted multi-layer 2D artwork without graphical seams.
- **Automatic Borderless Fullscreen:** Automatically starts in borderless fullscreen matching your display's native resolution.
- **Fixed Options Toggle:** Repairs the broken vanilla Fullscreen toggle button in the Options menu with persistent settings saved in `user://fullscreen_mod.json`.
- **Zero Dependencies & Zero Overhead:** Standalone, ultra-lightweight GDScript with zero performance impact and clean logs.

---

## Repository Structure

```text
.
├── mods-unpacked/
│   └── rauldzmartin-AspectRatio1610/
│       ├── manifest.json                  # ModLoader manifest metadata
│       ├── mod_main.gd                    # Main mod entrypoint & runtime context poller
│       ├── README.md                      # Mod README
│       └── extensions/
│           └── fullscreen_utils.gd        # Resolution, stretch mode, HUD, & borderless logic
├── description.md                         # Steam Workshop listing details (BBCode format)
├── preview.jpg                            # Steam Workshop cover preview image
├── AGENTS.md                              # Antigravity CLI / Agentic AI guidelines
└── .gitignore
```

---

## Building & Packaging for Steam Workshop

To package the mod into a Steam Workshop-compatible zip file:

```powershell
Compress-Archive -Path "mods-unpacked" -DestinationPath "rauldzmartin-AspectRatio1610-1.0.0.zip" -CompressionLevel Optimal -Force
```

### Automated Publishing (CLI via Skill & SteamCMD):

```powershell
& ".agents/skills/publish-workshop/scripts/publish.ps1" -ChangeNote "<English changelog description>"
```

### Manual Publishing via Godot Workshop Utility:
1. Launch `GodotWorkshopUtility.exe` from your Brotato game directory (`SteamLibrary/steamapps/common/Brotato/`).
2. Select `rauldzmartin-AspectRatio1610-1.0.0.zip` in **Select mod file**.
3. Select `preview.jpg` in **Select preview image**.
4. Set **Workshop ID** to `3785083246` (for updates) or leave blank for a new mod.
5. Set tags (`GUI`, `Utilities`) and click **Upload**.
