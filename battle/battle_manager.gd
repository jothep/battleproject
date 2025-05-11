extends Node
class_name BattleManager

var p1: Character
var p2: Character
var p1_hp: int
var p2_hp: int
var msg: String
var winner: String

@onready var p1_label = $"../P1Label"
@onready var p2_label = $"../P2Label"
@onready var msg_label = $"../MessageLabel"
@onready var attack_button = $"../AttackButton"
@onready var p1_info_label = $"../P1InfoLabel"
@onready var p2_info_label = $"../P2InfoLabel"
@onready var restart_button = $"../RestartButton"

func _ready():
	p1 = CharacterFactory.create_p1()
	p2 = CharacterFactory.create_p2()
	p1_hp = p1.max_hp
	p2_hp = p2.max_hp
	update_ui()
	msg_label.text = "†東亞重工 战斗開始！"
	attack_button.pressed.connect(_on_attack_pressed)
	restart_button.pressed.connect(_on_restart_pressed)

func update_ui():
	update_hp_labels()
	p1_info_label.text = HUDManager.get_character_info(p1)
	p2_info_label.text = HUDManager.get_character_info(p2)

func update_hp_labels():
	p1_label.text = "P1 HP: %d" % p1_hp
	p2_label.text = "P2 HP: %d" % p2_hp
	
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
		msg_label.text = msg
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

	msg_label.text = msg
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
	
func check_defeat() -> String:
	if p1_hp <= 0 and p2_hp <= 0:
		return "Draw"
	elif p1_hp <= 0:
		return p2.char_name
	elif p2_hp <= 0:
		return p1.char_name
	return ""
	
func end_battle(result_winner, result_msg):
	if result_winner == "Draw":
		result_msg += "\n战斗结果：平局！"
	else:
		result_msg += "\n战斗结果：%s 获胜！" % result_winner
	msg_label.text = result_msg
	attack_button.disabled = true
	update_ui()
	
func reset_battle():
	p1 = CharacterFactory.create_p1()
	p2 = CharacterFactory.create_p2()

	p1_hp = p1.max_hp
	p2_hp = p2.max_hp

	update_ui()
	msg_label.text = "†東亞重工 战斗重新开始！"
	attack_button.disabled = false

	
func _on_restart_pressed():
	reset_battle()
