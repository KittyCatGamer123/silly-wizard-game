extends FriendlyProjectile
class_name LineProjectileAi

var engraving_data: Dictionary = {}
var engraving_reference = null

func _ready() -> void:
	var weapon_data: Dictionary = GameData.CurrentPlayerLoadout["Weapon"]
	
	projectile_damage = weapon_data["Damage"]
	projectile_knockback = weapon_data["Knockback"]
	projectile_speed = weapon_data["ProjSpeed"]
	projectile_lifetime = weapon_data["Lifetime"]
	
	engraving_data = weapon_data["Engraving"]
	
	if !engraving_data.is_empty():
		if engraving_data["Id"] == "homing":
			var e_inst = load(EngravingPath + "homing.tscn")
			engraving_reference = e_inst.instantiate()
		
		if engraving_reference != null:
			add_child(engraving_reference)

func projectile_update(delta: float) -> void:
	engraving_check(delta)
	global_position += direction * projectile_speed * delta

func engraving_check(delta: float) -> void:
	if engraving_data.is_empty():
		return
	
	match engraving_data["Id"]:
		"homing": engraving_homing(delta)

func engraving_homing(delta: float) -> void:
	engraving_reference = (engraving_reference as Area2D)
	
	var overlapping_areas = engraving_reference.get_overlapping_areas()
	var enemies_in_range = []
	for n in overlapping_areas:
		if (n.get_parent() is Enemy):
			enemies_in_range.append(n)
	
	if len(enemies_in_range) != 0:
		var enemy_target = enemies_in_range[0]
		var to_target = (enemy_target.global_position - global_position).normalized()
		direction = direction.lerp(to_target, engraving_data["Value"] * delta).normalized()
		
		if projectile_sprite:
			projectile_sprite.rotation = direction.angle()
			projectile_sprite.flip_h = (direction.x < 0)
