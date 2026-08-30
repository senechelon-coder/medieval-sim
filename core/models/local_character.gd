class_name LocalCharacter
extends RefCounted

var id := ""
var full_name := "Unnamed"
var sex := "MALE"
var age := 30
var role := "Resident"
var location_id := ""
var alive := true
var death_year := 0
var relationship_to_player := 0
var spouse_id := ""
var father_id := ""
var mother_id := ""
var children_ids: Array[String] = []


func to_dict() -> Dictionary:
	return {"id": id, "full_name": full_name, "sex": sex, "age": age, "role": role, "location_id": location_id, "alive": alive, "death_year": death_year, "relationship_to_player": relationship_to_player, "spouse_id": spouse_id, "father_id": father_id, "mother_id": mother_id, "children_ids": children_ids.duplicate()}


static func from_dict(data: Dictionary) -> LocalCharacter:
	var character := LocalCharacter.new()
	character.id = str(data.get("id", ""))
	character.full_name = str(data.get("full_name", "Unnamed"))
	if data.has("sex"):
		character.sex = str(data.sex)
	else:
		character.sex = "FEMALE" if str(data.get("role", "")) in ["Mother", "Local Trader"] else "MALE"
	character.age = int(data.get("age", 30))
	character.role = str(data.get("role", "Resident"))
	character.location_id = str(data.get("location_id", ""))
	character.alive = bool(data.get("alive", true))
	character.death_year = int(data.get("death_year", 0))
	character.relationship_to_player = int(data.get("relationship_to_player", 0))
	character.spouse_id = str(data.get("spouse_id", ""))
	character.father_id = str(data.get("father_id", ""))
	character.mother_id = str(data.get("mother_id", ""))
	for child_id in data.get("children_ids", []):
		character.children_ids.append(str(child_id))
	return character
