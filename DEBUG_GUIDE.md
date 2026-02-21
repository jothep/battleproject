# 调试配置使用指南

## 简介

游戏现在使用 `DebugConfig` 单例来控制调试输出，避免控制台被重复信息淹没。

## 日志级别

从低到高有以下级别：

1. **NONE** - 不输出任何调试信息
2. **ERROR** - 仅输出错误
3. **WARNING** - 输出错误和警告
4. **INFO** - 输出一般信息（推荐，默认）
5. **DEBUG** - 输出详细调试信息
6. **VERBOSE** - 输出所有信息

## 快速调整日志级别

### 方法 1：在游戏开始时修改（推荐）

在任意场景的 `_ready()` 函数中添加：

```gdscript
func _ready():
    # 设置为 INFO 级别（默认，显示重要信息）
    DebugConfig.current_level = DebugConfig.LogLevel.INFO

    # 或者设置为 ERROR 级别（安静模式，只显示错误）
    # DebugConfig.current_level = DebugConfig.LogLevel.ERROR

    # 或者设置为 DEBUG 级别（详细模式，显示调试信息）
    # DebugConfig.current_level = DebugConfig.LogLevel.DEBUG
```

### 方法 2：直接修改 DebugConfig.gd

打开 `scripts/core/DebugConfig.gd`，修改第 17 行：

```gdscript
# 修改前（默认）
var current_level: LogLevel = LogLevel.INFO

# 修改为安静模式
var current_level: LogLevel = LogLevel.ERROR

# 修改为详细模式
var current_level: LogLevel = LogLevel.DEBUG
```

## 模块开关

你还可以单独控制某个模块的输出：

```gdscript
# 关闭资源管理器的详细输出
DebugConfig.module_enabled["resource_manager"] = false

# 打开战斗系统的详细输出
DebugConfig.module_enabled["battle"] = true

# 打开 UI 的详细输出
DebugConfig.module_enabled["ui"] = true
```

### 可用模块：

- `resource_manager` - 资源加载（技能、角色配置等）
- `character` - 角色创建
- `battle` - 战斗流程
- `ui` - UI 更新
- `skill` - 技能执行

## 推荐配置

### 正常游玩
```gdscript
DebugConfig.current_level = DebugConfig.LogLevel.INFO
```
只显示重要的启动信息和错误。

### 调试战斗逻辑
```gdscript
DebugConfig.current_level = DebugConfig.LogLevel.DEBUG
DebugConfig.module_enabled["battle"] = true
DebugConfig.module_enabled["skill"] = true
```
显示详细的战斗流程。

### 安静模式（发布版本）
```gdscript
DebugConfig.current_level = DebugConfig.LogLevel.ERROR
```
只显示错误信息。

### 超详细模式（排查问题）
```gdscript
DebugConfig.current_level = DebugConfig.LogLevel.VERBOSE
```
显示所有信息。

## 效果对比

### 修改前（INFO 级别）：
```
=== ResourceManager 初始化开始 ===
正在加载技能数据...
技能加载完成，共 5 个技能
正在加载角色数据...
角色加载完成，共 2 个角色
=== ResourceManager 初始化完成 ===
✅ BattleUI 初始化完成
```

### 修改后（ERROR 级别）：
```
（几乎没有输出，除非出错）
```

### DEBUG 级别：
```
=== ResourceManager 初始化开始 ===
正在加载技能数据...
[DEBUG]   ✓ 加载技能: attack (†東亞重工 攻击！)
[DEBUG]   ✓ 加载技能: skill_1 (音速指)
...
技能加载完成，共 5 个技能
[DEBUG] 创建角色: 艾露比 (p1)
[DEBUG] P1 HP: 430, P2 HP: 410
[DEBUG] 🎮 等待玩家操作...
```

## 在代码中使用

如果你要添加新的调试信息：

```gdscript
# 错误信息（总是显示）
DebugConfig.log_error("严重错误发生！", "your_module")

# 警告信息
DebugConfig.log_warning("这可能有问题", "your_module")

# 一般信息
DebugConfig.log_info("游戏开始", "your_module")

# 调试信息
DebugConfig.log_debug("变量 x = 10", "your_module")

# 详细信息
DebugConfig.log_verbose("每帧都会输出的信息", "your_module")
```
