class_name CompassEmblem
extends Control
## Small vector compass rose shown beside the header brand label.
## Same hand-drawn approach as the other vector icons in this project
## (stat_icon.gd, nation_emblem.gd, divider.gd).

@export var icon_color: Color = Color(0.85, 0.72, 0.45, 1.0):
	set(value):
		icon_color = value
		queue_redraw()


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var w := size.x
	var h := size.y
	var center := Vector2(w * 0.5, h * 0.5)
	var outer_r := minf(w, h) * 0.46
	var line_w := maxf(1.2, outer_r * 0.09)

	draw_arc(center, outer_r, 0.0, TAU, 28, icon_color, line_w)
	draw_arc(center, outer_r * 0.14, 0.0, TAU, 12, icon_color, line_w * 0.8)

	var long_angles := PackedFloat32Array([0.0, PI * 0.5, PI, PI * 1.5])
	for angle in long_angles:
		var dir := Vector2(sin(angle), -cos(angle))
		draw_line(center + dir * outer_r * 0.22, center + dir * outer_r * 0.86, icon_color, line_w)

	var short_angles := PackedFloat32Array([PI * 0.25, PI * 0.75, PI * 1.25, PI * 1.75])
	for angle in short_angles:
		var dir := Vector2(sin(angle), -cos(angle))
		draw_line(center + dir * outer_r * 0.22, center + dir * outer_r * 0.58, icon_color, line_w * 0.75)
