extends Node2D
class_name MainGame

var level_length = -1
var game_active = false

var enemy_count = 0
var enemy_cd_min = 2.0
var enemy_cd_max = 5.0

@onready var game_player: Player = $Player
@onready var player_camera: Camera2D = $Player/Camera2D

@onready var level_display: Label = $CanvasLayer/StatusUi/Level
@onready var level_progbar: ProgressBar = $CanvasLayer/LevelProgress

@onready var level_display_start: Label = $CanvasLayer/FloorDetails/TextBg/FloorTitle
@onready var level_start_animat: AnimationPlayer = $Doorway/AnimationPlayer
@onready var level_title_animat: AnimationPlayer = $CanvasLayer/FloorDetails/AnimationPlayer

@onready var hp_bar: ProgressBar = $CanvasLayer/StatusUi/HBoxContainer/HpBar
@onready var mp_bar: ProgressBar = $CanvasLayer/StatusUi/HBoxContainer2/MpBar
@onready var essence_label: Label = $CanvasLayer/StatusUi/HBoxContainer3/Label

@onready var weapon_slot: Panel = $CanvasLayer/SlotsUi/WeaponSlot
@onready var weapon_icon: TextureRect = $CanvasLayer/SlotsUi/WeaponSlot/WeaponIcon
@onready var engrave_icon: TextureRect = $CanvasLayer/SlotsUi/WeaponSlot/WeaponIcon/EngravingIcon
@onready var weapon_title: Label = $CanvasLayer/WeaponName

var enemy_scene = load("res://Prototype/Scenes/Enemies/enemy.tscn")

func _ready() -> void:
	setup_level()
	player_values_changed()
	major_player_values_changed()
	start_level_animation()

func setup_level() -> void:
	$CanvasLayer.visible = true
	game_player.global_position = $Doorway.global_position + Vector2(4,0)
	game_player.Active = false
	level_start_animat.play("reset")
	level_title_animat.play("reset")
	
	level_display.text = "Floor " + GlobalGame.value_to_roman_numeral(GlobalGame.LEVEL)
	level_display_start.text = "Floor " + GlobalGame.value_to_roman_numeral(GlobalGame.LEVEL)

func start_level_animation() -> void:
	level_start_animat.play("intro")
	await level_start_animat.animation_finished
	game_player.Active = true
	game_active = true
	level_title_animat.play("play")
	await level_title_animat.animation_finished
	await get_tree().create_tween().tween_method(
		func(value): level_display_start.material.set_shader_parameter("shine_progress", value), 
		0.0, 10.0, 0.75).finished
	level_title_animat.play_backwards("play")
	start_level()

func start_level() -> void:
	game_active = true

func _process(_delta: float) -> void:
	if game_active:
		var prog = (game_player.position.x / level_length) * 100
		level_progbar.value = prog

func player_values_changed() -> void:
	hp_bar.value = game_player.HP
	mp_bar.value = game_player.MP
	essence_label.text = GlobalGame.value_commas(GlobalGame.Essence) + " Essence"

func major_player_values_changed() -> void:
	hp_bar.max_value = game_player.hp_max
	mp_bar.max_value = game_player.mp_max
	
	var primary = GlobalGame.Weapon["Primary"]["Id"]
	var engrave = GlobalGame.Weapon["Engraving"]["Id"]
	weapon_icon.self_modulate = GlobalGame.WeaponPrimaryData[primary]["Color"]
	
	if engrave == "None":
		engrave_icon.visible = false
	else:
		engrave_icon.self_modulate = GlobalGame.WeaponEngravingData[engrave]["Color"]
		engrave_icon.visible = true
	
	weapon_title.text = "{0} {1} Tome".format([engrave.replace("None",""), primary.replace("None","Basic")]).lstrip(" ")

func text_glint_init() -> void:
	(level_display_start.material as ShaderMaterial).set_shader_parameter("text_size", level_display_start.size)
