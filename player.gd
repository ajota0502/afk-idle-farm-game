extends CharacterBody2D

@export var speed = 80
@onready var sprite = $AnimatedSprite2D

func _physics_process(delta):

	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	velocity = direction.normalized() * speed
	move_and_slide()

	update_animation(direction)
	
func play_idle():

	if sprite.animation.begins_with("walk"):
		sprite.play(sprite.animation.replace("walk", "idle"))

func play_walk(direction):

	if abs(direction.x) > abs(direction.y):

		if direction.x > 0:
			sprite.flip_h = false
			sprite.play("walk_right")

		else:
			sprite.flip_h = true
			sprite.play("walk_right")

	else:

		if direction.y > 0:
			sprite.play("walk_down")

		else:
			sprite.play("walk_up")


func update_animation(direction):

	if direction == Vector2.ZERO:
		play_idle()
	else:
		play_walk(direction)
