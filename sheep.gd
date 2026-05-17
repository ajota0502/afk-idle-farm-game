extends Sprite2D

# =========================
# SHEEP BOUNCE SETTINGS
# =========================
@export var bounce_height: float = 20
@export var bounce_duration: float = 0.4
@export var bounce_interval: float = 1.5

var original_position: Vector2
var player_near := false
var is_bouncing := false
var sheep_buff_timer := 0.0


func _ready():
	# Store the original position before any animations
	var base_scale = scale
	original_position = position

	# Connect the Area2D signals to detect player proximity
	if $BounceArea:
		$BounceArea.body_entered.connect(_on_body_entered)
		$BounceArea.body_exited.connect(_on_body_exited)
		print("🐑 Sheep BounceArea connected - Auto Harvest Speed Buff Active!")
	else:
		print("ERROR: BounceArea not found on Sheep")


# Called when player enters the BounceArea
func _on_body_entered(body):
	# Check if the body that entered is the player
	if body.is_in_group("player"):
		print("🐑 Player near sheep - Activating +15% Auto Harvest Speed buff!")
		
		# Set the buff active flag
		player_near = true
		GameManager.sheep_buff_active = true
		
		# Start the bounce animation loop
		bounce_loop()


# Called when player exits the BounceArea
func _on_body_exited(body):
	# Check if the body that exited is the player
	if body.is_in_group("player"):
		print("🐑 Player left sheep")
		
		# Stop bouncing immediately but delay buff removal
		player_near = false
		
		# Remove buff after 30 seconds
		remove_buff_after_delay()


# Animation loop: keeps bouncing while player is near
func bounce_loop():
	# Loop while player is still in range
	while player_near:
		# Only bounce if not already bouncing (prevents overlapping tweens)
		if not is_bouncing:
			start_bounce()
		
		# Wait for bounce_interval before next bounce
		await get_tree().create_timer(bounce_interval).timeout


# Start a single bounce animation
func start_bounce():
	is_bouncing = true
	var base_scale = scale
	var tween = create_tween()

	# Squish animation (compression before jump)
	tween.tween_property(self, "scale", base_scale*Vector2(1.2, 0.8), 0.08)

	# Jump up + stretch animation (parallel means simultaneous)
	tween.parallel().tween_property(self, "position:y", original_position.y - bounce_height, bounce_duration / 2)
	tween.parallel().tween_property(self, "scale",  base_scale*Vector2(0.8, 1.2), bounce_duration / 2)

	# Fall down animation
	tween.tween_property(self, "position:y", original_position.y, bounce_duration / 2)

	# Landing squish
	tween.parallel().tween_property(self, "scale", base_scale*Vector2(1.2, 0.8), 0.08)

	# Return to normal scale
	tween.tween_property(self, "scale", base_scale*Vector2(1, 1), 0.1)

	# Call function when animation finishes
	tween.finished.connect(_on_bounce_finished)


# Called when one bounce animation finishes
func _on_bounce_finished():
	is_bouncing = false


# Remove buff after player has been away for 30 seconds
func remove_buff_after_delay():
	# Wait 30 seconds before deactivating buff
	await get_tree().create_timer(30.0).timeout

	# Only deactivate if player hasn't come back
	if not player_near:
		GameManager.sheep_buff_active = false
		print("🐑 Sheep auto-harvest buff expired!")
