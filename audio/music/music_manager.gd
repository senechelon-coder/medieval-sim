extends Node

const FACTION_MUSIC := {
	"RASHIDUN CALIPHATE": "res://audio/music/rashidun_caliphate.mp3",
	"BYZANTINE EMPIRE": "res://audio/music/byzantine_empire.mp3",
	"SASANIAN EMPIRE": "res://audio/music/sasanian_empire.mp3",
}

var current_faction := ""
var player: AudioStreamPlayer


func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.name = "MusicPlayer"
	player.volume_db = -10.0
	add_child(player)


func play_faction_music(faction: String) -> void:
	var music_path: String = FACTION_MUSIC.get(faction, "")
	if music_path == "":
		return
	if current_faction == faction and player.playing:
		return
	var stream: AudioStream = load(music_path)
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	player.stream = stream
	current_faction = faction
	player.play()


func stop_music() -> void:
	player.stop()
	player.stream = null
	current_faction = ""
