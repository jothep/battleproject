extends Resource
class_name CharacterData

## 角色数据类 - 从配置文件加载角色信息

@export var character_id: String = ""
@export var character_name: String = ""
@export var description: String = ""

# 美术资源路径
@export var portrait_path: String = ""
@export var battle_sprite_path: String = ""

# 属性（使用 Fate 风格的等级制）
@export var strength_rank: String = "E"
@export var agility_rank: String = "E"
@export var luck_rank: String = "E"
@export var endurance_rank: String = "E"
@export var mana_rank: String = "E"
@export var noble_rank: String = "E"

# 技能列表（技能ID数组）
@export var skill_ids: Array[String] = []
@export var noble_phantasm_id: String = ""

func _init(data: Dictionary = {}):
	if data.is_empty():
		return

	character_id = data.get("character_id", "")
	character_name = data.get("character_name", "")
	description = data.get("description", "")
	portrait_path = data.get("portrait_path", "")
	battle_sprite_path = data.get("battle_sprite_path", "")

	# 读取属性
	var attributes = data.get("attributes", {})
	if attributes is Dictionary:
		strength_rank = attributes.get("strength", "E")
		agility_rank = attributes.get("agility", "E")
		luck_rank = attributes.get("luck", "E")
		endurance_rank = attributes.get("endurance", "E")
		mana_rank = attributes.get("mana", "E")
		noble_rank = attributes.get("noble", "E")

	# 读取技能列表
	var skills = data.get("skill_ids", [])
	if skills is Array:
		skill_ids.clear()
		for skill_id in skills:
			skill_ids.append(str(skill_id))

	noble_phantasm_id = data.get("noble_phantasm_id", "")

## 从 JSON 文件加载角色数据
static func load_from_json(file_path: String) -> CharacterData:
	if not FileAccess.file_exists(file_path):
		push_error("角色文件不存在: " + file_path)
		return null

	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("无法打开角色文件: " + file_path)
		return null

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		push_error("JSON 解析失败: " + file_path + " at line " + str(json.get_error_line()))
		return null

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("JSON 根节点不是字典: " + file_path)
		return null

	return CharacterData.new(data)

## 获取所有技能ID（包括宝具）
func get_all_skill_ids() -> Array[String]:
	var all_skills: Array[String] = []
	all_skills.append_array(skill_ids)
	if not noble_phantasm_id.is_empty():
		all_skills.append(noble_phantasm_id)
	return all_skills

## 创建 CharacterAttributes 对象
func create_attributes() -> CharacterAttributes:
	var attr = CharacterAttributes.new()
	attr.strength_rank = strength_rank
	attr.agility_rank = agility_rank
	attr.luck_rank = luck_rank
	attr.endurance_rank = endurance_rank
	attr.mana_rank = mana_rank
	attr.noble_rank = noble_rank
	attr.initialize()
	return attr
