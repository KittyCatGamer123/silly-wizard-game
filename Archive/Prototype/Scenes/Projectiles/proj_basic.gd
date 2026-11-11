extends Area2D
class_name ProjectileBasic

var game_player: Player = null
@onready var particle_nodes = $Particles
var active_particle: CPUParticles2D

var proj_hit_count = 0
var proj_type = "Basic"
var proj_engrave = "None"

var proj_damage = 0.0
var proj_knockback = 0.0
var proj_lifetime = 0.0
var proj_speed = 0.0

var direction = Vector2.ZERO
var time_alive = 0.0

func start_projectile() -> void:
	direction = -(position - get_global_mouse_position()).normalized()
	
	proj_type = GlobalGame.Weapon["Primary"]["Id"]
	proj_engrave = GlobalGame.Weapon["Engraving"]["Id"]
	
	active_particle = particle_nodes.get_node(proj_type)
	active_particle.emitting = true
	
	proj_damage = GlobalGame.Weapon["Damage"]
	proj_knockback = GlobalGame.Weapon["Knockback"]
	proj_speed = GlobalGame.Weapon["Speed"]
	proj_lifetime = GlobalGame.Weapon["Lifetime"]
	
	if proj_engrave == "Overcharged":
		proj_damage *= 2

func _physics_process(delta: float) -> void:
	global_position += direction * proj_speed * delta
	
	time_alive += delta
	if time_alive >= proj_lifetime:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if (area.get_parent() is BasicEnemy) and (not area.get_parent().health <= 0):
		area.get_parent().recieve_damage(proj_damage, proj_knockback, global_position)
		
		if proj_type == "Shock":
			shock_nearest_enemy(area)
		elif proj_type == "Venom":
			area.get_parent().recieve_venom()
		elif proj_type == "Vampire":
			if randi_range(1, 5) == 1:
				game_player.recieve_health(proj_damage)
		
		if (proj_engrave == "Rebounding") and (proj_hit_count == 0):
			time_alive = 0
			proj_hit_count += 1
			reflect_projectile()
		else:
			destroy_projectile()

func _on_body_entered(body: Node2D) -> void:
	if body is StaticBody2D:
		if (proj_engrave != "Rebounding") or (proj_hit_count > 0):
			destroy_projectile()
		else:
			time_alive = 0
			proj_hit_count += 1
			reflect_projectile()

func reflect_projectile() -> void:
	direction = -direction

func shock_nearest_enemy(area: Area2D) -> void:
	var enemies = []
	for n in get_tree().current_scene.get_children():
		if n is BasicEnemy:
			enemies.append(n)
	enemies.erase(area.get_parent())
	
	var split_enemy: BasicEnemy = enemies.pick_random()
	if split_enemy != null:
		split_enemy.recieve_damage(proj_damage, proj_knockback, global_position)

func destroy_projectile() -> void:
	$Polygon2D.visible = false
	active_particle.emitting = false
	proj_speed = 0
	set_deferred("monitoring", false)
	await get_tree().create_timer(1).timeout
	queue_free()
