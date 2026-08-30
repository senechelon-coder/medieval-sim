extends Control

const MAIN_MENU_SCENE := "res://ui/screens/main_menu/main_menu.tscn"
const FACTION_SELECT_SCENE := "res://ui/screens/faction_select/faction_select.tscn"
const BACKGROUND_ART_PATH := "res://art/backgrounds/main_menu_panel_v1.png"
const PRESS_SCALE := Vector2(0.97, 0.97)
const PRESS_DURATION := 0.10
const RELEASE_DURATION := 0.13
const PRESS_TINT := Color(1.06, 1.03, 0.94, 1.0)

@onready var background: TextureRect = %Background
@onready var vignette: TextureRect = %Vignette
@onready var safe_area: MarginContainer = %SafeArea
@onready var composition: VBoxContainer = %Composition
@onready var title: Label = %Title
@onready var title_gap: Control = %TitleGap
@onready var subtitle: Label = %Subtitle
@onready var header_gap: Control = %HeaderGap
@onready var divider: Control = %Divider
@onready var list_gap: Control = %ListGap
@onready var era_list: VBoxContainer = %EraList
@onready var era_632: Button = %Era632
@onready var back_gap: Control = %BackGap
@onready var back_button: Button = %BackButton
@onready var click_sound: AudioStreamPlayer = %ClickSound

var button_tweens: Dictionary = {}


func _ready() -> void:
	_setup_background()
	_setup_vignette()
	_setup_interactive_button(era_632)
	_setup_interactive_button(back_button)
	era_632.pressed.connect(_select_era_632)
	back_button.pressed.connect(_return_to_main_menu)
	resized.connect(_apply_responsive_layout)
	_apply_responsive_layout()


func _setup_interactive_button(button: Button) -> void:
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.button_down.connect(_on_button_down.bind(button))
	button.button_up.connect(_on_button_up.bind(button))
	button.resized.connect(_update_button_pivot.bind(button))


func _on_button_down(button: Button) -> void:
	_update_button_pivot(button)
	click_sound.stop()
	click_sound.play()
	_tween_button(button, PRESS_SCALE, PRESS_TINT, PRESS_DURATION)


func _on_button_up(button: Button) -> void:
	_tween_button(button, Vector2.ONE, Color.WHITE, RELEASE_DURATION)


func _tween_button(button: Button, target_scale: Vector2, target_tint: Color, duration: float) -> void:
	var existing_tween: Tween = button_tweens.get(button)
	if existing_tween and existing_tween.is_valid():
		existing_tween.kill()
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, duration)
	tween.tween_property(button, "self_modulate", target_tint, duration)
	button_tweens[button] = tween


func _return_to_main_menu() -> void:
	await get_tree().create_timer(RELEASE_DURATION).timeout
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _select_era_632() -> void:
	era_632.text = "632  —  SELECTED"
	subtitle.text = "Your life will begin in the year 632."
	await get_tree().create_timer(RELEASE_DURATION).timeout
	get_tree().change_scene_to_file(FACTION_SELECT_SCENE)


func _update_button_pivot(button: Button) -> void:
	button.pivot_offset = button.size * 0.5


func _apply_responsive_layout() -> void:
	var canvas_size := Vector2(get_window().content_scale_size)
	if canvas_size.x <= 0.0 or canvas_size.y <= 0.0:
		canvas_size = Vector2(1080.0, 1920.0)
	var edge_padding := clampf(canvas_size.x * 0.045, 24.0, 72.0)
	for margin_name in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		safe_area.add_theme_constant_override(margin_name, roundi(edge_padding))

	var content_width := clampf((canvas_size.x - edge_padding * 2.0) * 0.72, 520.0, 760.0)
	var row_height := clampf(canvas_size.y * 0.046, 68.0, 88.0)
	var row_gap := clampf(row_height * 0.14, 9.0, 13.0)
	var row_font_size := roundi(clampf(row_height * 0.27, 19.0, 25.0))
	composition.custom_minimum_size.x = content_width
	era_list.custom_minimum_size.x = content_width
	era_list.add_theme_constant_override("separation", roundi(row_gap))
	for child in era_list.get_children():
		if child is Button:
			child.custom_minimum_size = Vector2(content_width, row_height)
			child.add_theme_font_size_override("font_size", row_font_size)

	back_button.custom_minimum_size = Vector2(content_width * 0.56, row_height)
	back_button.add_theme_font_size_override("font_size", row_font_size)
	title.add_theme_font_size_override("font_size", roundi(clampf(canvas_size.y * 0.039, 48.0, 68.0)))
	subtitle.add_theme_font_size_override("font_size", roundi(clampf(canvas_size.y * 0.014, 19.0, 27.0)))
	divider.custom_minimum_size = Vector2(content_width * 0.54, clampf(canvas_size.y * 0.010, 16.0, 21.0))
	title_gap.custom_minimum_size.y = clampf(canvas_size.y * 0.008, 10.0, 16.0)
	header_gap.custom_minimum_size.y = clampf(canvas_size.y * 0.014, 19.0, 27.0)
	list_gap.custom_minimum_size.y = clampf(canvas_size.y * 0.014, 19.0, 27.0)
	back_gap.custom_minimum_size.y = clampf(canvas_size.y * 0.020, 27.0, 38.0)
	_update_button_pivot.call_deferred(era_632)
	_update_button_pivot.call_deferred(back_button)


func _setup_background() -> void:
	if ResourceLoader.exists(BACKGROUND_ART_PATH):
		background.texture = load(BACKGROUND_ART_PATH)
		return
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
