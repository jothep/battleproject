extends Node
class_name Character

var char_name: String
var attributes : CharacterAttributes
var max_hp := 0
var hp: int
var atk := 0
var noble_resource: int = 0
var cooldown = {
	"attack": 0,
	"skill_1": 0,
	"skill_2": 0,
	"skill_3": 0,
	"noble": 0,
}
const SKILL_NAME_MAP = {
	"attack": "普通攻击",
	"skill_1": "音速指",
	"skill_2": "钛刃",
	"skill_3": "雷鸣肘",
	"noble": "超限释放：火星武神式"
}
const SKILL_BASE_COOLDOWN = {"skill_1": 3, "skill_2": 3, "skill_3": 4, "noble": 0}
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

	# 攻击永远可用
	available_skills.append("attack")

	# 只有冷却为0的技能才可选
	for skill_id in ["skill_1", "skill_2", "skill_3"]:
		if cooldown.get(skill_id, 0) <= 0:
			available_skills.append(skill_id)

	# 宝具：冷却为0 且 能量达到5
	if cooldown.get("noble", 0) <= 0 and noble_resource >= 5:
		available_skills.append("noble")

	# 使用随机数生成器安全获取技能
	if available_skills.size() > 0:
		return available_skills[rng.randi_range(0, available_skills.size() - 1)]
	else:
		return "attack"

func prepare_for_turn():
	for skill_id in cooldown:
		if cooldown[skill_id] > 0:
			cooldown[skill_id] -= 1
	if noble_resource < NOBLE_REQUIRED_RESOURCE:
		noble_resource += 1

func get_skill_cooldown(skill_id: String) -> int:
	if skill_id == "attack":
		return 0
	return SKILL_BASE_COOLDOWN.get(skill_id, 0)
