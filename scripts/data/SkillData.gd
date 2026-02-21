extends Resource
class_name SkillData

## 技能数据类 - 从配置文件加载技能信息

@export var skill_id: String = ""
@export var skill_name: String = ""
@export var skill_type: String = "attack"  # "attack", "skill", "noble"
@export var damage_multiplier: float = 1.0
@export var cooldown: int = 0
@export var description: String = ""
@export var animation: String = ""

# 特殊属性
@export var requires_resource: bool = false  # 宝具需要资源
@export var required_resource_amount: int = 0

func _init(data: Dictionary = {}):
	if data.is_empty():
		return

	skill_id = data.get("skill_id", "")
	skill_name = data.get("skill_name", "")
	skill_type = data.get("skill_type", "attack")
	damage_multiplier = data.get("damage_multiplier", 1.0)
	cooldown = data.get("cooldown", 0)
	description = data.get("description", "")
	animation = data.get("animation", "")
	requires_resource = data.get("requires_resource", false)
	required_resource_amount = data.get("required_resource_amount", 0)

## 从 JSON 文件加载技能数据
static func load_from_json(file_path: String) -> SkillData:
	if not FileAccess.file_exists(file_path):
		push_error("技能文件不存在: " + file_path)
		return null

	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("无法打开技能文件: " + file_path)
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

	return SkillData.new(data)

## 创建一个用于显示的简短信息
func get_display_name() -> String:
	return skill_name

## 获取带冷却时间的显示名称
func get_display_name_with_cd(current_cd: int) -> String:
	if current_cd > 0:
		return "%s (CD:%d)" % [skill_name, current_cd]
	elif current_cd == -1:
		return skill_name  # 准备释放状态
	else:
		return skill_name
