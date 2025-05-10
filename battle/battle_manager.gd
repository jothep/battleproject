extends Node
class_name BattleManager

var p1: Character
var p2: Character
var p1_hp: int
var p2_hp: int

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
	if p1_hp <= 0 or p2_hp <= 0:
		return

	p2_hp -= p1.atk
	msg_label.text = "P1 攻击 P2！造成了 %d 点伤害。" % p1.atk
	update_ui()

	await get_tree().create_timer(1).timeout

	if p2_hp <= 0:
		msg_label.text += "\nP1 获胜！"
		attack_button.disabled = true
		return

	p1_hp -= p2.atk
	msg_label.text += "\nP2 反击！造成了 %d 点伤害。" % p2.atk
	update_ui()

	if p1_hp <= 0:
		msg_label.text += "\nP2 获胜！"
		attack_button.disabled = true
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
