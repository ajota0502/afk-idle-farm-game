extends Node
# =========================
# MONEY
# =========================

var level_up_choices = []

signal level_up(new_level, bonus)
signal prestige_activated(prestige_level, prestige_points, prestige_multiplier)

var gold: int = 0

var global_multiplier := 1.0

var prestige_level: int = 0
var prestige_points: int = 0
var prestige_multiplier := 1.0

const PRESTIGE_MIN_LEVEL := 25
const PRESTIGE_BASE_DIVISOR := 10.0
const PRESTIGE_POINT_FACTOR := 0.1

var wheat_multiplier := 1.0
var corn_multiplier := 1.0
var carrot_multiplier := 1.0

var crit_chance := 0.1
var crit_multiplier := 3.0

var cow_buff_active := false
var cow_multiplier := 1.5

var chicken_buff_active := false
var chicken_crit_bonus := 0.1  # 10% extra crit chance

var sheep_buff_active := false
var sheep_auto_harvest_multiplier := 0.85  # 15% faster (multiply interval by this)

var crop_values = {
	"Wheat": 1,
	"Corn": 3,
	"Carrot": 8
}

func get_random_upgrades():
	var pool = [
		{"id": "global", "text": "+0.1 Global Multiplier"},
		{"id": "wheat_speed", "text": "+20% Wheat Speed"},
		{"id": "corn_speed", "text": "+20% Corn Speed"},
		{"id": "carrot_speed", "text": "+20% Carrot Speed"},
		{"id": "auto_harvest", "text": "-15% Auto Harvest Interval"},
		{"id": "gold_ps", "text": "+1 Gold per second"},
		{"id": "crit_chance", "text": "+0.05 Crit Chance"},
		{"id": "crit_mult", "text": "+0.5 Crit Multiplier"}
	]
	
	pool.shuffle()
	return pool.slice(0, 3)

func apply_upgrade(id):
	match id:
		"global":
			global_multiplier += 0.1
		"wheat_speed":
			# esto afecta spawn rate indirectamente
			wheat_multiplier += 0.2
		"corn_speed":
			# esto afecta spawn rate indirectamente
			corn_multiplier += 0.2
		"carrot_speed":
			# esto afecta spawn rate indirectamente
			carrot_multiplier += 0.2
		"auto_harvest":
			auto_harvest_interval *= 0.85
		
		"auto_sell":
			auto_sell_interval *= 0.85
		
		"gold_ps":
			gold += 10  # simple por ahora
		"crit_chance":
			crit_chance += 0.05
		"crit_mult":
			crit_multiplier += 0.5
	update_crops_per_second()

func sell_all():
	gold += int(int(wheat) * crop_values["Wheat"] * prestige_multiplier)
	gold += int(int(corn) * crop_values["Corn"] * prestige_multiplier)
	gold += int(int(carrot) * crop_values["Carrot"] * prestige_multiplier)

	wheat = 0
	corn = 0
	carrot = 0

var auto_sell_unlocked := false
var auto_sell_interval := 10.0
var auto_sell_cost := 300

# =========================
# PLAYER STATS
# =========================
var level: int = 1
var xp: float = 0
var xp_to_next_level: float = 10

# =========================
# AUTO HARVEST
# =========================
var auto_harvest_tier := 0
var auto_harvest_interval := 5.0
var auto_harvest_cost := 200
var auto_harvest_unlocked := false

# =========================
# RESOURCES (INDIVIDUALES)
# =========================
var wheat: float = 0
var corn: float = 0
var carrot: float = 0

# =========================
# PRODUCTION PER SECOND
# =========================
var wheat_per_second: float = 0.0
var corn_per_second: float = 0.0
var carrot_per_second: float = 0.0

# =========================
# CROPS DATABASE
# =========================
var crop_database = {
	"Wheat": {"base_crops_per_second": 0.2, "unlock_level": 1},
	"Corn":  {"base_crops_per_second": 0.3, "unlock_level": 5},
	"Carrot": {"base_crops_per_second": 0.5, "unlock_level": 10},
}

# Lista de cultivos desbloqueados actualmente
var unlocked_crops: Array = []

var wheat_upgrade_cost := 25
var corn_upgrade_cost := 100
var carrot_upgrade_cost := 250
# =========================
# CROPS PLANTED
# =========================
class Crop:
	var name: String
	var crops_per_second: float

var planted_crops: Array = []

# =========================
# READY
# =========================
func _ready():
	print("GameManager iniciado")
	update_prestige_multiplier()
	update_unlocked_crops()
	update_crops_per_second()

# =========================
# UPDATE UNLOCKED CROPS
# =========================
func update_unlocked_crops():
	for crop_name in crop_database.keys():
		if level >= crop_database[crop_name]["unlock_level"]:
			if not crop_name in unlocked_crops:
				unlocked_crops.append(crop_name)
				print("Nuevo cultivo desbloqueado:", crop_name)

# =========================
# PLANT CROP
# =========================
func plant_crop(crop_name: String):
	if not crop_name in unlocked_crops:
		print("¡No puedes plantar", crop_name, "- desbloquea primero!")
		return

	var crop = Crop.new()
	crop.name = crop_name
	crop.crops_per_second = crop_database[crop_name]["base_crops_per_second"]

	planted_crops.append(crop)
	update_crops_per_second()

# =========================
# UPGRADE CROPS
# =========================
var crop_upgrade_base := 0.01

func get_crop_upgrade_amount() -> float:
	return crop_upgrade_base * level

func upgrade_crop(crop_name: String):
	var upgrade_amount = get_crop_upgrade_amount()
	for crop in planted_crops:
		if crop.name == crop_name:
			crop.crops_per_second += upgrade_amount
	update_crops_per_second()

# =========================
# CALCULATE PRODUCTION PER CROP
# =========================
func update_crops_per_second():
	wheat_per_second = 0.0
	corn_per_second = 0.0
	carrot_per_second = 0.0
	
	for crop in planted_crops:
		match crop.name:
			"Wheat":
				wheat_per_second += crop.crops_per_second
			"Corn":
				corn_per_second += crop.crops_per_second
			"Carrot":
				carrot_per_second += crop.crops_per_second

	# 🔥 aplicar multiplicador
	wheat_per_second *= wheat_multiplier
	corn_per_second *= corn_multiplier
	carrot_per_second *= carrot_multiplier
	
	wheat_per_second *= global_multiplier
	corn_per_second *= global_multiplier
	carrot_per_second *= global_multiplier

# =========================
# AUTO PRODUCTION (IDLE)
# =========================
func _process(delta):
	wheat += wheat_per_second * delta
	corn += corn_per_second * delta
	carrot += carrot_per_second * delta

# =========================
# XP SYSTEM
# =========================
func add_xp(amount: float):
	xp += amount * prestige_multiplier
	check_level_up()

func get_prestige_gain() -> int:
	if level < PRESTIGE_MIN_LEVEL:
		return 0
	return int(pow(level / PRESTIGE_BASE_DIVISOR, 2))

func can_prestige() -> bool:
	return level >= PRESTIGE_MIN_LEVEL

func prestige() -> void:
	var gain = get_prestige_gain()
	if gain <= 0:
		return

	prestige_points += gain
	prestige_level += 1
	update_prestige_multiplier()
	reset_progress()
	call_deferred("emit_signal", "prestige_activated", prestige_level, prestige_points, prestige_multiplier)

func update_prestige_multiplier() -> void:
	prestige_multiplier = 1.0 + prestige_points * PRESTIGE_POINT_FACTOR

func reset_progress() -> void:
	gold = 0
	level = 1
	xp = 0
	xp_to_next_level = 10

	wheat = 0
	corn = 0
	carrot = 0

	wheat_multiplier = 1.0
	corn_multiplier = 1.0
	carrot_multiplier = 1.0
	global_multiplier = 1.0

	unlocked_crops = ["Wheat"]
	planted_crops.clear()

	auto_harvest_tier = 0
	auto_harvest_interval = 5.0
	auto_harvest_cost = 200
	auto_harvest_unlocked = false
	
	auto_sell_unlocked = false
	auto_sell_interval = 10.0
	auto_sell_cost = 300

	update_unlocked_crops()
	update_crops_per_second()

func check_level_up():
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level += 1
		xp_to_next_level *= 1.2
		on_level_up()

# =========================
# LEVEL UP BONUS
# =========================
func on_level_up():
	global_multiplier += 0.05
	
	update_unlocked_crops()
	update_crops_per_second()
	
	level_up_choices = get_random_upgrades()
	
	call_deferred("emit_signal", "level_up", level, level_up_choices)
	

func sell_crop(crop_name: String):
	match crop_name:
		"Wheat":
			gold += int(int(wheat) * crop_values["Wheat"] * prestige_multiplier)
			wheat = 0
			
		"Corn":
			gold += int(int(corn) * crop_values["Corn"] * prestige_multiplier)
			corn = 0
			
		"Carrot":
			gold += int(int(carrot) * crop_values["Carrot"] * prestige_multiplier)
			carrot = 0

func roll_crit() -> bool:
	# Apply chicken buff if active: +10% crit chance
	var effective_crit_chance = crit_chance
	if chicken_buff_active:
		effective_crit_chance += chicken_crit_bonus
	return randf() <= effective_crit_chance

func get_effective_crit_chance() -> float:
	var effective = crit_chance
	if chicken_buff_active:
		effective += chicken_crit_bonus
	return effective
