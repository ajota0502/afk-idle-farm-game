extends Node2D

# =========================
# REFERENCES
# =========================
@onready var player = $Player/AnimatedSprite2D
@onready var xp_bar = $CanvasLayer/XPBar
@onready var xp_label = $CanvasLayer/XPBar/Label

@onready var shop_panel = $CanvasLayer/ShopPanel
@onready var shop_button = $CanvasLayer/ShopButton

@onready var wheat_upgrade_btn = $CanvasLayer/ShopPanel/WheatUpgradeButton
@onready var corn_upgrade_btn = $CanvasLayer/ShopPanel/CornUpgradeButton
@onready var carrot_upgrade_btn = $CanvasLayer/ShopPanel/CarrotUpgradeButton

@onready var gold_label = $CanvasLayer/GoldLabel
@onready var sell_button = $CanvasLayer/SellButton

@onready var corn_node = $Corn
@onready var carrot_node = $Carrot

@onready var wheat_label = $Wheat/wheatLabel
@onready var wheat_spawn_area = $Wheat/wheatSpawnArea
@onready var corn_label = $Corn/CornLabel
@onready var corn_spawn_area = $Corn/CornSpawnArea

@onready var carrot_spawn_area = $Carrot/CarrotSpawnArea
@onready var carrot_label = $Carrot/CarrotLabel

@onready var wheat_texture = load("res://Sprites/Wheat_JE2_BE2.png")
@onready var corn_texture = load("res://Sprites/Corn.webp")
@onready var carrot_texture = load("res://Sprites/Carrot.webp")

@onready var LevelUpSound = $AudioStreamPlayer2D2
# INVENTORY MENU
@onready var inventory_menu = $CanvasLayer/Inventory
@onready var inventory_button = $CanvasLayer/InventoryButton

@onready var wheat_icon = $"CanvasLayer/Inventory/VBoxContainer/WheatContainer/Wheat icon"
@onready var wheat_inventory_label = $"CanvasLayer/Inventory/VBoxContainer/WheatContainer/Wheat total"

@onready var corn_inventory = $"CanvasLayer/Inventory/VBoxContainer/CornContainer"
@onready var corn_icon = $"CanvasLayer/Inventory/VBoxContainer/CornContainer/Corn icon"
@onready var corn_inventory_label = $"CanvasLayer/Inventory/VBoxContainer/CornContainer/Corn total"

@onready var carrot_inventory = $"CanvasLayer/Inventory/VBoxContainer/CarrotContainer"
@onready var carrot_icon = $"CanvasLayer/Inventory/VBoxContainer/CarrotContainer/Carrot icon"
@onready var carrot_inventory_label = $"CanvasLayer/Inventory/VBoxContainer/CarrotContainer/Carrot total"

@onready var wheat_speed_btn = $CanvasLayer/ShopPanel/WheatSpeedButton
@onready var corn_speed_btn = $CanvasLayer/ShopPanel/CornSpeedButton
@onready var carrot_speed_btn = $CanvasLayer/ShopPanel/CarrotSpeedButton

@onready var auto_harvest_btn = $CanvasLayer/ShopPanel/AutoHarvestButton

@onready var sell_wheat_btn = $Wheat/SellWheat
@onready var sell_corn_btn = $Corn/SellCorn
@onready var sell_carrot_btn = $Carrot/SellCarrot

@onready var level_panel = $CanvasLayer/LevelUpPanel
@onready var choice1 = $CanvasLayer/LevelUpPanel/Choice1
@onready var choice2 = $CanvasLayer/LevelUpPanel/Choice2
@onready var choice3 = $CanvasLayer/LevelUpPanel/Choice3

@onready var musicapupu = $AudioStreamPlayer2D
@onready var menu = $CanvasLayer/Menu/TextureRect
@onready var menu1asset = load("res://Sprites/menu.png")
@onready var menu2asset = load("res://Sprites/menu2.png")
@onready var play_content = $CanvasLayer/Menu/Play/Content
@onready var options_content = $CanvasLayer/Menu/Options/Content
@onready var quit_content = $CanvasLayer/Menu/Quit/Content
@onready var crit_sound = $CritSound

@onready var choice1_icon = $CanvasLayer/LevelUpPanel/Choice1/Icon
@onready var choice2_icon = $CanvasLayer/LevelUpPanel/Choice2/Icon
@onready var choice3_icon = $CanvasLayer/LevelUpPanel/Choice3/Icon

@onready var choice1_text = $CanvasLayer/LevelUpPanel/Choice1/Text
@onready var choice2_text = $CanvasLayer/LevelUpPanel/Choice2/Text
@onready var choice3_text = $CanvasLayer/LevelUpPanel/Choice3/Text

@onready var level_title = $CanvasLayer/LevelUpPanel/LevelTitle
@onready var level_subtitle = $CanvasLayer/LevelUpPanel/Subtitle
@onready var tooltip = $TooltipLayer/UpgradeTooltip
@onready var tooltip_layer = $TooltipLayer
@onready var crop_manager = $CropManager
@onready var ui_manager = $UIManager
@onready var upgrade_manager = $UpgradeManager
@onready var level_up_manager = $LevelUpManager
@onready var prestige_button = $CanvasLayer/Prestige
# =========================
# SPAWN NODES
# =========================
var wheat_nodes = []
var corn_nodes = []
var carrot_nodes = []

var auto_harvest_timer := 0.0
var wheat_spawn_timer = 0.0
var wheat_upgrade_cost := 25
var wheat_min_interval := 0.01
var wheat_spawn_interval = 3.0

var corn_spawn_timer = 0.0
var corn_upgrade_cost := 100
var corn_min_interval := 0.01
var corn_spawn_interval = 5.0

var carrot_spawn_timer = 0.0
var carrot_upgrade_cost := 250
var carrot_min_interval := 0.01
var carrot_spawn_interval = 7.5

var wheat_speed_cost := 30
var corn_speed_cost := 120
var carrot_speed_cost := 300

var auto_sell_timer := 0.0
var menu_flag = 0
var menu_timer = 0.0
var menu_interval = 0.1
var base_play_size := Vector2()
var base_options_size := Vector2()
var base_quit_size := Vector2()

var showing_levelup := false
var xp_rainbow_tween
var frozen_xp_bar := false
var xp_visual := 0.0
var xp_tween

var current_choices = []

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

var upgrade_icons = {
	"global": preload("res://Sprites/Upgrades/Global.png"),
	"wheat_speed": preload("res://Sprites/Upgrades/Wheat.png"),
	"corn_speed": preload("res://Sprites/Upgrades/Corn.png"),
	"carrot_speed": preload("res://Sprites/Upgrades/Carrot.png"),
	"crit_chance": preload("res://Sprites/Upgrades/Chance.png"),
	"crit_mult": preload("res://Sprites/Upgrades/Mult.png"),
	"gold_ps": preload("res://Sprites/Upgrades/Gold.png"),
	"auto_harvest": preload("res://Sprites/Upgrades/Harvest.png")
}
# =========================
# READY
# =========================
func _ready():
	prestige_button.visible = GameManager.can_prestige()
	crop_manager.main = self
	crop_manager.player = player
	crop_manager._init_text_pool()  # ← Add this after setting main
	
	level_up_manager.main = self
	level_up_manager.upgrade_manager = upgrade_manager
	level_up_manager.game_manager = GameManager
	upgrade_manager.main = self
	crop_manager.main = self
	ui_manager.main = self
	tooltip_layer.layer = 9999
	ui_manager.update_tooltip()
	$TooltipLayer.process_mode = Node.PROCESS_MODE_ALWAYS
	$CanvasLayer.process_mode = Node.PROCESS_MODE_ALWAYS
	
	xp_visual = GameManager.xp
	xp_bar.value = xp_visual
	await get_tree().process_frame
	
	base_play_size = play_content.size
	base_options_size = options_content.size
	base_quit_size = quit_content.size
	
	level_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	level_panel.visible = false
	# delegate level-up UI to manager to avoid duplicate handlers
	GameManager.level_up.connect(level_up_manager.show_level_up_screen)
	GameManager.prestige_activated.connect(_on_prestige_activated)

	# inventory button -> UI manager
	inventory_button.pressed.connect(ui_manager._on_inventory_button_pressed)
	
	tooltip.process_mode = Node.PROCESS_MODE_ALWAYS
	choice1.process_mode = Node.PROCESS_MODE_ALWAYS
	choice2.process_mode = Node.PROCESS_MODE_ALWAYS
	choice3.process_mode = Node.PROCESS_MODE_ALWAYS
	
	sell_wheat_btn.pressed.connect(func(): GameManager.sell_crop("Wheat"))
	sell_corn_btn.pressed.connect(func(): GameManager.sell_crop("Corn"))
	sell_carrot_btn.pressed.connect(func(): GameManager.sell_crop("Carrot"))
	
	GameManager.level_up.connect(_on_level_up_popup)
	
	auto_harvest_btn.pressed.connect(upgrade_manager._on_auto_harvest)
	shop_panel.visible = false
	shop_button.pressed.connect(ui_manager._on_shop_pressed)
	
	wheat_speed_btn.pressed.connect(_on_wheat_speed)
	corn_speed_btn.pressed.connect(_on_corn_speed)
	carrot_speed_btn.pressed.connect(_on_carrot_speed)
	
	sell_button.pressed.connect(_on_sell_pressed)
	
	wheat_upgrade_btn.pressed.connect(upgrade_manager._on_wheat_upgrade)
	corn_upgrade_btn.pressed.connect(upgrade_manager._on_corn_upgrade)
	carrot_upgrade_btn.pressed.connect(upgrade_manager._on_carrot_upgrade)
	
	corn_inventory.visible = false
	carrot_inventory.visible = false
	
	corn_node.visible = false
	carrot_node.visible = false
	
	# spawnear inicial
	for i in range(40):
		spawn_wheat_sprite()
		spawn_corn_sprite()
		spawn_carrot_sprite()
	ui_manager.update_inventory_menu()

# =========================
# PROCESS
# =========================
func _process(delta):
	var speed = 1.0
	prestige_button.visible = GameManager.can_prestige()
	if GameManager.cow_buff_active:
		speed *= GameManager.cow_multiplier

	wheat_spawn_timer += delta * speed
	ui_manager.update_tooltip()
	print(get_viewport().get_mouse_position())
	for crop in tractors.keys():
		if tractors[crop]["timer"] > 0:
			tractors[crop]["timer"] -= delta
		if tractors[crop]["timer"] < 0:
			tractors[crop]["timer"] = 0
	update_tractor_ui()
	xp_bar.max_value = GameManager.xp_to_next_level

	if showing_levelup:
		xp_bar.value = xp_bar.max_value
		return

	xp_bar.value = xp_visual
	xp_label.text = "Lv. " + str(GameManager.level)
	
	menu_timer += delta
	if menu_flag == 0:
		if menu_timer >= menu_interval:
			menu_timer = 0
			menu.texture = menu2asset
			menu_flag = 1
	else:
		if menu_timer >= menu_interval:
			menu_timer = 0
			menu.texture = menu1asset
			menu_flag = 0

	if GameManager.auto_harvest_tier > 0:
		# Apply sheep buff if active: 15% faster auto-harvest
		var auto_harvest_delta = delta
		if GameManager.sheep_buff_active:
			auto_harvest_delta *= GameManager.sheep_auto_harvest_multiplier
		auto_harvest_timer += auto_harvest_delta
	
	if auto_harvest_timer >= GameManager.auto_harvest_interval:
		auto_harvest_timer = 0
		upgrade_manager.auto_harvest()
	
	if GameManager.auto_harvest_tier == 0:
		auto_harvest_btn.text = "Auto Harvest (Unlock) $" + str(int(GameManager.auto_harvest_cost))
	else:
		if GameManager.auto_harvest_tier < 3:
			auto_harvest_btn.text = "Upgrade Tier " + str(GameManager.auto_harvest_tier) + " → " + str(GameManager.auto_harvest_tier + 1) + " $" + str(int(GameManager.auto_harvest_cost))
		else:
			auto_harvest_btn.text = "Speed (" + str(snapped(GameManager.auto_harvest_interval, 0.1)) + "s) $" + str(int(GameManager.auto_harvest_cost))
	
	wheat_upgrade_btn.text = "Wheat x" + str(snapped(GameManager.wheat_multiplier, 0.1)) + " ($" + str(int(GameManager.wheat_upgrade_cost)) + ")"
	corn_upgrade_btn.text = "Corn x" + str(snapped(GameManager.corn_multiplier, 0.1)) + " ($" + str(int(GameManager.corn_upgrade_cost)) + ")"
	carrot_upgrade_btn.text = "Carrot x" + str(snapped(GameManager.carrot_multiplier, 0.1)) + " ($" + str(int(GameManager.carrot_upgrade_cost)) + ")"
	
	wheat_speed_btn.text = "⚡ Wheat Speed (" + str(snapped(wheat_spawn_interval, 0.1)) + "s) $" + str(int(wheat_speed_cost))
	corn_speed_btn.text = "⚡ Corn Speed (" + str(snapped(corn_spawn_interval, 0.1)) + "s) $" + str(int(corn_speed_cost))
	carrot_speed_btn.text = "⚡ Carrot Speed (" + str(snapped(carrot_spawn_interval, 0.1)) + "s) $" + str(int(carrot_speed_cost))
	
	gold_label.text = "Gold: " + str(GameManager.gold) + " | x" + str(snapped(GameManager.global_multiplier, 0.1))
	# Spawn automático
	check_unlocks()
	wheat_spawn_timer += delta
	if wheat_spawn_timer >= wheat_spawn_interval:
		wheat_spawn_timer = 0
		spawn_wheat_sprite()
		GameManager.wheat += 1
		crop_manager.spawn_wheatText(1)
		
	corn_spawn_timer += delta
	if corn_spawn_timer >= corn_spawn_interval:
		corn_spawn_timer = 0
		if "Corn" in GameManager.unlocked_crops:
			spawn_corn_sprite()
			GameManager.corn += 1
			crop_manager.spawn_cornText(1)
		
	carrot_spawn_timer += delta
	if carrot_spawn_timer >= carrot_spawn_interval:
		carrot_spawn_timer = 0
		if "Carrot" in GameManager.unlocked_crops:
			spawn_carrot_sprite()
			GameManager.carrot += 1
			crop_manager.spawn_carrotText(1)
			
	if GameManager.auto_harvest_unlocked:
		auto_harvest_timer += delta
	
	if auto_harvest_timer >= GameManager.auto_harvest_interval:
		auto_harvest_timer = 0
		
		# simular harvest
		upgrade_manager.auto_harvest()
	# actualizar UI de menu si está visible
	if inventory_menu.visible:
		ui_manager.update_inventory_menu()
	
	# actualizar labels de resources
	wheat_label.text = "Wheat: " + str(int(GameManager.wheat)) + " (" +str(float(GameManager.wheat_per_second)) + "/s)"
	corn_label.text = "Corn: " + str(int(GameManager.corn)) + " (" + str(int(GameManager.corn_per_second)) + "/s)"
	carrot_label.text = "Carrot: " + str(int(GameManager.carrot)) + " (" + str(int(GameManager.carrot_per_second)) + "/s)"
	
# =========================
# INVENTORY MENU
# =========================

# =========================
# SPAWN VISUAL
# =========================
func spawn_wheat_sprite():
	var sprite = Sprite2D.new()
	sprite.texture = wheat_texture
	sprite.scale = Vector2(0.15, 0.15)
	var rect = $Wheat/harvest.get_rect()
	sprite.position = rect.position + Vector2(
		randf_range(0, rect.size.x),
		randf_range(0, rect.size.y)
	)
	add_child(sprite)
	wheat_nodes.append(sprite)

func spawn_corn_sprite():
	var sprite = Sprite2D.new()
	sprite.texture = corn_texture
	sprite.scale = Vector2(0.1, 0.1)
	var rect = $Corn/HarvestCornButton.get_rect()
	sprite.position = rect.position + Vector2(
		randf_range(0, rect.size.x),
		randf_range(0, rect.size.y)
	)
	add_child(sprite)
	corn_nodes.append(sprite)

func spawn_carrot_sprite():
	var sprite = Sprite2D.new()
	sprite.texture = carrot_texture
	sprite.scale = Vector2(0.15, 0.15)
	var rect = $Carrot/HarvestCarrotButton.get_rect()
	sprite.position = rect.position + Vector2(
		randf_range(0, rect.size.x),
		randf_range(0, rect.size.y)
	)
	add_child(sprite)
	carrot_nodes.append(sprite)

# =========================
# REMOVE CROPS (HARVEST)
# =========================
func remove_wheat_sprite():
	if wheat_nodes.size() > 0:
		var sprite = wheat_nodes.pop_back()
		sprite.queue_free()

func remove_corn_sprite():
	if corn_nodes.size() > 0:
		var sprite = corn_nodes.pop_back()
		sprite.queue_free()

func remove_carrot_sprite():
	if carrot_nodes.size() > 0:
		var sprite = carrot_nodes.pop_back()
		sprite.queue_free()
# =========================
# HARVEST BUTTONS
# =========================
func _on_harvest_pressed():
	var amount = 1
	if wheat_nodes.size() <= 0:
		print("No hay wheat en el mapa")
		return

	remove_wheat_sprite()
	

	if GameManager.roll_crit():
		amount *= GameManager.crit_multiplier
		show_crit_text()
		crit_sound.play()
		# screen shake on crit
		trigger_crit_shake()

	GameManager.wheat += amount
	crop_manager.spawn_wheatText(amount)
	# 🌾 bonus permanente al cps
	for crop in GameManager.planted_crops:
		if crop.name == "Wheat":
			crop.crops_per_second += 0.05 * amount

	GameManager.plant_crop("Wheat")
	GameManager.update_crops_per_second()

	GameManager.add_xp(amount)
	animate_xp()

func _on_harvest_corn_button_pressed():
	var amount = 1
	if not "Corn" in GameManager.unlocked_crops:
		return

	if corn_nodes.size() <= 0:
		return

	remove_corn_sprite()



	if GameManager.roll_crit():
		amount *= GameManager.crit_multiplier
		show_crit_text()
		crit_sound.play()
		# screen shake on crit
		trigger_crit_shake()

	GameManager.corn += amount
	crop_manager.spawn_cornText(amount)
	
	for crop in GameManager.planted_crops:
		if crop.name == "Corn":
			crop.crops_per_second += 0.08 * amount

	GameManager.plant_crop("Corn")
	GameManager.update_crops_per_second()

	GameManager.add_xp(amount * 2)
	animate_xp()


# =========================
# FLOATING TEXT
# =========================

func _on_harvest_carrot_button_pressed():
	var amount = 1
	if not "Carrot" in GameManager.unlocked_crops:
		return

	if carrot_nodes.size() <= 0:
		return

	remove_carrot_sprite()


	if GameManager.roll_crit():
		amount *= GameManager.crit_multiplier
		show_crit_text()
		crit_sound.play()
		# screen shake on crit
		trigger_crit_shake()

	GameManager.carrot += amount
	crop_manager.spawn_carrotText(amount)

	for crop in GameManager.planted_crops:
		if crop.name == "Carrot":
			crop.crops_per_second += 0.12 * amount

	GameManager.plant_crop("Carrot")
	GameManager.update_crops_per_second()

	GameManager.add_xp(amount * 4)
	animate_xp()

func check_unlocks():

	if "Corn" in GameManager.unlocked_crops:
		corn_node.visible = true
		corn_inventory.visible = true

	if "Carrot" in GameManager.unlocked_crops:
		carrot_node.visible = true
		carrot_inventory.visible = true

func _on_sell_pressed():
	GameManager.sell_all()
	ui_manager.update_inventory_menu()


func _on_level_up_popup(new_level, bonus):
	var label = Label.new()
	label.text = "LEVEL UP!\nLv." + str(new_level)
	label.scale = Vector2(1.5, 1.5)
	label.modulate = Color(1, 1, 0)

	add_child(label)

	# 🔥 posición arriba del player
	label.global_position = player.global_position + Vector2(-40, -80)

	# animación flotante
	for i in range(30):
		await get_tree().create_timer(0.05).timeout
		label.global_position.y -= 2
		label.modulate.a -= 0.03

	label.queue_free()
	
func _on_prestige_activated(prestige_level, prestige_points, prestige_multiplier):
	var label = Label.new()
	label.text = "PRESTIGE +" + str(prestige_points) + " PP"
	label.modulate = Color(0.8, 0.7, 1)
	label.scale = Vector2(1.3, 1.3)
	add_child(label)
	label.global_position = get_viewport_rect().size / 2

	for i in range(40):
		await get_tree().create_timer(0.03).timeout
		label.global_position.y -= 2
		label.modulate.a -= 0.025

	label.queue_free()

func _on_wheat_speed():
	if GameManager.gold >= wheat_speed_cost:
		GameManager.gold -= wheat_speed_cost
		
		wheat_spawn_interval *= 0.9
		
		if wheat_spawn_interval < wheat_min_interval:
			wheat_spawn_interval = wheat_min_interval
		
		wheat_speed_cost *= 1.5

func _on_corn_speed():
	if GameManager.gold >= corn_speed_cost:
		GameManager.gold -= corn_speed_cost
		
		corn_spawn_interval *= 0.9
		
		if corn_spawn_interval < corn_min_interval:
			corn_spawn_interval = corn_min_interval
		
		corn_speed_cost *= 1.5
		
func _on_carrot_speed():
	if GameManager.gold >= carrot_speed_cost:
		GameManager.gold -= carrot_speed_cost
		
		carrot_spawn_interval *= 0.9
		
		if carrot_spawn_interval < carrot_min_interval:
			carrot_spawn_interval = carrot_min_interval
		
		carrot_speed_cost *= 1.5

func _on_auto_harvest():
	if GameManager.gold >= GameManager.auto_harvest_cost:
		GameManager.gold -= GameManager.auto_harvest_cost
		
		# subir tier (máx 3)
		if GameManager.auto_harvest_tier < 3:
			GameManager.auto_harvest_tier += 1
		else:
			# si ya está max → mejorar velocidad
			GameManager.auto_harvest_interval *= 0.85
			
			if GameManager.auto_harvest_interval < 0.01:
				GameManager.auto_harvest_interval = 0.01
		
		GameManager.auto_harvest_cost *= 1.7
		


func _on_carrot_upgrade_button_pressed() -> void:
	pass # Replace with function body.


func _on_level_up_screen(new_level, choices):
	# Delegate level-up screen handling to LevelUpManager
	level_up_manager.show_level_up_screen(new_level, choices)

func pick_upgrade(index):
	# Forward to level_up_manager (keeps single source of truth)
	level_up_manager.pick_upgrade(index)
func hover_in(content, base_size):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(content, "custom_minimum_size", base_size * 1.1, 0.1)

func hover_out(content, base_size):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(content, "custom_minimum_size", base_size, 0.1)

func _on_play_mouse_entered():
	hover_in(play_content, base_play_size)

func _on_play_mouse_exited():
	hover_out(play_content, base_play_size)


func _on_options_mouse_entered():
	hover_in(options_content, base_options_size)

func _on_options_mouse_exited():
	hover_out(options_content, base_options_size)


func _on_quit_mouse_entered():
	hover_in(quit_content, base_quit_size)

func _on_quit_mouse_exited():
	hover_out(quit_content, base_quit_size)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	$CanvasLayer/Menu.visible = false
	$CanvasLayer/XPBar.visible = true
func show_level_up_animation(level):
	var label = Label.new()
	label.text = "LEVEL UP!\nLv." + str(level)
	label.scale = Vector2(0.5, 0.5)
	label.modulate = Color(1,1,0,0)
	
	add_child(label)
	label.global_position = get_viewport_rect().size / 2 - Vector2(100,50)

	# tween
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(label, "scale", Vector2(1.5,1.5), 0.3)
	tween.parallel().tween_property(label, "modulate:a", 1.0, 0.2)
	
	tween.tween_interval(0.4)
	
	tween.tween_property(label, "modulate:a", 0.0, 0.3)
	tween.tween_property(label, "scale", Vector2(2,2), 0.3)
	
	await tween.finished
	
	label.queue_free()
func show_crit_text():
	crit_sound.pitch_scale = randf_range(0.4, 2.0)
	crit_sound.play()

	var label = Label.new()
	label.text = "CRITICAL!"
	label.modulate = Color(1, 0.8, 0)

	add_child(label)

	label.global_position = player.global_position + Vector2(-60, -120)

	for i in range(20):
		await get_tree().create_timer(0.03).timeout
		label.global_position.y -= 3
		label.modulate.a -= 0.05

	label.queue_free()
func animate_xp():
	if xp_tween:
		xp_tween.kill()

	xp_tween = create_tween()

	xp_tween.tween_property(
		self,
		"xp_visual",
		GameManager.xp,
		0.25
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func trigger_crit_shake():
	# Randomize intensity and duration for variety
	var intensity = randf_range(3.0, 6.0)
	var duration = randf_range(0.12, 0.45)
	var cam = null
	if has_node("Player/Camera2D"):
		cam = $Player/Camera2D
	elif has_node("../Player/Camera2D"):
		cam = get_node("../Player/Camera2D")
	if cam and cam.has_method("screen_shake"):
		cam.screen_shake(intensity, duration)
	elif cam and cam.has_method("screen_shake") == false:
		# fallback: call without params if method expects none
		cam.screen_shake()

func _on_wheat_tractor_unlock_pressed() -> void:
	if GameManager.gold >= 500:
		GameManager.gold -= 500
		$Tractors/WheatTractor.visible = true
		tractors["Wheat"]["unlocked"] = true


func activate_tractor(crop: String):
	
	var t = tractors[crop]

	if not t["unlocked"]:
		return

	if t["timer"] > 0:
		return # cooldown

	t["active"] = true
	run_tractor(crop)
	
	if t["active"]:
		return
func run_tractor(crop: String):
	tractors[crop]["active"] = true
	var nodes = []

	if crop == "Wheat":
		nodes = wheat_nodes
	elif crop == "Corn":
		nodes = corn_nodes
	elif crop == "Carrot":
		nodes = carrot_nodes

	if nodes.size() == 0:
		return


	while nodes.size() > 0:
		var amount = 1
		var xp_gain = 0
		if GameManager.roll_crit():
			amount *= GameManager.crit_multiplier
			show_crit_text()
			crit_sound.play()

		# give resources + XP
		match crop:
			"Wheat":
				GameManager.wheat += amount
				GameManager.plant_crop("Wheat")
				xp_gain += 1 * amount
				for c in GameManager.planted_crops:
					if c.name == "Wheat":
						c.crops_per_second += 0.05 * amount
				GameManager.update_crops_per_second()
			"Corn":
				GameManager.corn += amount
				GameManager.plant_crop("Corn")
				xp_gain += 3 * amount
				for c in GameManager.planted_crops:
					if c.name == "Corn":
						c.crops_per_second += 0.05 * amount
				GameManager.update_crops_per_second()
			"Carrot":
				GameManager.carrot += amount
				GameManager.plant_crop("Carrot")
				xp_gain += 5 * amount
				for c in GameManager.planted_crops:
					if c.name == "Carrot":
						c.crops_per_second += 0.05 * amount
				GameManager.update_crops_per_second()

		GameManager.add_xp(xp_gain)
		animate_xp()

		# remove node
		var sprite = nodes.pop_back()
		sprite.queue_free()

		await get_tree().create_timer(0.03).timeout

	# cooldown empieza aquí
	tractors[crop]["timer"] = tractors[crop]["cooldown"]
	tractors[crop]["active"] = false
	
func update_tractor_ui():
	for crop in tractors.keys():
		var t = tractors[crop]
		var node = null

		match crop:
			"Wheat":
				node = $Tractors/WheatTractor
			"Corn":
				node = $Tractors/CornTractor
			"Carrot":
				node = $Tractors/CarrotTractor

		if node == null:
			continue

		if not t["unlocked"]:
			update_tractor_label(crop, node, "Unlock " + crop + " Tractor")
			continue

		if t["timer"] > 0:
			update_tractor_label(crop, node, crop + " Tractor (" + str(round(t["timer"])) + "s)")
		else:
			update_tractor_label(crop, node, "Run " + crop + " Tractor")

func _on_wheat_tractor_pressed() -> void:
	activate_tractor("Wheat")


func _on_corn_tractor_pressed() -> void:
	activate_tractor("Corn")


func _on_carrot_tractor_pressed() -> void:
	activate_tractor("Carrot")

func update_tractor_label(crop: String, node: Control, text: String):
	var label_name = crop + "_tractor_label"

	var label = node.get_node_or_null(label_name)

	if label == null:
		label = Label.new()
		label.name = label_name
		label.add_theme_font_size_override("font_size", 14)
		label.modulate = Color.WHITE
		node.add_child(label)

		# posición arriba del tractor
		label.position = Vector2(-40, -60)

	label.text = text


func _on_corn_tractor_unlock_pressed() -> void:
	if GameManager.gold >= 500:
		if "Corn" in GameManager.unlocked_crops:
			GameManager.gold -= 500
			$Tractors/CornTractor.visible = true
			tractors["Corn"]["unlocked"] = true
		else:
			print("Corn Not Unlocked Yet")


func _on_carrot_tractor_unlock_pressed() -> void:
	if GameManager.gold >= 500:
		if "Carrot" in GameManager.unlocked_crops:
			GameManager.gold -= 500
			$Tractors/CarrotTractor.visible = true
			tractors["Carrot"]["unlocked"] = true
		else:
			print("Carrot Not Unlocked Yet")

func rainbow_title():
	var tween = create_tween()
	tween.set_loops()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	tween.tween_property(level_title, "modulate", Color(1,0.5,1), 0.3)
	tween.tween_property(level_title, "modulate", Color(0.5,1,1), 0.3)
	tween.tween_property(level_title, "modulate", Color(1,1,0.5), 0.3)

	return tween


func _on_prestige_pressed() -> void:
	if GameManager.can_prestige():
		GameManager.prestige()
		
