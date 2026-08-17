extends Node

const LOG_NAME := "AspectRatio1610"

const WINDOWED_SIZE := Vector2(1280, 720)
const PROJECT_SIZE := Vector2(1920.0, 1080.0)

const PAUSE_MENU_ARC_RATIO := 16.0 / 9.0
const PERSIST_PATH := "user://fullscreen_mod.json"


static func is_non_standard_aspect() -> bool:
	var screen_size := OS.get_screen_size()
	var aspect := float(screen_size.x) / float(screen_size.y)
	return abs(aspect - 16.0 / 9.0) >= 0.02


static func apply_borderless(fullscreen: bool) -> void:
	if fullscreen:
		var screen_size := OS.get_screen_size()
		OS.set_window_size(screen_size)
		OS.set_window_position(Vector2.ZERO)
		OS.window_borderless = true
	else:
		OS.window_borderless = false
		OS.set_window_size(WINDOWED_SIZE)
		OS.center_window()


static func should_fullscreen() -> bool:
	var file := File.new()
	if file.file_exists(PERSIST_PATH):
		var error := file.open(PERSIST_PATH, File.READ)
		if error == OK:
			var json := JSON.parse(file.get_as_text())
			file.close()
			if json.error == OK and json.result is Dictionary and json.result.has("fullscreen"):
				return bool(json.result.fullscreen)
	return true


static func persist_fullscreen(fullscreen: bool) -> void:
	var file := File.new()
	var error := file.open(PERSIST_PATH, File.WRITE)
	if error != OK:
		return
	file.store_string(JSON.print({"fullscreen": fullscreen}))
	file.close()


static func apply_stretch(tree: SceneTree, in_game: bool) -> void:
	if not is_non_standard_aspect():
		return

	if in_game:
		tree.set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_EXPAND, PROJECT_SIZE)
	else:
		tree.set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, PROJECT_SIZE)


static func ensure_in_game_layout(tree: SceneTree) -> void:
	var main: Node = tree.get_root().get_node_or_null("Main")
	if main == null:
		return
	ensure_hud_fullscreen(main)
	ensure_pause_menu_arc(main)
	expand_background(main)


static func ensure_hud_fullscreen(main: Node) -> void:
	var ui: Node = main.get_node_or_null("UI")
	if ui == null:
		return
	var hud: Control = ui.get_node_or_null("HUD")
	if hud == null:
		return
	hud.anchor_left = 0.0
	hud.anchor_top = 0.0
	hud.anchor_right = 1.0
	hud.anchor_bottom = 1.0
	hud.margin_left = 0.0
	hud.margin_top = 0.0
	hud.margin_right = 0.0
	hud.margin_bottom = 0.0


static func ensure_pause_menu_arc(main: Node) -> void:
	var pause_menu: Control = main.find_node("IngameMainMenu", true, false)
	if pause_menu == null:
		return
	var margin_container: Control = pause_menu.get_node_or_null("MarginContainer")
	if margin_container == null or pause_menu.get_node_or_null("ARC") != null:
		return
	var arc := AspectRatioContainer.new()
	arc.name = "ARC"
	arc.ratio = PAUSE_MENU_ARC_RATIO
	arc.anchor_right = 1.0
	arc.anchor_bottom = 1.0
	arc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_menu.add_child(arc)
	pause_menu.move_child(arc, 0)
	margin_container.rect_position = Vector2.ZERO
	pause_menu.remove_child(margin_container)
	arc.add_child(margin_container)
	margin_container.size_flags_horizontal = Control.SIZE_FILL
	margin_container.size_flags_vertical = Control.SIZE_FILL
	margin_container.mouse_filter = Control.MOUSE_FILTER_IGNORE


static func expand_background(main: Node) -> void:
	var bg: TextureRect = main.get_node_or_null("CanvasLayer/Background")
	if bg == null:
		return
	if bg.rect_rotation == 0.0 and bg.margin_left == 0.0:
		return
	bg.rect_rotation = 0.0
	bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.margin_top = 0.0
	bg.margin_right = 0.0
	bg.margin_bottom = 0.0
	bg.margin_left = 0.0
	bg.expand = true
