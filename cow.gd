extends Sprite2D

@export var bounce_height: float = 20
@export var bounce_duration: float = 0.4
@export var bounce_interval: float = 1.5

var original_position: Vector2
var player_near := false
var is_bouncing := false
var cow_buff_timer := 0.0


func _ready():
	var base_scale = scale
	original_position = position

	if $BounceArea:
		$BounceArea.body_entered.connect(_on_body_entered)
		$BounceArea.body_exited.connect(_on_body_exited)
		print("BounceArea conectado")
	else:
		print("ERROR: BounceArea no encontrado")


func _on_body_entered(body):

	print("Algo entró:", body.name)

	if body.is_in_group("player"):
		print("Player cerca de la vaca")

		player_near = true
		GameManager.cow_buff_active = true

		bounce_loop()


func _on_body_exited(body):

	if body.is_in_group("player"):
		print("Player se alejó")

		player_near = false

		remove_buff_after_delay()


func bounce_loop():

	while player_near:

		if not is_bouncing:
			start_bounce()

		await get_tree().create_timer(bounce_interval).timeout


func start_bounce():

	is_bouncing = true
	var base_scale = scale
	var tween = create_tween()

	# Squish al preparar saltoa
	tween.tween_property(self, "scale", base_scale*Vector2(1.2, 0.8), 0.08)

	# Salto hacia arriba + stretch
	tween.parallel().tween_property(self, "position:y", original_position.y - bounce_height, bounce_duration / 2)
	tween.parallel().tween_property(self, "scale",  base_scale*Vector2(0.8, 1.2), bounce_duration / 2)

	# Caída
	tween.tween_property(self, "position:y", original_position.y, bounce_duration / 2)

	# Squish al aterrizar
	tween.parallel().tween_property(self, "scale", base_scale*Vector2(1.2, 0.8), 0.08)

	# Volver a normal
	tween.tween_property(self, "scale", base_scale*Vector2(1, 1), 0.1)

	tween.finished.connect(_on_bounce_finished)


func _on_bounce_finished():

	is_bouncing = false

func remove_buff_after_delay():

	await get_tree().create_timer(30.0).timeout

	# evitar apagarlo si el player volvió a entrar
	if not player_near:
		GameManager.cow_buff_active = false
		print("Cow buff expiró")
