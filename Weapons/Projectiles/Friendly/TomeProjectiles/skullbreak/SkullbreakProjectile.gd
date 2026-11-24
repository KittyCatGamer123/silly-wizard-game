extends LineProjectileAi
class_name SkullbreakProjectile

func onEnemyHit(enemy_entity: Enemy) -> void:
	enemy_entity.recieve_debuff(GameData.Debuffs.Weakened, 3)
