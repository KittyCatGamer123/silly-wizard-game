extends FireballProjectile
class_name DarkflameProjectile

func projectile_post_start(shoot_point: Vector2) -> void:
	var shoot_direction = (shoot_point - global_position).normalized()
	projectile_rigidbody.apply_central_impulse(shoot_direction * 400)
	
	bounce_times += 1

func onEnemyHit(enemy_entity: Enemy) -> void:
	enemy_entity.recieve_debuff(GameData.Debuffs.Weakened, 3)
	enemy_entity.recieve_debuff(GameData.Debuffs.OnFire, 1)
	end_projectile()
