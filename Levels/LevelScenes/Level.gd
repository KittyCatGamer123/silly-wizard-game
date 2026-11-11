extends Node2D
class_name MainGame

var game_active = false
var cheats_nospawn: bool = false

@export var game_player: Player
@export var game_interface: GameUI
@export var entry_door: EntryDoor
var player_camera: Camera2D = null

func _ready() -> void:
	player_camera = game_player.player_camera
	
	setup_level()
	start_level_animation()

func setup_level() -> void:
	game_player.global_position = entry_door.global_position + Vector2(4,0)
	game_player.Active = false
	game_player.visible = false
	
	if cheats_nospawn:
		for n in get_children():
			if n is SpawnTrigger:
				n.set_deferred("monitoring", false)

func start_level_animation() -> void:
	await game_interface.overlay_burn_effect(false, 1.5)
	await entry_door.level_start_animation()
	
	game_player.Active = true
	game_active = true
	game_player.visible = true
	
	await game_interface.level_title_animation()
	start_level()

func start_level() -> void:
	game_active = true

func end_level() -> void:
	game_interface.overlay_burn_effect(true, 1.5)
	return
