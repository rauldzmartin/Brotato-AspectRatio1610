extends Node

const MOD_ID := "rauldzmartin-AspectRatio1610"
const LOG_NAME := "AspectRatio1610"

const FullScreenUtils := preload("res://mods-unpacked/rauldzmartin-AspectRatio1610/extensions/fullscreen_utils.gd")

const BUTTON_NAME := "FullScreenButton"
const EXPANDED_SCENES := ["Main", "Shop", "CoopShop", "EndRun", "CoopEndRun"]

var _hook_timer: Timer
var _context_timer: Timer
var _in_game := false


func _ready() -> void:
	var screen_size: Vector2 = OS.get_screen_size()
	ModLoaderLog.info("Initialized on %dx%d display" % [int(screen_size.x), int(screen_size.y)], LOG_NAME)

	call_deferred("_apply_startup_fullscreen")
	_start_button_hook()
	_start_context_poller()


func _apply_startup_fullscreen() -> void:
	if FullScreenUtils.should_fullscreen():
		FullScreenUtils.apply_borderless(true)
	_context_update()


func _start_button_hook() -> void:
	_hook_timer = Timer.new()
	_hook_timer.wait_time = 0.5
	_hook_timer.autostart = true
	_hook_timer.connect("timeout", self, "_hook_fullscreen_button")
	add_child(_hook_timer)


func _hook_fullscreen_button() -> void:
	var button: Button = get_tree().get_root().find_node(BUTTON_NAME, true, false)
	if button == null:
		return

	# Disconnect broken vanilla callback if owner doesn't implement it
	var owner_node: Node = button.owner
	if owner_node and not owner_node.has_method("_on_FullScreenButton_toggled"):
		if button.is_connected("toggled", owner_node, "_on_FullScreenButton_toggled"):
			button.disconnect("toggled", owner_node, "_on_FullScreenButton_toggled")

	# Connect custom handler with current persistent state
	if not button.is_connected("toggled", self, "_on_fullscreen_toggled"):
		button.pressed = FullScreenUtils.should_fullscreen()
		button.connect("toggled", self, "_on_fullscreen_toggled")

	_hook_timer.stop()


func _start_context_poller() -> void:
	_context_timer = Timer.new()
	_context_timer.wait_time = 0.3
	_context_timer.autostart = true
	_context_timer.connect("timeout", self, "_on_context_timer")
	add_child(_context_timer)


func _is_expanded_scene(scene: Node) -> bool:
	if scene == null:
		return false
	return scene.name in EXPANDED_SCENES


func _on_context_timer() -> void:
	var current_scene := get_tree().current_scene
	var in_game := _is_expanded_scene(current_scene)

	if in_game != _in_game:
		_in_game = in_game
		_context_update()
	elif _in_game:
		FullScreenUtils.ensure_in_game_layout(get_tree())


func _context_update() -> void:
	if not FullScreenUtils.should_fullscreen():
		return
	FullScreenUtils.apply_stretch(get_tree(), _in_game)
	if _in_game:
		FullScreenUtils.ensure_in_game_layout(get_tree())


func _on_fullscreen_toggled(pressed: bool) -> void:
	FullScreenUtils.apply_borderless(pressed)
	FullScreenUtils.persist_fullscreen(pressed)
	_context_update()
