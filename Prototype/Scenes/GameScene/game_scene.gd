extends Node2D

var LEVEL = 1
var level_length = -1
var game_active = false

const enemy_limit = 100
var spawn_rate = 425 # 1/x chance

@onready var game_player: Player = $Player
@onready var level_display: Label = $CanvasLayer/StatusUi/Level
@onready var level_progbar: ProgressBar = $CanvasLayer/LevelProgress

@onready var hp_bar: ProgressBar = $CanvasLayer/StatusUi/HBoxContainer/HpBar
@onready var mp_bar: ProgressBar = $CanvasLayer/StatusUi/HBoxContainer2/MpBar
@onready var essence_label: Label = $CanvasLayer/StatusUi/HBoxContainer3/Label

@onready var ground_polygon: Polygon2D = $GroundPiece/Polygon2D
@onready var ground_collision: CollisionPolygon2D = $GroundPiece/CollisionPolygon2D

func _ready() -> void:
	setup_level()
	player_values_changed()
	major_player_values_changed()

func setup_level() -> void:
	level_display.text = "Floor " + GlobalGame.value_to_roman_numeral(LEVEL)
	
	level_length = 0.2 * pow(1.3, LEVEL) * 3000 + 2500
	var ground_poly = [
		Vector2(0, 0),
		Vector2(level_length, 0),
		Vector2(level_length, 150),
		Vector2(0, 150)
	]
	
	ground_polygon.polygon = PackedVector2Array(ground_poly)
	ground_collision.polygon = ground_polygon.polygon
	print(level_length)

func start_level() -> void:
	game_active = true

func _process(delta: float) -> void:
	if game_active:
		var prog = (game_player.position.x / level_length) * 100
		level_progbar.value = prog

func _physics_process(delta: float) -> void:
	if not game_active:
		return
	
	var luck_hit = randi_range(1, spawn_rate) == 1
	if luck_hit:
		print("spawn")

func player_values_changed() -> void:
	hp_bar.value = game_player.HP
	mp_bar.value = game_player.MP
	essence_label.text = GlobalGame.value_commas(game_player.essence) + " Essence"

func major_player_values_changed() -> void:
	hp_bar.max_value = game_player.hp_max
	mp_bar.max_value = game_player.mp_max

func _on_level_start_trigger_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		$EntryDoor/LevelStartTrigger.set_deferred("monitoring", false)
		start_level()
