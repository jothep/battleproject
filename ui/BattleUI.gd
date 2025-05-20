extends Control
class_name BattleUI

# --- UI 节点引用 ---
@onready var attack_button = $AttackButton
@onready var skill1_button = $Skill1Button
@onready var skill2_button = $Skill2Button
@onready var skill3_button = $Skill3Button
@onready var noble_button = $NobleButton
@onready var restart_button = $RestartButton

@onready var msg_label = $MessageLabel
@onready var p1_label = $P1Label
@onready var p2_label = $P2Label
@onready var p1_info_label = $P1InfoLabel
@onready var p2_info_label = $P2InfoLabel

# 来自外部的 BattleManager 控制器
var battle_manager: BattleManager = null

# --- 角色引用（用于显示HP）---
var p1: Character = null
var p2: Character = null

func _ready():
	# 检查关键UI节点是否初始化成功
	var all_ok = true
	for node_name in [
		"AttackButton", "Skill1Button", "Skill2Button", "Skill3Button", "NobleButton", "RestartButton",
		"MessageLabel", "P1Label", "P2Label", "P1InfoLabel", "P2InfoLabel"
	]:
		if get_node_or_null(node_name) == null:
			print("❌ UI节点未找到：", name)
			all_ok = false
		else:
			print("✅ UI节点已找到：", name)

	if not all_ok:
		push_error("❗BattleUI 初始化失败：有控件未正确绑定！")
		return

	# 获取 battle_manager（它是本节点的子节点）
	battle_manager = get_node_or_null("BattleManager")
	if not battle_manager:
		push_error("❗未找到 BattleManager 节点")
		return

	# 注册按钮事件（安全连接）
	if attack_button: attack_button.pressed.connect(_on_attack_pressed)
	if skill1_button: skill1_button.pressed.connect(func(): _on_skill_pressed("skill_1"))
	if skill2_button: skill2_button.pressed.connect(func(): _on_skill_pressed("skill_2"))
	if skill3_button: skill3_button.pressed.connect(func(): _on_skill_pressed("skill_3"))
	if noble_button: noble_button.pressed.connect(_on_noble_pressed)
	if restart_button: restart_button.pressed.connect(_on_restart_pressed)

	print("✅ BattleUI 初始化完成")

func _on_attack_pressed():
	battle_manager.on_player_skill_selected("attack")
	
func _on_skill_pressed(skill_id: String):
	battle_manager.on_player_skill_selected(skill_id)

func _on_noble_pressed():
	battle_manager.on_player_skill_selected("noble")
	
func _on_restart_pressed():
	battle_manager.reset_battle()
	show_message("†東亞重工 战斗开始！")
	
func update_info_labels(p1_data: Character, p2_data: Character):
	p1_info_label.text = get_character_info(p1_data)
	p2_info_label.text = get_character_info(p2_data)
	
func update_hp_labels():
	if p1 and p2:
		p1_label.text = "P1 HP: %d" % p1.hp
		p2_label.text = "P2 HP: %d" % p2.hp

func update_noble_button(character: Character):
	noble_button.disabled = character.noble_resource < 3

func set_all_skill_buttons_enabled(enabled: bool):
	if attack_button == null:
		print("❗按钮未初始化，跳过按钮启用控制")
		return
		
	attack_button.disabled = not enabled
	skill1_button.disabled = not enabled
	skill2_button.disabled = not enabled
	skill3_button.disabled = not enabled
	noble_button.disabled = not enabled or noble_button.disabled  # 保留资源限制

func show_message(text: String):
	msg_label.text = text

func wait_for_input(character: Character):
	update_noble_button(character)
	set_all_skill_buttons_enabled(true)
	print("🎮 等待玩家操作...")

static func get_character_info(c: Character) -> String:
	var text = "【%s】\nMAX_HP: %d\nATK: %d\n" % [c.char_name, c.max_hp, c.atk]
	text += "力量: %s (%d)\n" % [c.attributes.strength_rank, c.attributes.get_strength()]
	text += "敏捷: %s (%d)\n" % [c.attributes.agility_rank, c.attributes.get_agility()]
	text += "幸运: %s (%d)\n" % [c.attributes.luck_rank, c.attributes.get_luck()]
	text += "耐久: %s (%d)\n" % [c.attributes.endurance_rank, c.attributes.get_endurance()]
	text += "魔力: %s (%d)\n" % [c.attributes.mana_rank, c.attributes.get_mana()]
	text += "宝具: %s (%d)" % [c.attributes.noble_rank, c.attributes.get_noble()]
	return text

func update_skill_buttons(character):
	var cooldown = character.cooldown

	# 技能1
	var cd1 = cooldown.get("skill_1", 0)
	skill1_button.text = "技能1 (CD: %d)" % cd1 if cd1 > 0 else "技能1"
	skill1_button.disabled = cd1 > 0

	# 技能2
	var cd2 = cooldown.get("skill_2", 0)
	skill2_button.text = "技能2 (CD: %d)" % cd2 if cd2 > 0 else "技能2"
	skill2_button.disabled = cd2 > 0

	# 技能3
	var cd3 = cooldown.get("skill_3", 0)
	skill3_button.text = "技能3 (CD: %d)" % cd3 if cd3 > 0 else "技能3"
	skill3_button.disabled = cd3 > 0

	# 宝具（考虑资源限制）
	var cd_noble = cooldown.get("noble", 0)
	noble_button.text = "宝具 (CD: %d)" % cd_noble if cd_noble > 0 else "宝具"
	noble_button.disabled = cd_noble > 0 or character.noble_resource < 3

	# 攻击永远可用（除非你在 end_battle 中统一禁用）
	attack_button.text = "攻击"
