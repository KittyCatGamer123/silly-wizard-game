extends Area2D
class_name ExitDoor

@onready var game_scene: MainGame = $".."
@onready var door_sprite: AnimatedSprite2D = $Doorway
@onready var wizard_clone_sprite: AnimatedSprite2D = $Doorway/Wizard

func _ready() -> void:
	door_sprite.frame = 0
	wizard_clone_sprite.visible = false
	wizard_clone_sprite.self_modulate = Color("FFFF")

func _on_area_entered(area: Area2D) -> void:
	if not (area.get_parent() is Player):
		return
	
	var plr: Player = area.get_parent() as Player
	game_scene.game_active = false
	plr.Active = false
	plr.damage_area.set_deferred("monitoring", false)
	plr.velocity = Vector2.ZERO
	door_sprite.play("open")
	await door_sprite.animation_finished
	
	plr.animsprite.play("walk")
	await create_tween().tween_property(plr, "global_position", global_position, 0.5).finished
	wizard_clone_sprite.flip_h = plr.animsprite.flip_h
	wizard_clone_sprite.play("idle")
	plr.visible = false
	wizard_clone_sprite.visible = true
	await create_tween().tween_property(wizard_clone_sprite, "self_modulate", Color("FFF0"), 1).finished
	game_scene.end_level()
