extends Node

const SAVE_DIRECTORY := "user://saves"
const SAVE_PATH := "user://saves/slot_1.json"
const SAVE_VERSION := 1


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func get_save_summary() -> Dictionary:
	var payload := _read_save_payload()
	if payload.is_empty():
		return {}
	var player: Dictionary = payload.get("player", {})
	var date: Dictionary = payload.get("date", {})
	return {
		"name": player.get("full_name", "Unnamed"),
		"age": player.get("age", 1),
		"homeland": player.get("homeland", "Unknown homeland"),
		"year": date.get("year", 632),
	}


func save_game() -> bool:
	if not WorldState.has_player():
		return false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIRECTORY))
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	var payload := {
		"save_version": SAVE_VERSION,
		"date": {
			"day": TimeManager.current_date.day,
			"month": TimeManager.current_date.month,
			"year": TimeManager.current_date.year,
		},
		"player": WorldState.player.to_dict(),
	}
	file.store_string(JSON.stringify(payload))
	return true


func load_game() -> bool:
	var parsed := _read_save_payload()
	if parsed.is_empty():
		return false
	WorldState.load_player(parsed.player)
	TimeManager.load_date(parsed.date)
	MusicManager.play_faction_music(WorldState.player.homeland)
	return true


func _read_save_payload() -> Dictionary:
	if not has_save():
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or not parsed.has("player") or not parsed.has("date"):
		return {}
	return parsed
