extends Area2D

@export var spawn_list: Array[Enemy] = []

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		summon_all()

func summon_all() -> void:
	monitoring = false
	for n in spawn_list:
		n.summon_enemy()
	queue_free()
