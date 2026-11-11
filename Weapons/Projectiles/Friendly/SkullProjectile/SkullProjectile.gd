extends Area2D

var game_player: Player = null

@export var projectile_damage: float = 15.0
@export var projectile_knockback: float = 500.0
@export var projectile_speed: float = 250.0
@export var projectile_lifetime: float = 1.0

@onready var projectile_sprite: Sprite2D = $Skull
@onready var projectile_lighting: PointLight2D = $PointLight2D
@onready var surrounding_particles: GPUParticles2D = $Surrounding

@onready var seeking_area: Area2D = $HoningRange
var seeking_strength: float = 6.0

var direction := Vector2.ZERO
var alive: bool = true
var time_alive = 0.0

func start_projectile(shoot_point: Vector2) -> void:
	projectile_sprite.material = projectile_sprite.material.duplicate()
	direction = -(position - shoot_point).normalized()
	projectile_sprite.look_at(shoot_point)
	
	var facing_left = (shoot_point.x - global_position.x <= 0)
	projectile_sprite.flip_h = facing_left
	if facing_left:
		projectile_sprite.rotation_degrees -= 180
	
	alive = true

func _physics_process(delta: float) -> void:
	var overlapping_areas = seeking_area.get_overlapping_areas()
	var enemies_in_range = []
	for n in overlapping_areas:
		if (n.get_parent() is Enemy):
			enemies_in_range.append(n)
	
	if len(enemies_in_range) != 0:
		var enemy_target = enemies_in_range[0]
		var to_target = (enemy_target.global_position - global_position).normalized()
		direction = direction.lerp(to_target, seeking_strength * delta).normalized()
		projectile_sprite.rotation = direction.angle()
		projectile_sprite.flip_h = (direction.x < 0)
	
	global_position += direction * projectile_speed * delta
	
	time_alive += delta
	if time_alive >= projectile_lifetime:
		end_projectile()

func _on_area_entered(area: Area2D) -> void:
	if (area.get_parent() is Enemy) and (area.get_parent().health > 0):
		area.get_parent().recieve_damage(projectile_damage, projectile_knockback, global_position)
		end_projectile()

func end_projectile() -> void:
	if not alive:
		return
	
	alive = false
	create_tween().tween_method(func(v: float): 
		projectile_sprite.material.set_shader_parameter("progress", v), 0.2, 1.0, 0.5)
	
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	surrounding_particles.emitting = false
	projectile_speed = 0
	create_tween().tween_property(projectile_lighting, "color", Color("#0000"), 0.75)
	await get_tree().create_timer(1).timeout
	queue_free()
