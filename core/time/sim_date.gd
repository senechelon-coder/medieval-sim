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


func advance_days(amount: int) -> void:
	day += amount
	while day > 30:
		day -= 30
		month += 1
		while month > 12:
			month -= 12
			year += 1


func display_year() -> String:
	return "%d AD" % year


const MONTH_NAMES := [
	"January", "February", "March", "April", "May", "June",
	"July", "August", "September", "October", "November", "December",
]


func display_date() -> String:
	var month_name: String = MONTH_NAMES[clampi(month, 1, 12) - 1]
	return "%s of %s" % [_ordinal(day), month_name]


func _ordinal(value: int) -> String:
	var suffix := "th"
	if value % 100 < 11 or value % 100 > 13:
		match value % 10:
			1: suffix = "st"
			2: suffix = "nd"
			3: suffix = "rd"
	return "%d%s" % [value, suffix]
