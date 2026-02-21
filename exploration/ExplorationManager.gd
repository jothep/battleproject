extends Node2D
class_name ExplorationManager

## 探索管理器 - 整合探索系统组件（简化版）

# 子节点引用
@onready var map_manager: MapManager = $MapManager
@onready var player: PlayerController = $Player
@onready var camera: Camera2D = $Camera

# 当前地图ID
var current_map_id: String = ""

func _ready():
	DebugConfig.log_info("探索管理器初始化", "exploration")

	# 加载测试地图
	load_map("test_map")

	# 设置玩家初始位置
	if map_manager.current_map_data:
		var spawn = map_manager.current_map_data.spawn_point
		player.set_grid_position(spawn)
		DebugConfig.log_info("玩家生成在: %v" % spawn, "exploration")

	# 将 MapManager 引用传给 PlayerController
	player.map_manager = map_manager

	# 相机跟随玩家
	camera.position = player.position

	# 连接信号
	player.player_moved.connect(_on_player_moved)

	DebugConfig.log_info("✅ 探索场景初始化完成", "exploration")

## 加载地图
func load_map(map_id: String):
	current_map_id = map_id

	if map_manager.load_map(map_id):
		DebugConfig.log_info("探索场景加载地图成功: %s" % map_id, "exploration")
	else:
		push_error("探索场景加载地图失败: " + map_id)

## 玩家移动回调
func _on_player_moved(from_pos: Vector2, to_pos: Vector2):
	# 这里可以添加：
	# - 检查遇敌
	# - 检查传送点
	# - 触发地图事件
	pass

## 更新循环（相机跟随）
func _process(_delta):
	# 相机直接跟随玩家（玩家本身已经平滑移动）
	camera.position = player.position
