class_name LifeScreen
extends Control

const BACKGROUND_ART_PATH := "res://art/backgrounds/main_menu_panel_v1.png"
const MAIN_MENU_SCENE := "res://ui/screens/main_menu/main_menu.tscn"

var character_name := "Unnamed"
var character_age := 1
var character_sex := "MALE"
var homeland := "RASHIDUN CALIPHATE"
var birthplace := "Medina"
var family_origin := "Unknown"
var upbringing := "Undetermined"
var father_name := "Unknown"
var mother_name := "Unknown"
var culture := "Unknown"
var faith := "Unknown"
var birth_season := "Unknown"
var appearance_seed := 1
var health := 90
var wealth := 10
var standing := "Unknown"
var primary_trait := "Undeveloped"
var apprenticeship := "None"
var pending_event := ""

@onready var background: TextureRect = %Background
@onready var era_label: Label = %Era
@onready var safe_area: MarginContainer = %SafeArea
@onready var composition: VBoxContainer = %Composition
@onready var portrait: CharacterPortrait = %Portrait
@onready var name_label: Label = %NameLabel
@onready var identity_label: Label = %IdentityLabel
@onready var homeland_label: Label = %HomelandLabel
@onready var birthplace_label: Label = %BirthplaceLabel
@onready var age_value: Label = %AgeValue
@onready var health_value: Label = %HealthValue
@onready var wealth_value: Label = %WealthValue
@onready var standing_value: Label = %StandingValue
@onready var trait_value: Label = %TraitValue
@onready var occupation_value: Label = %OccupationValue
@onready var event_placeholder: Label = %EventPlaceholder
@onready var chronicle_scroll: ScrollContainer = %ChronicleScroll
@onready var advance_button: Button = %AdvanceButton
@onready var upbringing_panel: PanelContainer = %UpbringingPanel
@onready var upbringing_buttons: Array[Button] = [
	%FamilyDutiesButton,
	%ReligiousSchoolingButton,
	%MarketUpbringingButton,
	%MartialUpbringingButton,
]
@onready var decision_panel: PanelContainer = %DecisionPanel
@onready var return_purse_button: Button = %ReturnPurseButton
@onready var keep_purse_button: Button = %KeepPurseButton
@onready var apprenticeship_panel: PanelContainer = %ApprenticeshipPanel
@onready var apprenticeship_buttons: Array[Button] = [
	%CraftApprenticeshipButton,
	%ScholarlyApprenticeshipButton,
	%TradeApprenticeshipButton,
	%MartialApprenticeshipButton,
]
@onready var more_button: Button = %More
@onready var pause_overlay: Control = %PauseOverlay
@onready var resume_button: Button = %ResumeButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	_load_character_state()
	_setup_background()
	_refresh_character_display()
	_refresh_stats()
	homeland_label.text = homeland
	occupation_value.text = _starting_occupation()
	portrait.female = character_sex == "FEMALE"
	portrait.variant_seed = appearance_seed
	if WorldState.player.chronicle.is_empty():
		WorldState.player.chronicle.append("Age 1, %s\nYou begin life in %s." % [TimeManager.year_label(), birthplace])
	event_placeholder.text = "\n\n".join(WorldState.player.chronicle)
	advance_button.disabled = false
	advance_button.text = "AGE UP"
	advance_button.pressed.connect(_advance_year)
	for button in upbringing_buttons:
		button.pressed.connect(_choose_upbringing.bind(button))
	return_purse_button.pressed.connect(_resolve_decision.bind(0))
	keep_purse_button.pressed.connect(_resolve_decision.bind(1))
	for button in apprenticeship_buttons:
		button.pressed.connect(_choose_apprenticeship.bind(button))
	more_button.pressed.connect(_open_pause_menu)
	resume_button.pressed.connect(_resume_game)
	main_menu_button.pressed.connect(_save_and_return_to_menu)
	_restore_pending_milestone()
	SaveManager.save_game()
	resized.connect(_apply_layout)
	_apply_layout()


func _advance_year() -> void:
	TimeManager.advance_year()
	character_age += 1
	_sync_character_state()
	_refresh_character_display()
	occupation_value.text = _starting_occupation()
	if character_age == 5:
		_append_chronicle("Age 5, %s\nYour early upbringing can now be chosen." % TimeManager.year_label())
		upbringing_panel.show()
		advance_button.disabled = true
	elif character_age == 6:
		_append_chronicle("Age 6, %s\nYou discover a merchant's lost purse near the market road." % TimeManager.year_label())
		_show_decision("lost_purse", "A LOST PURSE", "A merchant's purse lies unattended beside the market road. What will you do?", "RETURN IT TO THE MERCHANT", "BRING IT HOME")
	elif character_age == 8:
		_append_chronicle("Age 8, %s\nA sudden fever leaves you weak for several days." % TimeManager.year_label())
		_show_decision("childhood_fever", "A SUDDEN FEVER", "Your family urges you to rest, but household work remains unfinished.", "REST AND RECOVER", "KEEP HELPING")
	elif character_age == 10:
		_append_chronicle("Age 10, %s\nA respected elder notices your potential and offers personal guidance." % TimeManager.year_label())
		_show_decision("mentors_offer", "A MENTOR'S OFFER", "Learning from the elder will cost the household your daily help. What matters most?", "ACCEPT THE GUIDANCE", "REMAIN WITH YOUR FAMILY")
	elif character_age == 12:
		_append_chronicle("Age 12, %s\nChildhood gives way to responsibility. Your household must decide how you will be trained." % TimeManager.year_label())
		apprenticeship_panel.show()
		advance_button.disabled = true
	else:
		_append_chronicle("Age %d, %s\nAnother year of childhood passes." % [character_age, TimeManager.year_label()])


func _refresh_character_display() -> void:
	name_label.text = character_name
	identity_label.text = "%s  •  AGE %d" % [character_sex.capitalize(), character_age]
	era_label.text = TimeManager.year_label()
	birthplace_label.text = "%s  •  %s" % [birthplace, TimeManager.year_label()]
	age_value.text = str(character_age)


func _choose_upbringing(button: Button) -> void:
	upbringing = button.get_meta("upbringing", button.text.capitalize())
	var consequence := ""
	match upbringing:
		"Family Duties":
			health = mini(health + 2, 100)
			standing = "Dependable"
			consequence = "+2 Health • Dependable standing"
		"Religious Schooling":
			standing = "Studious"
			consequence = "Studious standing"
		"Market Upbringing":
			wealth += 5
			standing = "Streetwise"
			consequence = "+5 Wealth • Streetwise standing"
		"Martial Upbringing":
			health = mini(health + 3, 100)
			standing = "Promising"
			consequence = "+3 Health • Promising standing"
	upbringing_panel.hide()
	advance_button.disabled = false
	occupation_value.text = _starting_occupation()
	_refresh_stats()
	_append_chronicle("Your family begins raising you through %s.\n%s" % [upbringing.to_lower(), consequence])
	_sync_character_state()


func _refresh_stats() -> void:
	health_value.text = "%d%%" % health
	wealth_value.text = str(wealth)
	standing_value.text = standing
	trait_value.text = primary_trait


func _show_decision(event_id: String, title: String, description: String, first_choice: String, second_choice: String) -> void:
	pending_event = event_id
	%DecisionTitle.text = title
	%DecisionDescription.text = description
	return_purse_button.text = first_choice
	keep_purse_button.text = second_choice
	decision_panel.show()
	advance_button.disabled = true


func _resolve_decision(choice: int) -> void:
	decision_panel.hide()
	advance_button.disabled = false
	match pending_event:
		"lost_purse":
			if choice == 0:
				standing = "Honorable"
				_append_chronicle("You return it to its owner. Your honesty becomes known.\nHonorable standing")
			else:
				wealth += 8
				standing = "Questioned"
				_append_chronicle("You quietly bring it home. The money helps, but whispers follow.\n+8 Wealth • Questioned standing")
		"childhood_fever":
			if choice == 0:
				health = mini(health + 5, 100)
				wealth = maxi(wealth - 2, 0)
				_append_chronicle("You are allowed to recover beside the hearth.\n+5 Health • -2 Wealth")
			else:
				health = maxi(health - 8, 0)
				wealth += 3
				_append_chronicle("You work through the fever and worsen before recovering.\n-8 Health • +3 Wealth")
		"mentors_offer":
			if choice == 0:
				wealth = maxi(wealth - 3, 0)
				standing = "Promising"
				primary_trait = "Curious"
				_append_chronicle("You accept the elder's guidance and discover a hunger for knowledge.\n-3 Wealth • Curious trait • Promising standing")
			else:
				wealth += 4
				standing = "Dependable"
				primary_trait = "Loyal"
				_append_chronicle("You remain beside your family and become someone they can rely upon.\n+4 Wealth • Loyal trait • Dependable standing")
	if WorldState.has_player() and pending_event not in WorldState.player.completed_events:
		WorldState.player.completed_events.append(pending_event)
	pending_event = ""
	_refresh_stats()
	_sync_character_state()


func _append_chronicle(entry: String) -> void:
	event_placeholder.text += "\n\n" + entry
	if WorldState.has_player():
		WorldState.player.chronicle.append(entry)
		SaveManager.save_game()
	_scroll_chronicle_to_bottom.call_deferred()


func _scroll_chronicle_to_bottom() -> void:
	chronicle_scroll.scroll_vertical = int(chronicle_scroll.get_v_scroll_bar().max_value)


func _starting_occupation() -> String:
	if apprenticeship != "None":
		return apprenticeship
	if character_age < 5 or upbringing == "Undetermined":
		return "Child"
	match upbringing:
		"Family Duties": return "Household Helper"
		"Religious Schooling": return "Religious Student"
		"Market Upbringing": return "Trader's Helper"
		"Martial Upbringing": return "Martial Pupil"
		_: return "Child"


func _choose_apprenticeship(button: Button) -> void:
	var path: String = button.get_meta("path", "")
	match path:
		"craft":
			apprenticeship = "Craft Apprentice"
			standing = "Useful"
			_append_chronicle("You enter a household workshop and begin learning a practical craft.\nOccupation: Craft Apprentice • Useful standing")
		"scholar":
			apprenticeship = "Young Scholar"
			wealth = maxi(wealth - 3, 0)
			standing = "Learned"
			_append_chronicle("You continue formal study under a teacher of letters and faith.\nOccupation: Young Scholar • -3 Wealth • Learned standing")
		"trade":
			apprenticeship = "Merchant Apprentice"
			wealth += 5
			standing = "Connected"
			_append_chronicle("You join a merchant household and learn weights, prices, and negotiation.\nOccupation: Merchant Apprentice • +5 Wealth • Connected standing")
		"martial":
			apprenticeship = "Martial Apprentice"
			health = mini(health + 3, 100)
			standing = "Disciplined"
			_append_chronicle("You begin disciplined training in weapons, riding, and service.\nOccupation: Martial Apprentice • +3 Health • Disciplined standing")
	apprenticeship_panel.hide()
	advance_button.disabled = false
	occupation_value.text = _starting_occupation()
	_refresh_stats()
	_sync_character_state()


func _load_character_state() -> void:
	if not WorldState.has_player():
		WorldState.create_player({})
	var state: PlayerCharacter = WorldState.player
	character_name = state.full_name
	character_age = state.age
	character_sex = state.sex
	homeland = state.homeland
	birthplace = state.birthplace
	family_origin = state.family_origin
	father_name = state.father_name
	mother_name = state.mother_name
	culture = state.culture
	faith = state.faith
	birth_season = state.birth_season
	appearance_seed = state.appearance_seed
	health = state.health
	wealth = state.wealth
	standing = state.standing
	upbringing = state.upbringing
	primary_trait = state.primary_trait
	apprenticeship = state.apprenticeship


func _sync_character_state() -> void:
	if not WorldState.has_player():
		return
	var state: PlayerCharacter = WorldState.player
	state.age = character_age
	state.health = health
	state.wealth = wealth
	state.standing = standing
	state.upbringing = upbringing
	state.primary_trait = primary_trait
	state.apprenticeship = apprenticeship
	SaveManager.save_game()


func _restore_pending_milestone() -> void:
	if character_age == 5 and upbringing == "Undetermined":
		upbringing_panel.show()
		advance_button.disabled = true
	elif character_age == 6 and "lost_purse" not in WorldState.player.completed_events:
		_show_decision("lost_purse", "A LOST PURSE", "A merchant's purse lies unattended beside the market road. What will you do?", "RETURN IT TO THE MERCHANT", "BRING IT HOME")
	elif character_age == 8 and "childhood_fever" not in WorldState.player.completed_events:
		_show_decision("childhood_fever", "A SUDDEN FEVER", "Your family urges you to rest, but household work remains unfinished.", "REST AND RECOVER", "KEEP HELPING")
	elif character_age == 10 and "mentors_offer" not in WorldState.player.completed_events:
		_show_decision("mentors_offer", "A MENTOR'S OFFER", "Learning from the elder will cost the household your daily help. What matters most?", "ACCEPT THE GUIDANCE", "REMAIN WITH YOUR FAMILY")
	elif character_age == 12 and apprenticeship == "None":
		apprenticeship_panel.show()
		advance_button.disabled = true


func _open_pause_menu() -> void:
	SaveManager.save_game()
	pause_overlay.show()
	get_tree().paused = true


func _resume_game() -> void:
	get_tree().paused = false
	pause_overlay.hide()


func _save_and_return_to_menu() -> void:
	SaveManager.save_game()
	get_tree().paused = false
	MusicManager.stop_music()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


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
