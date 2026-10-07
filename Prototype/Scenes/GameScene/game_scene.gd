extends Node2D
class_name MainGame

var level_length = -1
var game_active = false

var enemy_count = 0
var enemy_cd_min = 1
var enemy_cd_max = 3.5

@onready var game_player: Player = $Player
@onready var player_camera: Camera2D = $Player/Camera2D
@onready var level_display: Label = $CanvasLayer/StatusUi/Level
@onready var level_progbar: ProgressBar = $CanvasLayer/LevelProgress

@onready var hp_bar: ProgressBar = $CanvasLayer/StatusUi/HBoxContainer/HpBar
@onready var mp_bar: ProgressBar = $CanvasLayer/StatusUi/HBoxContainer2/MpBar
@onready var essence_label: Label = $CanvasLayer/StatusUi/HBoxContainer3/Label

@onready var weapon_slot: Panel = $CanvasLayer/SlotsUi/WeaponSlot
@onready var weapon_icon: TextureRect = $CanvasLayer/SlotsUi/WeaponSlot/WeaponIcon
@onready var engrave_icon: TextureRect = $CanvasLayer/SlotsUi/WeaponSlot/WeaponIcon/EngravingIcon
@onready var weapon_title: Label = $CanvasLayer/WeaponName

@onready var ground_polygon: Polygon2D = $GroundPiece/Polygon2D
@onready var ground_collision: CollisionPolygon2D = $GroundPiece/CollisionPolygon2D
@onready var exit_door_section: StaticBody2D = $ExitDoor

var enemy_scene = load("res://Prototype/Scenes/Enemies/enemy.tscn")

func _ready() -> void:
	setup_level()
	player_values_changed()
	major_player_values_changed()

func setup_level() -> void:
	level_display.text = "Floor " + GlobalGame.value_to_roman_numeral(GlobalGame.LEVEL)
	
	level_length = 0.2 * pow(1.3, GlobalGame.LEVEL) * 3000 + 2500
	var ground_poly = [
		Vector2(0, 0),
		Vector2(level_length, 0),
		Vector2(level_length, 150),
		Vector2(0, 150)
	]
	
	ground_polygon.polygon = PackedVector2Array(ground_poly)
	ground_collision.polygon = ground_polygon.polygon
	exit_door_section.position = Vector2(level_length, 0)
	player_camera.limit_right = level_length + 220
	
	print(level_length)

func start_level() -> void:
	game_active = true
	spawn_enemy()
	enemy_spawn_loop()

func _process(delta: float) -> void:
	if game_active:
		var prog = (game_player.position.x / level_length) * 100
		level_progbar.value = prog

func enemy_spawn_loop():
	if not game_active:
		return
	
	var next_cd: float = randi_range(enemy_cd_min, enemy_cd_max) * (enemy_count)
	await get_tree().create_timer(next_cd).timeout
	spawn_enemy()
	enemy_spawn_loop()

@onready var leftspawnpoint: Node2D = $Player/Camera2D/SpawnPointLeft
@onready var rightspawnpoint: Node2D = $Player/Camera2D/SpawnPointRight

func spawn_enemy() -> void:
	var en = enemy_scene.instantiate()
	get_tree().current_scene.add_child(en)
	enemy_count += 1
	
	if game_player.position.x > 200:
		if randi_range(1,2) == 1:
			en.position = rightspawnpoint.global_position
		else:
			en.position = leftspawnpoint.global_position
	else:
		en.position = rightspawnpoint.global_position

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

func _on_level_start_trigger_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		$EntryDoor/LevelStartTrigger.set_deferred("monitoring", false)
		start_level()

func _on_level_end_trigger_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		get_tree().change_scene_to_file("res://Prototype/Scenes/Intermediate/intermediate.tscn")
