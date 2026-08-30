class_name WarSim
extends RefCounted

const RECRUIT_CHANCE_SOLDIER := 0.7
const RECRUIT_CHANCE_CIVILIAN := 0.15
const WAR_MAX_YEARS := 6
const WAR_SCORE_RESOLVE_THRESHOLD := 60.0


static func maybe_declare_war(current_year: int) -> String:
	if not WorldState.has_player():
		return ""
	if WorldState.get_active_war() != null:
		return ""
	if WorldState.player.age < 17:
		return ""
	var should_declare := WorldState.player.age >= 25 or randf() < 0.2
	if not should_declare:
		return ""
	var realm_id := WorldState.player.homeland.to_lower().replace(" ", "_")
	var rival_name := WarEventData.rival_for(WorldState.player.homeland)
	var war := War.new()
	war.id = "war_%d" % current_year
	war.attacker_kingdom_id = realm_id
	war.defender_name = rival_name
	war.war_score = 0.0
	war.start_year = current_year
	war.active = true
	WorldState.wars[war.id] = war

	var army := Army.new()
	army.id = "army_%s" % realm_id
	army.kingdom_id = realm_id
	army.strength = randi_range(80, 130)
	army.morale = randf_range(55.0, 80.0)
	WorldState.armies[army.id] = army

	return "%d AD — Your king has declared war upon the %s." % [current_year, rival_name]


static func advance_war(current_year: int) -> String:
	var war := WorldState.get_active_war()
	if war == null:
		return ""
	war.war_score = clampf(war.war_score + randf_range(-9.0, 11.0), -100.0, 100.0)
	var years_elapsed := current_year - war.start_year
	if absf(war.war_score) >= WAR_SCORE_RESOLVE_THRESHOLD or years_elapsed >= WAR_MAX_YEARS:
		war.active = false
		if war.war_score > 15.0:
			war.outcome = "victory"
			return "%d AD — The war against the %s has ended in victory." % [current_year, war.defender_name]
		elif war.war_score < -15.0:
			war.outcome = "defeat"
			return "%d AD — The war against the %s has ended in defeat." % [current_year, war.defender_name]
		else:
			war.outcome = "stalemate"
			return "%d AD — The war against the %s has ended in an uneasy stalemate." % [current_year, war.defender_name]
	return ""


static func attempt_recruit_player(current_year: int) -> Dictionary:
	if not WorldState.has_player():
		return {}
	var player: PlayerCharacter = WorldState.player
	if player.has_fought or player.in_army or player.age < 16:
		return {}
	var war := WorldState.get_active_war()
	if war == null:
		return {}
	var is_soldier := player.occupation_id == "soldier"
	var chance := RECRUIT_CHANCE_SOLDIER if is_soldier else RECRUIT_CHANCE_CIVILIAN
	if randf() >= chance:
		return {}
	return {"eligible": true, "is_soldier": is_soldier, "rival_name": war.defender_name}


static func resolve_battle_outcome(final_health: int, battle_morale: float) -> Dictionary:
	var army := WorldState.get_player_army()
	var strength_bonus := 0.0
	if army:
		strength_bonus = (float(army.strength) - 100.0) * 0.05 + (army.morale - 70.0) * 0.05
	var score := battle_morale + strength_bonus + randf_range(-6.0, 6.0)
	var outcome := {}
	if final_health < 25:
		outcome.tier = "wounded"
		outcome.wealth = 0
		outcome.health_floor = 15
		outcome.war_score = randf_range(-4.0, 4.0)
		outcome.summary = "You are carried from the field, grievously wounded but alive."
	elif score >= 12.0 and final_health >= 50:
		outcome.tier = "valorous"
		outcome.wealth = randi_range(12, 22)
		outcome.standing = "Battle-Tested"
		outcome.war_score = randf_range(10.0, 18.0)
		outcome.summary = "You fight with distinction. The line holds, and word of your courage spreads."
	else:
		outcome.tier = "survived"
		outcome.wealth = randi_range(3, 8)
		outcome.war_score = randf_range(2.0, 8.0)
		outcome.summary = "You survive the day. The line holds, won as much by others as by you."
	var war := WorldState.get_active_war()
	if war != null:
		war.war_score = clampf(war.war_score + float(outcome.war_score), -100.0, 100.0)
	return outcome
