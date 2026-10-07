extends Area2D
class_name ProjectileBasic

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
		
		if (proj_engrave != "Rebounding") or (proj_hit_count > 0):
			destroy_projectile()
		else:
			time_alive = 0
			proj_hit_count += 1
			direction = -direction

func _on_body_entered(body: Node2D) -> void:
	if body is StaticBody2D:
		if (proj_engrave != "Rebounding") or (proj_hit_count > 0):
			destroy_projectile()
		else:
			time_alive = 0
			proj_hit_count += 1
			direction = -direction

func destroy_projectile() -> void:
	$Polygon2D.visible = false
	$CPUParticles2D.emitting = false
	proj_speed = 0
	set_deferred("monitoring", false)
	await get_tree().create_timer(1).timeout
	queue_free()
