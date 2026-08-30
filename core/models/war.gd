class_name War
extends RefCounted

var id := ""
var attacker_kingdom_id := ""
var defender_name := "a rival power"
var war_score := 0.0
var start_year := 632
var active := true
var outcome := ""


func to_dict() -> Dictionary:
	return {
		"id": id, "attacker_kingdom_id": attacker_kingdom_id, "defender_name": defender_name,
		"war_score": war_score, "start_year": start_year, "active": active, "outcome": outcome,
	}


static func from_dict(data: Dictionary) -> War:
	var war := War.new()
	war.id = str(data.get("id", ""))
	war.attacker_kingdom_id = str(data.get("attacker_kingdom_id", ""))
	war.defender_name = str(data.get("defender_name", "a rival power"))
	war.war_score = float(data.get("war_score", 0.0))
	war.start_year = int(data.get("start_year", 632))
	war.active = bool(data.get("active", true))
	war.outcome = str(data.get("outcome", ""))
	return war
