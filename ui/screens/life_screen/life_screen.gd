class_name LifeScreen
extends Control

const BACKGROUND_ART_PATH := "res://art/backgrounds/main_menu_panel_v1.png"
const MAIN_MENU_SCENE := "res://ui/screens/main_menu/main_menu.tscn"
const TOUCH_PRESS_SCALE := Vector2(0.98, 0.98)
const TOUCH_PRESS_TINT := Color(1.08, 1.04, 0.92, 1.0)
const TOUCH_PRESS_DURATION := 0.09
const TOUCH_RELEASE_DURATION := 0.13
const HOMELAND_ART := {
	"RASHIDUN CALIPHATE": "res://art/locations/medina_632_life_v1.png",
	"BYZANTINE EMPIRE": "res://art/locations/byzantine_632_life_v1.png",
	"SASANIAN EMPIRE": "res://art/locations/sasanian_632_life_v1.png",
}
const HOMELAND_MAP := {
	"RASHIDUN CALIPHATE": "res://art/maps/arabia_632_life_map_v1.png",
	"BYZANTINE EMPIRE": "res://art/locations/byzantine_632_life_v1.png",
	"SASANIAN EMPIRE": "res://art/locations/sasanian_632_life_v1.png",
}
const HOMELAND_REGION := {
	"RASHIDUN CALIPHATE": "ARABIA",
	"BYZANTINE EMPIRE": "EASTERN ROMAN REALM",
	"SASANIAN EMPIRE": "PERSIAN REALM",
}
const MAP_MARKER_POSITION := {
	"Medina": Vector2(0.38, 0.4),
	"Mecca": Vector2(0.35, 0.52),
	"Constantinople": Vector2(0.12, 0.24),
	"Antioch": Vector2(0.25, 0.34),
	"Alexandria": Vector2(0.14, 0.46),
	"Ctesiphon": Vector2(0.67, 0.37),
	"Merv": Vector2(0.82, 0.28),
}

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
var occupation_id := ""
var occupation_experience := 0
var trade_reputation := 0
var pending_event := ""
var pending_recruitment: Dictionary = {}
var battle_beat_index := 0
var battle_morale := 0.0
var battle_rival_name := ""
var battle_log: Array[String] = []
var battle_beats: Array[Dictionary] = []
var button_tweens: Dictionary = {}
var landscape_main: HBoxContainer
var landscape_left: VBoxContainer
var landscape_world: VBoxContainer
var landscape_bottom: HBoxContainer
var landscape_events: VBoxContainer
var landscape_time: HBoxContainer
var season_label: Label
var next_year_label: Label

@onready var background: TextureRect = %Background
@onready var era_label: Label = %Era
@onready var header_date_label: Label = %HeaderDate
@onready var header_age_value: Label = %HeaderAgeValue
@onready var header_health_value: Label = %HeaderHealthValue
@onready var header_wealth_value: Label = %HeaderWealthValue
@onready var header_standing_value: Label = %HeaderStandingValue
@onready var header_trait_value: Label = %HeaderTraitValue
@onready var safe_area: MarginContainer = %SafeArea
@onready var composition: VBoxContainer = %Composition
@onready var divider_top: Control = $SafeArea/Center/Composition/DividerTop
@onready var character_panel: PanelContainer = $SafeArea/Center/Composition/CharacterPanel
@onready var portrait: CharacterPortrait = %Portrait
@onready var character_backdrop: TextureRect = %CharacterBackdrop
@onready var name_label: Label = %NameLabel
@onready var identity_label: Label = %IdentityLabel
@onready var homeland_label: Label = %HomelandLabel
@onready var birthplace_label: Label = %BirthplaceLabel
@onready var location_art: TextureRect = %Art
@onready var location_caption: Label = %Caption
@onready var map_realm_title: Label = %MapRealmTitle
@onready var map_context_title: Label = %MapContextTitle
@onready var player_map_marker: Label = %PlayerMapMarker
@onready var location_panel: PanelContainer = $SafeArea/Center/Composition/LocationPanel
@onready var age_value: Label = %AgeValue
@onready var health_value: Label = %HealthValue
@onready var health_bar: StatBar = %HealthBar
@onready var wealth_value: Label = %WealthValue
@onready var standing_value: Label = %StandingValue
@onready var trait_value: Label = %TraitValue
@onready var occupation_value: Label = %OccupationValue
@onready var stats_panel: PanelContainer = $SafeArea/Center/Composition/StatsPanel
@onready var chronicle_title: Label = $SafeArea/Center/Composition/ChronicleTitle
@onready var chronicle_panel: PanelContainer = $SafeArea/Center/Composition/ChroniclePanel
@onready var event_placeholder: RichTextLabel = %EventPlaceholder
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
@onready var decision_overlay: Control = %DecisionOverlay
@onready var decision_art: TextureRect = %DecisionArt
@onready var return_purse_button: Button = %ReturnPurseButton
@onready var keep_purse_button: Button = %KeepPurseButton
@onready var apprenticeship_panel: PanelContainer = %ApprenticeshipPanel
@onready var apprenticeship_buttons: Array[Button] = [
	%CraftApprenticeshipButton,
	%ScholarlyApprenticeshipButton,
	%TradeApprenticeshipButton,
	%MartialApprenticeshipButton,
]
@onready var occupation_panel: PanelContainer = %OccupationPanel
@onready var occupation_buttons: Array[Button] = [
	%FarmerOccupationButton,
	%ArtisanOccupationButton,
	%TraderOccupationButton,
	%SoldierOccupationButton,
	%ScholarOccupationButton,
]
@onready var more_button: Button = %More
@onready var character_button: Button = %Character
@onready var character_overlay: Control = %CharacterOverlay
@onready var character_scroll: ScrollContainer = $CharacterOverlay/Center
@onready var character_overlay_portrait: CharacterPortrait = %CharacterOverlayPortrait
@onready var character_summary_value: Label = %CharacterSummaryValue
@onready var character_status_value: Label = %CharacterStatusValue
@onready var character_details_value: Label = %CharacterDetailsValue
@onready var character_development_value: Label = %CharacterDevelopmentValue
@onready var close_character_button: Button = %CloseCharacterButton
@onready var activities_button: Button = %Activities
@onready var activities_overlay: Control = %ActivitiesOverlay
@onready var activities_scroll: ScrollContainer = $ActivitiesOverlay/Center
@onready var activity_context: Label = %ActivityContext
@onready var activity_occupation_title: Label = %ActivityOccupationTitle
@onready var activity_occupation_description: Label = %ActivityOccupationDescription
@onready var activity_occupation_progress: StatBar = %ActivityOccupationProgress
@onready var activity_occupation_progress_text: Label = %ActivityOccupationProgressText
@onready var market_summary: Label = %MarketSummary
@onready var upgrade_label: Label = %UpgradeLabel
@onready var upgrade_button: Button = %UpgradeButton
@onready var regional_prices: Label = %RegionalPrices
@onready var market_rows: VBoxContainer = %MarketRows
@onready var market_message: Label = %MarketMessage
@onready var close_activities_button: Button = %CloseActivitiesButton
@onready var world_button: Button = %World
@onready var world_overlay: Control = %WorldOverlay
@onready var world_scroll: ScrollContainer = $WorldOverlay/Center
@onready var world_realm_value: Label = %WorldRealmValue
@onready var world_province_value: Label = %WorldProvinceValue
@onready var world_settlement_value: Label = %WorldSettlementValue
@onready var world_population_value: Label = %WorldPopulationValue
@onready var world_prosperity_value: Label = %WorldProsperityValue
@onready var world_residents_value: Label = %WorldResidentsValue
@onready var world_reports_value: Label = %WorldReportsValue
@onready var travel_rows: VBoxContainer = %TravelRows
@onready var travel_message: Label = %TravelMessage
@onready var world_market_value: Label = %WorldMarketValue
@onready var world_action_message: Label = %WorldActionMessage
@onready var world_date: Label = %WorldDate
@onready var world_map_location: Label = %WorldMapLocation
@onready var realm_tint: ColorRect = %RealmTint
@onready var visit_family_button: Button = %VisitFamilyButton
@onready var help_trader_button: Button = %HelpTraderButton
@onready var close_world_button: Button = %CloseWorldButton
@onready var pause_overlay: Control = %PauseOverlay
@onready var resume_button: Button = %ResumeButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var death_overlay: Control = %DeathOverlay
@onready var death_scroll: ScrollContainer = $DeathOverlay/Center
@onready var death_epitaph_value: Label = %DeathEpitaphValue
@onready var death_summary_value: Label = %DeathSummaryValue
@onready var return_to_menu_button: Button = %ReturnToMenuButton
@onready var recruitment_panel: PanelContainer = %RecruitmentPanel
@onready var recruitment_title: Label = %RecruitmentTitle
@onready var recruitment_description: Label = %RecruitmentDescription
@onready var join_levy_button: Button = %JoinLevyButton
@onready var decline_levy_button: Button = %DeclineLevyButton
@onready var battle_overlay: Control = %BattleOverlay
@onready var battle_scroll: ScrollContainer = $BattleOverlay/Center
@onready var battle_title_value: Label = %BattleTitleValue
@onready var battle_time_value: Label = %BattleTimeValue
@onready var battle_narration_value: Label = %BattleNarrationValue
@onready var battle_art: TextureRect = %BattleArt
@onready var battle_player_force: Label = %BattlePlayerForce
@onready var battle_enemy_force: Label = %BattleEnemyForce
@onready var battle_health_value: Label = %BattleHealthValue
@onready var battle_morale_value: Label = %BattleMoraleValue
@onready var battle_progress: StatBar = %BattleProgress
@onready var battle_log_value: Label = %BattleLogValue
@onready var battle_choice_a_button: Button = %BattleChoiceAButton
@onready var battle_choice_b_button: Button = %BattleChoiceBButton


func _ready() -> void:
	if not _ensure_character_state():
		return
	_load_character_state()
	_style_decision_panel()
	_setup_background()
	_setup_location_banner()
	_refresh_character_display()
	_refresh_stats()
	homeland_label.text = homeland
	occupation_value.text = _starting_occupation()
	portrait.female = character_sex == "FEMALE"
	portrait.variant_seed = appearance_seed
	if WorldState.player.chronicle.is_empty():
		WorldState.player.chronicle.append("Age 1, %s\nYou begin life in %s." % [TimeManager.year_label(), birthplace])
	var chronicle_blocks: Array[String] = []
	for entry in WorldState.player.chronicle:
		chronicle_blocks.append(_chronicle_bbcode(entry))
	event_placeholder.text = "\n\n".join(chronicle_blocks)
	advance_button.disabled = false
	advance_button.text = "AGE UP"
	advance_button.pressed.connect(_advance_year)
	_style_age_button()
	for button in upbringing_buttons:
		button.pressed.connect(_choose_upbringing.bind(button))
	return_purse_button.pressed.connect(_resolve_decision.bind(0))
	keep_purse_button.pressed.connect(_resolve_decision.bind(1))
	for button in apprenticeship_buttons:
		button.pressed.connect(_choose_apprenticeship.bind(button))
	for button in occupation_buttons:
		button.pressed.connect(_choose_occupation.bind(button))
	more_button.pressed.connect(_open_pause_menu)
	character_button.pressed.connect(_open_character)
	close_character_button.pressed.connect(func(): character_overlay.hide())
	activities_button.pressed.connect(_open_activities)
	close_activities_button.pressed.connect(func(): activities_overlay.hide())
	upgrade_button.pressed.connect(_attempt_upgrade_tier)
	world_button.pressed.connect(_open_world)
	visit_family_button.pressed.connect(_perform_local_action.bind("family"))
	help_trader_button.pressed.connect(_perform_local_action.bind("trader"))
	close_world_button.pressed.connect(func(): world_overlay.hide())
	resume_button.pressed.connect(_resume_game)
	main_menu_button.pressed.connect(_save_and_return_to_menu)
	return_to_menu_button.pressed.connect(_return_after_death)
	join_levy_button.pressed.connect(_resolve_recruitment.bind(true))
	decline_levy_button.pressed.connect(_resolve_recruitment.bind(false))
	battle_choice_a_button.pressed.connect(_resolve_battle_choice.bind(0))
	battle_choice_b_button.pressed.connect(_resolve_battle_choice.bind(1))
	_restore_pending_milestone()
	SaveManager.save_game()
	resized.connect(_apply_layout)
	location_panel.resized.connect(_position_map_marker)
	event_placeholder.resized.connect(_scroll_chronicle_to_bottom)
	_apply_layout()
	_position_map_marker.call_deferred()
	_bind_button_feedback.call_deferred()
	_scroll_chronicle_to_bottom.call_deferred()


func _build_landscape_layout() -> void:
	landscape_main = HBoxContainer.new()
	landscape_main.name = "LandscapeMain"
	landscape_main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	landscape_main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	landscape_main.add_theme_constant_override("separation", 18)

	landscape_left = VBoxContainer.new()
	landscape_left.name = "CharacterColumn"
	landscape_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	landscape_left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	landscape_left.size_flags_stretch_ratio = 0.25
	landscape_left.add_theme_constant_override("separation", 10)

	landscape_world = VBoxContainer.new()
	landscape_world.name = "WorldColumn"
	landscape_world.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	landscape_world.size_flags_vertical = Control.SIZE_EXPAND_FILL
	landscape_world.size_flags_stretch_ratio = 0.75
	landscape_world.add_theme_constant_override("separation", 8)

	composition.add_child(landscape_main)
	composition.move_child(landscape_main, divider_top.get_index() + 1)
	landscape_main.add_child(landscape_left)
	landscape_main.add_child(landscape_world)
	character_panel.reparent(landscape_left)
	stats_panel.reparent(landscape_left)
	location_panel.reparent(landscape_world)

	landscape_bottom = HBoxContainer.new()
	landscape_bottom.name = "GameplayStrip"
	landscape_bottom.custom_minimum_size.y = 158
	landscape_bottom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	landscape_bottom.add_theme_constant_override("separation", 18)
	composition.add_child(landscape_bottom)
	composition.move_child(landscape_bottom, landscape_main.get_index() + 1)

	landscape_events = VBoxContainer.new()
	landscape_events.name = "RecentEvents"
	landscape_events.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	landscape_events.size_flags_vertical = Control.SIZE_EXPAND_FILL
	landscape_events.size_flags_stretch_ratio = 0.72
	landscape_events.add_theme_constant_override("separation", 4)
	landscape_bottom.add_child(landscape_events)
	chronicle_title.reparent(landscape_events)
	chronicle_panel.reparent(landscape_events)
	chronicle_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	landscape_time = HBoxContainer.new()
	landscape_time.name = "TimeControls"
	landscape_time.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	landscape_time.size_flags_vertical = Control.SIZE_EXPAND_FILL
	landscape_time.size_flags_stretch_ratio = 0.28
	landscape_time.add_theme_constant_override("separation", 12)
	landscape_bottom.add_child(landscape_time)
	advance_button.reparent(landscape_time)
	advance_button.text = "⌛\nAGE UP"
	advance_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	advance_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_style_age_button()

	var time_panel := PanelContainer.new()
	time_panel.name = "DatePanel"
	time_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	time_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	landscape_time.add_child(time_panel)
	var time_margin := MarginContainer.new()
	time_margin.add_theme_constant_override("margin_left", 16)
	time_margin.add_theme_constant_override("margin_top", 12)
	time_margin.add_theme_constant_override("margin_right", 16)
	time_margin.add_theme_constant_override("margin_bottom", 12)
	time_panel.add_child(time_margin)
	var date_column := VBoxContainer.new()
	date_column.alignment = BoxContainer.ALIGNMENT_CENTER
	date_column.add_theme_constant_override("separation", 10)
	time_margin.add_child(date_column)
	season_label = Label.new()
	season_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	season_label.add_theme_color_override("font_color", Color(0.72, 0.62, 0.42))
	season_label.add_theme_font_size_override("font_size", 18)
	date_column.add_child(season_label)
	next_year_label = Label.new()
	next_year_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	next_year_label.add_theme_color_override("font_color", Color(0.92, 0.78, 0.48))
	next_year_label.add_theme_font_size_override("font_size", 22)
	date_column.add_child(next_year_label)
	_refresh_time_panel()


func _style_age_button() -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.58, 0.4, 0.14, 1.0)
	normal.border_color = Color(0.92, 0.72, 0.32, 1.0)
	normal.set_border_width_all(3)
	normal.set_corner_radius_all(70)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.68, 0.49, 0.2, 1.0)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.45, 0.29, 0.1, 1.0)
	advance_button.add_theme_stylebox_override("normal", normal)
	advance_button.add_theme_stylebox_override("hover", hover)
	advance_button.add_theme_stylebox_override("pressed", pressed)
	advance_button.add_theme_stylebox_override("focus", hover)
	advance_button.add_theme_color_override("font_color", Color(0.96, 0.84, 0.58))
	advance_button.add_theme_font_size_override("font_size", 22)


func _style_decision_panel() -> void:
	var parchment := StyleBoxFlat.new()
	parchment.bg_color = Color(0.72, 0.63, 0.47, 0.98)
	parchment.border_color = Color(0.25, 0.16, 0.07, 1.0)
	parchment.set_border_width_all(4)
	parchment.set_corner_radius_all(6)
	parchment.shadow_color = Color(0.0, 0.0, 0.0, 0.72)
	parchment.shadow_size = 14
	decision_panel.add_theme_stylebox_override("panel", parchment)
	var ink := Color(0.16, 0.09, 0.035, 1.0)
	%DecisionTitle.add_theme_color_override("font_color", ink)
	%DecisionDescription.add_theme_color_override("font_color", ink)
	$DecisionOverlay/Center/DecisionPanel/Margin/Content/ChoicePrompt.add_theme_color_override("font_color", Color(0.28, 0.17, 0.07, 1.0))
	$DecisionOverlay/Center/DecisionPanel/Margin/Content/Eyebrow.add_theme_color_override("font_color", Color(0.34, 0.22, 0.1, 1.0))


func _refresh_time_panel() -> void:
	if season_label == null or next_year_label == null:
		return
	season_label.text = "%s\nCURRENT YEAR  •  %s" % [_season_name(TimeManager.current_date.month), TimeManager.year_label()]
	next_year_label.text = "NEXT YEAR\n%d AD" % (TimeManager.current_date.year + 1)


func _season_name(month: int) -> String:
	if month in [3, 4, 5]:
		return "SPRING"
	if month in [6, 7, 8]:
		return "SUMMER"
	if month in [9, 10, 11]:
		return "AUTUMN"
	return "WINTER"


func _advance_year() -> void:
	TimeManager.advance_year()
	character_age += 1
	WorldState.advance_local_year(TimeManager.current_date.year)
	_sync_character_state()
	_refresh_character_display()
	occupation_value.text = _starting_occupation()
	_apply_annual_income()
	if _roll_for_death():
		_handle_death()
		return
	_append_chronicle("Age %d, %s\nAnother year passes." % [character_age, TimeManager.year_label()])


func _refresh_character_display() -> void:
	name_label.text = character_name
	identity_label.text = "%s  •  AGE %d" % [character_sex.capitalize(), character_age]
	era_label.text = TimeManager.year_label()
	header_date_label.text = TimeManager.date_label()
	birthplace_label.text = "%s  •  %s" % [birthplace, TimeManager.year_label()]
	age_value.text = str(character_age)
	header_age_value.text = str(character_age)
	activities_button.disabled = character_age < 16
	map_context_title.text = "%s  •  %s" % [str(HOMELAND_REGION.get(homeland, "YOUR HOMELAND")), TimeManager.year_label()]
	_refresh_time_panel()


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
	health_bar.ratio = health / 100.0
	wealth_value.text = str(wealth)
	standing_value.text = standing
	trait_value.text = primary_trait
	header_health_value.text = "%d%%" % health
	header_wealth_value.text = str(wealth)
	header_standing_value.text = standing
	header_trait_value.text = primary_trait


func _show_decision(event: Dictionary) -> void:
	pending_event = str(event.id)
	%DecisionTitle.text = str(event.title)
	%DecisionDescription.text = str(event.description)
	return_purse_button.text = str(event.choices[0].text)
	keep_purse_button.text = str(event.choices[1].text)
	decision_art.texture = character_backdrop.texture
	_reveal_overlay(decision_overlay)
	advance_button.disabled = true


func _resolve_decision(choice: int) -> void:
	decision_overlay.hide()
	advance_button.disabled = false
	var event := EventResolver.event_by_id(pending_event)
	if event.is_empty():
		pending_event = ""
		return
	var selected_choice: Dictionary = event.choices[choice]
	_apply_event_effects(selected_choice.get("effects", {}))
	_append_chronicle("%s\n%s" % [selected_choice.result, selected_choice.summary])
	if WorldState.has_player() and pending_event not in WorldState.player.completed_events:
		WorldState.player.completed_events.append(pending_event)
	pending_event = ""
	_refresh_stats()
	_sync_character_state()


func _apply_event_effects(effects: Dictionary) -> void:
	health = clampi(health + int(effects.get("health", 0)), 0, 100)
	wealth = maxi(wealth + int(effects.get("wealth", 0)), 0)
	if effects.has("standing"):
		standing = str(effects.standing)
	if effects.has("trait"):
		primary_trait = str(effects.trait)


func _show_recruitment_call(context: Dictionary) -> void:
	pending_recruitment = context
	var event := WarEventData.recruitment_call(str(context.get("rival_name", "the enemy")), bool(context.get("is_soldier", false)))
	recruitment_title.text = str(event.title)
	recruitment_description.text = str(event.description)
	join_levy_button.text = str(event.choices[0].text)
	decline_levy_button.text = str(event.choices[1].text)
	recruitment_panel.show()
	advance_button.disabled = true


func _resolve_recruitment(join: bool) -> void:
	recruitment_panel.hide()
	var rival_name := str(pending_recruitment.get("rival_name", "the enemy"))
	var is_soldier := bool(pending_recruitment.get("is_soldier", false))
	var event := WarEventData.recruitment_call(rival_name, is_soldier)
	pending_recruitment = {}
	if join:
		var choice: Dictionary = event.choices[0]
		_apply_event_effects(choice.get("effects", {}))
		_append_chronicle("%s\n%s" % [choice.result, "You march to join the levy against the %s." % rival_name])
		WorldState.player.in_army = true
		_refresh_stats()
		_sync_character_state()
		_begin_battle(rival_name)
	else:
		var choice: Dictionary = event.choices[1]
		_apply_event_effects(choice.get("effects", {}))
		_append_chronicle(choice.result)
		advance_button.disabled = false
		_refresh_stats()
		_sync_character_state()


func _begin_battle(rival_name: String) -> void:
	battle_beat_index = 0
	battle_morale = 0.0
	battle_rival_name = rival_name
	battle_log.clear()
	battle_beats = BattleEventData.generate_battle(rival_name)
	var army := WorldState.get_player_army()
	if army != null:
		battle_log.append(_army_flavor_text(army))
		battle_player_force.text = "YOUR ARMY\n%d MEN  •  %d%% MORALE" % [army.strength, roundi(army.morale)]
	else:
		battle_player_force.text = "YOUR ARMY\nLEVY FORCE"
	battle_enemy_force.text = "%s\nENEMY HOST" % rival_name.to_upper()
	battle_art.texture = location_art.texture
	battle_title_value.text = "BATTLE AGAINST THE %s" % rival_name.to_upper()
	_reveal_overlay(battle_overlay)
	battle_scroll.set_deferred("scroll_vertical", 0)
	advance_button.disabled = true
	_show_battle_beat()


func _army_flavor_text(army: Army) -> String:
	if army.strength >= 115 and army.morale >= 70.0:
		return "Your army musters strong and confident before the battle."
	if army.strength <= 90 or army.morale <= 60.0:
		return "Your army is thin and spirits are low as the battle begins."
	return "Your army takes its position, neither confident nor afraid."


func _show_battle_beat() -> void:
	var beat: Dictionary = battle_beats[battle_beat_index]
	battle_time_value.text = str(beat.time)
	battle_narration_value.text = str(beat.narration)
	battle_choice_a_button.text = str(beat.choices[0].text)
	battle_choice_b_button.text = str(beat.choices[1].text)
	battle_health_value.text = "♥ HEALTH  %d%%" % health
	battle_morale_value.text = "⚑ MORALE  %s" % ("RISING" if battle_morale > 0.0 else ("FALLING" if battle_morale < 0.0 else "STEADY"))
	battle_progress.ratio = float(battle_beat_index) / float(maxi(battle_beats.size(), 1))
	battle_log_value.text = "The armies take their positions." if battle_log.is_empty() else battle_log[-1]


func _resolve_battle_choice(choice_index: int) -> void:
	var beat: Dictionary = battle_beats[battle_beat_index]
	var choice: Dictionary = beat.choices[choice_index]
	var effects: Dictionary = choice.get("effects", {})
	health = clampi(health + int(effects.get("health", 0)), 0, 100)
	battle_morale += float(effects.get("morale", 0))
	battle_log.append("%s — %s" % [str(beat.time), str(choice.result)])
	_refresh_stats()
	battle_beat_index += 1
	if battle_beat_index < battle_beats.size():
		_show_battle_beat()
	else:
		_resolve_battle_outcome()


func _resolve_battle_outcome() -> void:
	var outcome := WarSim.resolve_battle_outcome(health, battle_morale)
	wealth += int(outcome.get("wealth", 0))
	if outcome.has("health_floor"):
		health = maxi(health, int(outcome.health_floor))
	if outcome.has("standing"):
		standing = str(outcome.standing)
	WorldState.player.in_army = false
	WorldState.player.has_fought = true
	battle_log.append(str(outcome.get("summary", "")))
	_append_chronicle("Battle against the %s, %s\n%s" % [battle_rival_name, TimeManager.year_label(), "\n".join(battle_log)])
	_refresh_stats()
	_sync_character_state()
	battle_overlay.hide()
	advance_button.disabled = false
	_sync_character_state()


func _append_chronicle(entry: String) -> void:
	event_placeholder.text += "\n\n" + _chronicle_bbcode(entry)
	if WorldState.has_player():
		WorldState.player.chronicle.append(entry)
		SaveManager.save_game()
	_scroll_chronicle_to_bottom.call_deferred()


func _chronicle_bbcode(entry: String) -> String:
	var color := "ded3c2"
	if entry.findn("battle") != -1 or entry.findn("wounded") != -1 or entry.findn("rob") != -1 or entry.findn("attack") != -1 or entry.findn("has died") != -1:
		color = "d1524a"
	elif entry.findn("married") != -1 or entry.findn("welcomed a child") != -1 or entry.findn("younger sibling") != -1:
		color = "8cbf66"
	elif entry.findn("journey to") != -1 or entry.findn("arrive in") != -1 or entry.findn("road") != -1:
		color = "6fa8c9"
	elif entry.findn("bought") != -1 or entry.findn("sold") != -1 or entry.findn("trade standing") != -1 or entry.findn("wage") != -1 or entry.findn("earns") != -1:
		color = "e0c26e"
	return "[center][color=#%s]%s[/color][/center]" % [color, entry]


var _chronicle_scroll_pending := false


func _scroll_chronicle_to_bottom() -> void:
	if _chronicle_scroll_pending:
		return
	_chronicle_scroll_pending = true
	var last_max := -1
	var stable_frames := 0
	var safety := 0
	while stable_frames < 3 and safety < 30:
		await get_tree().process_frame
		var current_max := int(chronicle_scroll.get_v_scroll_bar().max_value)
		if current_max == last_max:
			stable_frames += 1
		else:
			stable_frames = 0
			last_max = current_max
		safety += 1
	chronicle_scroll.scroll_vertical = last_max
	_chronicle_scroll_pending = false


func _starting_occupation() -> String:
	if occupation_id != "":
		var occupation := OccupationData.get_occupation(occupation_id)
		return occupation.get("name", "Worker")
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


func _choose_occupation(button: Button) -> void:
	occupation_id = str(button.get_meta("occupation_id", ""))
	occupation_experience = 0
	var occupation := OccupationData.get_occupation(occupation_id)
	if occupation.is_empty():
		return
	standing = occupation.standing
	occupation_panel.hide()
	advance_button.disabled = false
	occupation_value.text = occupation.name
	_refresh_stats()
	_append_chronicle("You begin work as a %s.\n%s • Annual wage: %d Wealth" % [occupation.name, occupation.description, occupation.annual_wage])
	_sync_character_state()


func _apply_annual_income() -> void:
	if occupation_id == "":
		return
	var occupation := OccupationData.get_occupation(occupation_id)
	if occupation.is_empty():
		return
	occupation_experience += 1
	var rank := OccupationData.rank_for_experience(occupation_experience)
	var wage := int(occupation.annual_wage) + int(rank.wage_bonus)
	wealth += wage
	_refresh_stats()
	_sync_character_state()
	_append_chronicle("Work, %s\nYour year as a %s earns %d Wealth.\nExperience: %d • Rank: %s" % [TimeManager.year_label(), occupation.name, wage, occupation_experience, rank.name])


func _ensure_character_state() -> bool:
	if WorldState.has_player():
		return true
	if SaveManager.has_save() and SaveManager.load_game():
		return true
	push_warning("LifeScreen opened without a created or saved character; returning to the main menu.")
	get_tree().call_deferred("change_scene_to_file", MAIN_MENU_SCENE)
	return false


func _load_character_state() -> void:
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
	occupation_id = state.occupation_id
	occupation_experience = state.occupation_experience
	trade_reputation = state.trade_reputation


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
	state.occupation_id = occupation_id
	state.occupation_experience = occupation_experience
	state.trade_reputation = trade_reputation
	SaveManager.save_game()


func _restore_pending_milestone() -> void:
	pass


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


func _roll_for_death() -> bool:
	if health <= 0:
		return true
	var age_risk := 0.0
	if character_age >= 90: age_risk = 0.35
	elif character_age >= 80: age_risk = 0.18
	elif character_age >= 70: age_risk = 0.09
	elif character_age >= 60: age_risk = 0.04
	elif character_age >= 45: age_risk = 0.015
	var health_risk := 0.0
	if health <= 15: health_risk = 0.25
	elif health <= 30: health_risk = 0.08
	elif health <= 50: health_risk = 0.02
	return randf() < clampf(age_risk + health_risk, 0.0, 1.0)


func _handle_death() -> void:
	var cause := "declining health" if health <= 30 else "old age"
	var birth_year := TimeManager.current_date.year - character_age
	var death_line := "%s passed away of %s at age %d, in %s." % [character_name, cause, character_age, birthplace]
	_append_chronicle("Age %d, %s\n%s" % [character_age, TimeManager.year_label(), death_line])
	death_epitaph_value.text = "%s\n%d – %d AD" % [character_name, birth_year, TimeManager.current_date.year]
	death_summary_value.text = "%s\n\nAGE %d  •  %s\nWEALTH %d  •  %s" % [death_line, character_age, standing, wealth, _starting_occupation()]
	advance_button.disabled = true
	_reveal_overlay(death_overlay)


func _return_after_death() -> void:
	SaveManager.delete_save()
	get_tree().paused = false
	MusicManager.stop_music()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _open_world(reset_scroll := true) -> void:
	var context := WorldState.get_home_context()
	if context.is_empty():
		return
	world_realm_value.text = context.kingdom
	world_province_value.text = context.province
	world_settlement_value.text = "%s  •  %s" % [context.settlement, context.type]
	world_population_value.text = str(context.population)
	world_prosperity_value.text = "%d / 100" % context.prosperity
	world_date.text = "%s  •  YOUR REGION" % TimeManager.year_label()
	world_map_location.text = "●  %s\n%s  •  %s" % [str(context.settlement).to_upper(), str(context.kingdom).to_upper(), str(context.province).to_upper()]
	match homeland:
		"BYZANTINE EMPIRE":
			realm_tint.color = Color(0.35, 0.18, 0.42, 0.14)
		"SASANIAN EMPIRE":
			realm_tint.color = Color(0.2, 0.42, 0.24, 0.14)
		_:
			realm_tint.color = Color(0.56, 0.38, 0.12, 0.12)
	world_residents_value.text = "\n".join(context.residents)
	world_reports_value.text = "No major developments yet." if context.reports.is_empty() else "\n".join(context.reports)
	world_market_value.text = "\n".join(context.market)
	world_action_message.text = "You may spend time on each local activity once per year."
	visit_family_button.disabled = int(WorldState.player.local_action_years.get("family", 0)) == TimeManager.current_date.year
	help_trader_button.disabled = int(WorldState.player.local_action_years.get("trader", 0)) == TimeManager.current_date.year
	travel_message.text = ""
	_rebuild_travel_rows()
	_reveal_overlay(world_overlay)
	if reset_scroll:
		world_scroll.set_deferred("scroll_vertical", 0)


func _rebuild_travel_rows() -> void:
	for child in travel_rows.get_children():
		travel_rows.remove_child(child)
		child.queue_free()
	for settlement: Settlement in WorldState.settlements.values():
		if settlement.id == WorldState.player.location_id:
			continue
		var province: Province = WorldState.provinces.get(settlement.province_id)
		var days := TravelSim.days_to(settlement.id)
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 76
		row.add_theme_constant_override("separation", 8)
		var route_icon := Label.new()
		route_icon.custom_minimum_size.x = 48
		route_icon.text = "♞"
		route_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		route_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		route_icon.add_theme_color_override("font_color", Color(0.67, 0.55, 0.32))
		var details := Label.new()
		details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		details.autowrap_mode = TextServer.AUTOWRAP_WORD
		details.text = "%s  •  %s\nROUTE  •  ~%d DAYS" % [settlement.name, province.name if province else "Unknown", days]
		details.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var travel_button := Button.new()
		travel_button.text = "TRAVEL"
		travel_button.custom_minimum_size = Vector2(140, 68)
		_bind_tactile_button(travel_button)
		travel_button.pressed.connect(_begin_travel.bind(settlement.id))
		row.add_child(route_icon)
		row.add_child(details)
		row.add_child(travel_button)
		travel_rows.add_child(row)


func _begin_travel(destination_id: String) -> void:
	var result := TravelSim.begin_journey(destination_id)
	if not bool(result.get("ok", false)):
		travel_message.text = str(result.get("message", "You cannot travel there."))
		return
	var days := int(result.days)
	var journey_text := "\n".join(result.log as Array)
	_append_chronicle("Journey to %s, %s\n%d days on the road from %s.\n%s" % [result.destination, TimeManager.year_label(), days, result.origin, journey_text])
	health = WorldState.player.health
	wealth = WorldState.player.wealth
	_refresh_stats()
	_refresh_character_display()
	SaveManager.save_game()
	_open_world(false)
	travel_message.text = "You have arrived in %s." % result.destination


func _open_character() -> void:
	var context := WorldState.get_character_context()
	character_overlay_portrait.female = character_sex == "FEMALE"
	character_overlay_portrait.variant_seed = appearance_seed
	character_summary_value.text = "%s\n%s  •  AGE %d\n%s\n%s  •  %s" % [character_name, character_sex.capitalize(), character_age, homeland, birthplace, TimeManager.year_label()]
	character_status_value.text = "♥  HEALTH  %d%%    ◆  WEALTH  %d\n⚖  STANDING  %s\n✦  TRAIT  %s    ⚒  OCCUPATION  %s" % [health, wealth, standing, primary_trait, _starting_occupation()]
	character_details_value.text = "DYNASTY  •  %s  •  PRESTIGE %d\nLINEAGE  •  %s\n\nFATHER  •  %s\nMOTHER  •  %s\n\nCULTURE  •  %s    FAITH  •  %s\nBORN  •  %s  •  %s" % [context.dynasty, context.prestige, context.lineage, context.father, context.mother, context.culture, context.faith, context.birth_season, context.family_origin]
	character_development_value.text = "UPBRINGING  •  %s\nAPPRENTICESHIP  •  %s\nOCCUPATION EXPERIENCE  •  %d\nTRADE REPUTATION  •  %d" % [upbringing, apprenticeship, occupation_experience, trade_reputation]
	_reveal_overlay(character_overlay)
	character_scroll.set_deferred("scroll_vertical", 0)


func _open_activities() -> void:
	_refresh_activity_header()
	_rebuild_market_rows()
	market_message.text = "Buy locally now; future travel will let you seek better selling prices."
	_reveal_overlay(activities_overlay)
	activities_scroll.set_deferred("scroll_vertical", 0)


func _rebuild_market_rows() -> void:
	for child in market_rows.get_children():
		market_rows.remove_child(child)
		child.queue_free()
	var settlement: Settlement = WorldState.settlements.get(WorldState.player.location_id)
	if settlement == null:
		return
	var occupation := OccupationData.get_occupation(WorldState.player.occupation_id)
	var rank := OccupationData.rank_for_experience(WorldState.player.occupation_experience)
	var work_text := "No occupation" if occupation.is_empty() else "%s %s" % [rank.name, occupation.name]
	var tier: Dictionary = TradeTierData.get_tier(WorldState.player.trade_tier)
	market_summary.text = "%s MARKET\nWealth: %d  •  Cargo: %d / %d\nWork: %s  •  %s  •  Reputation: %d" % [settlement.name.to_upper(), WorldState.player.wealth, MarketService.inventory_count(), WorldState.player.cargo_capacity, work_text, tier.name, WorldState.player.trade_reputation]
	regional_prices.text = "\n".join(WorldState.get_regional_price_comparison())
	_refresh_upgrade_row()
	for good_id in GoodData.GOODS:
		var good := GoodData.get_good(good_id)
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 72
		row.add_theme_constant_override("separation", 8)
		var icon := Label.new()
		icon.custom_minimum_size.x = 48
		icon.text = _good_icon(good_id)
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		icon.add_theme_font_size_override("font_size", 28)
		var details := Label.new()
		details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var stock := int(settlement.goods_stock.get(good_id, 0))
		var condition := MarketService.stock_condition(stock)
		details.text = "%s\n%d Wealth  •  %s  •  Owned %d" % [good.name, settlement.goods_prices[good_id], condition, int(WorldState.player.inventory.get(good_id, 0))]
		details.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if condition.to_lower().contains("short") or condition.to_lower().contains("scarce"):
			details.add_theme_color_override("font_color", Color(0.88, 0.48, 0.32))
		elif condition.to_lower().contains("surplus") or condition.to_lower().contains("plent"):
			details.add_theme_color_override("font_color", Color(0.55, 0.75, 0.38))
		var buy_button := Button.new()
		buy_button.text = "BUY"
		buy_button.custom_minimum_size = Vector2(110, 58)
		_bind_tactile_button(buy_button)
		buy_button.disabled = stock <= 0
		buy_button.pressed.connect(_trade_good.bind(good_id, true))
		var sell_button := Button.new()
		sell_button.text = "SELL"
		sell_button.custom_minimum_size = Vector2(110, 58)
		_bind_tactile_button(sell_button)
		sell_button.disabled = int(WorldState.player.inventory.get(good_id, 0)) <= 0
		sell_button.pressed.connect(_trade_good.bind(good_id, false))
		row.add_child(icon)
		row.add_child(details)
		row.add_child(buy_button)
		row.add_child(sell_button)
		market_rows.add_child(row)


func _refresh_activity_header() -> void:
	var settlement: Settlement = WorldState.settlements.get(WorldState.player.location_id)
	activity_context.text = "%s  •  %s" % [settlement.name.to_upper() if settlement else birthplace.to_upper(), TimeManager.year_label()]
	var occupation := OccupationData.get_occupation(WorldState.player.occupation_id)
	if occupation.is_empty():
		activity_occupation_title.text = "NO OCCUPATION"
		activity_occupation_description.text = "Your working life has not begun."
		activity_occupation_progress.ratio = 0.0
		activity_occupation_progress_text.text = "0 / 3"
		return
	var rank := OccupationData.rank_for_experience(WorldState.player.occupation_experience)
	activity_occupation_title.text = "%s %s" % [str(rank.name).to_upper(), str(occupation.name).to_upper()]
	activity_occupation_description.text = str(occupation.description)
	var next_rank_at := 3 if WorldState.player.occupation_experience < 3 else 7
	activity_occupation_progress.ratio = clampf(float(WorldState.player.occupation_experience) / float(next_rank_at), 0.0, 1.0)
	activity_occupation_progress_text.text = "%d / %d" % [WorldState.player.occupation_experience, next_rank_at]


func _good_icon(good_id: String) -> String:
	return {
		"grain": "♨",
		"dates": "♣",
		"salt": "◇",
		"cloth": "▦",
		"pottery": "◉",
		"iron": "⚒",
	}.get(good_id, "◆")


func _refresh_upgrade_row() -> void:
	var status := MarketService.upgrade_status()
	if status.is_empty() or bool(status.get("maxed", false)):
		var current: Dictionary = status.get("current", {})
		upgrade_label.text = "You have reached the highest trade standing: %s." % str(current.get("name", "Ship Owner"))
		upgrade_button.hide()
		return
	var next_tier: Dictionary = status.next
	if bool(status.eligible):
		upgrade_label.text = "Eligible to become a %s." % str(next_tier.name)
		upgrade_button.text = "BECOME %s — %d WEALTH" % [str(next_tier.name).to_upper(), int(next_tier.cost)]
		upgrade_button.disabled = not bool(status.affordable)
		upgrade_button.show()
	else:
		upgrade_label.text = "Trade Reputation %d / %d needed to become a %s." % [WorldState.player.trade_reputation, int(next_tier.reputation_required), str(next_tier.name)]
		upgrade_button.hide()


func _attempt_upgrade_tier() -> void:
	var result := MarketService.attempt_upgrade_tier()
	market_message.text = result.message
	wealth = WorldState.player.wealth
	_refresh_stats()
	if bool(result.ok):
		_append_chronicle("Trade standing, %s\n%s" % [TimeManager.year_label(), result.message])
	SaveManager.save_game()
	_rebuild_market_rows()


func _trade_good(good_id: String, buying: bool) -> void:
	var result := MarketService.buy_good(good_id) if buying else MarketService.sell_good(good_id)
	market_message.text = result.message
	wealth = WorldState.player.wealth
	trade_reputation = WorldState.player.trade_reputation
	_refresh_stats()
	SaveManager.save_game()
	_rebuild_market_rows()


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
	var horizontal_edge := clampf(canvas.x * 0.045, 24.0, 72.0)
	var top_edge := clampf(canvas.y * 0.018, 20.0, 34.0)
	var bottom_edge := clampf(canvas.y * 0.024, 26.0, 42.0)
	safe_area.add_theme_constant_override("margin_left", roundi(horizontal_edge))
	safe_area.add_theme_constant_override("margin_right", roundi(horizontal_edge))
	safe_area.add_theme_constant_override("margin_top", roundi(top_edge))
	safe_area.add_theme_constant_override("margin_bottom", roundi(bottom_edge))
	var width := clampf((canvas.x - horizontal_edge * 2.0) * 0.98, 480.0, 1000.0)
	composition.custom_minimum_size.x = width
	portrait.custom_minimum_size = Vector2.ONE * clampf(canvas.x * 0.08, 78.0, 100.0)
	location_panel.custom_minimum_size.y = 60.0
	chronicle_scroll.custom_minimum_size.y = clampf(canvas.y * 0.1, 96.0, 120.0)
	var age_button_size := clampf(canvas.y * 0.125, 124.0, 142.0)
	advance_button.custom_minimum_size = Vector2.ONE * age_button_size
	name_label.add_theme_font_size_override("font_size", roundi(clampf(canvas.x * 0.019, 30.0, 38.0)))
	for button in find_children("*", "Button", true, false):
		(button as Button).pivot_offset = (button as Button).size * 0.5


func _setup_background() -> void:
	if ResourceLoader.exists(BACKGROUND_ART_PATH):
		background.texture = load(BACKGROUND_ART_PATH)


func _setup_location_banner() -> void:
	var map_path := str(HOMELAND_MAP.get(homeland, HOMELAND_MAP["RASHIDUN CALIPHATE"]))
	if ResourceLoader.exists(map_path):
		location_art.texture = load(map_path)
		location_art.self_modulate = Color(1.32, 1.2, 1.02, 1.0)
	var backdrop_path := str(HOMELAND_ART.get(homeland, HOMELAND_ART["RASHIDUN CALIPHATE"]))
	if ResourceLoader.exists(backdrop_path):
		character_backdrop.texture = load(backdrop_path)
	var region := str(HOMELAND_REGION.get(homeland, "YOUR HOMELAND"))
	map_realm_title.text = birthplace.to_upper()
	map_context_title.text = "%s  •  %s" % [region, TimeManager.year_label()]
	player_map_marker.text = "◆  %s\nCURRENT LOCATION" % birthplace.to_upper()
	location_caption.text = "%s  •  %s\nA living settlement shaped by households, markets, faith and power." % [birthplace.to_upper(), region]


func _position_map_marker() -> void:
	if player_map_marker == null or location_panel.size.x <= 0.0:
		return
	var normalized: Vector2 = MAP_MARKER_POSITION.get(birthplace, Vector2(0.5, 0.5))
	player_map_marker.position = Vector2(
		location_panel.size.x * normalized.x - player_map_marker.size.x * 0.5,
		location_panel.size.y * normalized.y - player_map_marker.size.y * 0.5
	)


func _reveal_overlay(overlay: Control) -> void:
	_force_full_rect(overlay)
	for child_name in [&"Shade", &"Center"]:
		var child := overlay.get_node_or_null(NodePath(child_name))
		if child is Control:
			_force_full_rect(child)
	_sync_panel_center(overlay)
	overlay.modulate.a = 0.0
	overlay.show()
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.14)


func _sync_panel_center(overlay: Control) -> void:
	var center := overlay.get_node_or_null(NodePath("Center"))
	if not (center is Control):
		return
	var panel_center := center.get_node_or_null(NodePath("PanelCenter"))
	if panel_center is Control:
		_apply_panel_center_size(center, panel_center)


func _apply_panel_center_size(center: Control, panel_center: Control) -> void:
	if panel_center.custom_minimum_size != center.size:
		panel_center.custom_minimum_size = center.size


func _force_full_rect(control: Control) -> void:
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0


func _bind_button_feedback() -> void:
	for node in find_children("*", "Button", true, false):
		_bind_tactile_button(node as Button)


func _bind_tactile_button(button: Button) -> void:
	if button == null or button.has_meta("life_feedback_bound"):
		return
	button.set_meta("life_feedback_bound", true)
	button.button_down.connect(_press_button.bind(button))
	button.button_up.connect(_release_button.bind(button))
	button.resized.connect(func(): button.pivot_offset = button.size * 0.5)


func _press_button(button: Button) -> void:
	_tween_button_feedback(button, TOUCH_PRESS_SCALE, TOUCH_PRESS_TINT, TOUCH_PRESS_DURATION)


func _release_button(button: Button) -> void:
	_tween_button_feedback(button, Vector2.ONE, Color.WHITE, TOUCH_RELEASE_DURATION)


func _tween_button_feedback(button: Button, target_scale: Vector2, tint: Color, duration: float) -> void:
	var existing: Tween = button_tweens.get(button)
	if existing and existing.is_valid():
		existing.kill()
	button.pivot_offset = button.size * 0.5
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, duration)
	tween.tween_property(button, "self_modulate", tint, duration)
	button_tweens[button] = tween
