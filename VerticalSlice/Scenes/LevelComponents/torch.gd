extends AnimatedSprite2D

func _ready() -> void:
	play("default")
	loop()

func loop() -> void:
	var lvl = randf_range(0.7,2)
	var time = randf_range(2,4)
	await get_tree().create_tween().tween_property($PointLight2D, "energy", lvl, time).finished
	loop()
