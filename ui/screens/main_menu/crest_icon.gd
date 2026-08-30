extends Control
## Vector placeholder crest. Drop a res://art/ui/crest.png in to replace it with real art.

const CREST_ART_PATH := "res://art/ui/crest.png"

var _crest_texture: Texture2D = null

func _ready() -> void:
	if ResourceLoader.exists(CREST_ART_PATH):
		_crest_texture = load(CREST_ART_PATH)
	resized.connect(queue_redraw)
	queue_redraw()

func _draw() -> void:
	if _crest_texture:
		draw_texture_rect(_crest_texture, Rect2(Vector2.ZERO, size), false)
		return

	var w := size.x
	var h := size.y
	var gold := Color(0.788, 0.635, 0.294, 1.0)
	var fill := Color(0.169, 0.106, 0.067, 1.0)
	var shield := PackedVector2Array([
		Vector2(w * 0.5, 0.0),
		Vector2(w, h * 0.22),
		Vector2(w, h * 0.55),
		Vector2(w * 0.5, h),
		Vector2(0.0, h * 0.55),
		Vector2(0.0, h * 0.22),
	])
	draw_colored_polygon(shield, fill)
	draw_polyline(shield + PackedVector2Array([shield[0]]), gold, 4.0, true)
	draw_line(Vector2(w * 0.5, h * 0.18), Vector2(w * 0.5, h * 0.82), gold, 4.0)
	draw_line(Vector2(w * 0.22, h * 0.42), Vector2(w * 0.78, h * 0.42), gold, 4.0)
