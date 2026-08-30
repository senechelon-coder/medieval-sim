extends Control
## Faint decorative ring arcs echoing the emblem's astrolabe ring.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var w := size.x
	var h := size.y
	var faint := Color(0.75, 0.63, 0.40, 0.10)
	var very_faint := Color(0.75, 0.63, 0.40, 0.06)

	draw_arc(Vector2(w * 0.08, h * 0.12), w * 0.55, 0.0, TAU, 96, faint, 1.0)
	draw_arc(Vector2(w * 0.95, h * 0.85), w * 0.5, 0.0, TAU, 96, very_faint, 1.0)
	draw_arc(Vector2(w * 0.5, h * 0.05), w * 0.7, 0.0, TAU, 96, very_faint, 1.0)
