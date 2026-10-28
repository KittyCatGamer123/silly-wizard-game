extends Enemy

@onready var light: PointLight2D = $PointLight2D
@onready var spawn_effect: GPUParticles2D = $SpawnEffect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var fire_projectile = load("res://VerticalSlice/Projectiles/Enemy/CastedFireball.tscn")

func _ready() -> void:
	attack_area.set_deferred("monitorable", false)
	attack_area.set_deferred("monitoring", false)
	
	visible = false
	anin_sprite.play("RESET")

func movement_handling(_delta: float) -> void:
	anin_sprite.flip_h = (target.global_position.x - global_position.x > 0)

func summon_enemy() -> void:
	visible = true
	await spawn_anim(true)
	await charge_and_fire()
	await spawn_anim(false)
	visible = false
	await teleport()
	summon_enemy()

func teleport() -> void:
	visible = false
	
	while true:
		var direction = 1 if randi_range(0, 1) == 0 else -1
		var offset = Vector2(randi_range(150, 250) * direction, randi_range(-250, 250))
		var reposition = target.global_position + offset
		
		global_position = reposition
		await get_tree().physics_frame
		
		$UpCheck.force_raycast_update()
		$DownCheck.force_raycast_update()
		$LeftCheck.force_raycast_update()
		$RightCheck.force_raycast_update()
		
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = $CollisionShape2D.shape
		query.transform = $CollisionShape2D.global_transform
		query.collision_mask = 1
		query.exclude = [get_rid()]
		
		var space_state = get_world_2d().direct_space_state
		var overlaps = space_state.intersect_shape(query)
		
		if (
			($DownCheck.is_colliding()) and 
			(not $LeftCheck.is_colliding()) and 
			(not $RightCheck.is_colliding()) and 
			(not $UpCheck.is_colliding()) and
			overlaps.is_empty()
		):
			break
	
	await get_tree().create_timer(randf_range(0, 0.5)).timeout
	visible = true

func spawn_anim(backwards: bool = true) -> void:
	if health >= 0:
		attack_area.set_deferred("monitorable", false)
		attack_area.set_deferred("monitoring", false)
	
	light.energy = 2.5
	create_tween().tween_property(light, "energy", 1.2, 1)
	if backwards:
		anin_sprite.play_backwards("respawn")
	else:
		anin_sprite.play("respawn")
	spawn_effect.emitting = true
	
	await anin_sprite.animation_finished
	
	if health >= 0:
		attack_area.set_deferred("monitorable", backwards)
		attack_area.set_deferred("monitoring", backwards)
	
	await get_tree().create_timer(0.5).timeout
	return

func charge_and_fire() -> void:
	anin_sprite.play("raise")
	await anin_sprite.animation_finished
	await get_tree().create_timer(0.5).timeout
	
	if health <= 0:
		return
	
	var face_right: bool = target.position.x > global_position.x
	var pos_name = "RightCast" if face_right else "LeftCast"
	
	var fireball = fire_projectile.instantiate()
	get_tree().current_scene.add_child(fireball)
	fireball.position = get_node(pos_name).global_position
	fireball.start_projectile(target.global_position)
	
	await get_tree().create_timer(0.5).timeout
	anin_sprite.play_backwards("raise")
	await anin_sprite.animation_finished
	return
