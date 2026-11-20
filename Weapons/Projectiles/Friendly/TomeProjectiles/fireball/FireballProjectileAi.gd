class_name FireballProjectileAi extends FriendlyProjectile

var bounce_times: int = 3

func _ready() -> void:
	projectile_area2d.connect("body_entered", _body_entered)

func projectile_post_start(shoot_point: Vector2) -> void:
	look_at(shoot_point)

func _body_entered(body) -> void:
	if body is TileMapLayer:
		bounce_times -= 1
		time_alive = 0.0
		
		if bounce_times <= 0:
			end_projectile()

func projectile_update(delta: float) -> void:
	pass
