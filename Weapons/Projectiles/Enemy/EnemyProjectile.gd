@abstract
class_name EnemyProjectile extends Projectile

func _on_area_entered(area: Area2D) -> void:
	var area_parent = area.get_parent()
	if (area_parent is Player) and (area_parent.HP > 0):
		area_parent.recieve_damage(projectile_damage, projectile_knockback, global_position)
		onPlayerHit(area_parent)
		end_projectile()

func onPlayerHit(player_entity: Player) -> void:
	pass
