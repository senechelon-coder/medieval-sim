class_name Province
extends RefCounted

var id := ""
var name := "Unknown"
var owner_kingdom_id := ""
var settlement_ids: Array[String] = []
var neighbor_ids: Array[String] = []
var unrest := 10.0


func to_dict() -> Dictionary:
	return {"id": id, "name": name, "owner_kingdom_id": owner_kingdom_id, "settlement_ids": settlement_ids.duplicate(), "neighbor_ids": neighbor_ids.duplicate(), "unrest": unrest}


static func from_dict(data: Dictionary) -> Province:
	var province := Province.new()
	province.id = str(data.get("id", ""))
	province.name = str(data.get("name", "Unknown"))
	province.owner_kingdom_id = str(data.get("owner_kingdom_id", ""))
	province.unrest = float(data.get("unrest", 10.0))
	for settlement_id in data.get("settlement_ids", []):
		province.settlement_ids.append(str(settlement_id))
	for neighbor_id in data.get("neighbor_ids", []):
		province.neighbor_ids.append(str(neighbor_id))
	return province
