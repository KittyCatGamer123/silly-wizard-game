extends Node

## Collection of all the Tomes in the game with their base values.
var WeaponData: Array[Dictionary] = []

## Collection of all the Engravings for tomes in the game with their base values.
var EngravingData: Array[Dictionary] = []

## Collection of all the Accessories in the game.
var AccessoryData: Array[Dictionary] = []

## Collection of all the Charged Casts in the game with their base values.
var ChargeCastData: Array[Dictionary] = []

var LEVEL = 1

## The current Weapon, Engraving, and equipped Accessory data that the Player
## is using. Data is calculated when Inventory or Hotbar data is changed.
## Accessed at the start of Floors to avoid multiple nested referencing to other data.
var CurrentPlayerLoadout: Dictionary = {
	"Weapon": {},
	"Accessories": []
}

## A list of items that the player has crafted throughout the game.
var PlayerInventory: Dictionary = {
	"Weapons": [],
	"Engravings": [],
	"Accessories": []
}

const EssenceScene = preload("res://Entities/Essence/Essence.tscn")
var Essence = 0

func _ready() -> void:
	WeaponData = _get_weapon_data()
	EngravingData = _get_engraving_data()
	reset_player_data()

func reset_player_data() -> void:
	LEVEL = 1
	
	#var base_tome = get_base_weapon_itemtype("basic")
	var base_tome = get_base_weapon_itemtype(WeaponData.pick_random()["Id"])
	base_tome["Engraving"] = get_base_engrave_itemtype("homing")
	
	PlayerInventory = {
		"Weapons": [base_tome],
		"Engravings": [],
		"Accessories": [],
		"ChargeCasts": []
	}
	
	CurrentPlayerLoadout = {
		"Weapon": base_tome,
		"Accessories": [],
		"ChargeCast": {}
	}

func get_weapon_title(weapon_data: Dictionary) -> String:
	var weapon_name: String = weapon_data["Name"] + " Tome"
	var current_tome_engrave: Dictionary = weapon_data["Engraving"]
	if current_tome_engrave != {}:
		weapon_name = "{0} {1}".format([current_tome_engrave["Name"], weapon_name])
	return weapon_name

func get_weapon_sprite(weapon_id: String) -> Texture2D:
	const TomePath = "res://Weapons/Tomes/"
	return _get_item_sprite(TomePath, weapon_id)

func get_engraving_sprite(engraving_id) -> Texture2D:
	const EngravPath = "res://Weapons/Engravings/"
	return _get_item_sprite(EngravPath, engraving_id)

func _get_item_sprite(parent_folder: String, item_id: String) -> Texture2D:
	var complete_filepath = parent_folder + item_id + ".png"
	if FileAccess.file_exists(complete_filepath):
		return load(complete_filepath)
	else:
		return load(parent_folder + "_fallback.png")

## Will swap out the CurrentPlayerLoadout's weapon with a weapon in the PlayerInventory.
func swap_loadout_weapon(updated_weapon_index: int) -> void:
	if updated_weapon_index >= len(PlayerInventory["Weapons"]):
		print("Unable to swap Weapon at index ", updated_weapon_index)
		return
	
	var weapon_buffer: Dictionary = PlayerInventory["Weapons"][updated_weapon_index].duplicate(true)
	var loadout_buffer: Dictionary = CurrentPlayerLoadout.duplicate(true)
	
	# Item in Slot X <-> Current Weapon
	PlayerInventory["Weapons"][updated_weapon_index] = loadout_buffer
	CurrentPlayerLoadout["Weapon"] = weapon_buffer

func get_merged_tomes(tome1: Dictionary, tome2: Dictionary) -> Dictionary:
	var id_combination: String = tome1["Id"] + "+" + tome2["Id"]
	var tome_combination = GameTools.get_dict_by_keyval(WeaponData, "CraftRequires", id_combination)
	
	# TODO: Expand with Level Multipliers
	# Need to plan how we combine levels together
	
	return tome_combination

# TODO: Implement with Level Multipliers
func set_weapon_level(weapon_data: Dictionary, level: int) -> void:
	pass

# TODO: Implement with Level Multipliers
func set_engraving_level(weapon_data: Dictionary, level: int) -> void:
	pass

## Returns a Dictionary of a Weapon specialised for inventory and loadout usage.
## Will use the base values only.
func get_base_weapon_itemtype(weapon_id: String) -> Dictionary:
	var reference_item = GameTools.get_dict_by_keyval(WeaponData, "Id", weapon_id)
	if reference_item == {}:
		print("WeaponId: ", weapon_id, " cannot be found!")
		return {}
	
	var itemtype = {
		"Damage": reference_item["BaseDamage"],
		"Level": 1,
		"Engraving": {}
	}
	
	var values_to_copy = "Name,Id,Knockback,UseTime,Mana,Lifetime,ProjSpeed,Colour1,Colour2,Desc".split(",")
	for k in values_to_copy:
		itemtype[k] = reference_item[k]
	return itemtype

func get_base_engrave_itemtype(engrave_id: String) -> Dictionary:
	var reference_item = GameTools.get_dict_by_keyval(EngravingData, "Id", engrave_id)
	if reference_item == {}:
		print("EngraveId: ", engrave_id, " cannot be found!")
		return {}
	
	var itemtype = {
		"Level": 1,
		"Value": float(reference_item["LevelValues"].split(";")[0])
	}
	
	var values_to_copy = "Name,Id".split(",")
	for k in values_to_copy:
		itemtype[k] = reference_item[k]
	return itemtype

func _get_weapon_data() -> Array[Dictionary]:
	return get_csv_data("res://GameData/WeaponData.csv")

func _get_engraving_data() -> Array[Dictionary]:
	return get_csv_data("res://GameData/EngravingData.csv")

func get_file_text(path: String) -> String:
	return FileAccess.open(path, FileAccess.READ).get_as_text()

func compile_values_to_dict(values: String) -> Array[Dictionary]:
	var rows: PackedStringArray = values.split("\n", true)
	var result: Array[Dictionary] = []
	var row_headers: Array[String] = []
	
	for row_idx in range(0, len(rows)):
		var row_values: PackedStringArray = rows[row_idx].split(",", true)
		
		if row_idx == 0:
			for n in row_values:
				row_headers.append(n.remove_chars("\r"))
		else:
			var entry: Dictionary = {}
			for idx in range(0, len(row_values)):
				var key: String = row_headers[idx]
				var val = row_values[idx].remove_chars("\r") # Assumed string, casted later
				
				if val.is_valid_int():
					val = int(val)
				elif val.is_valid_float():
					val = float(val)
				elif val.is_valid_html_color():
					val = Color(val)
				
				entry[key] = val
			result.append(entry)
	
	return result

func get_csv_data(filepath: String) -> Array[Dictionary]:
	return compile_values_to_dict(get_file_text(filepath))
