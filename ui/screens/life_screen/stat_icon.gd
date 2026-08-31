class_name StatIcon
extends Control
## Small vector glyph shown beside a stat label (age, health, wealth,
## standing, trait, occupation). Same hand-drawn approach as the other
## vector icons in this project (nation_emblem.gd, divider.gd).

@export var icon_type: String = "age":
	set(value):
		icon_type = value
		queue_redraw()
@export var icon_color: Color = Color(0.85, 0.72, 0.45, 1.0):
	set(value):
		icon_color = value
		queue_redraw()


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var w := size.x
	var h := size.y
	var line_w := maxf(1.4, w * 0.09)
	match icon_type:
		"age": _draw_hourglass(w, h, line_w)
		"health": _draw_heart(w, h, line_w)
		"wealth": _draw_coin(w, h, line_w)
		"standing": _draw_scale(w, h, line_w)
		"trait": _draw_gem(w, h, line_w)
		"occupation": _draw_tools(w, h, line_w)
		"life_stage": _draw_house(w, h, line_w)
		"life": _draw_tree(w, h, line_w)
		"world": _draw_world(w, h, line_w)
		"character": _draw_person(w, h, line_w)
		"more": _draw_grid(w, h)


func _draw_hourglass(w: float, h: float, line_w: float) -> void:
	var top := h * 0.12
	var bottom := h * 0.88
	var mid := h * 0.5
	var left := w * 0.2
	var right := w * 0.8
	var pts := PackedVector2Array([
		Vector2(left, top), Vector2(right, top), Vector2(w * 0.5, mid),
		Vector2(right, bottom), Vector2(left, bottom), Vector2(w * 0.5, mid), Vector2(left, top),
	])
	draw_polyline(pts, icon_color, line_w, true)
	draw_line(Vector2(left - w * 0.06, top), Vector2(right + w * 0.06, top), icon_color, line_w)
	draw_line(Vector2(left - w * 0.06, bottom), Vector2(right + w * 0.06, bottom), icon_color, line_w)


func _draw_heart(w: float, h: float, line_w: float) -> void:
	var cx := w * 0.5
	var r := w * 0.22
	draw_arc(Vector2(cx - r * 0.9, h * 0.38), r, PI, 0.0, 20, icon_color, line_w)
	draw_arc(Vector2(cx + r * 0.9, h * 0.38), r, PI, 0.0, 20, icon_color, line_w)
	var pts := PackedVector2Array([
		Vector2(cx - r * 1.85, h * 0.4), Vector2(cx, h * 0.86), Vector2(cx + r * 1.85, h * 0.4),
	])
	draw_polyline(pts, icon_color, line_w, true)


func _draw_coin(w: float, h: float, line_w: float) -> void:
	draw_arc(Vector2(w * 0.5, h * 0.5), w * 0.32, 0.0, TAU, 24, icon_color, line_w)
	draw_line(Vector2(w * 0.5, h * 0.3), Vector2(w * 0.5, h * 0.7), icon_color, line_w * 0.8)


func _draw_scale(w: float, h: float, line_w: float) -> void:
	draw_line(Vector2(w * 0.5, h * 0.1), Vector2(w * 0.5, h * 0.82), icon_color, line_w)
	draw_line(Vector2(w * 0.16, h * 0.28), Vector2(w * 0.84, h * 0.28), icon_color, line_w)
	draw_arc(Vector2(w * 0.16, h * 0.46), w * 0.13, PI * 0.15, PI * 0.85, 12, icon_color, line_w * 0.8)
	draw_arc(Vector2(w * 0.84, h * 0.46), w * 0.13, PI * 0.15, PI * 0.85, 12, icon_color, line_w * 0.8)
	draw_line(Vector2(w * 0.32, h * 0.86), Vector2(w * 0.68, h * 0.86), icon_color, line_w)


func _draw_gem(w: float, h: float, line_w: float) -> void:
	var pts := PackedVector2Array([
		Vector2(w * 0.5, h * 0.1), Vector2(w * 0.85, h * 0.38), Vector2(w * 0.68, h * 0.9),
		Vector2(w * 0.32, h * 0.9), Vector2(w * 0.15, h * 0.38), Vector2(w * 0.5, h * 0.1),
	])
	draw_polyline(pts, icon_color, line_w, true)
	draw_line(Vector2(w * 0.15, h * 0.38), Vector2(w * 0.85, h * 0.38), icon_color, line_w * 0.7)


func _draw_tools(w: float, h: float, line_w: float) -> void:
	draw_line(Vector2(w * 0.18, h * 0.18), Vector2(w * 0.82, h * 0.82), icon_color, line_w)
	draw_line(Vector2(w * 0.82, h * 0.18), Vector2(w * 0.18, h * 0.82), icon_color, line_w)


func _draw_house(w: float, h: float, line_w: float) -> void:
	var roof := PackedVector2Array([
		Vector2(w * 0.14, h * 0.5), Vector2(w * 0.5, h * 0.14), Vector2(w * 0.86, h * 0.5),
	])
	draw_polyline(roof, icon_color, line_w, true)
	draw_line(Vector2(w * 0.24, h * 0.46), Vector2(w * 0.24, h * 0.86), icon_color, line_w)
	draw_line(Vector2(w * 0.76, h * 0.46), Vector2(w * 0.76, h * 0.86), icon_color, line_w)
	draw_line(Vector2(w * 0.24, h * 0.86), Vector2(w * 0.76, h * 0.86), icon_color, line_w)
	draw_line(Vector2(w * 0.44, h * 0.86), Vector2(w * 0.44, h * 0.6), icon_color, line_w * 0.8)
	draw_line(Vector2(w * 0.56, h * 0.86), Vector2(w * 0.56, h * 0.6), icon_color, line_w * 0.8)
	draw_line(Vector2(w * 0.44, h * 0.6), Vector2(w * 0.56, h * 0.6), icon_color, line_w * 0.8)


func _draw_tree(w: float, h: float, line_w: float) -> void:
	draw_line(Vector2(w * 0.5, h * 0.38), Vector2(w * 0.5, h * 0.9), icon_color, line_w)
	draw_arc(Vector2(w * 0.5, h * 0.34), w * 0.29, 0.0, TAU, 24, icon_color, line_w)
	draw_line(Vector2(w * 0.25, h * 0.9), Vector2(w * 0.75, h * 0.9), icon_color, line_w)
	draw_line(Vector2(w * 0.5, h * 0.62), Vector2(w * 0.32, h * 0.49), icon_color, line_w * 0.75)
	draw_line(Vector2(w * 0.5, h * 0.55), Vector2(w * 0.7, h * 0.4), icon_color, line_w * 0.75)


func _draw_world(w: float, h: float, line_w: float) -> void:
	var center := Vector2(w * 0.5, h * 0.5)
	var radius := minf(w, h) * 0.38
	draw_arc(center, radius, 0.0, TAU, 28, icon_color, line_w)
	draw_arc(center, radius * 0.48, 0.0, TAU, 24, icon_color, line_w * 0.7)
	draw_line(Vector2(center.x - radius, center.y), Vector2(center.x + radius, center.y), icon_color, line_w * 0.7)
	draw_line(Vector2(center.x, center.y - radius), Vector2(center.x, center.y + radius), icon_color, line_w * 0.7)


func _draw_person(w: float, h: float, line_w: float) -> void:
	draw_arc(Vector2(w * 0.5, h * 0.3), w * 0.17, 0.0, TAU, 20, icon_color, line_w)
	draw_arc(Vector2(w * 0.5, h * 0.82), w * 0.32, PI, TAU, 20, icon_color, line_w)
	draw_line(Vector2(w * 0.18, h * 0.82), Vector2(w * 0.82, h * 0.82), icon_color, line_w)


func _draw_grid(w: float, h: float) -> void:
	var radius := minf(w, h) * 0.065
	for row in range(3):
		for column in range(3):
			draw_circle(Vector2(w * (0.25 + column * 0.25), h * (0.25 + row * 0.25)), radius, icon_color)
