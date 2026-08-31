class_name ChildhoodEventData
extends RefCounted

const EVENTS := [
	{
		"id": "festival_day", "age": 14, "title": "THE FESTIVAL DAY",
		"intro": "A crowded festival fills the settlement with contests, music, and trade.",
		"description": "Your duties leave room for only one opportunity. Where will you spend the day?",
		"choices": [
			{"text": "ENTER THE CONTEST", "result": "You test yourself before the crowd and earn approving cheers.", "effects": {"health": 2, "standing": "Bold"}, "summary": "+2 Health • Bold standing"},
			{"text": "HELP A MARKET STALL", "result": "You help a busy trader and take a small share of the day's earnings.", "effects": {"wealth": 6, "standing": "Connected"}, "summary": "+6 Wealth • Connected standing"},
		],
	},
]
