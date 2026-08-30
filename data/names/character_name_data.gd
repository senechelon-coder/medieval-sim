class_name CharacterNameData
extends RefCounted

# Curated period-facing pools. Full names are composed from given name,
# parent name and lineage/place, producing thousands of combinations per realm.
const GIVEN_NAMES := {
	"RASHIDUN CALIPHATE": {
		"MALE": ["Zayd", "Umar", "Ali", "Uthman", "Khalid", "Amr", "Sa'd", "Talha", "Zubayr", "Bilal", "Salman", "Ammar", "Abdullah", "Abbas", "Hamza", "Hasan", "Husayn", "Mu'adh", "Thabit", "Usama", "Hakim", "Harith", "Ikrima", "Jabir"],
		"FEMALE": ["Fatima", "Aisha", "Hafsa", "Zaynab", "Asma", "Safiyya", "Hind", "Khawla", "Sumayya", "Lubaynah", "Jamila", "Ruqayya", "Umm Kulthum", "Maymuna", "Ramla", "Salma", "Layla", "Atika", "Baraka", "Habiba", "Hindun", "Rayhana", "Sahla", "Khayra"],
	},
	"BYZANTINE EMPIRE": {
		"MALE": ["Herakleios", "Konstantinos", "Theodoros", "Ioannes", "Georgios", "Stephanos", "Andreas", "Petros", "Markos", "Tiberios", "Martinus", "David", "Anastasios", "Euphemios", "Gregorios", "Leontios", "Maurikios", "Niketas", "Paulos", "Sergios", "Thomas", "Theophilos", "Eusebios", "Kosmas"],
		"FEMALE": ["Anastasia", "Theodora", "Eudokia", "Martina", "Anna", "Maria", "Euphemia", "Helena", "Sophia", "Theodosia", "Epiphania", "Athanasia", "Agatha", "Arethusa", "Barbara", "Christina", "Domnika", "Eirene", "Eulogia", "Eusebia", "Ioanna", "Kyriake", "Pulcheria", "Tetradia"],
	},
	"SASANIAN EMPIRE": {
		"MALE": ["Khosrow", "Ardashir", "Bahram", "Yazdegerd", "Peroz", "Narseh", "Shapur", "Hormizd", "Rostam", "Farrukh", "Mihran", "Vistahm", "Vinduyih", "Mardanshah", "Adurbad", "Dadburzmihr", "Farrukhzad", "Gushnasp", "Mah-Adur", "Niw-Hormizd", "Shahrbaraz", "Surena", "Varaz", "Zarmihr"],
		"FEMALE": ["Denag", "Azarmidokht", "Boran", "Shirin", "Anahid", "Adur-Anahid", "Perozdukht", "Hormizddukht", "Gurdiyya", "Purandokht", "Ardashirdukht", "Bahrandukht", "Mihrandukht", "Narsehdukht", "Shapurdukht", "Yazdandukht", "Farrukhdukht", "Mahdukht", "Roshandukht", "Vehdukht", "Azarmidukht", "Dadmehr", "Gulnar", "Shahbanu"],
	},
}

const LINEAGES := {
	"RASHIDUN CALIPHATE": ["al-Madani", "al-Makki", "al-Ta'ifi", "al-Yamani", "al-Tamimi", "al-Qurashi", "al-Ansari", "al-Khazraji", "al-Awsi", "al-Kinani", "al-Thaqafi", "al-Hanafi"],
	"BYZANTINE EMPIRE": ["of Constantinople", "of Antioch", "of Alexandria", "of Ephesus", "of Nicaea", "of Caesarea", "of Damascus", "the Thracian", "the Isaurian", "the Cappadocian", "the Cilician", "the Syrian"],
	"SASANIAN EMPIRE": ["of Ctesiphon", "of Estakhr", "of Rey", "of Merv", "of Nishapur", "of Isfahan", "of the House of Karen", "of the House of Mihran", "of the House of Suren", "of the House of Ispahbudhan", "the Parsig", "the Pahlav"],
}

const REALM_CONTEXT := {
	"RASHIDUN CALIPHATE": ["Arabian", "Islam"],
	"BYZANTINE EMPIRE": ["Eastern Roman", "Chalcedonian Christianity"],
	"SASANIAN EMPIRE": ["Middle Persian", "Zoroastrianism"],
}

const FAMILY_ORIGINS := {
	"RASHIDUN CALIPHATE": ["Pastoral household", "Oasis-farming household", "Artisan household", "Caravan household", "Merchant household", "Soldier's household", "Religious household", "Tribal notable's household"],
	"BYZANTINE EMPIRE": ["Tenant-farming household", "Urban artisan household", "Merchant household", "Soldier's household", "Clerical household", "Provincial official's household", "Landowning household", "Dockworker household"],
	"SASANIAN EMPIRE": ["Farming household", "Craft household", "Merchant household", "Cavalry household", "Temple household", "Scribal household", "Estate household", "Noble-house retinue"],
}

const SEASONS := ["Spring", "Summer", "Autumn", "Winter"]


static func generate_profile(faction: String, sex: String) -> Dictionary:
	var faction_names: Dictionary = GIVEN_NAMES.get(faction, GIVEN_NAMES["RASHIDUN CALIPHATE"])
	var given_pool: Array = faction_names.get(sex, faction_names["MALE"])
	var parent_sex := "MALE"
	var father_pool: Array = faction_names[parent_sex]
	var mother_pool: Array = faction_names["FEMALE"]
	var given: String = given_pool.pick_random()
	var father: String = father_pool.pick_random()
	var mother: String = mother_pool.pick_random()
	var lineage: String = LINEAGES.get(faction, LINEAGES["RASHIDUN CALIPHATE"]).pick_random()
	var connector := ""
	match faction:
		"RASHIDUN CALIPHATE": connector = "ibn" if sex == "MALE" else "bint"
		"BYZANTINE EMPIRE": connector = "child of"
		"SASANIAN EMPIRE": connector = "i"
	var full_name := "%s %s %s %s" % [given, connector, father, lineage]
	var context: Array = REALM_CONTEXT.get(faction, ["Unknown", "Unknown"])
	return {
		"given_name": given,
		"lineage": "%s %s %s" % [connector, father, lineage],
		"full_name": full_name,
		"father": father,
		"mother": mother,
		"culture": context[0],
		"faith": context[1],
		"season": SEASONS.pick_random(),
		"family_origin": FAMILY_ORIGINS.get(faction, ["Ordinary household"]).pick_random(),
		"appearance_seed": randi(),
	}
