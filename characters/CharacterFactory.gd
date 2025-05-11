extends Object
class_name CharacterFactory

static func build_attributes(strength, agility, luck, endurance, mana, noble):
	var attr = CharacterAttributes.new()
	attr.strength_rank = strength
	attr.agility_rank = agility
	attr.luck_rank = luck
	attr.endurance_rank = endurance
	attr.mana_rank = mana
	attr.noble_rank = noble
	attr.initialize()
	return attr

static func build_attributes_from_values(strength: int, agility: int, luck: int, endurance: int, mana: int, noble: int) -> CharacterAttributes:
	var attr = CharacterAttributes.new()
	attr._strength = strength
	attr._agility = agility
	attr._luck = luck
	attr._endurance = endurance
	attr._mana = mana
	attr._noble = noble
	return attr

static func create_p1() -> Character:
	var c = Character.new()
	c.char_name = "p1"
	c.attributes = build_attributes("A", "B", "C", "B", "A-", "A")
	c.calculate_combat_stats()
	return c

static func create_p2() -> Character:
	var c = Character.new()
	c.char_name = "p2"
	c.attributes = build_attributes("A-", "B", "C+", "B", "B++", "B")
	c.calculate_combat_stats()
	return c
