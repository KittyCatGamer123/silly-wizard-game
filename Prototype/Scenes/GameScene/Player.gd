extends CharacterBody2D
class_name Player

@onready var GameRef = $".."
var HP = 80
var hp_max = 80
var MP: float = 100
var mp_max: float = 150
var essence = 0

var max_speed = 80
var accel_speed = 500
var jump_power = 225

var previous_direction: int = 0

@onready var animsprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_camera: Camera2D = $Camera2D
@onready var damage_area: Area2D = $DamageArea
const camera_x_offset: float = 50

var weapon_damage: float = 4
var weapon_use_time: float = 0.7
var weapon_use_timer: float = 0.0
var weapon_is_using: bool = false
var weapon_mana_usage: float = 4.5

func _physics_process(delta: float) -> void:
	if weapon_use_timer > 0:
		weapon_use_timer -= delta
		
		if weapon_use_timer <= 0:
			weapon_is_using = false
	
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
	mana_regeneration(direction)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if MP >= weapon_mana_usage:
				use_weapon()

func use_weapon() -> void:
	if weapon_is_using:
		return
	
	weapon_is_using = true
	weapon_use_timer = weapon_use_time
	animsprite.play("attack")
	
	var mouse_position := get_global_mouse_position()
	animsprite.flip_h = mouse_position.x > global_position.x
	previous_direction = sign((global_position.x - mouse_position.x) * -1)
	
	MP -= weapon_mana_usage
	GameRef.player_values_changed()

func update_animation(direction: float) -> void:
	if weapon_is_using:
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

func mana_regeneration(direction) -> void:
	if GameRef.game_active:
		var stationary_bonus: float = 1.5 if (direction == 0) else 0.5
		var item_usage_factor: float = 0.05 if (weapon_is_using) else 1.0
		var mp_regen_factor: float = (MP / mp_max) * 0.5 + 0.5
		var mp_bonus_regen = 0 # For accessories
		var mp_regen_base: float = ((mp_max / 3) + 1 + mp_bonus_regen)
		var mp_regen: float = (mp_regen_base * stationary_bonus * mp_regen_factor * item_usage_factor)
		
		MP += (mp_regen / 60) * 0.1
		GameRef.player_values_changed()

func recieve_damage(dmg: float, knockback_force: float, src_position: Vector2) -> void:#
	if damage_area.monitoring == false:
		return
	
	HP -= dmg
	GameRef.player_values_changed()
	
	var knockback_direction = (global_position - src_position).normalized()
	velocity.x = knockback_direction.x * knockback_force
	velocity.y = -knockback_force * 0.5
	
	damage_area.set_deferred("monitoring", false)
	animsprite.self_modulate = Color("ffffff87")
	await get_tree().create_timer(1.5).timeout
	animsprite.self_modulate = Color("ffffffff")
	damage_area.set_deferred("monitoring", true)

func move_camera_offset(offset_direction: float):
	if player_camera.offset.x != offset_direction:
			create_tween().tween_property(player_camera, "offset", Vector2(offset_direction, -80), 0.3)
