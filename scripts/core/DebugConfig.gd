extends Node

## 调试配置 - 控制游戏中的调试输出级别

enum LogLevel {
	NONE,      # 不输出任何调试信息
	ERROR,     # 仅输出错误
	WARNING,   # 输出错误和警告
	INFO,      # 输出一般信息（推荐）
	DEBUG,     # 输出详细调试信息
	VERBOSE    # 输出所有信息
}

# 当前日志级别（可以在运行时修改）
var current_level: LogLevel = LogLevel.DEBUG

# 模块开关（可以单独控制某个模块的输出）
var module_enabled = {
	"resource_manager": true,   # 资源加载
	"character": false,          # 角色创建
	"battle": true,              # 战斗流程
	"ui": false,                 # UI 更新
	"skill": false,              # 技能执行
}

## 检查是否应该输出日志
func should_log(level: LogLevel, module: String = "") -> bool:
	# 检查日志级别
	if level > current_level:
		return false

	# 检查模块开关
	if not module.is_empty() and module_enabled.has(module):
		return module_enabled[module]

	return true

## 便捷的日志函数
func log_error(message: String, module: String = ""):
	if should_log(LogLevel.ERROR, module):
		push_error(message)

func log_warning(message: String, module: String = ""):
	if should_log(LogLevel.WARNING, module):
		push_warning(message)

func log_info(message: String, module: String = ""):
	if should_log(LogLevel.INFO, module):
		print(message)

func log_debug(message: String, module: String = ""):
	if should_log(LogLevel.DEBUG, module):
		print("[DEBUG] " + message)

func log_verbose(message: String, module: String = ""):
	if should_log(LogLevel.VERBOSE, module):
		print("[VERBOSE] " + message)
