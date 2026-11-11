extends Node

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
