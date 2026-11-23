extends FireballProjectileAi
class_name PlasmaProjectileAi

func onEnemyHit(enemy_entity: Enemy) -> void:
	if projectile_area2d:
		projectile_area2d.set_deferred("monitoring", false)
		projectile_area2d.set_deferred("monitorable", false)
	
	# Find all enemies in scene and sort by nearest
	var enemy_list: Array[Enemy] = []
	for em in get_tree().get_nodes_in_group("Enemy"): 
		if (em.health > 0) and (em.attack_area.monitorable):
			enemy_list.append(em)
	enemy_list.erase(enemy_entity)
	enemy_list.sort_custom(func(x, y): 
		return global_position.distance_to(x.global_position) < global_position.distance_to(y.global_position)
	)
	
	# Send bolt to nearest 2 enemies
	var nearest_enemies = enemy_list.slice(0, 2)
	for idx in range(0,len(nearest_enemies)):
		var target = nearest_enemies[idx]
		
		if global_position.distance_to(target.global_position) > 300:
			continue
		
		target.recieve_damage(projectile_damage / 3, projectile_knockback, player_reference.global_position)
		
		if (!target) or target.health <= 0:
			continue
		
		# Drawing electricity jump
		var elec_line = Line2D.new()
		elec_line.width = 4.0
		elec_line.default_color = projectile_colours[0]
		elec_line.material = surrounding_particles.material
		
		var from_point: Vector2
		if idx == 0: from_point = enemy_entity.global_position
		else: from_point = nearest_enemies[idx-1].global_position
		elec_line.add_point(from_point)
		elec_line.add_point(target.global_position)
		
		get_tree().current_scene.add_child(elec_line)
		
		var tw = create_tween()
		tw.tween_property(elec_line, "self_modulate", Color("FFF0"), 1)
	
	end_projectile()
