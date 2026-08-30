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
@onready var character_button: Button = %Character
@onready var character_overlay: Control = %CharacterOverlay
@onready var character_details_value: Label = %CharacterDetailsValue
@onready var close_character_button: Button = %CloseCharacterButton
@onready var world_button: Button = %World
@onready var world_overlay: Control = %WorldOverlay
@onready var world_realm_value: Label = %WorldRealmValue
@onready var world_province_value: Label = %WorldProvinceValue
@onready var world_settlement_value: Label = %WorldSettlementValue
@onready var world_population_value: Label = %WorldPopulationValue
@onready var world_prosperity_value: Label = %WorldProsperityValue
@onready var world_residents_value: Label = %WorldResidentsValue
@onready var world_reports_value: Label = %WorldReportsValue
@onready var world_nearby_value: Label = %WorldNearbyValue
@onready var world_action_message: Label = %WorldActionMessage
@onready var visit_family_button: Button = %VisitFamilyButton
@onready var help_trader_button: Button = %HelpTraderButton
@onready var close_world_button: Button = %CloseWorldButton
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
	character_button.pressed.connect(_open_character)
	close_character_button.pressed.connect(func(): character_overlay.hide())
	world_button.pressed.connect(_open_world)
	visit_family_button.pressed.connect(_perform_local_action.bind("family"))
	help_trader_button.pressed.connect(_perform_local_action.bind("trader"))
	close_world_button.pressed.connect(func(): world_overlay.hide())
	resume_button.pressed.connect(_resume_game)
	main_menu_button.pressed.connect(_save_and_return_to_menu)
	_restore_pending_milestone()
	SaveManager.save_game()
	resized.connect(_apply_layout)
	_apply_layout()


func _advance_year() -> void:
	TimeManager.advance_year()
	character_age += 1
	var local_news := WorldState.advance_local_year(TimeManager.current_date.year)
	_sync_character_state()
	_refresh_character_display()
	occupation_value.text = _starting_occupation()
	for news in local_news:
		_append_chronicle("Local news, %s\n%s" % [TimeManager.year_label(), news])
	if character_age == 5:
		_append_chronicle("Age 5, %s\nYour early upbringing can now be chosen." % TimeManager.year_label())
		upbringing_panel.show()
		advance_button.disabled = true
	elif character_age == 12:
		_append_chronicle("Age 12, %s\nChildhood gives way to responsibility. Your household must decide how you will be trained." % TimeManager.year_label())
		apprenticeship_panel.show()
		advance_button.disabled = true
	else:
		var event := EventResolver.event_for_age(character_age, WorldState.player.completed_events)
		if event.is_empty():
			_append_chronicle("Age %d, %s\nAnother year of childhood passes." % [character_age, TimeManager.year_label()])
		else:
			_append_chronicle("Age %d, %s\n%s" % [character_age, TimeManager.year_label(), event.intro])
			_show_decision(event)


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


func _show_decision(event: Dictionary) -> void:
	pending_event = str(event.id)
	%DecisionTitle.text = str(event.title)
	%DecisionDescription.text = str(event.description)
	return_purse_button.text = str(event.choices[0].text)
	keep_purse_button.text = str(event.choices[1].text)
	decision_panel.show()
	advance_button.disabled = true


func _resolve_decision(choice: int) -> void:
	decision_panel.hide()
	advance_button.disabled = false
	var event := EventResolver.event_by_id(pending_event)
	if event.is_empty():
		pending_event = ""
		return
	var selected_choice: Dictionary = event.choices[choice]
	var effects: Dictionary = selected_choice.get("effects", {})
	health = clampi(health + int(effects.get("health", 0)), 0, 100)
	wealth = maxi(wealth + int(effects.get("wealth", 0)), 0)
	if effects.has("standing"):
		standing = str(effects.standing)
	if effects.has("trait"):
		primary_trait = str(effects.trait)
	_append_chronicle("%s\n%s" % [selected_choice.result, selected_choice.summary])
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
	elif character_age == 12 and apprenticeship == "None":
		apprenticeship_panel.show()
		advance_button.disabled = true
	else:
		var event := EventResolver.event_for_age(character_age, WorldState.player.completed_events)
		if not event.is_empty():
			_show_decision(event)


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


func _open_world() -> void:
	var context := WorldState.get_home_context()
	if context.is_empty():
		return
	world_realm_value.text = context.kingdom
	world_province_value.text = context.province
	world_settlement_value.text = "%s  •  %s" % [context.settlement, context.type]
	world_population_value.text = str(context.population)
	world_prosperity_value.text = "%d / 100" % context.prosperity
	world_residents_value.text = "\n".join(context.residents)
	world_reports_value.text = "No major developments yet." if context.reports.is_empty() else "\n".join(context.reports)
	world_nearby_value.text = "\n".join(context.nearby_places)
	world_action_message.text = "You may spend time on each local activity once per year."
	visit_family_button.disabled = int(WorldState.player.local_action_years.get("family", 0)) == TimeManager.current_date.year
	help_trader_button.disabled = int(WorldState.player.local_action_years.get("trader", 0)) == TimeManager.current_date.year
	world_overlay.show()


func _open_character() -> void:
	var context := WorldState.get_character_context()
	character_details_value.text = "LINEAGE\n%s\n\nDYNASTY\n%s  •  PRESTIGE %d\n\nPARENTS\n%s\n%s\n\nCULTURE\n%s\n\nFAITH\n%s\n\nBORN\n%s  •  %s" % [context.lineage, context.dynasty, context.prestige, context.father, context.mother, context.culture, context.faith, context.birth_season, context.family_origin]
	character_overlay.show()


func _perform_local_action(action_id: String) -> void:
	var result := WorldState.perform_local_action(action_id, TimeManager.current_date.year)
	if result.has("unavailable"):
		world_action_message.text = result.unavailable
		return
	if result.is_empty():
		world_action_message.text = "You have already done this activity this year."
		return
	health = clampi(health + int(result.get("health", 0)), 0, 100)
	wealth = maxi(wealth + int(result.get("wealth", 0)), 0)
	_append_chronicle("Age %d, %s\n%s" % [character_age, TimeManager.year_label(), result.chronicle])
	_refresh_stats()
	_sync_character_state()
	_open_world()
	world_action_message.text = "Activity completed and recorded in your chronicle."


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
