extends CharacterBody2D

var target: Player = null
var health: int = 15
var contact_damage: int = 14
var knockback_force: int = 450
@onready var anin_sprite: AnimatedSprite2D = $AnimatedSprite2D

var accel_speed = 500
var max_speed = 100

var jump_chance = 150
var jump_force = 400

func locate_target():
	target = get_tree().current_scene.get_node_or_null("Player")

func should_jump() -> bool:
	return randi_range(1, jump_chance) == 1

func _physics_process(delta: float) -> void:
	if target == null:
		locate_target()
		return
	
	var direction = sign(target.global_position.x - global_position.x)
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * max_speed, accel_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, accel_speed * delta)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor() and should_jump():
		velocity.y = -jump_force
	
	update_animation(direction)
	move_and_slide()

func update_animation(direction: float) -> void:
	if not is_on_floor():
		if anin_sprite.animation != "midair":
			anin_sprite.play("midair")
		return
	
	if direction != 0:
		anin_sprite.flip_h = direction > 0
	
	anin_sprite.play("walk")

func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().recieve_damage(contact_damage, knockback_force, global_position)
