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

const NOBLE_REQUIRED_RESOURCE = 5

func _ready():
	# 检查关键UI节点是否初始化成功
	var all_ok = true
	for node_name in [
		"AttackButton", "Skill1Button", "Skill2Button", "Skill3Button", "NobleButton", "RestartButton",
		"MessageLabel", "P1Label", "P2Label", "P1InfoLabel", "P2InfoLabel"
	]:
		if get_node_or_null(node_name) == null:
			DebugConfig.log_error("❌ UI节点未找到：" + node_name, "ui")
			all_ok = false
		else:
			DebugConfig.log_verbose("✅ UI节点已找到：" + node_name, "ui")

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

	DebugConfig.log_info("✅ BattleUI 初始化完成", "ui")

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
	var cd = character.cooldown.get("noble", 0)
	var noble_skill_data = ResourceManager.get_skill("noble")

	if not noble_skill_data:
		noble_button.disabled = true
		noble_button.text = "未配置"
		return

	if cd > 0:
		noble_button.disabled = true
		noble_button.text = "%s CD:%d" % [noble_skill_data.skill_name, cd]
	elif cd == -1:
		noble_button.disabled = true
		noble_button.text = noble_skill_data.skill_name
	elif character.noble_resource < NOBLE_REQUIRED_RESOURCE:
		noble_button.disabled = true
		noble_button.text = "%s (%d/%d)" % [noble_skill_data.skill_name, character.noble_resource, NOBLE_REQUIRED_RESOURCE]
	else:
		noble_button.disabled = false
		noble_button.text = noble_skill_data.skill_name

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
	update_skill_buttons(character)
	update_noble_button(character)
	attack_button.disabled = false
	DebugConfig.log_debug("🎮 等待玩家操作...", "ui")

static func get_character_info(c: Character) -> String:
	var text = "【%s】\nMAX_HP: %d\nATK: %d\n" % [c.char_name, c.max_hp, c.atk]
	text += "力量: %s (%d)\n" % [c.attributes.strength_rank, c.attributes.get_strength()]
	text += "敏捷: %s (%d)\n" % [c.attributes.agility_rank, c.attributes.get_agility()]
	text += "幸运: %s (%d)\n" % [c.attributes.luck_rank, c.attributes.get_luck()]
	text += "耐久: %s (%d)\n" % [c.attributes.endurance_rank, c.attributes.get_endurance()]
	text += "魔力: %s (%d)\n" % [c.attributes.mana_rank, c.attributes.get_mana()]
	text += "宝具: %s (%d)" % [c.attributes.noble_rank, c.attributes.get_noble()]
	return text

func update_skill_buttons(character: Character):
	var cd = character.cooldown

	# 动态更新技能按钮（假设技能按钮对应 skill_1, skill_2, skill_3）
	var skill_buttons = [skill1_button, skill2_button, skill3_button]
	var skill_ids = ["skill_1", "skill_2", "skill_3"]

	for i in range(3):
		var skill_id = skill_ids[i]
		var button = skill_buttons[i]
		var skill_data = ResourceManager.get_skill(skill_id)

		if skill_data:
			var cd_value = cd.get(skill_id, 0)
			button.disabled = cd_value != 0
			button.text = skill_data.get_display_name_with_cd(cd_value)
		else:
			button.disabled = true
			button.text = "未配置"

	# 宝具（考虑资源限制）
	var noble_skill_data = ResourceManager.get_skill("noble")
	if noble_skill_data:
		var cd_noble = cd.get("noble", 0)
		noble_button.text = noble_skill_data.get_display_name_with_cd(cd_noble)
		noble_button.disabled = cd_noble > 0 or character.noble_resource < 5
	else:
		noble_button.disabled = true
		noble_button.text = "未配置"

	# 攻击按钮
	var attack_skill_data = ResourceManager.get_skill("attack")
	if attack_skill_data:
		attack_button.text = attack_skill_data.skill_name
	else:
		attack_button.text = "攻击"

func lock_inputs():
	attack_button.disabled = true
	skill1_button.disabled = true
	skill2_button.disabled = true
	skill3_button.disabled = true
	noble_button.disabled = true
