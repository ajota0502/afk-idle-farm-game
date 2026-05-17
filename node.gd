extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Plantamos Wheat al inicio
	
	GameManager.update_crops_per_second()

	# Subimos XP para probar level up
	
	GameManager.gold = 2200000000
	GameManager.add_xp(3900)
	
	# Mostramos info en consola
	print(GameManager.unlocked_crops)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
