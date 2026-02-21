extends Resource
class_name MapData

## 地图数据类 - 从配置文件加载地图信息

@export var map_id: String = ""
@export var map_name: String = ""
@export var width: int = 20
@export var height: int = 15
@export var tile_size: int = 16

# 碰撞层数据（1D 数组表示 2D 格子）
@export var collision_layer: Array = []  # 1=墙壁，0=可通行

# 玩家出生点
@export var spawn_point: Vector2 = Vector2(5, 5)

func _init(data: Dictionary = {}):
	if data.is_empty():
		return

	map_id = data.get("map_id", "")
	map_name = data.get("map_name", "")
	width = data.get("width", 20)
	height = data.get("height", 15)
	tile_size = data.get("tile_size", 16)

	# 读取碰撞层
	var collision_data = data.get("collision_layer", [])
	if collision_data is Array:
		collision_layer.clear()
		for value in collision_data:
			collision_layer.append(int(value))

	# 读取出生点
	var spawn_data = data.get("spawn_point", {"x": 5, "y": 5})
	spawn_point = Vector2(spawn_data.get("x", 5), spawn_data.get("y", 5))

## 从 JSON 文件加载地图数据
static func load_from_json(file_path: String) -> MapData:
	if not FileAccess.file_exists(file_path):
		push_error("地图文件不存在: " + file_path)
		return null

	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("无法打开地图文件: " + file_path)
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

	return MapData.new(data)

## 检查位置是否可通行
func is_walkable(x: int, y: int) -> bool:
	# 边界检查
	if x < 0 or x >= width or y < 0 or y >= height:
		return false

	# 碰撞层检查
	var index = y * width + x
	if index >= collision_layer.size():
		return false

	return collision_layer[index] == 0
