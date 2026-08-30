class_name PlayerCharacter
extends RefCounted

var full_name := "Unnamed"
var age := 1
var sex := "MALE"
var homeland := "RASHIDUN CALIPHATE"
var birthplace := "Medina"
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
var chronicle: Array[String] = []


func to_dict() -> Dictionary:
	return {
		"full_name": full_name, "age": age, "sex": sex,
		"homeland": homeland, "birthplace": birthplace,
		"family_origin": family_origin, "father_name": father_name,
		"mother_name": mother_name, "culture": culture, "faith": faith,
		"birth_season": birth_season, "appearance_seed": appearance_seed,
		"health": health, "wealth": wealth, "standing": standing,
		"upbringing": upbringing, "primary_trait": primary_trait,
		"apprenticeship": apprenticeship, "chronicle": chronicle.duplicate(),
	}
