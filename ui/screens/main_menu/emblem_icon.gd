extends Control
## Vector placeholder emblem: an hourglass holding a globe inside an
## astrolabe ring. Drop a res://art/ui/emblem.png in to replace it with
## real art — no code changes needed.

const EMBLEM_ART_PATH := "res://art/ui/emblem.png"

var _emblem_texture: Texture2D = null


func _ready() -> void:
	if ResourceLoader.exists(EMBLEM_ART_PATH):
		_emblem_texture = load(EMBLEM_ART_PATH)
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if _emblem_texture:
		draw_texture_rect(_emblem_texture, Rect2(Vector2.ZERO, size), false)
		return

	var w := size.x
	var h := size.y
	var center := Vector2(w * 0.5, h * 0.5)
	var gold := Color(0.85, 0.72, 0.45, 1.0)
	var dim_gold := Color(0.85, 0.72, 0.45, 0.45)
	var line_w := max(1.5, w * 0.006)

	# Outer astrolabe ring
	var ring_radius := w * 0.46
	draw_arc(center, ring_radius, 0.0, TAU, 64, dim_gold, line_w)

	# Cardinal ticks
	for i in range(4):
		var angle := i * PI * 0.5
		var tick_center := center + Vector2(cos(angle), sin(angle)) * ring_radius
		var tick_size := w * 0.02
		var diamond := PackedVector2Array([
			tick_center + Vector2(0, -tick_size),
			tick_center + Vector2(tick_size, 0),
			tick_center + Vector2(0, tick_size),
			tick_center + Vector2(-tick_size, 0),
		])
		draw_colored_polygon(diamond, gold)

	# Hourglass frame
	var hg_w := w * 0.34
	var hg_h := h * 0.5
	var top := center.y - hg_h * 0.5
	var bottom := center.y + hg_h * 0.5
	var left := center.x - hg_w * 0.5
	var right := center.x + hg_w * 0.5
	var waist := center.y

	var hourglass := PackedVector2Array([
		Vector2(left, top),
		Vector2(right, top),
		Vector2(center.x, waist),
		Vector2(right, bottom),
		Vector2(left, bottom),
		Vector2(center.x, waist),
		Vector2(left, top),
	])
	draw_polyline(hourglass, gold, line_w, true)
	draw_line(Vector2(left - w * 0.03, top), Vector2(right + w * 0.03, top), gold, line_w)
	draw_line(Vector2(left - w * 0.03, bottom), Vector2(right + w * 0.03, bottom), gold, line_w)

	# Globe inside the upper bulb
	var globe_radius := hg_w * 0.28
	var globe_center := Vector2(center.x, top + (waist - top) * 0.42)
	draw_arc(globe_center, globe_radius, 0.0, TAU, 32, gold, line_w * 0.8)
	draw_line(
		globe_center + Vector2(0, -globe_radius),
		globe_center + Vector2(0, globe_radius),
		gold, line_w * 0.6
	)
	var latitude := PackedVector2Array()
	for i in range(33):
		var t := TAU * i / 32.0
		latitude.append(globe_center + Vector2(cos(t) * globe_radius, sin(t) * globe_radius * 0.55))
	draw_polyline(latitude, gold, line_w * 0.6, true)
