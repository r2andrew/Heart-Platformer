extends CharacterBody2D

@export var movement_data : PlayerMovementData

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

func _physics_process(delta):
	
	apply_gravity(delta)
	handle_jump()

	var input_axis = Input.get_axis("ui_left", "ui_right")

	if input_axis != 0:
		handle_acceleration(input_axis, delta)
	else:
		if is_on_floor():
			apply_friction(delta)
		else:
			apply_air_resistance(delta)
	
	update_animations(input_axis)
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()

	# TEST: change movement data
	if Input.is_action_just_pressed("ui_accept"):
		movement_data = load("res://FasterMovementData.tres")

func apply_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta

func handle_jump():
	# Handle jump.
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = movement_data.jump_velocity
	if not is_on_floor():
		if Input.is_action_just_released("ui_up") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2

func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(delta):
	velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func handle_acceleration(input_axis, delta):
	velocity.x = move_toward(velocity.x, input_axis * movement_data.speed, movement_data.acceleration * delta)

func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")
	
