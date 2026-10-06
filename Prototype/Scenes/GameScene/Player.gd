extends CharacterBody2D

var max_speed = 100
var accel_speed = 500
var jump_power = 225

var previous_direction: int = 0

@onready var animsprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_camera: Camera2D = $Camera2D
const camera_x_offset: float = 50

# Weapon
var use_time: float = 0.7
var use_timer: float = 0.0
var is_using := false

func _physics_process(delta: float) -> void:
	# Update weapon timer
	if use_timer > 0:
		use_timer -= delta
		
		if use_timer <= 0:
			is_using = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump_action") and is_on_floor():
		velocity.y = -jump_power
	
	var direction := Input.get_axis("left_movement", "right_movement")
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * max_speed, accel_speed * delta)
		previous_direction = sign(velocity.x)
	else:
		velocity.x = move_toward(velocity.x, 0, accel_speed * delta)
	
	move_and_slide()
	update_animation(direction)
	move_camera_offset(previous_direction * camera_x_offset)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			use_weapon()

func use_weapon() -> void:
	if is_using:
		return
	
	is_using = true
	use_timer = use_time
	
	var mouse_position := get_global_mouse_position()
	
	animsprite.flip_h = mouse_position.x > global_position.x
	previous_direction = sign((global_position.x - mouse_position.x) * -1)
	
	animsprite.play("attack")

func update_animation(direction: float) -> void:
	if is_using:
		return
	
	if not is_on_floor():
		if animsprite.animation != "midair":
			animsprite.play("midair")
		return
	
	if direction != 0:
		animsprite.flip_h = direction > 0
	
	if abs(velocity.x) > 1:
		animsprite.play("walk")
	else:
		animsprite.play("idle")

func move_camera_offset(offset_direction: float):
	if player_camera.offset.x != offset_direction:
			create_tween().tween_property(player_camera, "offset", Vector2(offset_direction, -80), 0.3)
