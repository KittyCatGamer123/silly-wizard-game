extends FireballProjectile
class_name FlamewallProjectile

var firering_scene = preload("res://Weapons/Projectiles/Friendly/TomeProjectiles/flamewall/fire_ring.tscn")

func onEnemyHit(enemy_entity: Enemy) -> void:
	var fr = firering_scene.instantiate()
	fr.global_position = enemy_entity.global_position
	get_tree().current_scene.call_deferred("add_child", fr)
	end_projectile()
