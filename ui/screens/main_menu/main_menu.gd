extends Control

const BACKGROUND_ART_PATH := "res://art/backgrounds/main_menu_bg.png"
const SAVE_DIR := "user://saves/"
const GAME_VERSION := "v0.1.0"

@onready var background: TextureRect = %Background
@onready var vignette: TextureRect = %Vignette
@onready var new_game_button: Button = %NewGameButton
@onready var load_game_button: Button = %LoadGameButton
@onready var options_button: Button = %OptionsButton
@onready var credits_button: Button = %CreditsButton
@onready var version_label: Label = %VersionLabel
@onready var placeholder_popup: PopupPanel = %PlaceholderPopup


func _ready() -> void:
	_setup_background()
	_setup_vignette()
	_setup_load_game_availability()
	version_label.text = GAME_VERSION

	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	options_button.pressed.connect(_on_options_pressed)
	credits_button.pressed.connect(_on_credits_pressed)


func _setup_background() -> void:
	if ResourceLoader.exists(BACKGROUND_ART_PATH):
		background.texture = load(BACKGROUND_ART_PATH)
		return

	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([
		Color(0.078, 0.086, 0.157, 1.0),
		Color(0.31, 0.22, 0.29, 1.0),
		Color(0.71, 0.47, 0.24, 1.0),
	])
	gradient.offsets = PackedFloat32Array([0.0, 0.55, 1.0])

	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill_from = Vector2(0.5, 0.0)
	gradient_texture.fill_to = Vector2(0.5, 1.0)
	gradient_texture.width = 4
	gradient_texture.height = 512
	background.texture = gradient_texture


func _setup_vignette() -> void:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([
		Color(0.0, 0.0, 0.0, 0.0),
		Color(0.0, 0.0, 0.0, 0.75),
	])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])

	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill_from = Vector2(0.5, 0.35)
	gradient_texture.fill_to = Vector2(0.5, 1.0)
	gradient_texture.width = 4
	gradient_texture.height = 512
	vignette.texture = gradient_texture


func _setup_load_game_availability() -> void:
	var dir := DirAccess.open(SAVE_DIR)
	var has_saves := false
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				has_saves = true
				break
			file_name = dir.get_next()
		dir.list_dir_end()
	load_game_button.disabled = not has_saves


func _on_new_game_pressed() -> void:
	placeholder_popup.show_message("Character creation isn't built yet.\nComing in Phase 1.")


func _on_load_game_pressed() -> void:
	placeholder_popup.show_message("Save/Load isn't built yet.")


func _on_options_pressed() -> void:
	placeholder_popup.show_message("Options are coming soon.")


func _on_credits_pressed() -> void:
	placeholder_popup.show_message("Medieval Life\n\nA text-driven medieval life simulator.")
