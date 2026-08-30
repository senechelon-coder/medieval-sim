class_name MarketService
extends RefCounted


static func buy_good(good_id: String) -> Dictionary:
	if not WorldState.has_player():
		return {"ok": false, "message": "No active character."}
	var settlement: Settlement = WorldState.settlements.get(WorldState.player.location_id)
	if settlement == null or not settlement.goods_prices.has(good_id):
		return {"ok": false, "message": "That good is unavailable here."}
	var price := int(settlement.goods_prices[good_id])
	if int(settlement.goods_stock.get(good_id, 0)) <= 0:
		return {"ok": false, "message": "This good is currently out of stock."}
	if WorldState.player.wealth < price:
		return {"ok": false, "message": "You cannot afford this purchase."}
	if inventory_count() >= WorldState.player.cargo_capacity:
		return {"ok": false, "message": "Your carrying capacity is full."}
	WorldState.player.wealth -= price
	WorldState.player.inventory[good_id] = int(WorldState.player.inventory.get(good_id, 0)) + 1
	WorldState.player.trade_reputation += 1
	settlement.goods_stock[good_id] = int(settlement.goods_stock[good_id]) - 1
	_adjust_price_for_stock(settlement, good_id)
	return {"ok": true, "message": "Bought 1 %s for %d Wealth." % [GoodData.get_good(good_id).name, price]}


static func sell_good(good_id: String) -> Dictionary:
	if not WorldState.has_player() or int(WorldState.player.inventory.get(good_id, 0)) <= 0:
		return {"ok": false, "message": "You have none to sell."}
	var settlement: Settlement = WorldState.settlements.get(WorldState.player.location_id)
	if settlement == null or not settlement.goods_prices.has(good_id):
		return {"ok": false, "message": "There is no buyer for that good here."}
	var price := int(settlement.goods_prices[good_id])
	WorldState.player.inventory[good_id] = int(WorldState.player.inventory[good_id]) - 1
	if int(WorldState.player.inventory[good_id]) <= 0:
		WorldState.player.inventory.erase(good_id)
	WorldState.player.wealth += price
	WorldState.player.trade_reputation += 1
	settlement.goods_stock[good_id] = int(settlement.goods_stock.get(good_id, 0)) + 1
	_adjust_price_for_stock(settlement, good_id)
	return {"ok": true, "message": "Sold 1 %s for %d Wealth." % [GoodData.get_good(good_id).name, price]}


static func inventory_count() -> int:
	var total := 0
	if not WorldState.has_player():
		return total
	for amount in WorldState.player.inventory.values():
		total += int(amount)
	return total


static func upgrade_status() -> Dictionary:
	if not WorldState.has_player():
		return {}
	var current_id := WorldState.player.trade_tier
	var next_id := TradeTierData.next_tier_id(current_id)
	if next_id == "":
		return {"current": TradeTierData.get_tier(current_id), "maxed": true}
	var next_tier := TradeTierData.get_tier(next_id)
	var eligible: bool = WorldState.player.trade_reputation >= int(next_tier.reputation_required)
	var affordable: bool = WorldState.player.wealth >= int(next_tier.cost)
	return {
		"current": TradeTierData.get_tier(current_id),
		"next": next_tier,
		"next_id": next_id,
		"eligible": eligible,
		"affordable": affordable,
		"maxed": false,
	}


static func attempt_upgrade_tier() -> Dictionary:
	var status := upgrade_status()
	if status.is_empty() or bool(status.get("maxed", false)):
		return {"ok": false, "message": "You have reached the highest trade standing."}
	if not bool(status.eligible):
		return {"ok": false, "message": "Your trade reputation is not yet high enough."}
	if not bool(status.affordable):
		return {"ok": false, "message": "You cannot afford this yet."}
	var next_tier: Dictionary = status.next
	WorldState.player.wealth -= int(next_tier.cost)
	WorldState.player.trade_tier = str(status.next_id)
	WorldState.player.cargo_capacity = int(next_tier.cargo_capacity)
	return {"ok": true, "message": "You are now a %s. Cargo capacity: %d." % [next_tier.name, next_tier.cargo_capacity]}


static func stock_condition(stock: int) -> String:
	if stock <= 4: return "SHORTAGE"
	if stock >= 16: return "SURPLUS"
	return "BALANCED"


static func _adjust_price_for_stock(settlement: Settlement, good_id: String) -> void:
	var good := GoodData.get_good(good_id)
	var stock := int(settlement.goods_stock[good_id])
	var price := int(settlement.goods_prices[good_id])
	if stock <= 4:
		price += 1
	elif stock >= 16:
		price -= 1
	settlement.goods_prices[good_id] = clampi(price, int(good.minimum), int(good.maximum))
