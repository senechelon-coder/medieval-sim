class_name PlayerCharacter
extends RefCounted

var full_name := "Unnamed"
var lineage := "Unknown"
var age := 1
var sex := "MALE"
var homeland := "RASHIDUN CALIPHATE"
var birthplace := "Medina"
var location_id := ""
var family_origin := "Unknown"
var father_name := "Unknown"
var mother_name := "Unknown"
var culture := "Unknown"
var faith := "Unknown"
var birth_season := "Unknown"
var appearance_seed := 1
var health := 90
var wealth := 10
var standing := "Unknown"
var upbringing := "Undetermined"
var primary_trait := "Undeveloped"
var apprenticeship := "None"
var occupation_id := ""
var occupation_experience := 0
var trade_reputation := 0
var trade_tier := "peddler"
var in_army := false
var has_fought := false
var inventory: Dictionary = {}
var cargo_capacity := 10
var chronicle: Array[String] = []
var completed_events: Array[String] = []
var local_action_years: Dictionary = {}


func to_dict() -> Dictionary:
	return {
		"full_name": full_name, "lineage": lineage, "age": age, "sex": sex,
		"homeland": homeland, "birthplace": birthplace, "location_id": location_id,
		"family_origin": family_origin, "father_name": father_name,
		"mother_name": mother_name, "culture": culture, "faith": faith,
		"birth_season": birth_season, "appearance_seed": appearance_seed,
		"health": health, "wealth": wealth, "standing": standing,
		"upbringing": upbringing, "primary_trait": primary_trait,
		"apprenticeship": apprenticeship, "occupation_id": occupation_id, "occupation_experience": occupation_experience, "trade_reputation": trade_reputation, "trade_tier": trade_tier, "in_army": in_army, "has_fought": has_fought, "inventory": inventory.duplicate(), "cargo_capacity": cargo_capacity, "chronicle": chronicle.duplicate(),
		"completed_events": completed_events.duplicate(),
		"local_action_years": local_action_years.duplicate(),
	}


func apply_dict(data: Dictionary) -> void:
	full_name = str(data.get("full_name", full_name))
	lineage = str(data.get("lineage", lineage))
	age = int(data.get("age", age))
	sex = str(data.get("sex", sex))
	homeland = str(data.get("homeland", homeland))
	birthplace = str(data.get("birthplace", birthplace))
	location_id = str(data.get("location_id", location_id))
	family_origin = str(data.get("family_origin", family_origin))
	father_name = str(data.get("father_name", father_name))
	mother_name = str(data.get("mother_name", mother_name))
	culture = str(data.get("culture", culture))
	faith = str(data.get("faith", faith))
	birth_season = str(data.get("birth_season", birth_season))
	appearance_seed = int(data.get("appearance_seed", appearance_seed))
	health = int(data.get("health", health))
	wealth = int(data.get("wealth", wealth))
	standing = str(data.get("standing", standing))
	upbringing = str(data.get("upbringing", upbringing))
	primary_trait = str(data.get("primary_trait", primary_trait))
	apprenticeship = str(data.get("apprenticeship", apprenticeship))
	occupation_id = str(data.get("occupation_id", occupation_id))
	occupation_experience = int(data.get("occupation_experience", occupation_experience))
	trade_reputation = int(data.get("trade_reputation", trade_reputation))
	trade_tier = str(data.get("trade_tier", trade_tier))
	in_army = bool(data.get("in_army", in_army))
	has_fought = bool(data.get("has_fought", has_fought))
	inventory.clear()
	for good_id in data.get("inventory", {}):
		inventory[str(good_id)] = int(data.inventory[good_id])
	cargo_capacity = int(data.get("cargo_capacity", cargo_capacity))
	chronicle.clear()
	for entry in data.get("chronicle", []):
		chronicle.append(str(entry))
	completed_events.clear()
	for event_id in data.get("completed_events", []):
		completed_events.append(str(event_id))
	local_action_years = data.get("local_action_years", {}).duplicate()
