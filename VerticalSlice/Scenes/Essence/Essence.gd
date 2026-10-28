extends Area2D

@onready var light: PointLight2D = $PointLight2D

var essence_drop: int = 1
var target = null

func _ready() -> void:
	essence_drop = randi_range(1, 15)
	loop()

func loop() -> void:
	await create_tween().tween_property(light, "energy", 1.5, 1.5).finished
	await create_tween().tween_property(light, "energy", 1, 1.5).finished
	loop()

func _physics_process(delta: float) -> void:
	if target == null:
		return
	
	var direction = global_position.direction_to(target.global_position)
	global_position += direction * 400 * delta

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		target = area.get_parent()

func _on_pickup_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		GlobalGame.Essence += essence_drop
		queue_free()
