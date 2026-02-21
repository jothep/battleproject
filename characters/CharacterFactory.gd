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

## 从配置文件创建角色（新方法）
static func create_from_data(character_id: String) -> Character:
	var char_data = ResourceManager.get_character(character_id)
	if not char_data:
		push_error("无法加载角色数据: " + character_id)
		return null

	var c = Character.new()
	c.char_name = char_data.character_name

	# 从 CharacterData 创建属性
	c.attributes = char_data.create_attributes()

	# 初始化技能列表
	var all_skills = char_data.get_all_skill_ids()
	c.initialize_skills(all_skills)

	# 计算战斗数值
	c.calculate_combat_stats()
	c.initialize()

	DebugConfig.log_debug("创建角色: %s (%s)" % [c.char_name, character_id], "character")
	return c

## 创建 P1（使用配置文件）
static func create_p1() -> Character:
	return create_from_data("p1")

## 创建 P2（使用配置文件）
static func create_p2() -> Character:
	return create_from_data("p2")
