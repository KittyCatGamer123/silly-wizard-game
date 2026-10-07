extends Node

var LEVEL = 1
var Essence = 0

var Weapon = {
	"Primary": {
		"Id": "None",
		"Level": 1
	},
	"Engraving": {
		"Id": "None",
		"Level": 1
	},
	"Damage": 5.0,
	"Knockback": 200.0,
	"UseTime": 0.7,
	"ManaUsage": 15.0,
	"Lifetime": 3.0,
	"Speed": 400.0
}
var Accessories = []

var WeaponPrimaryData = {
	"None": {
		"Description": "",
		"Color": Color("ffffcf")
	},
	"Shock": {
		"Description": "Chains to an additional enemy.\nReduced damage.",
		"Color": Color("d18100ff"),
		"Cost": 85
	}, 
	"Venom": {
		"Description": "Inflicts a damage-over-time debuff to enemies.\nMana usage doubled.",
		"Color": Color("14a330ff"),
		"Cost": 85
	},
	"Vampire": {
		"Description": "Has a 1 in 5 chance to lifesteal.",
		"Color": Color("b31e66ff"),
		"Cost": 85
	}
}

var WeaponEngravingData = {
	"Echoing": {
		"Description": "Fires an additional projectile.",
		"Color": Color("00ccffff"),
		"Cost": 35
	},
	"Rebounding": {
		"Description": "Riochets off whatever it hits once.",
		"Color": Color("2efff5ff"),
		"Cost": 35
	},
	"Overcharged": {
		"Description": "Uses double MP for double damage.",
		"Color": Color("6600ffff"),
		"Cost": 35
	}
}

func value_commas(value: int) -> String:
	var num_str: String = str(abs(value))
	var result: String = ""
	var count: int = 0
	
	for i in range(num_str.length() - 1, -1, -1):
		result = num_str[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result
	
	if value < 0:
		result = "-" + result

	return result

const RomanNumerals = {
	"M": 1000, "CM": 900, "D": 500, "CD": 400, "C": 100, "XC": 90,
	"L": 50, "XL": 40, "X": 10, "IX": 9, "V": 5, "IV": 4, "I": 1
}

func value_to_roman_numeral(value: int) -> String:
	var result = ""
	for key in RomanNumerals.keys():
		while value >= RomanNumerals[key]:
			result += key
			value -= RomanNumerals[key]
	return result
