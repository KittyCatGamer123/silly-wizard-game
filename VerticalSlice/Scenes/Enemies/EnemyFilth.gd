extends Enemy
class_name EnemySimple

@onready var digging_particles: GPUParticles2D = $SpawnDigging
@onready var digging_light: PointLight2D = $SpawnDigging/PointLight2D

var spawned: bool = false

var jump_chance = 150
var jump_force = 300

func _ready() -> void:
	digging_particles.emitting = false
	digging_light.visible = false
	
	anin_sprite.play("RESET")
	attack_area.monitoring = false
	attack_area.monitorable = false

func summon_enemy() -> void:
	digging_particles.emitting = true
	digging_light.visible = true
	await get_tree().create_timer(2).timeout
	anin_sprite.play("spawn")
	
	await anin_sprite.animation_finished
	
	digging_particles.emitting = false
	digging_light.visible = false
	attack_area.monitoring = true
	attack_area.monitorable = true
	
	spawned = true

func movement_handling(delta: float):
	if not spawned:
		return
	
	var direction = sign(target.global_position.x - global_position.x)
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * max_speed, accel_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, accel_speed * delta)
	
	if is_on_floor() and should_jump():
		velocity.y = -jump_force
	
	update_animation(direction)

func should_jump() -> bool:
	if get_node("JumpCasts/RightJump").is_colliding(): return true
	if get_node("JumpCasts/LeftJump").is_colliding(): return true
	
	return randi_range(1, jump_chance) == 1
