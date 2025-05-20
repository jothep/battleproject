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
const SKILL_BASE_COOLDOWN = {"skill_1": 2, "skill_2": 3, "skill_3": 4, "noble": 5}

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
	var skill_list = ["attack", "skill_1", "skill_2", "skill_3", "noble"]
	return skill_list[randi() % skill_list.size()]

func prepare_for_turn():
	# 技能冷却减少
	for skill_id in cooldown:
		if cooldown[skill_id] > 0:
			cooldown[skill_id] -= 1

	if noble_resource < 3:
		noble_resource += 1

	# 打印调试信息
	#print("→ %s 进入新回合：冷却状态 %s，宝具资源 %d" % [char_name, str(cooldown), noble_resource])

func get_skill_cooldown(skill_id: String) -> int:
	if skill_id == "attack":
		return 0
	return SKILL_BASE_COOLDOWN.get(skill_id, 0)
