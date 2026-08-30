extends Node

var player: PlayerCharacter


func create_player(profile: Dictionary) -> PlayerCharacter:
	player = PlayerCharacter.new()
	player.full_name = profile.get("full_name", "Unnamed")
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
	return player


func has_player() -> bool:
	return player != null


func clear() -> void:
	player = null
