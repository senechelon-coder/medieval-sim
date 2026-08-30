class_name SimDate
extends RefCounted

var day: int
var month: int
var year: int


func _init(start_day := 1, start_month := 1, start_year := 632) -> void:
	day = start_day
	month = start_month
	year = start_year


func advance_year() -> void:
	year += 1


func display_year() -> String:
	return "%d AD" % year
