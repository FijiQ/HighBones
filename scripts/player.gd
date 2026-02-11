extends CharacterBody2D

const SPEED = 200.0

func _physics_process(delta):
	# Управление WASD
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	# Атака дымом на Space
	if Input.is_action_just_pressed("ui_accept"):
		print("Smoke attack! (placeholder)")
