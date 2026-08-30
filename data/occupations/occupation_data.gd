class_name OccupationData
extends RefCounted

const OCCUPATIONS := {
	"farmer": {"name": "Farmer", "annual_wage": 6, "standing": "Working Commoner", "description": "Work fields and livestock to sustain the settlement."},
	"artisan": {"name": "Artisan", "annual_wage": 8, "standing": "Skilled Commoner", "description": "Produce practical goods through a learned household craft."},
	"trader": {"name": "Trader", "annual_wage": 10, "standing": "Market Regular", "description": "Buy, sell, and arrange goods within the local market."},
	"soldier": {"name": "Soldier", "annual_wage": 7, "standing": "Levy Soldier", "description": "Serve under local authority and train for armed duty."},
	"scholar": {"name": "Scholar", "annual_wage": 5, "standing": "Learned Assistant", "description": "Study letters, records, law, and matters of faith."},
}


static func get_occupation(occupation_id: String) -> Dictionary:
	return OCCUPATIONS.get(occupation_id, {})


static func rank_for_experience(experience: int) -> Dictionary:
	if experience >= 7:
		return {"name": "Master", "wage_bonus": 5}
	if experience >= 3:
		return {"name": "Experienced", "wage_bonus": 2}
	return {"name": "Novice", "wage_bonus": 0}
