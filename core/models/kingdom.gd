class_name Kingdom
extends RefCounted

var id := ""
var name := "Unknown Realm"
var province_ids: Array[String] = []
var treasury := 1000


func to_dict() -> Dictionary:
	return {"id": id, "name": name, "province_ids": province_ids.duplicate(), "treasury": treasury}


static func from_dict(data: Dictionary) -> Kingdom:
	var kingdom := Kingdom.new()
	kingdom.id = str(data.get("id", ""))
	kingdom.name = str(data.get("name", "Unknown Realm"))
	kingdom.treasury = int(data.get("treasury", 1000))
	for province_id in data.get("province_ids", []):
		kingdom.province_ids.append(str(province_id))
	return kingdom
