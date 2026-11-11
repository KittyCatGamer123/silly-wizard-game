extends Sprite2D
class_name EntryDoor

@onready var animator: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animator.play("RESET")

func level_start_animation() -> void:
	animator.play("intro")
	await animator.animation_finished
