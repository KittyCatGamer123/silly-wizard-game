extends Node2D

var game_active = true

@onready var game_player: Player = $Player
@onready var hp_bar: ProgressBar = $CanvasLayer/StatusUi/HBoxContainer/HpBar
@onready var mp_bar: ProgressBar = $CanvasLayer/StatusUi/HBoxContainer2/MpBar
@onready var essence_label: Label = $CanvasLayer/StatusUi/HBoxContainer3/Label

@onready var weapon_slot: Panel = $CanvasLayer/SlotsUi/WeaponSlot
@onready var weapon_icon: TextureRect = $CanvasLayer/SlotsUi/WeaponSlot/WeaponIcon
@onready var engrave_icon: TextureRect = $CanvasLayer/SlotsUi/WeaponSlot/WeaponIcon/EngravingIcon
@onready var weapon_title: Label = $CanvasLayer/WeaponName

@onready var selection_container: VBoxContainer = $CanvasLayer/BuyMenu/VBoxContainer
var spell_id = ""
var spell_selection = null
var engrave_id = ""
var engrave_selection = null

func _ready() -> void:
	major_player_values_changed()
	select_buy_menu_options()

func _input(event: InputEvent) -> void:
	if event.is_action_released("use_cauldron"):
		$CanvasLayer/BuyMenu.visible = true

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

func select_buy_menu_options() -> void:
	var spell_option = GlobalGame.WeaponPrimaryData.keys().slice(1).pick_random()
	spell_id = spell_option
	spell_selection = GlobalGame.WeaponPrimaryData[spell_option]
	
	var spell_button: Button = selection_container.get_children()[0]
	spell_button.get_node("Title").text = spell_option + " Tome"
	spell_button.get_node("Desc").text = spell_selection["Description"]
	spell_button.get_node("Icon").self_modulate = spell_selection["Color"]
	spell_button.get_node("HBoxContainer/Cost").text = GlobalGame.value_commas(spell_selection["Cost"])
	
	var engrave_option = GlobalGame.WeaponEngravingData.keys().pick_random()
	engrave_id = engrave_option
	engrave_selection = GlobalGame.WeaponEngravingData[engrave_option]
	
	var engrave_button: Button = selection_container.get_children()[1]
	engrave_button.get_node("Title").text = engrave_option + " Engraving"
	engrave_button.get_node("Desc").text = engrave_selection["Description"]
	engrave_button.get_node("Icon").self_modulate = engrave_selection["Color"]
	engrave_button.get_node("HBoxContainer/Cost").text = GlobalGame.value_commas(engrave_selection["Cost"])
	
	var accessory_button: Button = selection_container.get_children()[2]
	accessory_button.get_node("Title").text = "Starbound Charm"
	accessory_button.get_node("Desc").text = "+25 Max MP\nAccessories are not available currently."
	accessory_button.get_node("Icon").self_modulate = Color("bc36ff")
	accessory_button.get_node("HBoxContainer/Cost").text = GlobalGame.value_commas(35)

func spell_buy() -> void:
	if GlobalGame.Essence < spell_selection["Cost"]:
		return
	
	$CanvasLayer/BuyMenu/VBoxContainer/Button1.disabled = true
	if GlobalGame.Weapon["Primary"]["Id"] == "None":
		GlobalGame.Weapon["Primary"]["Id"] = spell_id
		
		match spell_id:
			"Shock": GlobalGame.Weapon["Damage"] = 2.5
			"Venom": GlobalGame.Weapon["ManaUsage"] = 30.0
			"Abyss": GlobalGame.Weapon["Speed"] = 150.0
	
	GlobalGame.Essence -= GlobalGame.WeaponEngravingData[engrave_id]["Cost"]
	player_values_changed()
	major_player_values_changed()

func engrave_buy() -> void:
	if GlobalGame.Essence < engrave_selection["Cost"]:
		return
	
	$CanvasLayer/BuyMenu/VBoxContainer/Button2.disabled = true
	if GlobalGame.Weapon["Engraving"]["Id"] == "None":
		GlobalGame.Weapon["Engraving"]["Id"] = engrave_id
	
	GlobalGame.Essence -= GlobalGame.WeaponEngravingData[engrave_id]["Cost"]
	player_values_changed()
	major_player_values_changed()

func menu_close() -> void:
	$CanvasLayer/BuyMenu.visible = false

func end_trigger(area: Area2D) -> void:
	if area.get_parent() is Player:
		GlobalGame.LEVEL += 1
		get_tree().change_scene_to_file("res://Prototype/Scenes/GameScene/game_scene.tscn")
