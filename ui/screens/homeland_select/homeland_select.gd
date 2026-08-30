extends Control

const ERA_SELECT_SCENE := "res://ui/screens/era_select/era_select.tscn"
const BACKGROUND_ART_PATH := "res://art/backgrounds/main_menu_bg.png"
const PRESS_SCALE := Vector2(0.97, 0.97)
const PRESS_DURATION := 0.10
const RELEASE_DURATION := 0.13
const PRESS_TINT := Color(1.06, 1.03, 0.94, 1.0)

@onready var background: TextureRect = %Background
@onready var vignette: TextureRect = %Vignette
@onready var safe_area: MarginContainer = %SafeArea
@onready var composition: VBoxContainer = %Composition
@onready var era_label: Label = %EraLabel
@onready var era_gap: Control = %EraGap
@onready var title: Label = %Title
@onready var title_gap: Control = %TitleGap
@onready var subtitle: Label = %Subtitle
@onready var header_gap: Control = %HeaderGap
@onready var divider: Control = %Divider
@onready var list_gap: Control = %ListGap
@onready var homeland_list: VBoxContainer = %HomelandList
@onready var arabia_button: Button = %ArabiaButton
@onready var back_gap: Control = %BackGap
@onready var back_button: Button = %BackButton
@onready var click_sound: AudioStreamPlayer = %ClickSound

var button_tweens: Dictionary = {}


func _ready() -> void:
	_setup_background()
	_setup_vignette()
	_setup_interactive_button(arabia_button)
	_setup_interactive_button(back_button)
	back_button.pressed.connect(_return_to_era_select)
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


func _return_to_era_select() -> void:
	await get_tree().create_timer(RELEASE_DURATION).timeout
	get_tree().change_scene_to_file(ERA_SELECT_SCENE)


func _update_button_pivot(button: Button) -> void:
	button.pivot_offset = button.size * 0.5


func _apply_responsive_layout() -> void:
	var canvas_size := Vector2(get_window().content_scale_size)
	if canvas_size.x <= 0.0 or canvas_size.y <= 0.0:
		canvas_size = Vector2(1080.0, 1920.0)
	var edge_padding := clampf(canvas_size.x * 0.045, 24.0, 72.0)
	for margin_name in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		safe_area.add_theme_constant_override(margin_name, roundi(edge_padding))

	var content_width := clampf((canvas_size.x - edge_padding * 2.0) * 0.88, 560.0, 920.0)
	var row_height := clampf(canvas_size.y * 0.047, 72.0, 94.0)
	var feature_height := clampf(row_height * 1.48, 112.0, 140.0)
	var row_gap := clampf(row_height * 0.14, 10.0, 15.0)
	var row_font_size := roundi(clampf(row_height * 0.29, 21.0, 28.0))
	composition.custom_minimum_size.x = content_width
	homeland_list.custom_minimum_size.x = content_width
	homeland_list.add_theme_constant_override("separation", roundi(row_gap))
	for child in homeland_list.get_children():
		if child is Button:
			child.custom_minimum_size = Vector2(content_width, row_height)
			child.add_theme_font_size_override("font_size", row_font_size)
	arabia_button.custom_minimum_size.y = feature_height

	back_button.custom_minimum_size = Vector2(content_width * 0.48, row_height)
	back_button.add_theme_font_size_override("font_size", row_font_size)
	era_label.add_theme_font_size_override("font_size", roundi(clampf(canvas_size.y * 0.014, 18.0, 26.0)))
	# This heading is much longer than the era-screen title. Scale it from the
	# usable width so its Cinzel letter spacing never clips on portrait screens.
	title.add_theme_font_size_override("font_size", roundi(clampf(content_width * 0.053, 42.0, 52.0)))
	subtitle.add_theme_font_size_override("font_size", roundi(clampf(canvas_size.y * 0.018, 24.0, 34.0)))
	divider.custom_minimum_size = Vector2(content_width * 0.62, clampf(canvas_size.y * 0.012, 18.0, 24.0))
	era_gap.custom_minimum_size.y = clampf(canvas_size.y * 0.007, 8.0, 14.0)
	title_gap.custom_minimum_size.y = clampf(canvas_size.y * 0.008, 10.0, 16.0)
	header_gap.custom_minimum_size.y = clampf(canvas_size.y * 0.016, 22.0, 32.0)
	list_gap.custom_minimum_size.y = clampf(canvas_size.y * 0.016, 22.0, 32.0)
	back_gap.custom_minimum_size.y = clampf(canvas_size.y * 0.022, 28.0, 42.0)
	_update_button_pivot.call_deferred(arabia_button)
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
