extends Node2D

const Constants = preload("res://Constants.gd")

var main
@onready var crop_manager = $"../CropManager"

var tractors = {
	"Wheat": {
		"unlocked": false,
		"cooldown": 10.0,
		"timer": 0.0,
		"active": false
	},
	"Corn": {
		"unlocked": false,
		"cooldown": 15.0,
		"timer": 0.0,
		"active": false
	},
	"Carrot": {
		"unlocked": false,
		"cooldown": 20.0,
		"timer": 0.0,
		"active": false
	}
}

# =========================
# PROCESS
# =========================
func _process(delta: float) -> void:
	# Update tractor timers
	for crop in tractors.keys():
		if tractors[crop]["timer"] > 0:
			tractors[crop]["timer"] -= delta
		if tractors[crop]["timer"] < 0:
			tractors[crop]["timer"] = 0
	update_tractor_ui()

# =========================
# CROP UPGRADES
# =========================
func _on_wheat_upgrade():
	if GameManager.gold >= GameManager.wheat_upgrade_cost:
		GameManager.gold -= GameManager.wheat_upgrade_cost
		GameManager.wheat_multiplier += 0.2
		GameManager.wheat_upgrade_cost *= Constants.UPGRADE_COST_MULTIPLIER
		GameManager.update_crops_per_second()

func _on_corn_upgrade():
	if GameManager.gold >= GameManager.corn_upgrade_cost:
		GameManager.gold -= GameManager.corn_upgrade_cost
		GameManager.corn_multiplier += 0.2
		GameManager.corn_upgrade_cost *= Constants.UPGRADE_COST_MULTIPLIER
		GameManager.update_crops_per_second()

func _on_carrot_upgrade():
	if GameManager.gold >= GameManager.carrot_upgrade_cost:
		GameManager.gold -= GameManager.carrot_upgrade_cost
		GameManager.carrot_multiplier += 0.2
		GameManager.carrot_upgrade_cost *= Constants.UPGRADE_COST_MULTIPLIER
		GameManager.update_crops_per_second()

# =========================
# SPEED UPGRADES
# =========================
func _on_wheat_speed():
	if GameManager.gold >= main.wheat_speed_cost:
		GameManager.gold -= main.wheat_speed_cost
		main.wheat_spawn_interval *= Constants.SPEED_REDUCTION
		if main.wheat_spawn_interval < Constants.WHEAT_MIN_INTERVAL:
			main.wheat_spawn_interval = Constants.WHEAT_MIN_INTERVAL
		main.wheat_speed_cost *= Constants.SPEED_COST_MULTIPLIER

func _on_corn_speed():
	if GameManager.gold >= main.corn_speed_cost:
		GameManager.gold -= main.corn_speed_cost
		main.corn_spawn_interval *= Constants.SPEED_REDUCTION
		if main.corn_spawn_interval < Constants.CORN_MIN_INTERVAL:
			main.corn_spawn_interval = Constants.CORN_MIN_INTERVAL
		main.corn_speed_cost *= Constants.SPEED_COST_MULTIPLIER

func _on_carrot_speed():
	if GameManager.gold >= main.carrot_speed_cost:
		GameManager.gold -= main.carrot_speed_cost
		main.carrot_spawn_interval *= Constants.SPEED_REDUCTION
		if main.carrot_spawn_interval < Constants.CARROT_MIN_INTERVAL:
			main.carrot_spawn_interval = Constants.CARROT_MIN_INTERVAL
		main.carrot_speed_cost *= Constants.SPEED_COST_MULTIPLIER

# =========================
# AUTO HARVEST
# =========================
func _on_auto_harvest():
	if GameManager.gold >= GameManager.auto_harvest_cost:
		GameManager.gold -= GameManager.auto_harvest_cost
		
		if GameManager.auto_harvest_tier < 3:
			GameManager.auto_harvest_tier += 1
		else:
			GameManager.auto_harvest_interval *= 0.85
			if GameManager.auto_harvest_interval < 0.01:
				GameManager.auto_harvest_interval = 0.01
		
		GameManager.auto_harvest_cost *= Constants.AUTO_HARVEST_COST_MULTIPLIER

func auto_harvest():
	if GameManager.auto_harvest_tier >= 1:
		if main.wheat_nodes.size() > 0:
			main.remove_wheat_sprite()
			crop_manager.spawn_wheatText(1)
			GameManager.wheat += 1
			GameManager.plant_crop("Wheat")
			GameManager.upgrade_crop("Wheat")
			GameManager.add_xp(1)
			main.animate_xp()
	
	if GameManager.auto_harvest_tier >= 2:
		if "Corn" in GameManager.unlocked_crops and main.corn_nodes.size() > 0:
			main.remove_corn_sprite()
			crop_manager.spawn_cornText(1)
			GameManager.corn += 1
			GameManager.plant_crop("Corn")
			GameManager.upgrade_crop("Corn")
			GameManager.add_xp(3)
			main.animate_xp()
	
	if GameManager.auto_harvest_tier >= 3:
		if "Carrot" in GameManager.unlocked_crops and main.carrot_nodes.size() > 0:
			main.remove_carrot_sprite()
			crop_manager.spawn_carrotText(1)
			GameManager.carrot += 1
			GameManager.plant_crop("Carrot")
			GameManager.upgrade_crop("Carrot")
			GameManager.add_xp(5)
			main.animate_xp()

# =========================
# TRACTORS
# =========================
func _on_wheat_tractor_unlock_pressed() -> void:
	if GameManager.gold >= 500:
		GameManager.gold -= 500
		$"../Tractors/WheatTractor".visible = true
		tractors["Wheat"]["unlocked"] = true

func _on_wheat_tractor_pressed() -> void:
	activate_tractor("Wheat")

func _on_corn_tractor_unlock_pressed() -> void:
	if GameManager.gold >= 500:
		if "Corn" in GameManager.unlocked_crops:
			GameManager.gold -= 500
			$"../Tractors/CornTractor".visible = true
			tractors["Corn"]["unlocked"] = true

func _on_corn_tractor_pressed() -> void:
	activate_tractor("Corn")

func _on_carrot_tractor_unlock_pressed() -> void:
	if GameManager.gold >= 500:
		if "Carrot" in GameManager.unlocked_crops:
			GameManager.gold -= 500
			$"../Tractors/CarrotTractor".visible = true
			tractors["Carrot"]["unlocked"] = true

func _on_carrot_tractor_pressed() -> void:
	activate_tractor("Carrot")

func activate_tractor(crop: String):
	var t = tractors[crop]
	
	if not t["unlocked"] or t["timer"] > 0:
		return
	
	t["active"] = true
	run_tractor(crop)

func run_tractor(crop: String):
	var nodes = []
	
	match crop:
		"Wheat":
			nodes = main.wheat_nodes
		"Corn":
			nodes = main.corn_nodes
		"Carrot":
			nodes = main.carrot_nodes
	
	if nodes.size() == 0:
		return
	
	while nodes.size() > 0:
		var amount = 1
		var xp_gain = 0
		
		if GameManager.roll_crit():
			amount *= GameManager.crit_multiplier
			crop_manager.show_crit_text()
		
		match crop:
			"Wheat":
				GameManager.wheat += amount
				GameManager.plant_crop("Wheat")
				xp_gain = 1 * amount
				for c in GameManager.planted_crops:
					if c.name == "Wheat":
						c.crops_per_second += 0.05 * amount
			"Corn":
				GameManager.corn += amount
				GameManager.plant_crop("Corn")
				xp_gain = 3 * amount
				for c in GameManager.planted_crops:
					if c.name == "Corn":
						c.crops_per_second += 0.05 * amount
			"Carrot":
				GameManager.carrot += amount
				GameManager.plant_crop("Carrot")
				xp_gain = 5 * amount
				for c in GameManager.planted_crops:
					if c.name == "Carrot":
						c.crops_per_second += 0.05 * amount
		
		GameManager.update_crops_per_second()
		GameManager.add_xp(xp_gain)
		main.animate_xp()
		
		var sprite = nodes.pop_back()
		sprite.queue_free()
		
		await get_tree().create_timer(0.03).timeout
	
	tractors[crop]["timer"] = tractors[crop]["cooldown"]
	tractors[crop]["active"] = false

func update_tractor_ui():
	for crop in tractors.keys():
		var t = tractors[crop]
		var node = null
		
		match crop:
			"Wheat":
				node = $"../Tractors/WheatTractor"
			"Corn":
				node = $"../Tractors/CornTractor"
			"Carrot":
				node = $"../Tractors/CarrotTractor"
		
		if node == null:
			continue
		
		if not t["unlocked"]:
			update_tractor_label(crop, node, "Unlock " + crop + " Tractor")
		elif t["timer"] > 0:
			update_tractor_label(crop, node, crop + " Tractor (" + str(round(t["timer"])) + "s)")
		else:
			update_tractor_label(crop, node, "Run " + crop + " Tractor")

func update_tractor_label(crop: String, node: Control, text: String):
	var label_name = crop + "_tractor_label"
	var label = node.get_node_or_null(label_name)
	
	if label == null:
		label = Label.new()
		label.name = label_name
		label.add_theme_font_size_override("font_size", 14)
		label.modulate = Color.WHITE
		node.add_child(label)
		label.position = Vector2(-40, -60)
	
	label.text = text
		
