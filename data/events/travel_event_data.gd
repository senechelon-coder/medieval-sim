class_name TravelEventData
extends RefCounted

const BENIGN_EVENTS := [
	{"text": "The road is quiet and you make good progress.", "effects": {}},
	{"text": "You share a meal with fellow travelers at a wayside inn.", "effects": {"wealth": -1}},
	{"text": "A merchant convoy passes, trading news of the road ahead.", "effects": {}},
	{"text": "Clear weather speeds the journey along a well-kept road.", "effects": {}},
	{"text": "You help a stranded traveler repair a broken cart wheel.", "effects": {"health": -1}},
	{"text": "A sudden rainstorm slows the way and soaks your goods.", "effects": {"health": -2}},
	{"text": "You trade words with a wandering scholar about the lands ahead.", "effects": {}},
	{"text": "A local guide points out a shortcut through the hills.", "effects": {}},
]
