class_name NationEmblem
extends Control
## Small vector rosette shown beside the chosen faction's name.

@export var emblem_color: Color = Color(0.85, 0.72, 0.45, 1.0):
	set(value):
		emblem_color = value
		queue_redraw()


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var w := size.x
	var h := size.y
	var center := Vector2(w * 0.5, h * 0.5)
	var outer_radius := minf(w, h) * 0.48
	var line_w := maxf(1.5, w * 0.02)

	draw_arc(center, outer_radius, 0.0, TAU, 48, emblem_color, line_w)

	var petal_count := 8
	for i in range(petal_count):
		var angle := TAU * i / float(petal_count)
		var dir := Vector2(cos(angle), sin(angle))
		var tip := center + dir * outer_radius * 0.82
		var side := dir.rotated(PI * 0.5) * outer_radius * 0.09
		var petal := PackedVector2Array([
			center,
			center + side,
			tip,
			center - side,
		])
		draw_colored_polygon(petal, Color(emblem_color, 0.85))

	draw_circle(center, outer_radius * 0.12, emblem_color)
