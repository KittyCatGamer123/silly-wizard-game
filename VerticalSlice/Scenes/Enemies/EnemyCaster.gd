extends Enemy

@onready var light: PointLight2D = $PointLight2D
@onready var spawn_effect: GPUParticles2D = $SpawnEffect

var fire_projectile = load("res://VerticalSlice/Projectiles/Enemy/CastedFireball.tscn")

func _ready() -> void:
	anin_sprite.play("RESET")

func movement_handling(_delta: float) -> void:
	anin_sprite.flip_h = (target.global_position.x - global_position.x > 0)

func summon_enemy() -> void:
	await spawn_anim(true)
	await charge_and_fire()
	await spawn_anim(false)
	await teleport()
	summon_enemy()

func teleport() -> void:
	visible = false
	
	while true:
		var direction = 1 if randi_range(0, 1) == 0 else -1
		var offset = Vector2(randi_range(150, 250) * direction, 0)
		
		global_position = target.global_position + offset
		
		await get_tree().physics_frame
		
		$DownCheck.force_raycast_update()
		$LeftCheck.force_raycast_update()
		$RightCheck.force_raycast_update()
		
		if $DownCheck.is_colliding() and not $LeftCheck.is_colliding() and not $RightCheck.is_colliding():
			break
	
	visible = true

func spawn_anim(backwards: bool = true) -> void:
	light.energy = 2.5
	create_tween().tween_property(light, "energy", 1.2, 1)
	if backwards:
		anin_sprite.play_backwards("respawn")
	else:
		anin_sprite.play("respawn")
	spawn_effect.emitting = true
	
	await anin_sprite.animation_finished
	
	if health >= 0:
		attack_area.monitorable = backwards
		attack_area.monitoring = backwards
	
	await get_tree().create_timer(0.5).timeout
	return

func charge_and_fire() -> void:
	anin_sprite.play("raise")
	await anin_sprite.animation_finished
	await get_tree().create_timer(0.5).timeout
	
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
