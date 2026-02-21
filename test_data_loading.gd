extends Node

## 数据加载测试脚本
## 运行这个场景来验证所有配置文件是否正确加载

func _ready():
	print("========================================")
	print("开始测试数据加载系统")
	print("========================================\n")

	test_resource_manager()
	test_skill_loading()
	test_character_loading()
	test_character_creation()

	print("\n========================================")
	print("所有测试完成！")
	print("========================================")

	# 退出游戏（如果需要）
	# get_tree().quit()

func test_resource_manager():
	print("--- 测试 ResourceManager ---")

	if ResourceManager == null:
		push_error("❌ ResourceManager 未加载！")
		return

	print("✓ ResourceManager 已加载")
	print("  技能数量: %d" % ResourceManager.skills.size())
	print("  角色数量: %d" % ResourceManager.characters.size())
	print()

func test_skill_loading():
	print("--- 测试技能加载 ---")

	var test_skills = ["attack", "skill_1", "skill_2", "skill_3", "noble"]

	for skill_id in test_skills:
		var skill = ResourceManager.get_skill(skill_id)
		if skill:
			print("✓ 技能 [%s]: %s (倍率: %.1f, CD: %d)" % [
				skill.skill_id,
				skill.skill_name,
				skill.damage_multiplier,
				skill.cooldown
			])
		else:
			push_error("❌ 技能加载失败: " + skill_id)
	print()

func test_character_loading():
	print("--- 测试角色数据加载 ---")

	var test_characters = ["p1", "p2"]

	for char_id in test_characters:
		var char_data = ResourceManager.get_character(char_id)
		if char_data:
			print("✓ 角色 [%s]: %s" % [char_data.character_id, char_data.character_name])
			print("  属性: STR=%s AGI=%s LCK=%s END=%s" % [
				char_data.strength_rank,
				char_data.agility_rank,
				char_data.luck_rank,
				char_data.endurance_rank
			])
			print("  技能列表: %s" % str(char_data.skill_ids))
			print("  宝具: %s" % char_data.noble_phantasm_id)
		else:
			push_error("❌ 角色加载失败: " + char_id)
	print()

func test_character_creation():
	print("--- 测试角色实例创建 ---")

	var p1 = CharacterFactory.create_p1()
	var p2 = CharacterFactory.create_p2()

	if p1:
		print("✓ P1 创建成功: %s" % p1.char_name)
		print("  MAX_HP: %d, ATK: %d" % [p1.max_hp, p1.atk])
		print("  技能列表: %s" % str(p1.skill_ids))
		print("  技能冷却初始化: %s" % str(p1.cooldown))

		# 测试技能名称获取
		for skill_id in p1.skill_ids:
			var skill_name = p1.get_skill_name(skill_id)
			print("    - %s: %s" % [skill_id, skill_name])
	else:
		push_error("❌ P1 创建失败")

	if p2:
		print("✓ P2 创建成功: %s" % p2.char_name)
		print("  MAX_HP: %d, ATK: %d" % [p2.max_hp, p2.atk])
	else:
		push_error("❌ P2 创建失败")

	print()
