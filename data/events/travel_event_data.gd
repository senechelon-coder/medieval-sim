class_name TravelEventData
extends RefCounted

const BENIGN_EVENTS_BY_HOMELAND := {
	"RASHIDUN CALIPHATE": [
		{"text": "You share dates and water with fellow travelers at a desert well.", "effects": {"wealth": -1}},
		{"text": "A caravan of pilgrims passes, trading news of the road ahead.", "effects": {}},
		{"text": "You rest beneath a palm grove as the midday heat passes.", "effects": {}},
		{"text": "A Bedouin guide points out a shorter path through the dunes.", "effects": {}},
		{"text": "Sandstorm winds slow the caravan and scour your supplies.", "effects": {"health": -2}},
		{"text": "The call to prayer echoes from a wayside settlement as you pass.", "effects": {}},
		{"text": "A camel in your party goes lame and must be tended to.", "effects": {"wealth": -2}},
	],
	"BYZANTINE EMPIRE": [
		{"text": "You rest at an old Roman waystation along the imperial road.", "effects": {"wealth": -1}},
		{"text": "A column of Byzantine soldiers marches past toward the frontier.", "effects": {}},
		{"text": "You pay a modest toll to cross a garrisoned bridge.", "effects": {"wealth": -2}},
		{"text": "Church bells mark the hour as you pass through a fortified town.", "effects": {}},
		{"text": "Autumn rain turns the paved road slick and slow.", "effects": {"health": -2}},
		{"text": "A merchant from Constantinople shares news of the capital.", "effects": {}},
		{"text": "You shelter overnight within an old imperial waystation's walls.", "effects": {}},
	],
	"SASANIAN EMPIRE": [
		{"text": "You rest at a caravanserai along the royal road.", "effects": {"wealth": -1}},
		{"text": "Smoke from a fire temple marks the settlement ahead.", "effects": {}},
		{"text": "Royal messengers on fast horses overtake your party.", "effects": {}},
		{"text": "You trade stories with merchants bound for Ctesiphon.", "effects": {}},
		{"text": "Dust winds off the plateau slow the journey.", "effects": {"health": -2}},
		{"text": "You pay a toll at a royal road checkpoint.", "effects": {"wealth": -2}},
		{"text": "A local guide warns of washed-out paths ahead and reroutes you.", "effects": {}},
	],
}

const DEFAULT_BENIGN_EVENTS := [
	{"text": "The road is quiet and you make good progress.", "effects": {}},
	{"text": "You share a meal with fellow travelers at a wayside inn.", "effects": {"wealth": -1}},
	{"text": "A merchant convoy passes, trading news of the road ahead.", "effects": {}},
	{"text": "Clear weather speeds the journey along a well-kept road.", "effects": {}},
]

const DANGER_LABELS_BY_HOMELAND := {
	"RASHIDUN CALIPHATE": "Desert Raiders",
	"BYZANTINE EMPIRE": "Highway Brigands",
	"SASANIAN EMPIRE": "Persian Brigands",
}
const SEA_DANGER_LABEL := "Pirates"
const DEFAULT_DANGER_LABEL := "Bandits"


static func benign_events_for(homeland: String) -> Array:
	return BENIGN_EVENTS_BY_HOMELAND.get(homeland, DEFAULT_BENIGN_EVENTS)


static func danger_label_for(homeland: String, trade_tier: String) -> String:
	if trade_tier == "ship":
		return SEA_DANGER_LABEL
	return DANGER_LABELS_BY_HOMELAND.get(homeland, DEFAULT_DANGER_LABEL)
