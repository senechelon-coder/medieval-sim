class_name LifeScreen
extends Control

const BACKGROUND_ART_PATH := "res://art/backgrounds/main_menu_panel_v1.png"

var character_name := "Unnamed"
var character_age := 1
var character_sex := "MALE"
var homeland := "RASHIDUN CALIPHATE"
var birthplace := "Medina"
var social_origin := "Peasant"
var father_name := "Unknown"
var mother_name := "Unknown"
var culture := "Unknown"
var faith := "Unknown"
var birth_season := "Unknown"
var appearance_seed := 1

@onready var background: TextureRect = %Background
@onready var safe_area: MarginContainer = %SafeArea
@onready var composition: VBoxContainer = %Composition
@onready var portrait: CharacterPortrait = %Portrait
@onready var name_label: Label = %NameLabel
@onready var identity_label: Label = %IdentityLabel
@onready var homeland_label: Label = %HomelandLabel
@onready var birthplace_label: Label = %BirthplaceLabel
@onready var age_value: Label = %AgeValue
@onready var occupation_value: Label = %OccupationValue
@onready var event_placeholder: Label = %EventPlaceholder
@onready var advance_button: Button = %AdvanceButton


func _ready() -> void:
	_setup_background()
	name_label.text = character_name
	identity_label.text = "%s  •  AGE %d" % [character_sex.capitalize(), character_age]
	homeland_label.text = homeland
	birthplace_label.text = "%s  •  632 AD" % birthplace
	age_value.text = str(character_age)
	occupation_value.text = _starting_occupation()
	portrait.female = character_sex == "FEMALE"
	portrait.variant_seed = appearance_seed
	event_placeholder.text = "Your chronicle begins here.\nAdvance Time will be activated in the next step."
	resized.connect(_apply_layout)
	_apply_layout()


func _starting_occupation() -> String:
	if character_age < 5 or social_origin == "Undetermined":
		return "Child"
	match social_origin:
		"Farmer": return "Farm Worker"
		"Artisan": return "Artisan's Assistant"
		"Merchant": return "Merchant's Assistant"
		"Soldier": return "Levy Recruit"
		"Clergy": return "Religious Student"
		"Noble": return "Noble Household"
		_: return "Labourer"


func _apply_layout() -> void:
	var canvas := Vector2(get_window().content_scale_size)
	if canvas.x <= 0.0: canvas = Vector2(1080, 1920)
	var edge := clampf(canvas.x * 0.045, 26.0, 54.0)
	for side in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		safe_area.add_theme_constant_override(side, roundi(edge))
	var width := clampf((canvas.x - edge * 2.0) * 0.92, 600.0, 880.0)
	composition.custom_minimum_size.x = width
	portrait.custom_minimum_size = Vector2(width * 0.27, width * 0.32)
	advance_button.custom_minimum_size = Vector2(width * 0.62, clampf(canvas.y * 0.052, 76.0, 98.0))
	name_label.add_theme_font_size_override("font_size", roundi(clampf(width * 0.047, 34.0, 44.0)))


func _setup_background() -> void:
	if ResourceLoader.exists(BACKGROUND_ART_PATH):
		background.texture = load(BACKGROUND_ART_PATH)
