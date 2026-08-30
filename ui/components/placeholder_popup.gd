extends PopupPanel
## Reusable "not built yet" popup used by menu buttons that don't have a real
## destination screen yet (New Game, Options, Credits, ...).

@onready var message_label: Label = %MessageLabel
@onready var close_button: Button = %CloseButton


func _ready() -> void:
	close_button.pressed.connect(hide)


func show_message(text: String) -> void:
	message_label.text = text
	popup_centered(Vector2(820, 420))
