extends FriendlyProjectile
class_name FireballProjectile

var bounce_times: int = 3

var engraving_data: Dictionary = {}
var engraving_reference = null

func _ready() -> void:
	projectile_area2d.connect("body_entered", _body_entered)

	var weapon_data: Dictionary = GameData.CurrentPlayerLoadout["Weapon"]
	weapon_data = projectile_modifier_calculations(weapon_data, stat_modifiers)
	
	projectile_damage = weapon_data["Damage"]
	projectile_knockback = weapon_data["Knockback"]
	projectile_speed = weapon_data["ProjSpeed"]
	projectile_lifetime = weapon_data["Lifetime"]
	projectile_colours = [weapon_data["Colour1"],weapon_data["Colour2"]]
	
	engraving_data = weapon_data["Engraving"]
	
	if !engraving_data.is_empty():
		if engraving_data["Id"] == "homing":
			var e_inst = load(EngravingPath + "homing.tscn")
			engraving_reference = e_inst.instantiate()
		
		if engraving_reference != null:
			projectile_rigidbody.add_child(engraving_reference)

func projectile_post_start(shoot_point: Vector2) -> void:
	var shoot_direction = (shoot_point - global_position).normalized()
	projectile_rigidbody.apply_central_impulse(shoot_direction * 400)

func _body_entered(body) -> void:
	if body is TileMapLayer:
		bounce_times -= 1
		time_alive = 0.0
		
		if bounce_times <= 0:
			end_projectile()

func projectile_update(delta: float) -> void:
	engraving_check(delta)

func engraving_check(delta: float) -> void:
	if engraving_data.is_empty():
		return
	
	match engraving_data["Id"]:
		"homing": engraving_homing(delta)

func engraving_homing(delta: float) -> void:
	engraving_reference = (engraving_reference as Area2D)
	var pull_stength = engraving_data["Value"] * 100000
	
	var overlapping_areas = engraving_reference.get_overlapping_areas()
	var enemies_in_range = []
	for n in overlapping_areas:
		if (n.get_parent() is Enemy):
			enemies_in_range.append(n)
	enemies_in_range.sort_custom(func(x, y): 
		return global_position.distance_to(x.global_position) < global_position.distance_to(y.global_position)
	)
	
	if len(enemies_in_range) != 0:
		# Inverse square law to gravitate towards nearest enemy
		var enemy_target = enemies_in_range[0]
		var dir = (enemy_target.global_position - global_position)
		var distance = dir.length()
		var force_magnitude = pull_stength / (distance * distance)
		projectile_rigidbody.apply_central_force(dir.normalized() * force_magnitude)

func onEnemyHit(enemy_entity: Enemy) -> void:
	enemy_entity.recieve_debuff(GameData.Debuffs.OnFire, 1)
	end_projectile()
