extends Area2D
class_name FriendlyFireRing

@onready var fire_sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var turn_dir = 1 if randi_range(0, 1) == 1 else -1

func _physics_process(delta: float) -> void:
	fire_sprite.rotation_degrees += 300 * turn_dir * delta
	
	for n in get_overlapping_areas():
		if n.get_parent() is Enemy:
			var en = n.get_parent() as Enemy
			if !en.debuffs_stack.has(GameData.Debuffs.OnFire):
				en.recieve_debuff(GameData.Debuffs.OnFire, 0.5)
