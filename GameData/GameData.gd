extends Node

const EssenceScene = preload("res://Entities/Essence/Essence.tscn")

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
	"ManaUsage": 25.0,
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
