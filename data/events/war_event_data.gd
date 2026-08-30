class_name WarEventData
extends RefCounted

const RIVAL_BY_HOMELAND := {
	"RASHIDUN CALIPHATE": "Byzantine Empire",
	"BYZANTINE EMPIRE": "Sasanian Empire",
	"SASANIAN EMPIRE": "Rashidun Caliphate",
}
const DEFAULT_RIVAL := "a rival power"


static func rival_for(homeland: String) -> String:
	return RIVAL_BY_HOMELAND.get(homeland, DEFAULT_RIVAL)


static func recruitment_call(rival_name: String, is_soldier: bool) -> Dictionary:
	if is_soldier:
		return {
			"title": "THE LEVY IS CALLED",
			"description": "War against the %s has reached your settlement. As a soldier, your name stands first on the muster roll." % rival_name,
			"choices": [
				{"text": "ANSWER THE CALL", "result": "You take up your arms and march to join the levy.", "effects": {}},
				{"text": "DESERT THE MUSTER", "result": "You slip away rather than march to war, and your standing suffers for it.", "effects": {"wealth": -4, "standing": "Disgraced"}},
			],
		}
	return {
		"title": "THE LEVY IS CALLED",
		"description": "War against the %s has reached your settlement. Every household owes service or coin to the muster." % rival_name,
		"choices": [
			{"text": "JOIN THE LEVY", "result": "You leave your trade behind and join the muster.", "effects": {}},
			{"text": "PAY THE EXEMPTION", "result": "You pay to send another in your place.", "effects": {"wealth": -6}},
		],
	}
