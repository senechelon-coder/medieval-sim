class_name TradeTierData
extends RefCounted

const TIERS := {
	"peddler": {"name": "Travelling Peddler", "cargo_capacity": 10, "reputation_required": 0, "cost": 0, "next": "caravan"},
	"caravan": {"name": "Caravan Owner", "cargo_capacity": 30, "reputation_required": 15, "cost": 40, "next": "ship"},
	"ship": {"name": "Ship Owner", "cargo_capacity": 80, "reputation_required": 40, "cost": 120, "next": ""},
}


static func get_tier(tier_id: String) -> Dictionary:
	return TIERS.get(tier_id, TIERS["peddler"])


static func next_tier_id(tier_id: String) -> String:
	return str(get_tier(tier_id).get("next", ""))
