class_name ChildhoodEventData
extends RefCounted

const EVENTS := [
	{
		"id": "lost_purse", "age": 6, "title": "A LOST PURSE",
		"intro": "You discover a merchant's lost purse near the market road.",
		"description": "A merchant's purse lies unattended beside the market road. What will you do?",
		"choices": [
			{"text": "RETURN IT TO THE MERCHANT", "result": "You return it to its owner. Your honesty becomes known.", "effects": {"standing": "Honorable"}, "summary": "Honorable standing"},
			{"text": "BRING IT HOME", "result": "You quietly bring it home. The money helps, but whispers follow.", "effects": {"wealth": 8, "standing": "Questioned"}, "summary": "+8 Wealth • Questioned standing"},
		],
	},
	{
		"id": "childhood_fever", "age": 8, "title": "A SUDDEN FEVER",
		"intro": "A sudden fever leaves you weak for several days.",
		"description": "Your family urges you to rest, but household work remains unfinished.",
		"choices": [
			{"text": "REST AND RECOVER", "result": "You are allowed to recover beside the hearth.", "effects": {"health": 5, "wealth": -2}, "summary": "+5 Health • -2 Wealth"},
			{"text": "KEEP HELPING", "result": "You work through the fever and worsen before recovering.", "effects": {"health": -8, "wealth": 3}, "summary": "-8 Health • +3 Wealth"},
		],
	},
	{
		"id": "mentors_offer", "age": 10, "title": "A MENTOR'S OFFER",
		"intro": "A respected elder notices your potential and offers personal guidance.",
		"description": "Learning from the elder will cost the household your daily help. What matters most?",
		"choices": [
			{"text": "ACCEPT THE GUIDANCE", "result": "You accept the elder's guidance and discover a hunger for knowledge.", "effects": {"wealth": -3, "standing": "Promising", "trait": "Curious"}, "summary": "-3 Wealth • Curious trait • Promising standing"},
			{"text": "REMAIN WITH YOUR FAMILY", "result": "You remain beside your family and become someone they can rely upon.", "effects": {"wealth": 4, "standing": "Dependable", "trait": "Loyal"}, "summary": "+4 Wealth • Loyal trait • Dependable standing"},
		],
	},
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
