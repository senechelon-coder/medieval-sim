extends Control

const HOMELAND_SELECT_SCENE := "res://ui/screens/homeland_select/homeland_select.tscn"
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
@onready var title: Label = %Title
@onready var subtitle: Label = %Subtitle
@onready var divider: Control = %Divider
@onready var birthplace_list: VBoxContainer = %BirthplaceList
@onready var fate_button: Button = %FateButton
@onready var continue_button: Button = %ContinueButton
@onready var back_button: Button = %BackButton
@onready var selection_label: Label = %SelectionLabel
@onready var popup: Control = %PlaceholderPopup
@onready var click_sound: AudioStreamPlayer = %ClickSound

var selected_birthplace := ""
var birthplace_buttons: Array[Button] = []
var button_tweens: Dictionary = {}


func _ready() -> void:
	_setup_background()
	_setup_vignette()
	for child in birthplace_list.get_children():
		if child is Button:
			var button := child as Button
			birthplace_buttons.append(button)
			_setup_interactive_button(button)
			button.pressed.connect(_select_birthplace.bind(button))
	for button in [fate_button, continue_button, back_button]:
		_setup_interactive_button(button)
	fate_button.pressed.connect(_choose_by_fate)
	continue_button.pressed.connect(_continue_to_next_step)
	back_button.pressed.connect(_return_to_homeland_select)
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


func _select_birthplace(button: Button) -> void:
	_set_selection(button.text.get_slice("\n", 0))


func _choose_by_fate() -> void:
	var button := birthplace_buttons.pick_random()
	_set_selection(button.text.get_slice("\n", 0))


func _set_selection(place_name: String) -> void:
	selected_birthplace = place_name
	selection_label.text = "YOUR BIRTHPLACE  •  %s" % place_name
	continue_button.disabled = false
	for button in birthplace_buttons:
		button.theme_type_variation = &"AvailableButton" if button.text.get_slice("\n", 0) == place_name else &"Button"


func _continue_to_next_step() -> void:
	await get_tree().create_timer(RELEASE_DURATION).timeout
	popup.show_message("%s is chosen.\n\nSocial Origin is the next phase." % selected_birthplace)


func _return_to_homeland_select() -> void:
	await get_tree().create_timer(RELEASE_DURATION).timeout
	get_tree().change_scene_to_file(HOMELAND_SELECT_SCENE)


func _update_button_pivot(button: Button) -> void:
	button.pivot_offset = button.size * 0.5


func _apply_responsive_layout() -> void:
	var canvas_size := Vector2(get_window().content_scale_size)
	if canvas_size.x <= 0.0 or canvas_size.y <= 0.0:
		canvas_size = Vector2(1080.0, 1920.0)
	var edge_padding := clampf(canvas_size.x * 0.042, 22.0, 68.0)
	for margin_name in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		safe_area.add_theme_constant_override(margin_name, roundi(edge_padding))
	var content_width := clampf((canvas_size.x - edge_padding * 2.0) * 0.88, 560.0, 920.0)
	var row_height := clampf(canvas_size.y * 0.043, 66.0, 84.0)
	var row_font_size := roundi(clampf(row_height * 0.27, 18.0, 23.0))
	composition.custom_minimum_size.x = content_width
	birthplace_list.custom_minimum_size.x = content_width
	birthplace_list.add_theme_constant_override("separation", roundi(clampf(row_height * 0.11, 7.0, 10.0)))
	for button in birthplace_buttons:
		button.custom_minimum_size = Vector2(content_width, row_height)
		button.add_theme_font_size_override("font_size", row_font_size)
	for button in [fate_button, continue_button, back_button]:
		button.custom_minimum_size = Vector2(content_width * 0.31, row_height)
		button.add_theme_font_size_override("font_size", row_font_size)
	era_label.add_theme_font_size_override("font_size", roundi(clampf(canvas_size.y * 0.013, 17.0, 24.0)))
	title.add_theme_font_size_override("font_size", roundi(clampf(content_width * 0.057, 40.0, 52.0)))
	subtitle.add_theme_font_size_override("font_size", roundi(clampf(canvas_size.y * 0.017, 22.0, 31.0)))
	selection_label.add_theme_font_size_override("font_size", roundi(clampf(canvas_size.y * 0.014, 18.0, 25.0)))
	divider.custom_minimum_size = Vector2(content_width * 0.62, clampf(canvas_size.y * 0.01, 16.0, 22.0))
	for button in birthplace_buttons:
		_update_button_pivot.call_deferred(button)
	for button in [fate_button, continue_button, back_button]:
		_update_button_pivot.call_deferred(button)


func _setup_background() -> void:
	if ResourceLoader.exists(BACKGROUND_ART_PATH):
		background.texture = load(BACKGROUND_ART_PATH)
		return
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(0.34, 0.23, 0.09), Color(0.075, 0.052, 0.058), Color(0.009, 0.008, 0.013)])
	gradient.offsets = PackedFloat32Array([0.0, 0.38, 1.0])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.08)
	texture.fill_to = Vector2(0.5, 0.6)
	texture.width = 512
	texture.height = 512
	background.texture = texture


func _setup_vignette() -> void:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0.4)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0.5, 0.4)
	texture.fill_to = Vector2(0.5, 1.0)
	texture.width = 4
	texture.height = 512
	vignette.texture = texture
