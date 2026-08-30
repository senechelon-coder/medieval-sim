class_name BattleEventData
extends RefCounted

const BEATS := [
	{
		"time": "DAWN",
		"narration": "Horns sound across the field as the enemy line comes into view.",
		"choices": [
			{"text": "HOLD FORMATION", "result": "You hold your place as the ranks steady around you.", "effects": {"morale": 5}},
			{"text": "ADVANCE WITH THE VANGUARD", "result": "You push forward with the boldest of the line.", "effects": {"morale": 8, "health": -3}},
		],
	},
	{
		"time": "MIDDAY",
		"narration": "Arrows fall like rain as the two lines close.",
		"choices": [
			{"text": "RAISE YOUR SHIELD", "result": "You raise your shield and weather the volley.", "effects": {"health": -2}},
			{"text": "CHARGE THROUGH THE VOLLEY", "result": "You charge through the falling arrows toward the enemy line.", "effects": {"health": -6, "morale": 6}},
		],
	},
	{
		"time": "AFTERNOON",
		"narration": "The soldier beside you is struck down. The enemy line presses hard.",
		"choices": [
			{"text": "PROTECT YOUR COMPANIONS", "result": "You fight to hold the line for those beside you.", "effects": {"health": -5, "morale": 4}},
			{"text": "FIGHT FOR YOUR OWN SURVIVAL", "result": "You fight only to see the day through.", "effects": {"health": -2, "morale": -3}},
		],
	},
]
