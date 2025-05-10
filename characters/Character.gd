extends Node
class_name Character

var char_name := ""
var attributes := CharacterAttributes.new()

var max_hp := 0
var atk := 0

func calculate_combat_stats():
	max_hp = attributes.get_endurance() * 10
	atk = round(attributes.get_strength() * 2 + randf_range(0, attributes.get_luck() * 0.5))
