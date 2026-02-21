extends Node2D
class_name MapManager

## 地图管理器 - 加载和管理地图（简化版）

var current_map_data: MapData = null

func _ready():
	DebugConfig.log_info("地图管理器初始化", "exploration")

## 加载地图
func load_map(map_id: String) -> bool:
	DebugConfig.log_info("加载地图: %s" % map_id, "exploration")

	# 从 ResourceManager 获取地图数据
	current_map_data = ResourceManager.get_map(map_id)
	if not current_map_data:
		push_error("地图数据不存在: " + map_id)
		return false

	DebugConfig.log_info("地图加载完成: %s (%dx%d)" % [current_map_data.map_name, current_map_data.width, current_map_data.height], "exploration")

	# 绘制地图可视化（测试用）
	_draw_map_visual()

	return true

## 检查位置是否可通行
func is_walkable(grid_pos: Vector2) -> bool:
	if not current_map_data:
		return false

	return current_map_data.is_walkable(int(grid_pos.x), int(grid_pos.y))

## 绘制地图可视化（优化版 - 使用自定义绘制）
func _draw_map_visual():
	if not current_map_data:
		return

	# 触发重绘
	queue_redraw()
	DebugConfig.log_info("地图可视化绘制完成", "exploration")

## 自定义绘制（性能优化 - 替代300个ColorRect节点）
func _draw():
	if not current_map_data:
		return

	# 定义颜色
	var wall_color = Color(0.3, 0.3, 0.3, 1.0)    # 灰色墙壁
	var floor_color = Color(0.1, 0.3, 0.1, 1.0)   # 深绿色地面

	# 使用 draw_rect 绘制每个格子
	for y in range(current_map_data.height):
		for x in range(current_map_data.width):
			var is_wall = current_map_data.collision_layer[y * current_map_data.width + x] == 1

			var rect = Rect2(
				x * current_map_data.tile_size,
				y * current_map_data.tile_size,
				current_map_data.tile_size,
				current_map_data.tile_size
			)

			# 绘制格子
			if is_wall:
				draw_rect(rect, wall_color, true)
			else:
				draw_rect(rect, floor_color, true)

			# 绘制网格线（帮助看清格子边界）
			draw_rect(rect, Color(0, 0, 0, 0.2), false, 1.0)
