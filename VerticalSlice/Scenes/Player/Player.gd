extends CharacterBody2D
class_name Player

var Active: bool = true
@onready var GameRef = $".."
@export var HurtOverlay: TextureRect

var HP: float = 100
var hp_max: float = 100
var MP: float = 150
var mp_max: float = 150
var alive: bool = true

var max_speed = 150
var accel_speed = 500
var jump_power = 350

var previous_direction: int = 0

var AltCharging: bool = false
var alt_charge_time: float = 0.0
var alt_charge_limit: float = 1.75

@onready var altcast_tome: Sprite2D = $Tome
@onready var altcast_engraving: Sprite2D = $Tome/Engraving
@onready var alt_cast_position: Node2D = $AltCastPosition
@onready var alt_animator: AnimationPlayer = $Tome/AnimationPlayer
@onready var alt_effect: GPUParticles2D = $Tome/Charging
@onready var alt_activate_effect: GPUParticles2D = $AltCastPosition/AltRelease

@onready var animsprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_camera: Camera2D = $Camera2D
@onready var damage_area: Area2D = $DamageArea
const camera_offset: Vector2 = Vector2(70, -75)

var weapon_projectile = load("res://VerticalSlice/Projectiles/Friendly/SkullProjectile.tscn")
var weapon_use_timer: float = 0.0
var weapon_is_using: bool = false

func _ready() -> void:
	if HurtOverlay: 
		HurtOverlay.visible = true
		HurtOverlay.self_modulate = Color("FFF0")

func _physics_process(delta: float) -> void:
	if weapon_use_timer > 0:
		weapon_use_timer -= delta
		
		if weapon_use_timer <= 0:
			weapon_is_using = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump_action") and is_on_floor() and alive and Active:
		velocity.y = -jump_power
	
	var direction: float = 0
	if Active and (not AltCharging):
		direction = Input.get_axis("left_movement", "right_movement")
		if not alive:
			direction = 0
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * max_speed, accel_speed * delta)
			previous_direction = sign(velocity.x)
		else:
			velocity.x = move_toward(velocity.x, 0, accel_speed * delta)
	else:
		velocity.x = 0
	
	if AltCharging:
		alt_charge_time = min(alt_charge_time + delta, alt_charge_limit)
	
	move_and_slide()
	update_animation(direction)
	move_camera_offset(previous_direction)
	mana_regeneration(direction)

func _input(event: InputEvent) -> void:
	if (not alive) or (not Active):
		return
	
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_RIGHT) and MP > 10:
			AltCharging = event.pressed
			alt_effect.emitting = event.pressed
		
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and (not AltCharging):
			if MP >= GlobalGame.Weapon["ManaUsage"]:
				use_weapon()

func use_weapon() -> void:
	if weapon_is_using:
		return
	
	weapon_is_using = true
	weapon_use_timer = GlobalGame.Weapon["UseTime"]
	animsprite.play("attack")
	
	var mouse_position := get_global_mouse_position()
	var face_right: bool = mouse_position.x > global_position.x
	animsprite.flip_h = (not face_right)
	previous_direction = sign((global_position.x - mouse_position.x) * -1)
	
	var pos_name = "RightCast" if face_right else "LeftCast"
	var proj = weapon_projectile.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.game_player = self
	proj.position = get_node(pos_name).global_position
	proj.start_projectile(get_global_mouse_position())
	
	MP -= GlobalGame.Weapon["ManaUsage"]
	GameRef.player_values_changed()

func use_weapon_alt_cast() -> void:
	alt_activate_effect.emitting = true
	weapon_is_using = true
	
	var projectile_directions: Array[Vector2] = [
		global_position + Vector2(1,0), # R
		global_position + Vector2(1,1), # RD
		global_position + Vector2(0,1), # D
		global_position + Vector2(-1,1), # LD
		global_position + Vector2(-1,0), # L
		global_position + Vector2(-1,-1), # LU
		global_position + Vector2(0,-1), # U
		global_position + Vector2(1,-1) # RU
	]
	
	for pnt in projectile_directions:
		var proj = weapon_projectile.instantiate()
		get_tree().current_scene.add_child(proj)
		proj.game_player = self
		proj.global_position = alt_cast_position.global_position
		proj.projectile_damage *= 2
		proj.projectile_lifetime *= 2
		proj.start_projectile(pnt)
	
	MP = 0
	GameRef.player_values_changed()
	
	await get_tree().create_timer(2).timeout
	weapon_is_using = false

func update_animation(direction: float) -> void:
	if weapon_is_using:
		return
	
	if AltCharging:
		var prog: float = (alt_charge_time) / (alt_charge_limit)
		
		if animsprite.animation != "raise":
			animsprite.play("raise")
			alt_animator.play("altcast")
			
		if alt_animator.current_animation_position == alt_animator.current_animation_length:
			var shake_range = lerpf(0, 1, prog)
			var shake_origin = Vector2(-5.35, -30.0)
			var shake_position = Vector2(randf_range(-shake_range, shake_range), randf_range(-shake_range, shake_range))
			altcast_tome.position = shake_origin + shake_position
			
		var effect_speed = lerpf(1, 7, prog)
		alt_effect.speed_scale = effect_speed
		
		if alt_charge_time == alt_charge_limit:
			altcast_tome.modulate = Color(12,12,12,1)
		return
	
	elif alt_charge_time > 0.0:
		if alt_charge_time == alt_charge_limit:
			use_weapon_alt_cast()
		
		alt_animator.play_backwards("altcast")
		alt_charge_time = 0
	
	if not is_on_floor():
		if animsprite.animation != "jump":
			animsprite.play("jump")
		return
	
	if direction != 0:
		animsprite.flip_h = direction <= 0
	
	if abs(velocity.x) > 1:
		animsprite.play("walk")
	else:
		animsprite.play("idle")

func mana_regeneration(direction) -> void:
	if (GameRef.game_active):
		var stationary_bonus: float = 2 if (direction == 0) else 1
		var item_usage_factor: float = 0.05 if (weapon_is_using) else 1.0
		var mp_regen_factor: float = (MP / mp_max) * 0.5 + 0.5
		var mp_bonus_regen = 0 # For accessories
		var mp_regen_base: float = ((mp_max / 3) + 1 + mp_bonus_regen)
		var mp_regen: float = (mp_regen_base * stationary_bonus * mp_regen_factor * item_usage_factor)
		
		MP += (mp_regen / 60) * 0.8
		if MP > mp_max:
			MP = mp_max
		GameRef.player_values_changed()

func recieve_health(hp_income: float) -> void:
	HP += hp_income
	if HP > hp_max: HP = hp_max
	GameRef.player_values_changed()

func recieve_damage(dmg: float, knockback_force: float, src_position: Vector2) -> void:#
	if damage_area.monitoring == false:
		return
	
	HP -= dmg
	if HurtOverlay:
		HurtOverlay.self_modulate = Color("FFFF")
		create_tween().tween_property(HurtOverlay, "self_modulate", Color("FFF0"), 2)
	
	if AltCharging:
		AltCharging = false
		alt_animator.play_backwards("altcast")
		alt_charge_time = 0
	
	GameRef.player_values_changed()
	
	var knockback_direction = (global_position - src_position)
	velocity.x = sign(knockback_direction.x) * knockback_force
	velocity.y = -knockback_force * 0.5
	
	if HP <= 0:
		player_death()
	else:
		damage_area.set_deferred("monitoring", false)
		animsprite.self_modulate = Color("ffffff87")
		await get_tree().create_timer(1.5).timeout
		animsprite.self_modulate = Color("ffffffff")
		damage_area.set_deferred("monitoring", true)

func player_death() -> void:
	if not alive: 
		return
	alive = false
	$DamageArea.set_deferred("monitoring", false)
	
	animsprite.material = animsprite.material.duplicate(true)
	await get_tree().create_tween().tween_method(func(v: float): 
		animsprite.material.set_shader_parameter("progress", v), 0.2, 1.0, 0.8).finished

func move_camera_offset(offset_direction: int):
	if player_camera == null:
		return
	var fixed_offset = camera_offset
	fixed_offset.x *= offset_direction
	
	if player_camera.offset.x != offset_direction:
		create_tween().tween_property(player_camera, "offset", fixed_offset, 0.5)
