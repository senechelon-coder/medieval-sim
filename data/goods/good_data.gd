class_name GoodData
extends RefCounted

const GOODS := {
	"grain": {"name": "Grain", "base_price": 4, "minimum": 2, "maximum": 9},
	"dates": {"name": "Dates", "base_price": 6, "minimum": 3, "maximum": 12},
	"salt": {"name": "Salt", "base_price": 7, "minimum": 4, "maximum": 14},
	"cloth": {"name": "Cloth", "base_price": 11, "minimum": 6, "maximum": 20},
	"pottery": {"name": "Pottery", "base_price": 9, "minimum": 5, "maximum": 17},
	"iron": {"name": "Iron", "base_price": 14, "minimum": 8, "maximum": 25},
}


static func get_good(good_id: String) -> Dictionary:
	return GOODS.get(good_id, {})
