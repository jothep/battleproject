extends CharacterBody2D
class_name PlayerController

## 玩家控制器 - 处理探索场景中的移动（简化版）

@export var move_speed: float = 12.0             # 移动速度（插值速度，越大越快）
@export var tile_size: int = 16                  # 瓦片大小

var is_moving: bool = false
var target_position: Vector2 = Vector2.ZERO
var grid_position: Vector2 = Vector2.ZERO        # 当前网格位置
var facing_direction: Vector2 = Vector2.DOWN     # 当前朝向

# 引用
var map_manager = null  # MapManager 引用

signal player_moved(from_pos: Vector2, to_pos: Vector2)

func _ready():
	# 初始化位置
	target_position = position
	grid_position = position / tile_size
	DebugConfig.log_info("玩家控制器初始化", "exploration")

func _process(delta):
	if is_moving:
		_process_movement(delta)
	else:
		_process_input()

## 处理输入
func _process_input():
	var input_direction = Vector2.ZERO

	# 获取方向输入（WASD 或 方向键）
	if Input.is_action_pressed("ui_up") or Input.is_physical_key_pressed(KEY_W):
		input_direction = Vector2.UP
	elif Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S):
		input_direction = Vector2.DOWN
	elif Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A):
		input_direction = Vector2.LEFT
	elif Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D):
		input_direction = Vector2.RIGHT

	# 尝试移动
	if input_direction != Vector2.ZERO:
		_try_move(input_direction)

## 尝试移动
func _try_move(direction: Vector2):
	var new_grid_pos = grid_position + direction

	# 检查是否可通行
	if map_manager and map_manager.is_walkable(new_grid_pos):
		facing_direction = direction
		is_moving = true
		target_position = new_grid_pos * tile_size

		# 记录移动
		var old_pos = grid_position
		grid_position = new_grid_pos

		# 触发移动信号
		player_moved.emit(old_pos, grid_position)

		DebugConfig.log_debug("玩家移动: %v -> %v" % [old_pos, grid_position], "exploration")
	else:
		# 转向但不移动
		facing_direction = direction
		DebugConfig.log_debug("玩家被阻挡，朝向: %v" % facing_direction, "exploration")

## 处理移动动画（使用lerp插值，更平滑）
func _process_movement(delta):
	# 使用 lerp 插值，平滑移动到目标位置
	position = position.lerp(target_position, move_speed * delta)

	# 当非常接近目标位置时，直接到达
	if position.distance_to(target_position) < 0.5:
		position = target_position
		is_moving = false

## 设置网格位置（用于初始化）
func set_grid_position(pos: Vector2):
	grid_position = pos
	position = pos * tile_size
	target_position = position
	DebugConfig.log_info("玩家位置设置为: %v (像素: %v)" % [grid_position, position], "exploration")
