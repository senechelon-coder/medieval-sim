extends Control

const BACKGROUND_ART_PATH := "res://art/backgrounds/main_menu_panel_v1.png"
const LOAD_GAME_SCENE := "res://ui/screens/load_game/load_game.tscn"
const GAME_VERSION := "v 0.1.0"
const BUTTON_PRESS_SCALE := Vector2(0.97, 0.97)
const BUTTON_PRESS_DURATION := 0.10
const BUTTON_RELEASE_DURATION := 0.13
const BUTTON_PRESS_TINT := Color(1.06, 1.03, 0.94, 1.0)

@onready var background: TextureRect = %Background
@onready var vignette: TextureRect = %Vignette
@onready var safe_area: MarginContainer = %SafeArea
@onready var composition: VBoxContainer = %Composition
@onready var logo_image: TextureRect = %LogoImage
@onready var logo_title: Label = %LogoTitle
@onready var logo_to_divider_gap: Control = %LogoToDividerGap
@onready var divider_top: Control = %DividerTop
@onready var divider_to_menu_gap: Control = %DividerToMenuGap
@onready var button_column: VBoxContainer = %ButtonColumn
@onready var new_game_button: Button = %NewGameButton
@onready var load_game_button: Button = %LoadGameButton
@onready var options_button: Button = %OptionsButton
@onready var credits_button: Button = %CreditsButton
@onready var store_button: Button = %StoreButton
@onready var menu_to_footer_gap: Control = %MenuToFooterGap
@onready var divider_bottom: Control = %DividerBottom
@onready var version_gap: Control = %VersionGap
@onready var version_label: Label = %VersionLabel
@onready var placeholder_popup: Control = %PlaceholderPopup
@onready var click_sound: AudioStreamPlayer = %ClickSound

var button_tweens: Dictionary = {}


func _ready() -> void:
	_setup_background()
	_setup_vignette()
	_setup_load_game_availability()
	version_label.text = GAME_VERSION
	resized.connect(_apply_responsive_layout)
	_apply_responsive_layout()

	_setup_menu_button(new_game_button, _on_new_game_pressed)
	_setup_menu_button(load_game_button, _on_load_game_pressed)
	_setup_menu_button(options_button, _on_options_pressed)
	_setup_menu_button(credits_button, _on_credits_pressed)
	_setup_menu_button(store_button, _on_store_pressed)
	_update_button_pivots.call_deferred()


func _setup_menu_button(button: Button, action: Callable) -> void:
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.gui_input.connect(_on_menu_button_gui_input.bind(button))
	button.button_down.connect(_on_menu_button_down.bind(button))
	button.button_up.connect(_on_menu_button_up.bind(button))
	button.pressed.connect(_on_menu_button_pressed.bind(action))
	button.resized.connect(_update_button_pivot.bind(button))


func _on_menu_button_gui_input(event: InputEvent, button: Button) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			button.release_focus.call_deferred()
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if not touch_event.pressed:
			button.release_focus.call_deferred()


func _on_menu_button_down(button: Button) -> void:
	if button.disabled:
		return
	_update_button_pivot(button)
	click_sound.stop()
	click_sound.play()
	_tween_button(button, BUTTON_PRESS_SCALE, BUTTON_PRESS_TINT, BUTTON_PRESS_DURATION)


func _on_menu_button_up(button: Button) -> void:
	_tween_button(button, Vector2.ONE, Color.WHITE, BUTTON_RELEASE_DURATION)


func _on_menu_button_pressed(action: Callable) -> void:
	await get_tree().create_timer(BUTTON_RELEASE_DURATION).timeout
	if is_instance_valid(self):
		action.call()


func _tween_button(button: Button, target_scale: Vector2, target_tint: Color, duration: float) -> void:
	var existing_tween: Tween = button_tweens.get(button)
	if existing_tween and existing_tween.is_valid():
		existing_tween.kill()

	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, duration)
	tween.tween_property(button, "self_modulate", target_tint, duration)
	button_tweens[button] = tween


func _update_button_pivots() -> void:
	for button in [new_game_button, load_game_button, options_button, credits_button, store_button]:
		_update_button_pivot(button)


func _update_button_pivot(button: Button) -> void:
	button.pivot_offset = button.size * 0.5


func _apply_responsive_layout() -> void:
	# Size against Godot's logical portrait canvas, not the editor's embedded
	# preview panel. The engine scales this canvas to the physical device.
	var viewport_size := Vector2(get_window().content_scale_size)
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(
			float(ProjectSettings.get_setting("display/window/size/viewport_width", 1080)),
			float(ProjectSettings.get_setting("display/window/size/viewport_height", 1920))
		)

	var short_edge := minf(viewport_size.x, viewport_size.y)
	var edge_padding := clampf(short_edge * 0.045, 24.0, 72.0)
	for margin_name in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		safe_area.add_theme_constant_override(margin_name, roundi(edge_padding))

	var available_width := viewport_size.x - edge_padding * 2.0
	var available_height := viewport_size.y - edge_padding * 2.0
	# The menu is deliberately narrower and denser than the in-game panels.
	# This mirrors the tall, premium manuscript composition in the reference.
	var button_width := clampf(available_width * 0.68, minf(320.0, available_width), 760.0)
	var button_height := clampf(available_height * 0.047, 58.0, 92.0)
	var button_gap := clampf(button_height * 0.13, 8.0, 14.0)
	var button_font_size := roundi(clampf(button_height * 0.30, 18.0, 28.0))

	button_column.custom_minimum_size = Vector2(button_width, 0.0)
	button_column.add_theme_constant_override("separation", roundi(button_gap))
	for button in [new_game_button, load_game_button, options_button, credits_button, store_button]:
		button.custom_minimum_size = Vector2(button_width, button_height)
		button.add_theme_font_size_override("font_size", button_font_size)
	_update_button_pivots.call_deferred()

	var menu_height := button_height * 5.0 + button_gap * 4.0
	var detail_height := clampf(available_height * 0.12, 110.0, 190.0)
	var logo_height_budget := available_height * 0.84 - menu_height - detail_height
	var logo_minimum := minf(300.0, available_height * 0.30)
	var logo_height := clampf(logo_height_budget, logo_minimum, available_height * 0.34)
	var logo_width := logo_height
	logo_image.custom_minimum_size = Vector2(logo_width, logo_height)
	logo_title.add_theme_font_size_override("font_size", roundi(clampf(available_width * 0.065, 42.0, 68.0)))

	var divider_width := clampf(button_width * 0.52, minf(220.0, available_width * 0.60), 440.0)
	var divider_height := clampf(available_height * 0.012, 14.0, 26.0)
	divider_top.custom_minimum_size = Vector2(divider_width, divider_height)
	divider_bottom.custom_minimum_size = Vector2(divider_width, divider_height)

	logo_to_divider_gap.custom_minimum_size.y = clampf(available_height * 0.006, 8.0, 14.0)
	divider_to_menu_gap.custom_minimum_size.y = clampf(available_height * 0.012, 16.0, 24.0)
	menu_to_footer_gap.custom_minimum_size.y = clampf(available_height * 0.014, 20.0, 30.0)
	version_gap.custom_minimum_size.y = clampf(available_height * 0.006, 8.0, 14.0)
	version_label.add_theme_font_size_override("font_size", roundi(clampf(button_font_size * 0.68, 14.0, 26.0)))

	composition.custom_minimum_size.x = button_width


func _setup_background() -> void:
	if ResourceLoader.exists(BACKGROUND_ART_PATH):
		background.texture = load(BACKGROUND_ART_PATH)
		return

	# Warm gold glow fading to near-black, radiating from the top.
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([
		Color(0.34, 0.23, 0.09, 1.0),
		Color(0.075, 0.052, 0.058, 1.0),
		Color(0.025, 0.019, 0.029, 1.0),
		Color(0.009, 0.008, 0.013, 1.0),
	])
	gradient.offsets = PackedFloat32Array([0.0, 0.28, 0.64, 1.0])

	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill = GradientTexture2D.FILL_RADIAL
	gradient_texture.fill_from = Vector2(0.5, 0.08)
	gradient_texture.fill_to = Vector2(0.5, 0.55)
	gradient_texture.width = 512
	gradient_texture.height = 512
	background.texture = gradient_texture


func _setup_vignette() -> void:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([
		Color(0.0, 0.0, 0.0, 0.0),
		Color(0.0, 0.0, 0.0, 0.4),
	])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])

	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill_from = Vector2(0.5, 0.4)
	gradient_texture.fill_to = Vector2(0.5, 1.0)
	gradient_texture.width = 4
	gradient_texture.height = 512
	vignette.texture = gradient_texture


func _setup_load_game_availability() -> void:
	load_game_button.disabled = not SaveManager.has_save()


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/screens/era_select/era_select.tscn")


func _on_load_game_pressed() -> void:
	get_tree().change_scene_to_file(LOAD_GAME_SCENE)


func _on_options_pressed() -> void:
	placeholder_popup.show_message("Options are coming soon.")


func _on_credits_pressed() -> void:
	placeholder_popup.show_message("Worldly Life\n\nA text-driven medieval life simulator.")


func _on_store_pressed() -> void:
	placeholder_popup.show_message("There's no store yet —\nand nothing planned to sell.")
