extends Control

const MAIN_MENU_SCENE := "res://ui/screens/main_menu/main_menu.tscn"
const LIFE_SCREEN_SCENE := "res://ui/screens/life_screen/life_screen.tscn"
const BACKGROUND_ART_PATH := "res://art/backgrounds/main_menu_panel_v1.png"

@onready var background: TextureRect = %Background
@onready var safe_area: MarginContainer = %SafeArea
@onready var composition: VBoxContainer = %Composition
@onready var slot_one: Button = %SlotOne
@onready var back_button: Button = %BackButton
@onready var message: Label = %Message
@onready var click_sound: AudioStreamPlayer = %ClickSound


func _ready() -> void:
	if ResourceLoader.exists(BACKGROUND_ART_PATH):
		background.texture = load(BACKGROUND_ART_PATH)
	var summary := SaveManager.get_save_summary()
	if summary.is_empty():
		slot_one.text = "SLOT 1\nEMPTY"
		slot_one.disabled = true
	else:
		slot_one.text = "SLOT 1\n%s  •  AGE %d\n%s  •  %d AD" % [summary.name, summary.age, summary.homeland, summary.year]
	for button in [slot_one, back_button]:
		button.button_down.connect(_play_click)
	slot_one.pressed.connect(_load_slot_one)
	back_button.pressed.connect(func(): get_tree().change_scene_to_file(MAIN_MENU_SCENE))
	resized.connect(_apply_layout)
	_apply_layout()


func _play_click() -> void:
	click_sound.stop()
	click_sound.play()


func _load_slot_one() -> void:
	if SaveManager.load_game():
		get_tree().change_scene_to_file(LIFE_SCREEN_SCENE)
	else:
		message.text = "THE SAVE COULD NOT BE LOADED"


func _apply_layout() -> void:
	var canvas := Vector2(get_window().content_scale_size)
	if canvas.x <= 0.0:
		canvas = Vector2(1920, 1080)
	var edge := clampf(canvas.x * 0.045, 26.0, 54.0)
	for side in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		safe_area.add_theme_constant_override(side, roundi(edge))
	var width := clampf((canvas.x - edge * 2.0) * 0.76, 560.0, 900.0)
	composition.custom_minimum_size.x = width
	for button in [%SlotOne, %SlotTwo, %SlotThree]:
		button.custom_minimum_size = Vector2(width, clampf(canvas.y * 0.09, 130.0, 170.0))
	back_button.custom_minimum_size = Vector2(width * 0.48, clampf(canvas.y * 0.045, 68.0, 86.0))
