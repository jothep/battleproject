extends Resource
class_name CharacterAttributes

const ATTRIBUTE_RANKS = {
	"F": [1, 4],
	"E": [5, 8],
	"D": [9, 14],

	"C-": [15, 18],
	"C":  [19, 22],
	"C+": [23, 26],
	"C++":[27, 30],

	"B-": [31, 37],
	"B":  [38, 45],
	"B+": [46, 54],
	"B++":[55, 63],

	"A-": [64, 76],
	"A":  [77, 90],
	"A+": [91, 105],
	"A++":[106, 120],

	"EX": [121, 9999]
}

const RANK_ORDER = [
	"F", "E", "D",
	"C-", "C", "C+", "C++",
	"B-", "B", "B+", "B++",
	"A-", "A", "A+", "A++",
	"EX"
]

var strength_rank := "C"
var agility_rank := "C"
var luck_rank := "C"
var endurance_rank := "C"
var mana_rank := "C"
var noble_rank := "C"

var _strength := 0
var _agility := 0
var _luck := 0
var _endurance := 0
var _mana := 0
var _noble := 0

func initialize():
	_strength = get_value_from_rank(strength_rank)
	_agility = get_value_from_rank(agility_rank)
	_luck = get_value_from_rank(luck_rank)
	_endurance = get_value_from_rank(endurance_rank)
	_mana = get_value_from_rank(mana_rank)
	_noble = get_value_from_rank(noble_rank)
	
func get_value_from_rank(rank: String) -> int:
	var value_range = ATTRIBUTE_RANKS.get(rank, [1, 1])
	return randi_range(value_range[0], value_range[1])

func get_strength(): return _strength
func get_agility(): return _agility
func get_luck(): return _luck
func get_endurance(): return _endurance
func get_mana(): return _mana
func get_noble(): return _noble
