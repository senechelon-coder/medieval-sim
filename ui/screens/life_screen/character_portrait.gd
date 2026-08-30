class_name CharacterPortrait
extends Control

var female := false:
	set(value):
		female = value
		queue_redraw()
var variant_seed := 1:
	set(value):
		variant_seed = value
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var centre := size * Vector2(0.5, 0.44)
	var scale_unit := minf(size.x, size.y)
	var dark := Color(0.055, 0.043, 0.031, 1.0)
	var gold := Color(0.67, 0.52, 0.29, 0.95)
	var rng := RandomNumberGenerator.new()
	rng.seed = variant_seed
	var skin := Color.from_hsv(0.075, rng.randf_range(0.38, 0.58), rng.randf_range(0.48, 0.72))
	var cloth := Color.from_hsv(rng.randf_range(0.05, 0.16), rng.randf_range(0.40, 0.68), rng.randf_range(0.15, 0.28))
	draw_rect(Rect2(Vector2.ZERO, size), dark)
	draw_circle(centre, scale_unit * 0.19, skin)
	draw_circle(centre + Vector2(0, scale_unit * 0.34), scale_unit * 0.31, cloth)
	var wrap := PackedVector2Array([
		centre + Vector2(-scale_unit * 0.22, -scale_unit * 0.05),
		centre + Vector2(-scale_unit * 0.13, -scale_unit * 0.24),
		centre + Vector2(scale_unit * 0.13, -scale_unit * 0.24),
		centre + Vector2(scale_unit * 0.22, -scale_unit * 0.05),
		centre + Vector2(scale_unit * 0.12, -scale_unit * 0.13),
		centre + Vector2(-scale_unit * 0.12, -scale_unit * 0.13),
	])
	draw_colored_polygon(wrap, gold.darkened(0.28))
	if not female:
		draw_arc(centre + Vector2(0, scale_unit * 0.075), scale_unit * 0.15, 0.15, PI - 0.15, 24, cloth, scale_unit * 0.07)
	draw_rect(Rect2(Vector2(1, 1), size - Vector2(2, 2)), Color.TRANSPARENT, false, 2.0)
	draw_line(Vector2(1, 1), Vector2(size.x - 1, 1), gold, 2.0)
	draw_line(Vector2(size.x - 1, 1), Vector2(size.x - 1, size.y - 1), gold, 2.0)
	draw_line(Vector2(size.x - 1, size.y - 1), Vector2(1, size.y - 1), gold, 2.0)
	draw_line(Vector2(1, size.y - 1), Vector2(1, 1), gold, 2.0)
