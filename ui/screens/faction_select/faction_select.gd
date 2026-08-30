extends Control

const ERA_SCENE := "res://ui/screens/era_select/era_select.tscn"
const CHARACTER_CREATION_SCENE := "res://ui/screens/character_creation/character_creation.tscn"
const RELEASE_DURATION := 0.13
const FACTION_MUSIC := {
	"RASHIDUN CALIPHATE": "res://audio/music/rashidun_caliphate.mp3",
	"BYZANTINE EMPIRE": "res://audio/music/byzantine_empire.mp3",
	"SASANIAN EMPIRE": "res://audio/music/sasanian_empire.mp3",
}
const FACTION_COLORS := {
	"RASHIDUN CALIPHATE": Color(0.45, 0.78, 0.48, 1.0),
	"BYZANTINE EMPIRE": Color(0.72, 0.58, 0.88, 1.0),
	"SASANIAN EMPIRE": Color(0.38, 0.80, 0.75, 1.0),
}
const BODY_FONT_PATH := "res://ui/theme/fonts/IMFellEnglish-Regular.ttf"

@onready var safe_area: MarginContainer = %SafeArea
@onready var composition: VBoxContainer = %Composition
@onready var map_frame: PanelContainer = %MapFrame
@onready var info_panel: PanelContainer = %InfoPanel
@onready var title: Label = %Title
@onready var faction_name: Label = %FactionName
@onready var availability: RichTextLabel = %Availability
@onready var select_label: Label = %SelectLabel
@onready var back_button: Button = %BackButton
@onready var continue_button: Button = %ContinueButton
@onready var click_sound: AudioStreamPlayer = %ClickSound
@onready var music_player: AudioStreamPlayer = %MusicPlayer

var selected_faction := ""
var faction_buttons: Array[Button]
var tweens: Dictionary = {}
var bold_body_font: FontVariation


func _ready() -> void:
	bold_body_font = FontVariation.new()
	bold_body_font.base_font = load(BODY_FONT_PATH)
	bold_body_font.variation_embolden = 0.6

	faction_buttons = [%RashidunButton, %ByzantineButton, %SasanianButton]
	for button in faction_buttons:
		_wire_button(button)
		button.pressed.connect(_select_faction.bind(button))
	for button in [back_button, continue_button]:
		_wire_button(button)
	back_button.pressed.connect(_go_back)
	continue_button.pressed.connect(_continue)
	resized.connect(_apply_layout)
	_apply_layout()


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


func _select_faction(button: Button) -> void:
	selected_faction = button.text
	var nation_color: Color = FACTION_COLORS.get(selected_faction, Color(0.87, 0.83, 0.76, 1.0))
	faction_name.text = selected_faction
	faction_name.add_theme_color_override("font_color", nation_color)
	faction_name.add_theme_font_override("font", bold_body_font)
	availability.text = "[center][color=#7aad4c]●[/color]  [color=#%s]AVAILABLE[/color][/center]" % nation_color.to_html(false)
	select_label.text = "HOMELAND SELECTED  •  %s" % selected_faction
	continue_button.disabled = false
	for item in faction_buttons:
		item.theme_type_variation = &"AvailableButton" if item == button else &"Button"
	_play_faction_music(selected_faction)


func _play_faction_music(faction: String) -> void:
	var music_path: String = FACTION_MUSIC.get(faction, "")
	if music_path == "":
		return
	var stream: AudioStream = load(music_path)
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	music_player.stream = stream
	music_player.play()


func _go_back() -> void:
	await get_tree().create_timer(RELEASE_DURATION).timeout
	get_tree().change_scene_to_file(ERA_SCENE)


func _continue() -> void:
	await get_tree().create_timer(RELEASE_DURATION).timeout
	var next_scene: PackedScene = load(CHARACTER_CREATION_SCENE)
	var next: CharacterCreation = next_scene.instantiate()
	next.selected_faction = selected_faction
	get_tree().root.add_child(next)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = next


func _set_pivot(button: Button) -> void:
	button.pivot_offset = button.size * 0.5


func _apply_layout() -> void:
	var canvas := Vector2(get_window().content_scale_size)
	if canvas.x <= 0.0: canvas = Vector2(1080, 1920)
	var edge := clampf(canvas.x * 0.045, 26.0, 54.0)
	for side in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		safe_area.add_theme_constant_override(side, roundi(edge))
	var width := clampf((canvas.x - edge * 2.0) * 0.90, 600.0, 920.0)
	composition.custom_minimum_size.x = width
	map_frame.custom_minimum_size = Vector2(width, width * 0.56)
	info_panel.custom_minimum_size = Vector2(width, clampf(canvas.y * 0.1, 150.0, 190.0))
	title.add_theme_font_size_override("font_size", roundi(clampf(width * 0.05, 38.0, 50.0)))
	faction_name.add_theme_font_size_override("font_size", roundi(clampf(width * 0.034, 25.0, 34.0)))
	for button in faction_buttons:
		button.add_theme_font_size_override("font_size", roundi(clampf(width * 0.024, 18.0, 23.0)))
	for button in [back_button, continue_button]:
		button.custom_minimum_size = Vector2(width * 0.34, clampf(canvas.y * 0.045, 68.0, 86.0))
	for button in faction_buttons + [back_button, continue_button]:
		_set_pivot.call_deferred(button)
