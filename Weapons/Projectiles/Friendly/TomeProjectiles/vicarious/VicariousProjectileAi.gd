extends TeslaProjectile
class_name VicariousProjectileAi

func onEnemyHit(enemy_entity: Enemy) -> void:
	enemy_entity.recieve_debuff(GameData.Debuffs.Weakened, 3)
