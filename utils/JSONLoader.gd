extends Object
class_name JSONLoader

## JSON 加载工具类 - 用于批量加载配置文件

## 加载目录下所有 JSON 文件并返回字典数组
static func load_all_from_directory(dir_path: String) -> Array[Dictionary]:
	var results: Array[Dictionary] = []

	if not DirAccess.dir_exists_absolute(dir_path):
		push_error("目录不存在: " + dir_path)
		return results

	var dir = DirAccess.open(dir_path)
	if not dir:
		push_error("无法打开目录: " + dir_path)
		return results

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var full_path = dir_path.path_join(file_name)
			var data = load_json_file(full_path)
			if data != null:
				results.append(data)
		file_name = dir.get_next()

	dir.list_dir_end()

	DebugConfig.log_debug("从目录 %s 加载了 %d 个 JSON 文件" % [dir_path, results.size()], "resource_manager")
	return results

## 加载单个 JSON 文件并返回字典
static func load_json_file(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		push_error("文件不存在: " + file_path)
		return {}

	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("无法打开文件: " + file_path)
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		push_error("JSON 解析失败: %s at line %d" % [file_path, json.get_error_line()])
		return {}

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("JSON 根节点不是字典: " + file_path)
		return {}

	return data

## 验证 JSON 数据是否包含必需字段
static func validate_required_fields(data: Dictionary, required_fields: Array[String]) -> bool:
	for field in required_fields:
		if not data.has(field):
			push_error("缺少必需字段: " + field)
			return false
	return true
