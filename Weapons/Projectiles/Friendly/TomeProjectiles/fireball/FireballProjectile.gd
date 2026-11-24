extends FriendlyProjectile
class_name FireballProjectile

var bounce_times: int = 3

func _ready() -> void:
	projectile_area2d.connect("body_entered", _body_entered)

	var weapon_data: Dictionary = GameData.CurrentPlayerLoadout["Weapon"]
	
	projectile_damage = weapon_data["Damage"]
	projectile_knockback = weapon_data["Knockback"]
	projectile_speed = weapon_data["ProjSpeed"]
	projectile_lifetime = weapon_data["Lifetime"]
	projectile_colours = [weapon_data["Colour1"],weapon_data["Colour2"]]

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
	pass

func onEnemyHit(enemy_entity: Enemy) -> void:
	enemy_entity.recieve_debuff(GameData.Debuffs.OnFire, 1)
	end_projectile()
