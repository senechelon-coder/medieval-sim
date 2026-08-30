class_name TravelSim
extends RefCounted

const BASE_DAYS := 3
const DANGER_CHANCE := 0.22


static func days_to(destination_id: String) -> int:
	var origin: Settlement = WorldState.settlements.get(WorldState.player.location_id)
	var destination: Settlement = WorldState.settlements.get(destination_id)
	if origin == null or destination == null:
		return BASE_DAYS
	var hops := _province_hop_distance(origin.province_id, destination.province_id)
	return maxi(BASE_DAYS + hops * 2, 2)


static func begin_journey(destination_id: String) -> Dictionary:
	if not WorldState.has_player():
		return {"ok": false, "message": "No active character."}
	var destination: Settlement = WorldState.settlements.get(destination_id)
	if destination == null:
		return {"ok": false, "message": "Unknown destination."}
	if destination_id == WorldState.player.location_id:
		return {"ok": false, "message": "You are already there."}
	var origin: Settlement = WorldState.settlements[WorldState.player.location_id]
	var days := days_to(destination_id) + randi_range(-1, 1)
	days = maxi(days, 2)
	var danger_label := TravelEventData.danger_label_for(WorldState.player.homeland, WorldState.player.trade_tier)
	var benign_events := TravelEventData.benign_events_for(WorldState.player.homeland)
	var log: Array[String] = []
	for day in range(1, days + 1):
		if randf() < DANGER_CHANCE:
			log.append("Day %d — %s" % [day, _resolve_danger(danger_label)])
		else:
			var event: Dictionary = benign_events[randi() % benign_events.size()]
			_apply_effects(event.get("effects", {}))
			log.append("Day %d — %s" % [day, str(event.text)])
	TimeManager.advance_days(days)
	WorldState.player.location_id = destination_id
	log.append("You arrive in %s." % destination.name)
	return {"ok": true, "days": days, "origin": origin.name, "destination": destination.name, "log": log}


static func _resolve_danger(danger_label: String) -> String:
	var roll := randf()
	if roll < 0.35:
		return "%s appear on the route, but you evade them unseen." % danger_label
	elif roll < 0.65:
		var loss := randi_range(6, 14)
		WorldState.player.health = maxi(WorldState.player.health - loss, 0)
		return "%s attack! You fight them off, but suffer wounds (-%d Health)." % [danger_label, loss]
	else:
		var stolen := mini(randi_range(4, 12), WorldState.player.wealth)
		if stolen <= 0:
			return "%s corner you, but find your purse already empty." % danger_label
		WorldState.player.wealth -= stolen
		return "%s rob you before fleeing (-%d Wealth)." % [danger_label, stolen]


static func _apply_effects(effects: Dictionary) -> void:
	if effects.has("health"):
		WorldState.player.health = clampi(WorldState.player.health + int(effects.health), 0, 100)
	if effects.has("wealth"):
		WorldState.player.wealth = maxi(WorldState.player.wealth + int(effects.wealth), 0)


static func _province_hop_distance(from_id: String, to_id: String) -> int:
	if from_id == to_id:
		return 0
	var visited := {from_id: true}
	var frontier: Array[String] = [from_id]
	var distance := 0
	while not frontier.is_empty():
		distance += 1
		var next_frontier: Array[String] = []
		for province_id in frontier:
			var province: Province = WorldState.provinces.get(province_id)
			if province == null:
				continue
			for neighbor_id in province.neighbor_ids:
				if neighbor_id == to_id:
					return distance
				if not visited.has(neighbor_id):
					visited[neighbor_id] = true
					next_frontier.append(neighbor_id)
		frontier = next_frontier
	return 3
