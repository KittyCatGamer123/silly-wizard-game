extends LineProjectileAi
class_name DrownedProjectile

func onEnemyHit(enemy_entity: Enemy) -> void:
	enemy_entity.recieve_debuff(GameData.Debuffs.Weakened, 3)
	end_projectile()
