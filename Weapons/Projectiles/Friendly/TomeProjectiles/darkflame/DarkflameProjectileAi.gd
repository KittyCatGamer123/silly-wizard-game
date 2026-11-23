extends FireballProjectileAi
class_name DarkflameProjectileAi

func projectile_post_start(shoot_point: Vector2) -> void:
	var shoot_direction = (shoot_point - global_position).normalized()
	projectile_rigidbody.apply_central_impulse(shoot_direction * 400)
	
	bounce_times += 1

# TODO: Give enemies Weakened once debuffs are added to the game
