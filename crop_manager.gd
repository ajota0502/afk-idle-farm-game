extends Node2D

const Constants = preload("res://Constants.gd")

var main
var player

# =========================
# REFERENCES
# =========================
@onready var wheat_label = $"../Wheat/wheatLabel"
@onready var corn_label = $"../Corn/CornLabel"
@onready var carrot_label = $"../Carrot/CarrotLabel"

@onready var wheat_texture = load("res://Sprites/Wheat_JE2_BE2.png")
@onready var corn_texture = load("res://Sprites/Corn.webp")
@onready var carrot_texture = load("res://Sprites/Carrot.webp")

@onready var wheat_spawn_area = $"../Wheat/wheatSpawnArea"
@onready var corn_spawn_area = $"../Corn/CornSpawnArea"
@onready var carrot_spawn_area = $"../Carrot/CarrotSpawnArea"

@onready var crit_sound = $"../CritSound"

# =========================
# STATE
# =========================
var text_pool = []
var text_pool_index = 0

# =========================
# TIMERS
# =========================
var wheat_spawn_timer = 0.0
var corn_spawn_timer = 0.0
var carrot_spawn_timer = 0.0

# =========================
# READY
# =========================
func _ready() -> void:
	pass  # Pool will be initialized from node_2d after main is set

func _init_text_pool() -> void:
	for i in range(Constants.FLOATING_TEXT_POOL_SIZE):
		var container = Node2D.new()
		var label = Label.new()
		var icon = TextureRect.new()
		
		icon.custom_minimum_size = Vector2(24, 24)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		container.add_child(icon)
		container.add_child(label)
		container.visible = false
		
		main.add_child(container)
		text_pool.append({"container": container, "label": label, "icon": icon})

func _get_pooled_text() -> Dictionary:
	var item = text_pool[text_pool_index]
	text_pool_index = (text_pool_index + 1) % text_pool.size()
	item["container"].visible = true
	return item

# =========================
# SPAWN SPRITES
# =========================
func spawn_wheat_sprite():
	var sprite = Sprite2D.new()
	sprite.texture = wheat_texture
	sprite.scale = Constants.WHEAT_SCALE
	var rect = $"../Wheat/harvest".get_rect()
	sprite.position = rect.position + Vector2(
		randf_range(0, rect.size.x),
		randf_range(0, rect.size.y)
	)
	main.add_child(sprite)
	main.wheat_nodes.append(sprite)

func spawn_corn_sprite():
	var sprite = Sprite2D.new()
	sprite.texture = corn_texture
	sprite.scale = Constants.CORN_SCALE
	var rect = $"../Corn/HarvestCornButton".get_rect()
	sprite.position = rect.position + Vector2(
		randf_range(0, rect.size.x),
		randf_range(0, rect.size.y)
	)
	main.add_child(sprite)
	main.corn_nodes.append(sprite)

func spawn_carrot_sprite():
	var sprite = Sprite2D.new()
	sprite.texture = carrot_texture
	sprite.scale = Constants.CARROT_SCALE
	var rect = $"../Carrot/HarvestCarrotButton".get_rect()
	sprite.position = rect.position + Vector2(
		randf_range(0, rect.size.x),
		randf_range(0, rect.size.y)
	)
	main.add_child(sprite)
	main.carrot_nodes.append(sprite)

# =========================
# REMOVE SPRITES
# =========================
func remove_wheat_sprite():
	if main.wheat_nodes.size() > 0:
		var sprite = main.wheat_nodes.pop_back()
		sprite.queue_free()

func remove_corn_sprite():
	if main.corn_nodes.size() > 0:
		var sprite = main.corn_nodes.pop_back()
		sprite.queue_free()

func remove_carrot_sprite():
	if main.carrot_nodes.size() > 0:
		var sprite = main.carrot_nodes.pop_back()
		sprite.queue_free()

# =========================
# FLOATING TEXT (POOLED)
# =========================
func spawn_wheatText(amount):
	_spawn_text(amount, "Wheat", wheat_spawn_area, wheat_texture)

func spawn_cornText(amount):
	_spawn_text(amount, "Corn", corn_spawn_area, corn_texture)

func spawn_carrotText(amount):
	_spawn_text(amount, "Carrot", carrot_spawn_area, carrot_texture)

func _spawn_text(amount, crop_name: String, spawn_area, texture):
	var item = _get_pooled_text()
	var label = item["label"]
	var icon = item["icon"]
	var container = item["container"]
	
	label.text = "+" + str(int(amount)) + " " + crop_name
	icon.texture = texture
	
	var random_offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
	label.position = spawn_area.position + random_offset
	icon.position = label.position + Vector2(-30, 0)
	
	if amount > 1:
		label.modulate = Constants.CRIT_COLOR
	else:
		label.modulate = Color.WHITE
	
	label.modulate.a = 1.0
	icon.modulate.a = 1.0
	
	_animate_float_text(label, icon, container)

func _animate_float_text(label, icon, container):
	for i in range(Constants.FLOAT_TEXT_FRAMES):
		await get_tree().create_timer(Constants.FLOAT_TEXT_TIMER).timeout
		label.modulate.a -= Constants.FLOATING_TEXT_FADE_SPEED
		icon.modulate.a -= Constants.FLOATING_TEXT_FADE_SPEED
		label.position.y -= Constants.FLOATING_TEXT_MOVE_SPEED
		icon.position.y -= Constants.FLOATING_TEXT_MOVE_SPEED
	
	container.visible = false

# =========================
# HARVEST BUTTON HANDLERS
# =========================
func harvest_wheat():
	if main.wheat_nodes.size() <= 0:
		return
	
	var amount = 1
	remove_wheat_sprite()
	
	if GameManager.roll_crit():
		amount *= GameManager.crit_multiplier
		show_crit_text()
		crit_sound.play()
		# screen shake on crit (use main which references node_2d)
		if main:
			main.trigger_crit_shake()
	
	GameManager.wheat += amount
	spawn_wheatText(amount)
	
	for crop in GameManager.planted_crops:
		if crop.name == "Wheat":
			crop.crops_per_second += 0.05 * amount
	
	GameManager.plant_crop("Wheat")
	GameManager.update_crops_per_second()
	GameManager.add_xp(amount)
	main.animate_xp()

func harvest_corn():
	if not "Corn" in GameManager.unlocked_crops:
		return
	if main.corn_nodes.size() <= 0:
		return
	
	var amount = 1
	remove_corn_sprite()
	
	if GameManager.roll_crit():
		amount *= GameManager.crit_multiplier
		show_crit_text()
		crit_sound.play()
		# screen shake on crit (use main which references node_2d)
		if main:
			main.trigger_crit_shake()
	
	GameManager.corn += amount
	spawn_cornText(amount)
	
	for crop in GameManager.planted_crops:
		if crop.name == "Corn":
			crop.crops_per_second += 0.08 * amount
	
	GameManager.plant_crop("Corn")
	GameManager.update_crops_per_second()
	GameManager.add_xp(amount * 2)
	main.animate_xp()

func harvest_carrot():
	if not "Carrot" in GameManager.unlocked_crops:
		return
	if main.carrot_nodes.size() <= 0:
		return
	
	var amount = 1
	remove_carrot_sprite()
	
	if GameManager.roll_crit():
		amount *= GameManager.crit_multiplier
		show_crit_text()
		crit_sound.play()
		# screen shake on crit (use main which references node_2d)
		if main:
			main.trigger_crit_shake()
	
	GameManager.carrot += amount
	spawn_carrotText(amount)
	
	for crop in GameManager.planted_crops:
		if crop.name == "Carrot":
			crop.crops_per_second += 0.12 * amount
	
	GameManager.plant_crop("Carrot")
	GameManager.update_crops_per_second()
	GameManager.add_xp(amount * 4)
	main.animate_xp()

func show_crit_text():
	crit_sound.pitch_scale = randf_range(0.4, 2.0)
	var label = Label.new()
	label.text = "CRITICAL!"
	label.modulate = Constants.CRIT_COLOR
	main.add_child(label)
	label.global_position = player.global_position + Vector2(-60, -120)
	
	for i in range(20):
		await get_tree().create_timer(0.03).timeout
		label.global_position.y -= 3
		label.modulate.a -= 0.05
	
	label.queue_free()
