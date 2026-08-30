extends Control
## Reusable "not built yet" popup used by menu buttons that don't have a real
## destination screen yet (New Game, Options, Credits, ...).

@onready var message_label: Label = %MessageLabel
@onready var close_button: Button = %CloseButton
@onready var panel_container: PanelContainer = %PanelContainer


func _ready() -> void:
	close_button.pressed.connect(hide)
	resized.connect(_apply_responsive_size)


func show_message(text: String) -> void:
	message_label.text = text
	_apply_responsive_size()
	show()
	close_button.grab_focus.call_deferred()


func _apply_responsive_size() -> void:
	var canvas_size := Vector2(get_window().content_scale_size)
	if canvas_size.x <= 0.0 or canvas_size.y <= 0.0:
		canvas_size = Vector2(1080.0, 1920.0)
	panel_container.custom_minimum_size = Vector2(
		clampf(canvas_size.x * 0.76, 560.0, 820.0),
		clampf(canvas_size.y * 0.19, 280.0, 380.0)
	)
