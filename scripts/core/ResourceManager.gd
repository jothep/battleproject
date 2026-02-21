extends Node

## 资源管理器 - 单例，负责加载和管理所有配置数据

# 数据存储
var skills: Dictionary = {}       # skill_id -> SkillData
var characters: Dictionary = {}   # character_id -> CharacterData
var maps: Dictionary = {}          # map_id -> MapData

# 数据路径
const SKILLS_PATH = "res://data/skills/"
const CHARACTERS_PATH = "res://data/characters/"
const MAPS_PATH = "res://data/maps/"

func _ready():
	DebugConfig.log_info("=== ResourceManager 初始化开始 ===", "resource_manager")
	load_all_data()
	DebugConfig.log_info("=== ResourceManager 初始化完成 ===", "resource_manager")

## 加载所有配置数据
func load_all_data():
	load_skills()
	load_characters()
	load_maps()

## 加载所有技能
func load_skills():
	DebugConfig.log_info("正在加载技能数据...", "resource_manager")
	var skill_files = JSONLoader.load_all_from_directory(SKILLS_PATH)

	for skill_data_dict in skill_files:
		var skill_data = SkillData.new(skill_data_dict)
		if skill_data and not skill_data.skill_id.is_empty():
			skills[skill_data.skill_id] = skill_data
			DebugConfig.log_debug("  ✓ 加载技能: %s (%s)" % [skill_data.skill_id, skill_data.skill_name], "resource_manager")
		else:
			push_error("  ✗ 技能数据无效")

	DebugConfig.log_info("技能加载完成，共 %d 个技能" % skills.size(), "resource_manager")

## 加载所有角色
func load_characters():
	DebugConfig.log_info("正在加载角色数据...", "resource_manager")
	var character_files = JSONLoader.load_all_from_directory(CHARACTERS_PATH)

	for char_data_dict in character_files:
		var char_data = CharacterData.new(char_data_dict)
		if char_data and not char_data.character_id.is_empty():
			characters[char_data.character_id] = char_data
			DebugConfig.log_debug("  ✓ 加载角色: %s (%s)" % [char_data.character_id, char_data.character_name], "resource_manager")
		else:
			push_error("  ✗ 角色数据无效")

	DebugConfig.log_info("角色加载完成，共 %d 个角色" % characters.size(), "resource_manager")

## 获取技能数据
func get_skill(skill_id: String) -> SkillData:
	if not skills.has(skill_id):
		push_error("技能不存在: " + skill_id)
		return null
	return skills[skill_id]

## 获取角色数据
func get_character(character_id: String) -> CharacterData:
	if not characters.has(character_id):
		push_error("角色不存在: " + character_id)
		return null
	return characters[character_id]

## 检查技能是否存在
func has_skill(skill_id: String) -> bool:
	return skills.has(skill_id)

## 检查角色是否存在
func has_character(character_id: String) -> bool:
	return characters.has(character_id)

## 获取所有技能ID列表
func get_all_skill_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in skills.keys():
		ids.append(id)
	return ids

## 获取所有角色ID列表
func get_all_character_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in characters.keys():
		ids.append(id)
	return ids

## 加载所有地图
func load_maps():
	DebugConfig.log_info("正在加载地图数据...", "resource_manager")
	var map_files = JSONLoader.load_all_from_directory(MAPS_PATH)

	for map_data_dict in map_files:
		var map_data = MapData.new(map_data_dict)
		if map_data and not map_data.map_id.is_empty():
			maps[map_data.map_id] = map_data
			DebugConfig.log_debug("  ✓ 加载地图: %s (%s)" % [map_data.map_id, map_data.map_name], "resource_manager")
		else:
			push_error("  ✗ 地图数据无效")

	DebugConfig.log_info("地图加载完成，共 %d 个地图" % maps.size(), "resource_manager")

## 获取地图数据
func get_map(map_id: String) -> MapData:
	if not maps.has(map_id):
		push_error("地图不存在: " + map_id)
		return null
	return maps[map_id]

## 检查地图是否存在
func has_map(map_id: String) -> bool:
	return maps.has(map_id)

## 获取所有地图ID列表
func get_all_map_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in maps.keys():
		ids.append(id)
	return ids

## 重新加载所有数据（用于热更新）
func reload_all_data():
	skills.clear()
	characters.clear()
	maps.clear()
	load_all_data()
	print("所有数据已重新加载")
