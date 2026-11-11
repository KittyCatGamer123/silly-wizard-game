extends CanvasLayer
class_name GameUI

# Exports
@export var game_reference: MainGame
@export var player_reference: Player

# Floor No. and Overlay
@onready var level_number: Label = $StatusUi/FloorNumber
@onready var level_display_start: Label = $FloorDetails/TextBg/FloorTitle
@onready var level_title_animat: AnimationPlayer = $FloorDetails/AnimationPlayer
@onready var level_trans_overlay: ColorRect = $LevelTransitionOverlay

@onready var hurt_overlay: TextureRect = $HurtOverlay
var hurt_overlay_tween: Tween = null

# User Stats
@onready var hp_container: HBoxContainer = $StatusUi/HBoxContainer
@onready var hp_bar: ProgressBar = $StatusUi/HBoxContainer/NinePatchRect/HpBar
@onready var mp_bar: ProgressBar = $StatusUi/HBoxContainer2/NinePatchRect/MpBar
@onready var alt_charge_mp: ProgressBar = $SlotsUi/AltAttack/NinePatchRect/AltCharge
@onready var essence_label: Label = $StatusUi/HBoxContainer3/Label
@onready var essence_animatr: AnimationPlayer = $StatusUi/HBoxContainer3/AnimationPlayer

# Weapon & Accessory Slots
@onready var weapon_slot: TextureRect = $SlotsUi/WeaponSlot
@onready var weapon_icon: TextureRect = $SlotsUi/WeaponSlot/WeaponIcon
@onready var engrave_icon: TextureRect = $SlotsUi/WeaponSlot/WeaponIcon/EngravingIcon
@onready var weapon_title: Label = $WeaponName

func _ready() -> void:
	_debug_missing_references()
	reset_interface()

func reset_interface() -> void:
	level_trans_overlay.material.set_shader_parameter("progress", 0.0)
	level_trans_overlay.visible = true
	level_title_animat.play("reset")
	
	hurt_overlay.self_modulate = Color("FFF0")
	hurt_overlay.visible = true
	
	var level_title: String = "Floor " + GameTools.value_to_roman_numeral(GameData.LEVEL)
	level_number.text = level_title
	level_display_start.text = level_title
	
	player_values_changed()
	major_player_values_changed()
	
	visible = true

func overlay_burn_effect(cover_screen: bool, speed_override: float = 1.5) -> void:
	if cover_screen:
		level_trans_overlay.visible = true
	
	var from_val: float = 1.0 if cover_screen else 0.0
	var to_val: float = 1.0 - from_val 
	level_trans_overlay.material.set_shader_parameter("progress", from_val)
	
	await get_tree().create_tween().tween_method(func(v: float): 
		level_trans_overlay.material.set_shader_parameter("progress", v), from_val, to_val, speed_override).finished
	
	if not cover_screen:
		level_trans_overlay.visible = false
	
	return

func overlay_hurt_effect() -> void:
	if hurt_overlay_tween != null:
		hurt_overlay_tween.stop()
	
	hurt_overlay.self_modulate = Color("FFFF")
	hurt_overlay_tween = create_tween()
	hurt_overlay.tween_property(hurt_overlay, "self_modulate", Color("FFF0"), 2)

func level_title_animation() -> void:
	level_title_animat.play("play")
	await level_title_animat.animation_finished
	
	await get_tree().create_tween().tween_method(
		func(value): level_display_start.material.set_shader_parameter("shine_progress", value), 
		0.0, 10.0, 0.75).finished
	
	level_title_animat.play_backwards("play")
	return

func player_values_changed() -> void:
	if player_reference:
		hp_bar.value = player_reference.HP
		mp_bar.value = player_reference.MP
		essence_label.text = GameTools.value_commas(GameData.Essence) + " Essence"

func major_player_values_changed() -> void:
	if player_reference:
		hp_bar.max_value = player_reference.hp_max
		mp_bar.max_value = player_reference.mp_max
	
	#var primary = GlobalGame.Weapon["Primary"]["Id"]
	#var engrave = GlobalGame.Weapon["Engraving"]["Id"]
	#weapon_icon.self_modulate = GlobalGame.WeaponPrimaryData[primary]["Color"]
	
	#if engrave == "None":
		#engrave_icon.visible = false
	#else:
		#engrave_icon.self_modulate = GlobalGame.WeaponEngravingData[engrave]["Color"]
		#engrave_icon.visible = true
	
	#weapon_title.text = "{0} {1} Tome".format([engrave.replace("None",""), primary.replace("None","Basic")]).lstrip(" ")

func _text_glint_init() -> void:
	(level_display_start.material as ShaderMaterial).set_shader_parameter("text_size", level_display_start.size)

func _process(_delta: float) -> void:
	if game_reference and player_reference:
		alt_charge_mp.value = (player_reference.alt_charge_time / player_reference.alt_charge_limit)
		
		if player_reference.HP <= (player_reference.hp_max * 0.15):
			hp_container.offset_transform_position = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))

func _debug_missing_references():
	if not game_reference: print("GameUI: Missing game_reference in export variables")
	if not player_reference: print("GameUI: Missing player_reference in export variables")
