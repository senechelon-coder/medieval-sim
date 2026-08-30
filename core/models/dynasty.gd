class_name Dynasty
extends RefCounted

var id := ""
var name := "Unnamed House"
var member_ids: Array[String] = []
var head_character_id := ""
var prestige := 0


func to_dict() -> Dictionary:
	return {"id": id, "name": name, "member_ids": member_ids.duplicate(), "head_character_id": head_character_id, "prestige": prestige}


static func from_dict(data: Dictionary) -> Dynasty:
	var dynasty := Dynasty.new()
	dynasty.id = str(data.get("id", ""))
	dynasty.name = str(data.get("name", "Unnamed House"))
	dynasty.head_character_id = str(data.get("head_character_id", ""))
	dynasty.prestige = int(data.get("prestige", 0))
	for member_id in data.get("member_ids", []):
		dynasty.member_ids.append(str(member_id))
	return dynasty
