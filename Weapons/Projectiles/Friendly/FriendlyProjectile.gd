@abstract
class_name FriendlyProjectile extends Projectile

const EngravingPath = "res://Weapons/Projectiles/Friendly/EngravingModifiers/"

func _on_area_entered(area: Area2D) -> void:
	var area_parent = area.get_parent()
	if (area_parent is Enemy) and (area_parent.health > 0):
		area_parent.recieve_damage(projectile_damage, projectile_knockback, player_reference.global_position)
		onEnemyHit(area_parent)

func onEnemyHit(enemy_entity: Enemy) -> void:
	end_projectile()
