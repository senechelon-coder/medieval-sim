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
var occupation_id := ""
var occupation_experience := 0
var trade_reputation := 0
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
@onready var character_details_value: Label = %CharacterDetailsValue
@onready var close_character_button: Button = %CloseCharacterButton
@onready var activities_button: Button = %Activities
@onready var activities_overlay: Control = %ActivitiesOverlay
@onready var market_summary: Label = %MarketSummary
@onready var upgrade_label: Label = %UpgradeLabel
@onready var upgrade_button: Button = %UpgradeButton
@onready var regional_prices: Label = %RegionalPrices
@onready var market_rows: VBoxContainer = %MarketRows
@onready var market_message: Label = %MarketMessage
@onready var close_activities_button: Button = %CloseActivitiesButton
@onready var world_button: Button = %World
@onready var world_overlay: Control = %WorldOverlay
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
	_apply_annual_income()
	if character_age == 5:
		_append_chronicle("Age 5, %s\nYour early upbringing can now be chosen." % TimeManager.year_label())
		upbringing_panel.show()
		advance_button.disabled = true
	elif character_age == 12:
		_append_chronicle("Age 12, %s\nChildhood gives way to responsibility. Your household must decide how you will be trained." % TimeManager.year_label())
		apprenticeship_panel.show()
		advance_button.disabled = true
	elif character_age == 16 and occupation_id == "":
		_append_chronicle("Age 16, %s\nYour apprenticeship gives way to adult work. You must choose how to earn your living." % TimeManager.year_label())
		occupation_panel.show()
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
	activities_button.disabled = character_age < 16


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
	if character_age == 5 and upbringing == "Undetermined":
		upbringing_panel.show()
		advance_button.disabled = true
	elif character_age == 12 and apprenticeship == "None":
		apprenticeship_panel.show()
		advance_button.disabled = true
	elif character_age == 16 and occupation_id == "":
		occupation_panel.show()
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
	world_market_value.text = "\n".join(context.market)
	world_action_message.text = "You may spend time on each local activity once per year."
	visit_family_button.disabled = int(WorldState.player.local_action_years.get("family", 0)) == TimeManager.current_date.year
	help_trader_button.disabled = int(WorldState.player.local_action_years.get("trader", 0)) == TimeManager.current_date.year
	travel_message.text = ""
	_rebuild_travel_rows()
	world_overlay.show()


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
		row.add_theme_constant_override("separation", 8)
		var details := Label.new()
		details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		details.autowrap_mode = TextServer.AUTOWRAP_WORD
		details.text = "%s  •  %s\n~%d days" % [settlement.name, province.name if province else "Unknown", days]
		var travel_button := Button.new()
		travel_button.text = "TRAVEL"
		travel_button.custom_minimum_size = Vector2(140, 68)
		travel_button.pressed.connect(_begin_travel.bind(settlement.id))
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
	_open_world()
	travel_message.text = "You have arrived in %s." % result.destination


func _open_character() -> void:
	var context := WorldState.get_character_context()
	character_details_value.text = "LINEAGE\n%s\n\nDYNASTY\n%s  •  PRESTIGE %d\n\nPARENTS\n%s\n%s\n\nCULTURE\n%s\n\nFAITH\n%s\n\nBORN\n%s  •  %s" % [context.lineage, context.dynasty, context.prestige, context.father, context.mother, context.culture, context.faith, context.birth_season, context.family_origin]
	character_overlay.show()


func _open_activities() -> void:
	_rebuild_market_rows()
	market_message.text = "Buy locally now; future travel will let you seek better selling prices."
	activities_overlay.show()


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
		row.add_theme_constant_override("separation", 8)
		var details := Label.new()
		details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var stock := int(settlement.goods_stock.get(good_id, 0))
		details.text = "%s  •  %d Wealth  •  %s  •  Owned %d" % [good.name, settlement.goods_prices[good_id], MarketService.stock_condition(stock), int(WorldState.player.inventory.get(good_id, 0))]
		var buy_button := Button.new()
		buy_button.text = "BUY"
		buy_button.custom_minimum_size = Vector2(110, 58)
		buy_button.disabled = stock <= 0
		buy_button.pressed.connect(_trade_good.bind(good_id, true))
		var sell_button := Button.new()
		sell_button.text = "SELL"
		sell_button.custom_minimum_size = Vector2(110, 58)
		sell_button.disabled = int(WorldState.player.inventory.get(good_id, 0)) <= 0
		sell_button.pressed.connect(_trade_good.bind(good_id, false))
		row.add_child(details)
		row.add_child(buy_button)
		row.add_child(sell_button)
		market_rows.add_child(row)


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
