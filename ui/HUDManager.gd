extends Node
class_name HUDManager

static func get_character_info(c: Character) -> String:
	var text = "【%s】\nHP: %d\nATK: %d\n" % [c.char_name, c.max_hp, c.atk]
	text += "力量: %s (%d)\n" % [c.attributes.strength_rank, c.attributes.get_strength()]
	text += "敏捷: %s (%d)\n" % [c.attributes.agility_rank, c.attributes.get_agility()]
	text += "幸运: %s (%d)\n" % [c.attributes.luck_rank, c.attributes.get_luck()]
	text += "耐久: %s (%d)\n" % [c.attributes.endurance_rank, c.attributes.get_endurance()]
	text += "魔力: %s (%d)\n" % [c.attributes.mana_rank, c.attributes.get_mana()]
	text += "宝具: %s (%d)" % [c.attributes.noble_rank, c.attributes.get_noble()]
	return text
