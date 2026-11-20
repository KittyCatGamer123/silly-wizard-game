@abstract
extends Node2D
class_name Projectile

var player_reference: Player = null
var projectile_damage: float = 1
var projectile_knockback: float = 1
var projectile_speed: float = 1
var projectile_lifetime: float = 1

@export var projectile_area2d: Area2D
@export var projectile_sprite: Sprite2D
@export var projectile_lighting: PointLight2D
@export var surrounding_particles: GPUParticles2D

var direction := Vector2.ZERO
var alive: bool = true
var time_alive = 0.0

func _process(delta: float) -> void:
	projectile_update(delta)
	
	time_alive += delta
	if time_alive >= projectile_lifetime:
		end_projectile()

@abstract
func _on_area_entered(area: Area2D) -> void

func projectile_post_start(shoot_point: Vector2) -> void:
	pass

@abstract
func projectile_update(delta: float) -> void

func start_projectile(shoot_point: Vector2) -> void:
	if projectile_area2d:
		projectile_area2d.connect("area_entered", _on_area_entered)
		projectile_area2d.collision_layer = 2
	
	direction = -(position - shoot_point).normalized()
	
	if projectile_sprite:
		projectile_sprite.material = projectile_sprite.material.duplicate()
		projectile_sprite.look_at(shoot_point)
		
		var facing_left = (shoot_point.x - global_position.x <= 0)
		projectile_sprite.flip_h = facing_left
		if facing_left:
			projectile_sprite.rotation_degrees -= 180
	
	alive = true
	projectile_post_start(shoot_point)

func end_projectile() -> void:
	if not alive:
		return
	
	alive = false
	
	if projectile_sprite:
		create_tween().tween_method(func(v: float): 
			projectile_sprite.material.set_shader_parameter("progress", v), 0.2, 1.0, 0.5)
	
	if projectile_area2d:
		projectile_area2d.set_deferred("monitoring", false)
		projectile_area2d.set_deferred("monitorable", false)
	
	if surrounding_particles:
		surrounding_particles.emitting = false
	
	projectile_speed = 0
	
	if projectile_lighting:
		create_tween().tween_property(projectile_lighting, "color", Color("#0000"), 0.75)
	
	await get_tree().create_timer(1).timeout
	queue_free()
