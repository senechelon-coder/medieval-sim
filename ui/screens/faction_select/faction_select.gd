extends Control

const ERA_SCENE := "res://ui/screens/era_select/era_select.tscn"
const RELEASE_DURATION := 0.13
const FACTIONS := {
	"RASHIDUN CALIPHATE": ["A young realm emerging from Arabia,\nheld together by faith, tribal relationships\nand rapid political change.", "CARAVANS  •  TRIBAL LIFE\nFAITH  •  EXPANSION"],
	"BYZANTINE EMPIRE": ["An old Christian empire of fortified cities,\nimperial law and Mediterranean commerce,\nweakened by decades of war.", "CITIES  •  IMPERIAL LAW\nTRADE  •  FRONTIER WAR"],
	"SASANIAN EMPIRE": ["A wealthy Persian empire of royal courts,\nfarming estates and ancient traditions,\nnow facing internal instability.", "COURTLY LIFE  •  AGRICULTURE\nCRAFTS  •  POLITICAL CRISIS"],
}
const FACTION_MUSIC := {
	"RASHIDUN CALIPHATE": "res://audio/music/rashidun_caliphate.mp3",
	"BYZANTINE EMPIRE": "res://audio/music/byzantine_empire.mp3",
	"SASANIAN EMPIRE": "res://audio/music/sasanian_empire.mp3",
}

@onready var safe_area: MarginContainer = %SafeArea
@onready var composition: VBoxContainer = %Composition
@onready var map_frame: PanelContainer = %MapFrame
@onready var info_panel: PanelContainer = %InfoPanel
@onready var title: Label = %Title
@onready var faction_name: Label = %FactionName
@onready var availability: RichTextLabel = %Availability
@onready var description: Label = %Description
@onready var traits: Label = %Traits
@onready var select_label: Label = %SelectLabel
@onready var back_button: Button = %BackButton
@onready var continue_button: Button = %ContinueButton
@onready var popup: Control = %PlaceholderPopup
@onready var click_sound: AudioStreamPlayer = %ClickSound
@onready var music_player: AudioStreamPlayer = %MusicPlayer

var selected_faction := ""
var faction_buttons: Array[Button]
var tweens: Dictionary = {}


func _ready() -> void:
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
	var data: Array = FACTIONS[selected_faction]
	faction_name.text = selected_faction
	availability.text = "[center][color=#7aad4c]●[/color]  AVAILABLE[/center]"
	description.text = data[0]
	traits.text = data[1]
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
	popup.show_message("Your life will begin in the %s.\n\nThis is the end of the current New Game flow." % selected_faction)


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
	info_panel.custom_minimum_size = Vector2(width, clampf(canvas.y * 0.205, 320.0, 380.0))
	title.add_theme_font_size_override("font_size", roundi(clampf(width * 0.05, 38.0, 50.0)))
	faction_name.add_theme_font_size_override("font_size", roundi(clampf(width * 0.034, 25.0, 34.0)))
	description.add_theme_font_size_override("font_size", roundi(clampf(width * 0.026, 19.0, 25.0)))
	traits.add_theme_font_size_override("font_size", roundi(clampf(width * 0.024, 18.0, 23.0)))
	for button in faction_buttons:
		button.add_theme_font_size_override("font_size", roundi(clampf(width * 0.024, 18.0, 23.0)))
	for button in [back_button, continue_button]:
		button.custom_minimum_size = Vector2(width * 0.34, clampf(canvas.y * 0.045, 68.0, 86.0))
	for button in faction_buttons + [back_button, continue_button]:
		_set_pivot.call_deferred(button)
