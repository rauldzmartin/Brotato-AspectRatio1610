---
name: publish-workshop
description: >-
  Builds, packages, and publishes/updates the Brotato AspectRatio1610 mod to the Steam Workshop
  using automated SteamCMD integration. Use whenever the user asks to publish, update, or upload
  the mod to Steam Workshop.
---

# Publish Workshop Skill

Automates building, validating, packaging, and publishing the **AspectRatio1610** mod to Steam Workshop (Workshop ID: `3785083246`, AppID: `1942280`).

## Target Workshop Item
- **Workshop URL:** https://steamcommunity.com/sharedfiles/filedetails/?id=3785083246
- **Workshop ID:** `3785083246`
- **Game AppID:** `1942280` (Brotato)

---

## Workflow Steps

### One-Shot Publish / Update
To publish or update the mod to Steam Workshop in a single automated step:
```powershell
& ".agents/skills/publish-workshop/scripts/publish.ps1" -ChangeNote "<English changelog description>"
```

### Parameters
- `-WorkshopId`: Steam Workshop Item ID (defaults to `3785083246`).
- `-SteamUser`: Steam account username (defaults to `rauldmartin` / registry `AutoLoginUser`).
- `-ChangeNote`: Detailed description of changes for the Steam Workshop changelog. **Must ALWAYS be written in English.**
- `-DryRun`: Switch to only validate files and create the `.zip` / `.vdf` without invoking SteamCMD.

---

## Technical Details

1. **Manifest Validation:** Ensures `extra.godot.compatible_game_version` is present to prevent ModLoader startup crashes.
2. **Zip Structure:** Packs `mods-unpacked/` as the root directory within the zip file.
3. **SteamCMD Integration:** Automatically uses cached credentials in `SteamCMD` to publish headlessly without manual prompts.
4. **Language Rule:** Change notes and release summaries published to Steam Workshop MUST ALWAYS be in English.
