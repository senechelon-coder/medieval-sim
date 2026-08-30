class_name Settlement
extends RefCounted

var id := ""
var name := "Unknown"
var type := "town"
var province_id := ""
var population := 1000
var population_sample: Array[String] = []
var prosperity := 50.0
var recent_reports: Array[String] = []
var goods_prices: Dictionary = {}
var goods_stock: Dictionary = {}


func to_dict() -> Dictionary:
	return {"id": id, "name": name, "type": type, "province_id": province_id, "population": population, "population_sample": population_sample.duplicate(), "prosperity": prosperity, "recent_reports": recent_reports.duplicate(), "goods_prices": goods_prices.duplicate(), "goods_stock": goods_stock.duplicate()}


static func from_dict(data: Dictionary) -> Settlement:
	var settlement := Settlement.new()
	settlement.id = str(data.get("id", ""))
	settlement.name = str(data.get("name", "Unknown"))
	settlement.type = str(data.get("type", "town"))
	settlement.province_id = str(data.get("province_id", ""))
	settlement.population = int(data.get("population", 1000))
	settlement.prosperity = float(data.get("prosperity", 50.0))
	for character_id in data.get("population_sample", []):
		settlement.population_sample.append(str(character_id))
	for report in data.get("recent_reports", []):
		settlement.recent_reports.append(str(report))
	for good_id in data.get("goods_prices", {}):
		settlement.goods_prices[str(good_id)] = int(data.goods_prices[good_id])
	for good_id in data.get("goods_stock", {}):
		settlement.goods_stock[str(good_id)] = int(data.goods_stock[good_id])
	return settlement
