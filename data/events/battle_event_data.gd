class_name BattleEventData
extends RefCounted

const STAGES := ["DAWN", "MIDDAY", "AFTERNOON"]

const BEATS_BY_RIVAL := {
	"Byzantine Empire": {
		"DAWN": [
			{
				"narration": "Byzantine trumpets sound as their disciplined ranks form a wall of shields across the field.",
				"choices": [
					{"text": "HOLD FORMATION", "result": "You hold your place as the shield wall opposite steadies to match.", "effects": {"morale": 5}},
					{"text": "ADVANCE WITH THE VANGUARD", "result": "You push forward with the boldest of the line toward the waiting shields.", "effects": {"morale": 8, "health": -3}},
				],
			},
			{
				"narration": "Mist clings to the ground as Byzantine cataphracts wheel into position on the flank.",
				"choices": [
					{"text": "HOLD FORMATION", "result": "You hold your place and watch the armored riders circle.", "effects": {"morale": 4}},
					{"text": "ADVANCE WITH THE VANGUARD", "result": "You press forward before the cataphracts can fully form up.", "effects": {"morale": 7, "health": -4}},
				],
			},
		],
		"MIDDAY": [
			{
				"narration": "Byzantine archers loose volley after volley into your advancing line.",
				"choices": [
					{"text": "RAISE YOUR SHIELD", "result": "You raise your shield and weather the volley.", "effects": {"health": -2}},
					{"text": "CHARGE THROUGH THE VOLLEY", "result": "You charge through the falling arrows toward the enemy line.", "effects": {"health": -6, "morale": 6}},
				],
			},
			{
				"narration": "Armored cataphracts grind forward, immovable as a wall of iron.",
				"choices": [
					{"text": "BRACE THE LINE", "result": "You brace with the line and absorb the charge's shock.", "effects": {"health": -4}},
					{"text": "COUNTER-CHARGE", "result": "You break ranks to meet the cataphracts head-on.", "effects": {"health": -7, "morale": 7}},
				],
			},
		],
		"AFTERNOON": [
			{
				"narration": "A comrade falls beside you as the Byzantine line refuses to break.",
				"choices": [
					{"text": "PROTECT YOUR COMPANIONS", "result": "You fight to hold the line for those beside you.", "effects": {"health": -5, "morale": 4}},
					{"text": "FIGHT FOR YOUR OWN SURVIVAL", "result": "You fight only to see the day through.", "effects": {"health": -2, "morale": -3}},
				],
			},
			{
				"narration": "The Byzantine standard wavers as both sides tire in the afternoon heat.",
				"choices": [
					{"text": "PRESS THE ATTACK", "result": "You press forward, sensing the enemy's line is close to breaking.", "effects": {"health": -5, "morale": 6}},
					{"text": "HOLD YOUR GROUND", "result": "You hold steady, letting exhaustion work against the enemy first.", "effects": {"health": -2, "morale": 2}},
				],
			},
		],
	},
	"Sasanian Empire": {
		"DAWN": [
			{
				"narration": "War elephants trumpet at the center of the Sasanian line, iron-plated and terrible.",
				"choices": [
					{"text": "HOLD FORMATION", "result": "You hold your place as the great beasts sway at the enemy center.", "effects": {"morale": 5}},
					{"text": "ADVANCE WITH THE VANGUARD", "result": "You push forward before the elephants can be driven into a charge.", "effects": {"morale": 8, "health": -3}},
				],
			},
			{
				"narration": "Sasanian horse archers wheel and loose arrows from the saddle before your ranks can close.",
				"choices": [
					{"text": "HOLD FORMATION", "result": "You hold your place under the harassing fire.", "effects": {"morale": 4}},
					{"text": "ADVANCE WITH THE VANGUARD", "result": "You push forward to close the distance and deny them room to shoot.", "effects": {"morale": 7, "health": -4}},
				],
			},
		],
		"MIDDAY": [
			{
				"narration": "An elephant breaks from the line, scattering men before it.",
				"choices": [
					{"text": "STAND FIRM AGAINST THE BEAST", "result": "You stand firm as the elephant is turned aside by the line's spears.", "effects": {"health": -4}},
					{"text": "FALL BACK AND REGROUP", "result": "You fall back with your section rather than face the beast head-on.", "effects": {"health": -1, "morale": -3}},
				],
			},
			{
				"narration": "Armored Sasanian cataphracts grind forward, immovable as a wall of iron.",
				"choices": [
					{"text": "BRACE THE LINE", "result": "You brace with the line and absorb the charge's shock.", "effects": {"health": -4}},
					{"text": "COUNTER-CHARGE", "result": "You break ranks to meet the cataphracts head-on.", "effects": {"health": -7, "morale": 7}},
				],
			},
		],
		"AFTERNOON": [
			{
				"narration": "A comrade falls beside you as the Sasanian nobles fight on, unwilling to yield.",
				"choices": [
					{"text": "PROTECT YOUR COMPANIONS", "result": "You fight to hold the line for those beside you.", "effects": {"health": -5, "morale": 4}},
					{"text": "FIGHT FOR YOUR OWN SURVIVAL", "result": "You fight only to see the day through.", "effects": {"health": -2, "morale": -3}},
				],
			},
			{
				"narration": "Dust and noise swallow the field as the Sasanian center begins to waver.",
				"choices": [
					{"text": "PRESS THE ATTACK", "result": "You press forward, sensing the enemy's line is close to breaking.", "effects": {"health": -5, "morale": 6}},
					{"text": "HOLD YOUR GROUND", "result": "You hold steady, letting exhaustion work against the enemy first.", "effects": {"health": -2, "morale": 2}},
				],
			},
		],
	},
	"Rashidun Caliphate": {
		"DAWN": [
			{
				"narration": "Swift Arab cavalry appear at the ridge line, sunlight flashing off spearpoints.",
				"choices": [
					{"text": "HOLD FORMATION", "result": "You hold your place as the riders survey the field.", "effects": {"morale": 5}},
					{"text": "ADVANCE WITH THE VANGUARD", "result": "You push forward before the cavalry can build up speed.", "effects": {"morale": 8, "health": -3}},
				],
			},
			{
				"narration": "The Rashidun line advances on foot, disciplined and unhurried despite the heat.",
				"choices": [
					{"text": "HOLD FORMATION", "result": "You hold your place and let the heat work against them first.", "effects": {"morale": 4}},
					{"text": "ADVANCE WITH THE VANGUARD", "result": "You push forward to meet their advance head-on.", "effects": {"morale": 7, "health": -4}},
				],
			},
		],
		"MIDDAY": [
			{
				"narration": "Mounted raiders wheel around your flank, striking and withdrawing before you can respond.",
				"choices": [
					{"text": "TIGHTEN THE LINE", "result": "You tighten the line and deny the raiders an opening.", "effects": {"health": -3}},
					{"text": "PURSUE THE RAIDERS", "result": "You break formation to chase down a rider, and pay for it.", "effects": {"health": -7, "morale": 6}},
				],
			},
			{
				"narration": "The Rashidun line holds firm under the midday sun, undaunted by heat that saps your own men.",
				"choices": [
					{"text": "BRACE THE LINE", "result": "You brace with the line and endure the heat alongside your comrades.", "effects": {"health": -4}},
					{"text": "COUNTER-CHARGE", "result": "You break ranks to press the advantage while you still have strength.", "effects": {"health": -7, "morale": 7}},
				],
			},
		],
		"AFTERNOON": [
			{
				"narration": "A comrade falls beside you as the desert warriors press their advantage.",
				"choices": [
					{"text": "PROTECT YOUR COMPANIONS", "result": "You fight to hold the line for those beside you.", "effects": {"health": -5, "morale": 4}},
					{"text": "FIGHT FOR YOUR OWN SURVIVAL", "result": "You fight only to see the day through.", "effects": {"health": -2, "morale": -3}},
				],
			},
			{
				"narration": "The Rashidun war-cries rise as their line surges forward once more.",
				"choices": [
					{"text": "PRESS THE ATTACK", "result": "You press forward, sensing the enemy's line is close to breaking.", "effects": {"health": -5, "morale": 6}},
					{"text": "HOLD YOUR GROUND", "result": "You hold steady, letting exhaustion work against the enemy first.", "effects": {"health": -2, "morale": 2}},
				],
			},
		],
	},
}

const DEFAULT_BEATS := {
	"DAWN": [
		{
			"narration": "Horns sound across the field as the enemy line comes into view.",
			"choices": [
				{"text": "HOLD FORMATION", "result": "You hold your place as the ranks steady around you.", "effects": {"morale": 5}},
				{"text": "ADVANCE WITH THE VANGUARD", "result": "You push forward with the boldest of the line.", "effects": {"morale": 8, "health": -3}},
			],
		},
	],
	"MIDDAY": [
		{
			"narration": "Arrows fall like rain as the two lines close.",
			"choices": [
				{"text": "RAISE YOUR SHIELD", "result": "You raise your shield and weather the volley.", "effects": {"health": -2}},
				{"text": "CHARGE THROUGH THE VOLLEY", "result": "You charge through the falling arrows toward the enemy line.", "effects": {"health": -6, "morale": 6}},
			],
		},
	],
	"AFTERNOON": [
		{
			"narration": "The soldier beside you is struck down. The enemy line presses hard.",
			"choices": [
				{"text": "PROTECT YOUR COMPANIONS", "result": "You fight to hold the line for those beside you.", "effects": {"health": -5, "morale": 4}},
				{"text": "FIGHT FOR YOUR OWN SURVIVAL", "result": "You fight only to see the day through.", "effects": {"health": -2, "morale": -3}},
			],
		},
	],
}


static func generate_battle(rival_name: String) -> Array[Dictionary]:
	var pool: Dictionary = BEATS_BY_RIVAL.get(rival_name, DEFAULT_BEATS)
	var beats: Array[Dictionary] = []
	for stage in STAGES:
		var options: Array = pool.get(stage, DEFAULT_BEATS[stage])
		var chosen: Dictionary = options[randi() % options.size()]
		beats.append({"time": stage, "narration": chosen.narration, "choices": chosen.choices})
	return beats
