class_name StatBar
extends Control
## A small color-coded gauge. Set `ratio` (0..1); fill color interpolates
## green -> gold -> red as the value drops, unless `fixed_color` is set.

@export var ratio: float = 1.0:
	set(v):
		ratio = clampf(v, 0.0, 1.0)
		queue_redraw()
@export var fixed_color: Color = Color(0, 0, 0, 0):
	set(v):
		fixed_color = v
		queue_redraw()

const TRACK_COLOR := Color(0.05, 0.045, 0.035, 0.85)
const BORDER_COLOR := Color(0.55, 0.47, 0.34, 0.7)
const HEALTHY_COLOR := Color(0.55, 0.75, 0.4, 1.0)
const WARNING_COLOR := Color(0.85, 0.72, 0.35, 1.0)
const CRITICAL_COLOR := Color(0.82, 0.32, 0.28, 1.0)


func _ready() -> void:
	resized.connect(queue_redraw)


func _fill_color() -> Color:
	if fixed_color.a > 0.0:
		return fixed_color
	if ratio >= 0.55:
		return HEALTHY_COLOR.lerp(WARNING_COLOR, 1.0 - (ratio - 0.55) / 0.45)
	return WARNING_COLOR.lerp(CRITICAL_COLOR, 1.0 - ratio / 0.55)


func _draw() -> void:
	var h := size.y
	var w := size.x
	var radius := h * 0.5
	draw_rect(Rect2(0, 0, w, h), TRACK_COLOR, true, -1.0, true)
	if ratio > 0.0:
		draw_rect(Rect2(0, 0, w * ratio, h), _fill_color(), true, -1.0, true)
	draw_rect(Rect2(0, 0, w, h), BORDER_COLOR, false, max(1.0, h * 0.06), true)
