extends Control
## Thin ornamental divider: a line, a small hollow circle, a line.


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var w := size.x
	var mid_y := size.y * 0.5
	var gold := Color(0.75, 0.63, 0.40, 0.7)
	var circle_radius := size.y * 0.18
	var gap := circle_radius * 2.6
	var line_width := 1.5

	draw_line(Vector2(0.0, mid_y), Vector2(w * 0.5 - gap * 0.5, mid_y), gold, line_width)
	draw_line(Vector2(w * 0.5 + gap * 0.5, mid_y), Vector2(w, mid_y), gold, line_width)
	draw_arc(Vector2(w * 0.5, mid_y), circle_radius, 0.0, TAU, 24, gold, line_width)
