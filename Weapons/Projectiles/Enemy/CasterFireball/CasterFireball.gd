extends EnemyProjectile

func _ready() -> void:
	# TODO: CSV Data for Enemy Projectiles
	projectile_damage = 20.0
	projectile_knockback = 200.0
	projectile_speed = 200.0
	projectile_lifetime = 2.0

func projectile_update(delta: float) -> void:
	global_position += direction * projectile_speed * delta
