class_name CharacterCreation
extends Control

const FACTION_SELECT_SCENE := "res://ui/screens/faction_select/faction_select.tscn"
const BACKGROUND_ART_PATH := "res://art/backgrounds/main_menu_panel_v1.png"
const RELEASE_DURATION := 0.13

const FACTION_COLORS := {
	"RASHIDUN CALIPHATE": Color(0.45, 0.78, 0.48, 1.0),
	"BYZANTINE EMPIRE": Color(0.72, 0.58, 0.88, 1.0),
	"SASANIAN EMPIRE": Color(0.38, 0.80, 0.75, 1.0),
}
const BIRTHPLACES_BY_FACTION := {
	"RASHIDUN CALIPHATE": ["Medina", "Mecca", "Ta'if", "Khaybar", "Sana'a", "Najran", "Al-Yamama", "Nomadic Encampment"],
	"BYZANTINE EMPIRE": ["Constantinople", "Antioch", "Alexandria", "Ephesus", "Thessalonica", "Nicaea"],
	"SASANIAN EMPIRE": ["Ctesiphon", "Estakhr", "Rey", "Merv", "Nishapur", "Gundeshapur"],
}
const SOCIAL_ORIGINS := ["Peasant", "Farmer", "Artisan", "Merchant", "Soldier", "Clergy", "Noble"]

var selected_faction := "RASHIDUN CALIPHATE"
var selected_sex := ""
var tweens: Dictionary = {}

@onready var background: TextureRect = %Background
@onready var vignette: TextureRect = %Vignette
@onready var safe_area: MarginContainer = %SafeArea
@onready var composition: VBoxContainer = %Composition
@onready var info_panel: PanelContainer = %InfoPanel
@onready var emblem: NationEmblem = %Emblem
@onready var faction_name_label: Label = %FactionNameLabel
@onready var name_field: LineEdit = %NameField
@onready var male_button: Button = %MaleButton
@onready var female_button: Button = %FemaleButton
@onready var age_field: LineEdit = %AgeField
@onready var birthplace_field: OptionButton = %BirthplaceField
@onready var origin_field: OptionButton = %OriginField
@onready var back_button: Button = %BackButton
@onready var begin_button: Button = %BeginButton
@onready var click_sound: AudioStreamPlayer = %ClickSound
@onready var popup: Control = %PlaceholderPopup


func _ready() -> void:
	_setup_background()
	_setup_vignette()

	var nation_color: Color = FACTION_COLORS.get(selected_faction, Color(0.85, 0.72, 0.45, 1.0))
	faction_name_label.text = selected_faction
	faction_name_label.add_theme_color_override("font_color", nation_color)
	emblem.emblem_color = nation_color

	_populate_options(birthplace_field, BIRTHPLACES_BY_FACTION.get(selected_faction, []))
	_populate_options(origin_field, SOCIAL_ORIGINS)

	for button in [male_button, female_button, back_button, begin_button]:
		_wire_button(button)
	male_button.pressed.connect(func(): selected_sex = "MALE"; _update_begin_availability())
	female_button.pressed.connect(func(): selected_sex = "FEMALE"; _update_begin_availability())

	name_field.text_changed.connect(func(_t): _update_begin_availability())
	age_field.text_changed.connect(func(_t): _update_begin_availability())
	age_field.focus_exited.connect(_sanitize_age)
	birthplace_field.item_selected.connect(func(_i): _update_begin_availability())
	origin_field.item_selected.connect(func(_i): _update_begin_availability())

	back_button.pressed.connect(_go_back)
	begin_button.pressed.connect(_begin_life)
	_update_begin_availability()

	resized.connect(_apply_layout)
	_apply_layout()


func _apply_layout() -> void:
	var canvas := Vector2(get_window().content_scale_size)
	if canvas.x <= 0.0: canvas = Vector2(1080, 1920)
	var edge := clampf(canvas.x * 0.045, 26.0, 54.0)
	for side in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		safe_area.add_theme_constant_override(side, roundi(edge))
	var width := clampf((canvas.x - edge * 2.0) * 0.92, 600.0, 860.0)
	composition.custom_minimum_size.x = width
	info_panel.custom_minimum_size.x = width
	for button in [back_button, begin_button]:
		button.custom_minimum_size = Vector2(width * 0.34, clampf(canvas.y * 0.045, 68.0, 86.0))
	for button in [male_button, female_button]:
		button.custom_minimum_size = Vector2(0, clampf(canvas.y * 0.04, 60.0, 76.0))
	for field in [name_field, age_field, birthplace_field, origin_field]:
		field.custom_minimum_size.y = clampf(canvas.y * 0.04, 58.0, 72.0)
	for button in [male_button, female_button, back_button, begin_button]:
		_set_pivot.call_deferred(button)


func _populate_options(option_button: OptionButton, options: Array) -> void:
	option_button.clear()
	option_button.add_item("— Select —")
	option_button.set_item_disabled(0, true)
	option_button.selected = 0
	for option in options:
		option_button.add_item(option)


func _wire_button(button: Button) -> void:
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.button_down.connect(_press.bind(button))
	button.button_up.connect(_release.bind(button))
	button.resized.connect(_set_pivot.bind(button))


func _press(button: Button) -> void:
	if button.disabled: return
	click_sound.stop(); click_sound.play()
	_animate(button, Vector2(0.97, 0.97), Color(1.06, 1.03, 0.94), 0.10)


func _release(button: Button) -> void:
	_animate(button, Vector2.ONE, Color.WHITE, RELEASE_DURATION)


func _animate(button: Button, scale_to: Vector2, tint: Color, duration: float) -> void:
	_set_pivot(button)
	var old: Tween = tweens.get(button)
	if old and old.is_valid(): old.kill()
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", scale_to, duration)
	tween.tween_property(button, "self_modulate", tint, duration)
	tweens[button] = tween


func _set_pivot(button: Button) -> void:
	button.pivot_offset = button.size * 0.5


func _sanitize_age() -> void:
	var value := age_field.text.strip_edges()
	if value.is_valid_int() and int(value) >= 1 and int(value) <= 99:
		age_field.text = str(int(value))
	else:
		age_field.text = "16"


func _update_begin_availability() -> void:
	var has_name := name_field.text.strip_edges() != ""
	var has_sex := selected_sex != ""
	var has_birthplace := birthplace_field.selected > 0
	var has_origin := origin_field.selected > 0
	begin_button.disabled = not (has_name and has_sex and has_birthplace and has_origin)


func _go_back() -> void:
	await get_tree().create_timer(RELEASE_DURATION).timeout
	get_tree().change_scene_to_file(FACTION_SELECT_SCENE)


func _begin_life() -> void:
	await get_tree().create_timer(RELEASE_DURATION).timeout
	popup.show_message("Character creation is wired up, but life simulation isn't built yet.\n\nThis is the end of the current New Game flow.")


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
