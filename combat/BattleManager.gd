extends Node
class_name BattleManager

var ui: BattleUI
var p1: Character
var p2: Character

enum BattleMode { MANUAL, AUTO }
var battle_mode := BattleMode.MANUAL

var p1_hp: int
var p2_hp: int
var msg: String
var winner: String
var turn_count := 0
var p1_action: String 
var p2_action: String

const NOBLE_REQUIRED_RESOURCE = 5

func _ready():
	p1 = CharacterFactory.create_p1()
	p2 = CharacterFactory.create_p2()
	p1.reset_for_battle()
	p2.reset_for_battle()
	ui = get_parent() as BattleUI
	p1_hp = p1.max_hp
	p2_hp = p2.max_hp
	ui.p1 = p1
	ui.p2 = p2
	await get_tree().process_frame
	update_ui()
	ui.show_message("†東亞重工 战斗開始！")
	
	start_battle(p1,p2)
	
func start_battle(p1_instance: Character, p2_instance: Character, mode: int = BattleMode.MANUAL):
	p1 = p1_instance
	p2 = p2_instance
	
	match mode:
		BattleMode.MANUAL:
			battle_mode = BattleMode.MANUAL
		BattleMode.AUTO:
			battle_mode = BattleMode.AUTO
		_:
			battle_mode = BattleMode.MANUAL  # fallback
	
	turn_count = 0
	p1_action = ""
	p2_action = ""
	
	p1.reset_for_battle()
	p2.reset_for_battle()
	
	if battle_mode == BattleMode.AUTO:
		start_auto_battle()
	else:
		ui.wait_for_input(p1)

func start_auto_battle():
	p1_action = p1.get_random_available_skill()
	start_next_turn()
	
func on_player_skill_selected(skill_id: String):
	p1_action = skill_id
	
	if skill_id.begins_with("skill_") and p1.cooldown[skill_id] == 0:
		p1.cooldown[skill_id] = -1  # 特别标记
	elif skill_id == "noble" and p1.noble_resource >= 5:
		p1.cooldown["noble"] = -1
	# ⚠️ 这一步很关键：立刻更新UI
	ui.update_skill_buttons(p1)
	ui.update_noble_button(p1)
	start_next_turn()

func on_p2_action():
	p2_action = p2.get_random_available_skill()
	
func start_next_turn():
	msg = ""
	p1.prepare_for_turn()
	p2.prepare_for_turn()
	
	ui.update_skill_buttons(p1)
	ui.update_noble_button(p1)
	
	on_p2_action()
	
	var order = ActionOrderResolver.determine_order(p1, p2)
	
	match order:
		"simultaneous":
			msg += handle_clash(p1, p2, p1_action, p2_action)
			update_ui()
			winner = check_defeat()
			if winner != "":
				end_battle(winner, msg)
			else:
				ui.show_message(msg)
				ui.wait_for_input(p1)
			return

		"p1_first":
			msg += "p1 first!\n"
			msg += execute_skill(p1, p2, p1_action)
			update_ui()
			winner = check_defeat()
			if winner != "":
				end_battle(winner, msg)
				return
			
			msg += execute_skill(p2, p1, p2_action)
			update_ui()
			winner = check_defeat()
			if winner != "":
				end_battle(winner, msg)
			else:
				ui.show_message(msg)
				ui.wait_for_input(p1)
			return

		"p2_first":
			msg += "p2 first!\n"
			msg += execute_skill(p2, p1, p2_action)
			update_ui()
			winner = check_defeat()
			if winner != "":
				end_battle(winner, msg)
				return
				
			msg += execute_skill(p1, p2, p1_action)
			update_ui()
			winner = check_defeat()
			if winner != "":
				end_battle(winner, msg)
			else:
				ui.show_message(msg)
				ui.wait_for_input(p1)
			return
		
func handle_clash(attacker_p1: Character, attacker_p2: Character, p1action: String, p2action: String) -> String:
	var clash_msg := "⚡ 相打触发！双方同时行动\n"

	var r1 = execute_skill(attacker_p1, attacker_p2, p1action)
	clash_msg += r1 + "\n"
	
	var r2 = execute_skill(attacker_p2, attacker_p1, p2action)
	clash_msg += r2 + "\n"
	
	winner = check_defeat()
	if winner != "":
		end_battle(winner, msg)
	else:
		ui.show_message(clash_msg)
		ui.wait_for_input(attacker_p1)

	return clash_msg

func update_ui():
	update_hp_labels()
	ui.update_hp_labels()
	ui.update_info_labels(p1, p2)
	ui.update_skill_buttons(p1)
	ui.update_noble_button(p1)

func update_hp_labels():
	p1_hp = p1.hp
	p2_hp = p2.hp
	ui.set_all_skill_buttons_enabled(false)
	print("P1 HP: %d, P2 HP: %d" % [p1_hp, p2_hp])
	
func execute_skill(user: Character, target: Character, skill_id: String) -> String:
	var result_info := ""
	var current_cd = user.cooldown.get(skill_id, 0)
	# 技能类型描述
	match skill_id:
		"attack":
			result_info += "→ %s 使用了 普通攻击\n" % user.char_name
			
		"noble":
			if user.noble_resource < NOBLE_REQUIRED_RESOURCE:
				return "⚠️ 宝具资源不足，无法释放！\n"
			if current_cd > 0:
				return "⚠️ 宝具仍在冷却中，无法释放！\n"
			elif current_cd == -1:
				user.cooldown["noble"] = user.get_skill_cooldown("noble")
			user.noble_resource = 0
			result_info += "→ %s 使用了 宝具\n" % user.char_name
			
		_:
			result_info += "→ %s 使用了技能：%s\n" % [user.char_name, skill_id]

	# 技能冷却判断与设置
	if skill_id.begins_with("skill_"):
		if current_cd > 0:
			result_info += "⚠️ 技能 %s 仍在冷却中，无法使用！\n" % skill_id
			return result_info
		# 如果为 -1，代表这是本轮准备释放的技能，现在正式设定冷却
		if current_cd == -1:
			user.cooldown[skill_id] = user.get_skill_cooldown(skill_id)

	# 命中判定
	var hit_level = judge_hit_level(user, target)

	match hit_level:
		"miss":
			result_info += "未命中！%s 闪避了攻击。\n" % target.char_name
			return result_info
		"graze":
			result_info += "擦伤命中！%s 受到轻微伤害。" % target.char_name
		"normal":
			result_info += "命中！%s 受到伤害。" % target.char_name
		"critical":
			result_info += "暴击！%s 遭受重创！" % target.char_name

	# 计算伤害并扣除
	var dmg = calculate_damage(user, target, skill_id, hit_level)
	target.hp -= dmg
	result_info += " 造成 %d 点伤害。\n" % dmg

	return result_info
	
func calculate_damage(user: Character, _target: Character, skill_id: String, hit_type: String) -> int:
	# 如果未命中，伤害为0
	if hit_type == "miss":
		return 0

	# 技能伤害倍率
	var skill_multiplier := 1.0
	match skill_id:
		"attack":
			skill_multiplier = 1.0
		"skill_1":
			skill_multiplier = 1.2
		"skill_2":
			skill_multiplier = 1.5
		"skill_3":
			skill_multiplier = 1.7
		"noble":
			skill_multiplier = 3.0
		_:
			skill_multiplier = 1.0

	# 命中结果倍率
	var hit_multiplier := 1.0
	match hit_type:
		"graze":
			hit_multiplier = 0.3
		"normal":
			hit_multiplier = 1.0
		"critical":
			hit_multiplier = 1.5
		_:
			hit_multiplier = 1.0

	# 计算基础伤害并应用倍率
	var base_damage = user.get_attack_damage()
	var raw_damage = base_damage * skill_multiplier * hit_multiplier

	# 输出为整数伤害，保底至少1点（除非未命中）
	var damage = int(raw_damage)
	return damage
	
func apply_skill_costs(user: Character, skill_id: String):
	if skill_id.begins_with("skill_"):
		if user.cooldown.has(skill_id) and user.cooldown[skill_id] == 0:
			user.cooldown[skill_id] = user.get_skill_cooldown(skill_id)
	elif skill_id == "noble":
		if user.noble_resource >= 5:
			user.cooldown["noble"] = user.get_skill_cooldown("noble")
			user.noble_resource = 0
			
func check_defeat() -> String:
	if p1.hp <= 0 and p2.hp <= 0:
		return "Draw"
	elif p1.hp <= 0:
		return p2.char_name
	elif p2.hp <= 0:
		return p1.char_name
	return ""
	
func end_battle(result_winner, result_msg):
	if result_winner == "Draw":
		result_msg += "\n战斗结果：平局！"
	else:
		result_msg += "\n战斗结果：%s 获胜！" % result_winner
	
	# 🧹 清理 -1 冷却值（准备释放但没能执行的技能）
	for skill in p1.cooldown.keys():
		if p1.cooldown[skill] == -1:
			p1.cooldown[skill] = 0
	for skill in p2.cooldown.keys():
		if p2.cooldown[skill] == -1:
			p2.cooldown[skill] = 0
	
	update_ui()
	ui.lock_inputs()
	ui.show_message(result_msg)
	
func reset_battle():
	p1 = CharacterFactory.create_p1()
	p2 = CharacterFactory.create_p2()
	p1.reset_for_battle()
	p2.reset_for_battle()
	ui.p1 = p1
	ui.p2 = p2
	p1_hp = p1.max_hp
	p2_hp = p2.max_hp
	p1.noble_resource = 0
	p2.noble_resource = 0

	ui.set_all_skill_buttons_enabled(true)
	update_ui()
	start_battle(p1, p2)
	
func judge_hit_level(_attacker: Character, defender: Character) -> String:
	var roll = DiceRoller.roll_d20()
	var ac = defender.get_ac()

	if roll == 1:
		return "miss"
	elif roll == 20:
		return "critical"
	elif roll >= ac:
		return "normal"
	elif roll >= ac * 0.75:
		return "graze"
	else:
		return "miss"

func _on_skill_pressed(skill_id: String):
	on_player_skill_selected(skill_id)

	# 判断宝具资源是否足够
	if skill_id == "noble" and p1.noble_resource < 5:
		#print("❌ 宝具资源不足，无法释放")
		return  # 不执行回合，玩家可重新选择技能

	p1_action = skill_id
	start_next_turn()

func _on_attack_pressed():
	var pair = choose_attacker()
	var first = pair[0]
	var second = pair[1]
	
	if p1_hp <= 0 or p2_hp <= 0:
		return

	if randf() < 0.2:
		msg = "相互击中！两人的攻击同时命中！"
		var p1_damage = perform_attack(p1, p2)
		var p2_damage = perform_attack(p2, p1)
		msg += "\n%s 对 %s 造成 %d 点伤害。" % [first.char_name, second.char_name, p1_damage]
		msg += "\n%s 对 %s 造成 %d 点伤害。" % [second.char_name, first.char_name, p2_damage]
		ui.msg_label.text = msg
		update_ui()
		await get_tree().create_timer(1).timeout
		winner = check_defeat()
		if winner != "":
			end_battle(winner, msg)
		return

	msg = "%s 先手攻击！" % first.char_name
	var dmg = perform_attack(first, second)
	msg += "\n%s 对 %s 造成 %d 点伤害。" % [first.char_name, second.char_name, dmg]
	update_ui()
	await get_tree().create_timer(1).timeout

	winner = check_defeat()
	if winner != "":
		end_battle(winner, msg)
		return

	dmg = perform_attack(second, first)
	msg += "\n%s 反击！" % second.char_name
	msg += "\n%s 对 %s 造成 %d 点伤害。" % [second.char_name,first.char_name, dmg]

	winner = check_defeat()
	if winner != "":
		end_battle(winner, msg)
		return

	ui.show_message(msg)
	update_ui()
		
func choose_attacker() -> Array:
	var s1 = p1.attributes.get_agility()
	var s2 = p2.attributes.get_agility()
	var total = s1 + s2
	var roll = randi_range(1, total)
	return [p1, p2] if roll <= s1 else [p2, p1]

func perform_attack(attacker: Character, defender: Character) -> int:
	var dmg = attacker.get_attack_damage()
	if defender == p1:
		p1_hp -= dmg
	else:
		p2_hp -= dmg
	return dmg
	
func calculate_ac(attributes: CharacterAttributes, armor_bonus := 0, buff_bonus := 0) -> int:
	var agi_bonus = floor(attributes.get_agility() / 10)
	var luk_bonus = floor(attributes.get_luck() / 20)
	var endu_bonus = floor(attributes.get_endurance() / 30)

	return 10 + agi_bonus + luk_bonus + endu_bonus + armor_bonus + buff_bonus
	
