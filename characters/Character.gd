extends Node
class_name Character

var char_name: String
var attributes : CharacterAttributes
var max_hp := 0
var hp: int
var atk := 0
var noble_resource: int = 0

# 技能系统（使用 SkillData）
var skill_ids: Array[String] = []  # 角色拥有的技能ID列表
var cooldown: Dictionary = {}       # skill_id -> 当前冷却时间

const NOBLE_REQUIRED_RESOURCE = 5

var rng := RandomNumberGenerator.new()

func initialize():
	rng.randomize()

func calculate_combat_stats():
	max_hp = attributes.get_endurance() * 10
	atk = round(attributes.get_strength() * 2 + randf_range(0, attributes.get_luck() * 0.5))

func get_attack_damage() -> int:
	return round(atk + randf_range(0, attributes.get_luck() * 0.3))

func get_ac() -> int:
	var agi_bonus = floor(attributes.get_agility() / 10)
	var luk_bonus = floor(attributes.get_luck() / 20)
	var endu_bonus = floor(attributes.get_endurance() / 30)
	return 10 + agi_bonus + luk_bonus + endu_bonus

func reset_for_battle():
	hp = max_hp
	noble_resource = 0
	
	for skill_id in cooldown:
		cooldown[skill_id] = 0

func get_random_available_skill() -> String:
	var available_skills = []

	# 遍历角色的所有技能
	for skill_id in skill_ids:
		var skill_data = ResourceManager.get_skill(skill_id)
		if not skill_data:
			continue

		# 检查技能是否可用
		if is_skill_available(skill_id):
			available_skills.append(skill_id)

	# 使用随机数生成器安全获取技能
	if available_skills.size() > 0:
		return available_skills[rng.randi_range(0, available_skills.size() - 1)]
	else:
		# 如果没有可用技能，返回第一个技能（通常是 attack）
		if skill_ids.size() > 0:
			return skill_ids[0]
		return "attack"

func prepare_for_turn():
	for skill_id in cooldown:
		if cooldown[skill_id] > 0:
			cooldown[skill_id] -= 1
	if noble_resource < NOBLE_REQUIRED_RESOURCE:
		noble_resource += 1

func get_skill_cooldown(skill_id: String) -> int:
	var skill_data = ResourceManager.get_skill(skill_id)
	if skill_data:
		return skill_data.cooldown
	return 0

## 获取技能名称
func get_skill_name(skill_id: String) -> String:
	var skill_data = ResourceManager.get_skill(skill_id)
	if skill_data:
		return skill_data.skill_name
	return skill_id

## 检查技能是否可用
func is_skill_available(skill_id: String) -> bool:
	var skill_data = ResourceManager.get_skill(skill_id)
	if not skill_data:
		return false

	# 检查冷却时间
	var cd = cooldown.get(skill_id, 0)
	if cd > 0:
		return false

	# 检查宝具资源需求
	if skill_data.requires_resource:
		if noble_resource < skill_data.required_resource_amount:
			return false

	return true

## 初始化技能冷却字典
func initialize_skills(skill_id_list: Array[String]):
	skill_ids = skill_id_list.duplicate()
	cooldown.clear()
	for skill_id in skill_ids:
		cooldown[skill_id] = 0
