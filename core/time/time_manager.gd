extends Node

signal year_passed(new_year: int)

var current_date := SimDate.new()


func start_new_game(start_year := 632) -> void:
	current_date = SimDate.new(1, 1, start_year)


func advance_year() -> void:
	current_date.advance_year()
	year_passed.emit(current_date.year)


func year_label() -> String:
	return current_date.display_year()
