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
	essence_label.text = GameTools.value_commas(GameData.Essence) + " Essence"

func major_player_values_changed() -> void:
	hp_bar.max_value = game_player.hp_max
	mp_bar.max_value = game_player.mp_max
	
	var primary = GameData.Weapon["Primary"]["Id"]
	var engrave = GameData.Weapon["Engraving"]["Id"]
	weapon_icon.self_modulate = GameData.WeaponPrimaryData[primary]["Color"]
	
	if engrave == "None":
		engrave_icon.visible = false
	else:
		engrave_icon.self_modulate = GameData.WeaponEngravingData[engrave]["Color"]
		engrave_icon.visible = true
	
	weapon_title.text = "{0} {1} Tome".format([engrave.replace("None",""), primary.replace("None","Basic")]).lstrip(" ")

func select_buy_menu_options() -> void:
	var spell_option = GameData.WeaponPrimaryData.keys().slice(1).pick_random()
	spell_id = spell_option
	spell_selection = GameData.WeaponPrimaryData[spell_option]
	
	var spell_button: Button = selection_container.get_children()[0]
	spell_button.get_node("Title").text = spell_option + " Tome"
	spell_button.get_node("Desc").text = spell_selection["Description"]
	spell_button.get_node("Icon").self_modulate = spell_selection["Color"]
	spell_button.get_node("HBoxContainer/Cost").text = GameTools.value_commas(spell_selection["Cost"])
	
	var engrave_option = GameData.WeaponEngravingData.keys().pick_random()
	engrave_id = engrave_option
	engrave_selection = GameData.WeaponEngravingData[engrave_option]
	
	var engrave_button: Button = selection_container.get_children()[1]
	engrave_button.get_node("Title").text = engrave_option + " Engraving"
	engrave_button.get_node("Desc").text = engrave_selection["Description"]
	engrave_button.get_node("Icon").self_modulate = engrave_selection["Color"]
	engrave_button.get_node("HBoxContainer/Cost").text = GameTools.value_commas(engrave_selection["Cost"])
	
	var accessory_button: Button = selection_container.get_children()[2]
	accessory_button.get_node("Title").text = "Starbound Charm"
	accessory_button.get_node("Desc").text = "+25 Max MP\nAccessories are not available currently."
	accessory_button.get_node("Icon").self_modulate = Color("bc36ff")
	accessory_button.get_node("HBoxContainer/Cost").text = GameTools.value_commas(35)

func spell_buy() -> void:
	if GameData.Essence < spell_selection["Cost"]:
		return
	
	$CanvasLayer/BuyMenu/VBoxContainer/Button1.disabled = true
	if GameData.Weapon["Primary"]["Id"] == "None":
		GameData.Weapon["Primary"]["Id"] = spell_id
		
		match spell_id:
			"Shock": GameData.Weapon["Damage"] = 2.5
			"Venom": GameData.Weapon["ManaUsage"] = 30.0
			"Abyss": GameData.Weapon["Speed"] = 150.0
	
	GameData.Essence -= GameData.WeaponEngravingData[engrave_id]["Cost"]
	player_values_changed()
	major_player_values_changed()

func engrave_buy() -> void:
	if GameData.Essence < engrave_selection["Cost"]:
		return
	
	$CanvasLayer/BuyMenu/VBoxContainer/Button2.disabled = true
	if GameData.Weapon["Engraving"]["Id"] == "None":
		GameData.Weapon["Engraving"]["Id"] = engrave_id
	
	GameData.Essence -= GameData.WeaponEngravingData[engrave_id]["Cost"]
	player_values_changed()
	major_player_values_changed()

func menu_close() -> void:
	$CanvasLayer/BuyMenu.visible = false

func end_trigger(area: Area2D) -> void:
	if area.get_parent() is Player:
		GameData.LEVEL += 1
		get_tree().change_scene_to_file("res://Prototype/Scenes/GameScene/game_scene.tscn")
