extends Node

var player: PlayerCharacter
var kingdoms: Dictionary = {}
var provinces: Dictionary = {}
var settlements: Dictionary = {}
var local_characters: Dictionary = {}
var dynasties: Dictionary = {}
var wars: Dictionary = {}
var armies: Dictionary = {}


func create_player(profile: Dictionary) -> PlayerCharacter:
	player = PlayerCharacter.new()
	player.full_name = profile.get("full_name", "Unnamed")
	player.lineage = profile.get("lineage", "Unknown")
	player.age = profile.get("age", 1)
	player.sex = profile.get("sex", "MALE")
	player.homeland = profile.get("homeland", "RASHIDUN CALIPHATE")
	player.birthplace = profile.get("birthplace", "Medina")
	player.family_origin = profile.get("family_origin", "Unknown")
	player.father_name = profile.get("father_name", "Unknown")
	player.mother_name = profile.get("mother_name", "Unknown")
	player.culture = profile.get("culture", "Unknown")
	player.faith = profile.get("faith", "Unknown")
	player.birth_season = profile.get("birth_season", "Unknown")
	player.appearance_seed = profile.get("appearance_seed", 1)
	seed_local_world()
	return player


func has_player() -> bool:
	return player != null


func load_player(data: Dictionary) -> PlayerCharacter:
	player = PlayerCharacter.new()
	player.apply_dict(data)
	if player.lineage == "Unknown":
		var name_parts := player.full_name.split(" ", false)
		if not name_parts.is_empty():
			player.lineage = name_parts[name_parts.size() - 1]
	return player


func clear() -> void:
	player = null
	kingdoms.clear()
	provinces.clear()
	settlements.clear()
	local_characters.clear()
	dynasties.clear()
	wars.clear()
	armies.clear()


func seed_local_world() -> void:
	kingdoms.clear()
	provinces.clear()
	settlements.clear()
	local_characters.clear()
	dynasties.clear()
	wars.clear()
	armies.clear()
	var realm_id := player.homeland.to_lower().replace(" ", "_")
	var province_name := _province_for_birthplace(player.birthplace)
	var province_id := province_name.to_lower().replace(" ", "_")
	var settlement_id := player.birthplace.to_lower().replace("'", "").replace(" ", "_")

	var realm := Kingdom.new()
	realm.id = realm_id
	realm.name = player.homeland.capitalize()
	realm.province_ids = [province_id]
	kingdoms[realm.id] = realm

	var province := Province.new()
	province.id = province_id
	province.name = province_name
	province.owner_kingdom_id = realm.id
	province.settlement_ids = [settlement_id]
	provinces[province.id] = province

	var settlement := Settlement.new()
	settlement.id = settlement_id
	settlement.name = player.birthplace
	settlement.type = "city" if player.birthplace in ["Medina", "Mecca", "Constantinople", "Antioch", "Alexandria", "Ctesiphon", "Merv"] else "town"
	settlement.province_id = province.id
	settlement.population = 4200 if settlement.type == "city" else 1300
	settlement.prosperity = 58.0
	_seed_market_prices(settlement)
	settlements[settlement.id] = settlement
	player.location_id = settlement.id
	_seed_neighboring_places(realm, province)

	_add_local_character("father", player.father_name, "MALE", 31, "Father", settlement.id, 75)
	_add_local_character("mother", player.mother_name, "FEMALE", 27, "Mother", settlement.id, 80)
	(local_characters.father as LocalCharacter).spouse_id = "mother"
	(local_characters.mother as LocalCharacter).spouse_id = "father"
	var elder_profile := CharacterNameData.generate_profile(player.homeland, "MALE")
	var trader_profile := CharacterNameData.generate_profile(player.homeland, "FEMALE")
	_add_local_character("elder", elder_profile.full_name, "MALE", 54, "Community Elder", settlement.id, 30)
	_add_local_character("trader", trader_profile.full_name, "FEMALE", 36, "Local Trader", settlement.id, 20)
	_seed_player_dynasty()


func _add_local_character(id: String, full_name: String, sex: String, age: int, role: String, location_id: String, relationship: int) -> void:
	var character := LocalCharacter.new()
	character.id = id
	character.full_name = full_name
	character.sex = sex
	character.age = age
	character.role = role
	character.location_id = location_id
	character.relationship_to_player = relationship
	local_characters[id] = character
	(settlements[location_id] as Settlement).population_sample.append(id)


func _province_for_birthplace(place: String) -> String:
	if place in ["Medina", "Mecca", "Ta'if", "Khaybar"]: return "Hejaz"
	if place in ["Sana'a", "Najran"]: return "Yemen"
	if place in ["Al-Yamama", "Nomadic Encampment"]: return "Central Arabia"
	if place in ["Constantinople", "Thessalonica"]: return "Thrace"
	if place in ["Antioch", "Damascus", "Caesarea"]: return "Syria"
	if place == "Alexandria": return "Egypt"
	if place in ["Ephesus", "Nicaea"]: return "Anatolia"
	if place in ["Ctesiphon", "Susa", "Gundeshapur"]: return "Asoristan"
	if place in ["Estakhr", "Isfahan"]: return "Persis"
	return "Khorasan"


func _seed_player_dynasty() -> void:
	var dynasty := Dynasty.new()
	dynasty.id = "player_family"
	dynasty.name = "Household of %s" % player.lineage
	dynasty.member_ids = ["player", "father", "mother"]
	dynasty.head_character_id = "father"
	dynasty.prestige = 10
	dynasties[dynasty.id] = dynasty


func _seed_neighboring_places(realm: Kingdom, home_province: Province) -> void:
	var places: Array[Dictionary]
	match player.homeland:
		"RASHIDUN CALIPHATE": places = [{"name": "Mecca", "province": "Hejaz"}, {"name": "Sana'a", "province": "Yemen"}, {"name": "Al-Yamama", "province": "Central Arabia"}]
		"BYZANTINE EMPIRE": places = [{"name": "Constantinople", "province": "Thrace"}, {"name": "Nicaea", "province": "Anatolia"}, {"name": "Antioch", "province": "Syria"}]
		_: places = [{"name": "Ctesiphon", "province": "Asoristan"}, {"name": "Estakhr", "province": "Persis"}, {"name": "Merv", "province": "Khorasan"}]
	for place in places:
		if place.name == player.birthplace:
			continue
		var province_id := str(place.province).to_lower().replace(" ", "_")
		var province: Province = provinces.get(province_id)
		if province == null:
			province = Province.new()
			province.id = province_id
			province.name = place.province
			province.owner_kingdom_id = realm.id
			provinces[province_id] = province
			realm.province_ids.append(province_id)
		if province_id != home_province.id and province_id not in home_province.neighbor_ids:
			home_province.neighbor_ids.append(province_id)
			province.neighbor_ids.append(home_province.id)
		var settlement_id := str(place.name).to_lower().replace("'", "").replace(" ", "_")
		if settlements.has(settlement_id):
			continue
		var settlement := Settlement.new()
		settlement.id = settlement_id
		settlement.name = place.name
		settlement.type = "city"
		settlement.province_id = province_id
		settlement.population = 3200
		settlement.prosperity = 52.0
		_seed_market_prices(settlement)
		settlements[settlement_id] = settlement
		province.settlement_ids.append(settlement_id)


func world_to_dict() -> Dictionary:
	return {
		"kingdoms": _registry_to_dict(kingdoms),
		"provinces": _registry_to_dict(provinces),
		"settlements": _registry_to_dict(settlements),
		"local_characters": _registry_to_dict(local_characters),
		"dynasties": _registry_to_dict(dynasties),
		"wars": _registry_to_dict(wars),
		"armies": _registry_to_dict(armies),
	}


func load_world(data: Dictionary) -> void:
	kingdoms.clear(); provinces.clear(); settlements.clear(); local_characters.clear(); dynasties.clear(); wars.clear(); armies.clear()
	for id in data.get("kingdoms", {}): kingdoms[id] = Kingdom.from_dict(data.kingdoms[id])
	for id in data.get("provinces", {}): provinces[id] = Province.from_dict(data.provinces[id])
	for id in data.get("settlements", {}): settlements[id] = Settlement.from_dict(data.settlements[id])
	for id in data.get("local_characters", {}): local_characters[id] = LocalCharacter.from_dict(data.local_characters[id])
	for id in data.get("dynasties", {}): dynasties[id] = Dynasty.from_dict(data.dynasties[id])
	for id in data.get("wars", {}): wars[id] = War.from_dict(data.wars[id])
	for id in data.get("armies", {}): armies[id] = Army.from_dict(data.armies[id])
	if settlements.is_empty():
		seed_local_world()
	else:
		if player.location_id == "" or not settlements.has(player.location_id):
			player.location_id = str(settlements.keys()[0])
		if settlements.size() < 2:
			var home: Settlement = settlements[player.location_id]
			var home_province: Province = provinces[home.province_id]
			var realm: Kingdom = kingdoms[home_province.owner_kingdom_id]
			_seed_neighboring_places(realm, home_province)
		if dynasties.is_empty():
			_seed_player_dynasty()
		for settlement: Settlement in settlements.values():
			if settlement.goods_prices.is_empty():
				_seed_market_prices(settlement)
			elif settlement.goods_stock.is_empty():
				_seed_market_stock(settlement)


func _registry_to_dict(registry: Dictionary) -> Dictionary:
	var result := {}
	for id in registry:
		result[id] = registry[id].to_dict()
	return result


func get_home_context() -> Dictionary:
	if settlements.is_empty():
		return {}
	var settlement: Settlement = settlements.get(player.location_id)
	if settlement == null:
		settlement = settlements.values()[0]
		player.location_id = settlement.id
	var province: Province = provinces.get(settlement.province_id)
	var kingdom: Kingdom = kingdoms.get(province.owner_kingdom_id)
	var residents: Array[String] = []
	for character_id in settlement.population_sample:
		var character: LocalCharacter = local_characters.get(character_id)
		if character and character.alive:
			var spouse_text := ""
			if character.spouse_id != "" and local_characters.has(character.spouse_id):
				var spouse: LocalCharacter = local_characters[character.spouse_id]
				spouse_text = " • Spouse: %s" % spouse.full_name
			residents.append("%s — %s, age %d • Bond %d%s" % [character.full_name, character.role, character.age, character.relationship_to_player, spouse_text])
	var market: Array[String] = []
	for good_id in settlement.goods_prices:
		var stock := int(settlement.goods_stock.get(good_id, 0))
		market.append("%s — %d Wealth • %s" % [GoodData.get_good(good_id).name, settlement.goods_prices[good_id], MarketService.stock_condition(stock)])
	return {"kingdom": kingdom.name, "province": province.name, "settlement": settlement.name, "type": settlement.type.capitalize(), "population": settlement.population, "prosperity": roundi(settlement.prosperity), "residents": residents, "reports": settlement.recent_reports.duplicate(), "market": market}


func get_character_context() -> Dictionary:
	var dynasty: Dynasty = dynasties.get("player_family")
	return {
		"lineage": player.lineage,
		"father": player.father_name,
		"mother": player.mother_name,
		"culture": player.culture,
		"faith": player.faith,
		"birth_season": player.birth_season,
		"family_origin": player.family_origin,
		"dynasty": dynasty.name if dynasty else "Unknown household",
		"prestige": dynasty.prestige if dynasty else 0,
	}


func perform_local_action(action_id: String, current_year: int) -> Dictionary:
	if not has_player() or int(player.local_action_years.get(action_id, 0)) == current_year:
		return {}
	match action_id:
		"family":
			var living_family: Array[LocalCharacter] = []
			for id in ["father", "mother"]:
				var relative: LocalCharacter = local_characters.get(id)
				if relative and relative.alive:
					living_family.append(relative)
			if living_family.is_empty():
				return {"unavailable": "No close family remains here."}
			for relative in living_family:
				relative.relationship_to_player = mini(relative.relationship_to_player + 5, 100)
			player.local_action_years[action_id] = current_year
			return {"chronicle": "You spend time helping your family at home.\n+1 Health • Family bonds strengthened", "health": 1}
		"trader":
			var trader: LocalCharacter = local_characters.get("trader")
			if not trader or not trader.alive:
				return {"unavailable": "The local trader is no longer available."}
			trader.relationship_to_player = mini(trader.relationship_to_player + 6, 100)
			player.local_action_years[action_id] = current_year
			return {"chronicle": "You help the local trader sort goods and observe the day's bargaining.\n+2 Wealth • Trader bond strengthened", "wealth": 2}
	return {}


func advance_local_year(current_year: int) -> Array[String]:
	var local_news: Array[String] = []
	for character: LocalCharacter in local_characters.values():
		if not character.alive:
			continue
		character.age += 1
		var mortality_chance := _mortality_chance(character.age)
		if randf() < mortality_chance:
			character.alive = false
			character.death_year = current_year
			var settlement: Settlement = settlements.get(character.location_id)
			if settlement:
				settlement.population = maxi(settlement.population - 1, 0)
			local_news.append("%s, the %s, has died at age %d." % [character.full_name, character.role.to_lower(), character.age])
	for settlement: Settlement in settlements.values():
		settlement.prosperity = clampf(settlement.prosperity + randf_range(-1.0, 1.0), 0.0, 100.0)
		_update_market_prices(settlement)
		if current_year % 5 == 0:
			settlement.prosperity = clampf(settlement.prosperity - 6.0, 0.0, 100.0)
			settlement.population = maxi(settlement.population - 18, 0)
			_record_settlement_report(settlement, "%d AD — A poor harvest reduced local stores and prosperity." % current_year)
			if settlement.id == player.location_id:
				local_news.append("A poor harvest has reduced stores in %s." % settlement.name)
		if current_year % 7 == 0:
			settlement.prosperity = clampf(settlement.prosperity + 5.0, 0.0, 100.0)
			settlement.population += 9
			_record_settlement_report(settlement, "%d AD — A prosperous caravan brought goods and travelers." % current_year)
			if settlement.id == player.location_id:
				local_news.append("A prosperous caravan has arrived in %s." % settlement.name)
	var trade_news := _simulate_background_trade(current_year)
	if trade_news != "":
		local_news.append(trade_news)
	if current_year % 6 == 0:
		var marriage_news := _attempt_local_marriage(current_year)
		if marriage_news != "":
			local_news.append(marriage_news)
	if current_year % 4 == 0:
		var birth_news := _attempt_local_birth(current_year)
		if birth_news != "":
			local_news.append(birth_news)
	return local_news


func _record_settlement_report(settlement: Settlement, report: String) -> void:
	settlement.recent_reports.push_front(report)
	if settlement.recent_reports.size() > 4:
		settlement.recent_reports.resize(4)


func _attempt_local_marriage(current_year: int) -> String:
	var candidate: LocalCharacter
	for preferred_id in ["trader", "elder"]:
		var resident: LocalCharacter = local_characters.get(preferred_id)
		if resident and resident.alive and resident.spouse_id == "" and resident.age >= 18 and resident.age <= 65:
			candidate = resident
			break
	if candidate == null:
		return ""
	var spouse_sex := "FEMALE" if candidate.sex == "MALE" else "MALE"
	var spouse_profile := CharacterNameData.generate_profile(player.homeland, spouse_sex)
	var spouse_id := "spouse_%s_%d" % [candidate.id, current_year]
	var spouse_age := maxi(candidate.age - randi_range(0, 6), 18)
	_add_local_character(spouse_id, spouse_profile.full_name, spouse_sex, spouse_age, "Resident", candidate.location_id, 10)
	var spouse: LocalCharacter = local_characters[spouse_id]
	candidate.spouse_id = spouse_id
	spouse.spouse_id = candidate.id
	var settlement: Settlement = settlements[candidate.location_id]
	settlement.population += 1
	var report := "%d AD — %s and %s were married." % [current_year, candidate.full_name, spouse.full_name]
	_record_settlement_report(settlement, report)
	return "%s and %s have married in %s." % [candidate.full_name, spouse.full_name, settlement.name]


func _attempt_local_birth(current_year: int) -> String:
	var mother: LocalCharacter
	for resident: LocalCharacter in local_characters.values():
		if resident.alive and resident.sex == "FEMALE" and resident.age >= 18 and resident.age <= 42 and resident.spouse_id != "" and resident.children_ids.size() < 4:
			var partner: LocalCharacter = local_characters.get(resident.spouse_id)
			if partner and partner.alive:
				mother = resident
				break
	if mother == null:
		return ""
	var father: LocalCharacter = local_characters[mother.spouse_id]
	if father.sex == "FEMALE":
		var swap := mother
		mother = father
		father = swap
	var child_sex := "MALE" if randi() % 2 == 0 else "FEMALE"
	var child_profile := CharacterNameData.generate_profile(player.homeland, child_sex)
	var child_id := "child_%s_%d_%d" % [mother.id, current_year, mother.children_ids.size()]
	var child_role := "Younger Sibling" if mother.id == "mother" or father.id == "father" else "Child"
	var relationship := 55 if child_role == "Younger Sibling" else 10
	_add_local_character(child_id, child_profile.full_name, child_sex, 0, child_role, mother.location_id, relationship)
	var child: LocalCharacter = local_characters[child_id]
	child.mother_id = mother.id
	child.father_id = father.id
	mother.children_ids.append(child_id)
	father.children_ids.append(child_id)
	if child_role == "Younger Sibling" and dynasties.has("player_family"):
		(dynasties.player_family as Dynasty).member_ids.append(child_id)
	var settlement: Settlement = settlements[mother.location_id]
	settlement.population += 1
	var family_text := "A younger sibling, %s, was born into your family." % child.full_name if child_role == "Younger Sibling" else "%s and %s welcomed a child named %s." % [mother.full_name, father.full_name, child.full_name]
	_record_settlement_report(settlement, "%d AD — %s" % [current_year, family_text])
	return family_text


func _mortality_chance(age: int) -> float:
	if age < 15: return 0.004
	if age < 40: return 0.006
	if age < 55: return 0.012
	if age < 65: return 0.025
	if age < 75: return 0.065
	if age < 85: return 0.14
	return 0.28


func _seed_market_prices(settlement: Settlement) -> void:
	for good_id in GoodData.GOODS:
		var good := GoodData.get_good(good_id)
		var variation := absi((settlement.id + good_id).hash()) % 7 - 3
		settlement.goods_prices[good_id] = clampi(int(good.base_price) + variation, int(good.minimum), int(good.maximum))
	_seed_market_stock(settlement)


func _seed_market_stock(settlement: Settlement) -> void:
	for good_id in GoodData.GOODS:
		settlement.goods_stock[good_id] = 8 + absi((good_id + settlement.id).hash()) % 13


func _update_market_prices(settlement: Settlement) -> void:
	for good_id in settlement.goods_prices:
		var good := GoodData.get_good(good_id)
		var stock_change := randi_range(-2, 2)
		settlement.goods_stock[good_id] = maxi(int(settlement.goods_stock.get(good_id, 10)) + stock_change, 0)
		var prosperity_pressure := -1 if settlement.prosperity > 65.0 else (1 if settlement.prosperity < 40.0 else 0)
		var stock_pressure := 1 if int(settlement.goods_stock[good_id]) <= 4 else (-1 if int(settlement.goods_stock[good_id]) >= 16 else 0)
		var movement := randi_range(-1, 1) + prosperity_pressure + stock_pressure
		settlement.goods_prices[good_id] = clampi(int(settlement.goods_prices[good_id]) + movement, int(good.minimum), int(good.maximum))


func _simulate_background_trade(current_year: int) -> String:
	if current_year % 2 != 0 or settlements.size() < 2:
		return ""
	var good_ids := GoodData.GOODS.keys()
	var good_id: String = good_ids[current_year % good_ids.size()]
	var source: Settlement
	var destination: Settlement
	for settlement: Settlement in settlements.values():
		if source == null or int(settlement.goods_stock.get(good_id, 0)) > int(source.goods_stock.get(good_id, 0)):
			source = settlement
		if destination == null or int(settlement.goods_stock.get(good_id, 0)) < int(destination.goods_stock.get(good_id, 0)):
			destination = settlement
	if source == null or destination == null or source == destination:
		return ""
	var stock_difference := int(source.goods_stock[good_id]) - int(destination.goods_stock[good_id])
	if stock_difference < 4:
		return ""
	var amount := mini(3, int(source.goods_stock[good_id]))
	source.goods_stock[good_id] = int(source.goods_stock[good_id]) - amount
	destination.goods_stock[good_id] = int(destination.goods_stock[good_id]) + amount
	_reprice_after_shipment(source, good_id)
	_reprice_after_shipment(destination, good_id)
	var good_name: String = GoodData.get_good(good_id).name
	_record_settlement_report(source, "%d AD — Merchants carried %s toward %s." % [current_year, good_name, destination.name])
	_record_settlement_report(destination, "%d AD — A shipment of %s arrived from %s." % [current_year, good_name, source.name])
	if source.id == player.location_id or destination.id == player.location_id:
		return "Merchants moved %s from %s to %s, changing local supply." % [good_name, source.name, destination.name]
	return ""


func _reprice_after_shipment(settlement: Settlement, good_id: String) -> void:
	var good := GoodData.get_good(good_id)
	var condition := MarketService.stock_condition(int(settlement.goods_stock[good_id]))
	var adjustment := 1 if condition == "SHORTAGE" else (-1 if condition == "SURPLUS" else 0)
	settlement.goods_prices[good_id] = clampi(int(settlement.goods_prices[good_id]) + adjustment, int(good.minimum), int(good.maximum))


func get_active_war() -> War:
	for war: War in wars.values():
		if war.active:
			return war
	return null


func get_player_army() -> Army:
	var realm_id := player.homeland.to_lower().replace(" ", "_")
	for army: Army in armies.values():
		if army.kingdom_id == realm_id:
			return army
	return null


func get_regional_price_comparison() -> Array[String]:
	var comparison: Array[String] = []
	for good_id in GoodData.GOODS:
		var cheapest: Settlement
		var dearest: Settlement
		for settlement: Settlement in settlements.values():
			if cheapest == null or int(settlement.goods_prices[good_id]) < int(cheapest.goods_prices[good_id]):
				cheapest = settlement
			if dearest == null or int(settlement.goods_prices[good_id]) > int(dearest.goods_prices[good_id]):
				dearest = settlement
		var good_name: String = GoodData.get_good(good_id).name
		comparison.append("%s: %s %d  →  %s %d" % [good_name, cheapest.name, cheapest.goods_prices[good_id], dearest.name, dearest.goods_prices[good_id]])
	return comparison
