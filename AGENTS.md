# AGENTS.md — AspectRatio1610 (Brotato Mod)

Este archivo define las reglas de comportamiento, arquitectura y directrices para **Antigravity CLI (agy)** y asistentes de IA trabajando en este repositorio.

---

## 1. Reglas Generales de Antigravity CLI

- **Living Document:** Actualiza este archivo tras cada aprendizaje técnico validado empíricamente.
- **Mantén la simplicidad:** Cero dependencias externas. No introducir librerías de terceros a menos que sea explícitamente solicitado por el usuario.
- **Sintaxis del motor:** Godot 3.5.x GDScript (sintaxis Godot 3) + ModLoader API v6 (`ModLoaderMod`, `ModLoaderLog`).

---

## 2. Reglas Técnicas Críticas (Brotato v1.1.15.4)

1. **Resolución Base del Proyecto:**
   - La resolución de diseño interna es **1920x1080**.
   - `SceneTree.set_screen_stretch()` SIEMPRE debe recibir `Vector2(1920, 1080)`.
   - **NUNCA** usar 1280x720 como base de stretch, o causará un recorte del 150% hacia el cuadrante superior izquierdo.

2. **Diseño Híbrido Pantalla Completa:**
   - **Menús de inicio (`TitleScreen`):** `2D Keep` base (1920, 1080) -> Proporción 16:9 con barras negras limpias, manteniendo el arte 2D centrado e intacto.
   - **Gameplay y Run (`Main`, `Shop`, `EndRun`, etc.):** `2D Expand` base (1920, 1080) -> Ocupa el 100% de la pantalla 16:10 sin barras negras.
   - **HUD:** Se ancla a pantalla completa (`anchor_top = 0.0`, `margin_top = 0.0`) para situar vida/oro/oleada pegados al borde superior real.

3. **Compatibilidad ModLoader:**
   - `compatible_mod_loader_version: ["6.2.0"]` y `compatible_game_version: ["1.1.15.4"]` son obligatorios en `manifest.json` bajo `extra.godot`. Sin `compatible_game_version`, ModLoader aborta el juego con un FATAL-ERROR.
   - La estructura de carpetas dentro del zip empaquetado debe ser exactamente:
     `mods-unpacked/<namespace>-<mod_id>/manifest.json` y `mod_main.gd`.

---

## 3. Comandos Útiles para el Agente

- **Empaquetar mod para pruebas o distribución:**
  ```powershell
  Compress-Archive -Path "mods-unpacked" -DestinationPath "rauldzmartin-AspectRatio1610-1.0.0.zip" -CompressionLevel Optimal -Force
  ```
- **Lanzar Brotato vía Steam:**
  ```powershell
  Start-Process "steam://rungameid/1942280"
  ```
- **Cerrar Brotato tras pruebas:**
  ```powershell
  Get-Process Brotato -ErrorAction SilentlyContinue | Stop-Process -Force
  ```
- **Publicar / Actualizar en Steam Workshop (Skill `publish-workshop` — One-Shot, notas siempre en inglés):**
  ```powershell
  & ".agents/skills/publish-workshop/scripts/publish.ps1" -ChangeNote "<English changelog>"
  ```
- **Restaurar resolución del monitor a 1080p @ 100Hz:**
  ```powershell
  & "C:\Users\RAULDZ~1\AppData\Local\Temp\opencode\nircmd\nircmd.exe" setdisplay 1920 1080 32 100
  ```
