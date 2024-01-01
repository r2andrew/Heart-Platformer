extends CharacterBody2D

@export var movement_data : PlayerMovementData

var air_jump = false
var just_wall_jumped = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_known_wall_normal = Vector2.ZERO

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position
@onready var wall_jump_timer = $WallJumpTimer

func _physics_process(delta):
	
	# TEST: change movement data
	if Input.is_action_just_pressed("ui_page_down"):
		movement_data = load("res://FasterMovementData.tres")
		
	just_wall_jumped = false
	
	# TEST: go to spawn
	if Input.is_action_just_pressed("ui_page_up"):
		global_position = starting_position
		
	
	apply_gravity(delta)
	
	if is_on_wall_only() or wall_jump_timer.time_left > 0.0:
		handle_wall_jump()
	
	handle_jump()

	var input_axis = Input.get_axis("move_left", "move_right")

	if input_axis != 0:
		if is_on_floor():
			handle_acceleration(input_axis, delta)
		else:
			handle_air_acceleration(input_axis, delta)
	else:
		if is_on_floor():
			apply_friction(delta)
		else:
			apply_air_resistance(delta)
	
	update_animations(input_axis)
	
	var was_on_floor = is_on_floor()
	
	var was_on_wall = is_on_wall_only()
	if was_on_wall:
		last_known_wall_normal = get_wall_normal()
	
	move_and_slide()
	
	# Grace Periods for jump and wall jump
	
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
		
	var just_left_wall = was_on_wall and not is_on_wall_only()
	if just_left_wall:
		wall_jump_timer.start()
	

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta

func handle_wall_jump():
	if Input.is_action_just_pressed("jump"):
		velocity.x = last_known_wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity * 0.8
		just_wall_jumped = true

	
func handle_jump():
	if is_on_floor(): air_jump = true
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2
		if Input.is_action_just_pressed("jump") and air_jump and not just_wall_jumped:
			velocity.y = movement_data.jump_velocity * 0.8
			air_jump = false

func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(delta):
	velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	velocity.x = move_toward(velocity.x, input_axis * movement_data.speed, movement_data.acceleration * delta)
	
func handle_air_acceleration(input_axis, delta):
	velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)

func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")
	
func _on_hazard_detector_area_entered(area):
	global_position = starting_position
