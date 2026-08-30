class_name EventResolver
extends RefCounted


static func event_for_age(age: int, completed_events: Array[String]) -> Dictionary:
	for event in ChildhoodEventData.EVENTS:
		if int(event.age) == age and str(event.id) not in completed_events:
			return event
	return {}


static func event_by_id(event_id: String) -> Dictionary:
	for event in ChildhoodEventData.EVENTS:
		if str(event.id) == event_id:
			return event
	return {}
