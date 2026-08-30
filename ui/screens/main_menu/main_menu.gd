extends Control

const BACKGROUND_ART_PATH := "res://art/backgrounds/main_menu_bg.png"
const SAVE_DIR := "user://saves/"
const GAME_VERSION := "v 0.1.0"

@onready var background: TextureRect = %Background
@onready var vignette: TextureRect = %Vignette
@onready var safe_area: MarginContainer = %SafeArea
@onready var composition: VBoxContainer = %Composition
@onready var logo_image: TextureRect = %LogoImage
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
@onready var placeholder_popup: PopupPanel = %PlaceholderPopup


func _ready() -> void:
	_setup_background()
	_setup_vignette()
	_setup_load_game_availability()
	version_label.text = GAME_VERSION
	resized.connect(_apply_responsive_layout)
	_apply_responsive_layout()

	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	options_button.pressed.connect(_on_options_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	store_button.pressed.connect(_on_store_pressed)


func _apply_responsive_layout() -> void:
	var viewport_size := size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = get_viewport_rect().size

	var short_edge := minf(viewport_size.x, viewport_size.y)
	var edge_padding := clampf(short_edge * 0.045, 24.0, 72.0)
	for margin_name in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		safe_area.add_theme_constant_override(margin_name, roundi(edge_padding))

	var available_width := viewport_size.x - edge_padding * 2.0
	var available_height := viewport_size.y - edge_padding * 2.0
	var button_width := clampf(available_width * 0.86, minf(320.0, available_width), 980.0)
	var button_height := clampf(available_height * 0.052, 48.0, 116.0)
	var button_gap := clampf(button_height * 0.17, 8.0, 22.0)
	var button_font_size := roundi(clampf(button_height * 0.34, 18.0, 40.0))

	button_column.custom_minimum_size = Vector2(button_width, 0.0)
	button_column.add_theme_constant_override("separation", roundi(button_gap))
	for button in [new_game_button, load_game_button, options_button, credits_button, store_button]:
		button.custom_minimum_size = Vector2(button_width, button_height)
		button.add_theme_font_size_override("font_size", button_font_size)

	var menu_height := button_height * 5.0 + button_gap * 4.0
	var detail_height := clampf(available_height * 0.07, 64.0, 138.0)
	var logo_height_budget := available_height * 0.88 - menu_height - detail_height
	var logo_minimum := minf(300.0, available_height * 0.32)
	var logo_height := clampf(logo_height_budget, logo_minimum, available_height * 0.50)
	var logo_width := logo_height * 0.657
	logo_image.custom_minimum_size = Vector2(logo_width, logo_height)

	var divider_width := clampf(button_width * 0.58, minf(240.0, available_width * 0.72), 620.0)
	var divider_height := clampf(available_height * 0.012, 14.0, 26.0)
	divider_top.custom_minimum_size = Vector2(divider_width, divider_height)
	divider_bottom.custom_minimum_size = Vector2(divider_width, divider_height)

	logo_to_divider_gap.custom_minimum_size.y = clampf(available_height * 0.006, 8.0, 14.0)
	divider_to_menu_gap.custom_minimum_size.y = clampf(available_height * 0.014, 18.0, 30.0)
	menu_to_footer_gap.custom_minimum_size.y = clampf(available_height * 0.018, 24.0, 38.0)
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
		Color(0.48, 0.36, 0.18, 1.0),
		Color(0.1, 0.08, 0.11, 1.0),
		Color(0.043, 0.035, 0.055, 1.0),
	])
	gradient.offsets = PackedFloat32Array([0.0, 0.35, 1.0])

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
	placeholder_popup.show_message("Worldly Life\n\nA text-driven medieval life simulator.")


func _on_store_pressed() -> void:
	placeholder_popup.show_message("There's no store yet —\nand nothing planned to sell.")
