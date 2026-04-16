extends CharacterBody2D

@export var speed := 100

@onready var anim = $AnimatedSprite2D


func _physics_process(delta):

	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	input_vector = input_vector.normalized()

	# Convert to isometric movement
	var iso_vector = Vector2(
		input_vector.x - input_vector.y,
		(input_vector.x + input_vector.y) / 2
	)

	velocity = iso_vector * speed
	move_and_slide()

	play_animation(input_vector)


func play_animation(direction):

	if direction == Vector2.ZERO:
		anim.stop()
		return

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim.play("right")
		else:
			anim.play("left")
	else:
		if direction.y > 0:
			anim.play("front")
		else:
			anim.play("up")
