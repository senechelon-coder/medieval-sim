class_name Army
extends RefCounted

var id := ""
var kingdom_id := ""
var strength := 100
var morale := 70.0


func to_dict() -> Dictionary:
	return {"id": id, "kingdom_id": kingdom_id, "strength": strength, "morale": morale}


static func from_dict(data: Dictionary) -> Army:
	var army := Army.new()
	army.id = str(data.get("id", ""))
	army.kingdom_id = str(data.get("kingdom_id", ""))
	army.strength = int(data.get("strength", 100))
	army.morale = float(data.get("morale", 70.0))
	return army
