# DiceRoller.gd
# 通用骰子掷骰工具类，支持 d20、优势/劣势、任意面数骰等
class_name DiceRoller

static func roll_dice(sides: int = 20, count: int = 1) -> int:
	# 掷 count 个 sides 面骰子，返回总和（例如：2d6）
	var total = 0
	for i in count:
		total += randi() % sides + 1
	return total

static func roll_d20() -> int:
	# 返回 1d20
	return roll_dice(20)

static func roll_d20_advantage(advantage: int = 0) -> int:
	# 优势/劣势掷骰
	# advantage = 0 正常, 1 有优势（取高值）, -1 有劣势（取低值）
	var r1 = roll_d20()
	var r2 = roll_d20()
	if advantage > 0:
		return max(r1, r2)
	elif advantage < 0:
		return min(r1, r2)
	else:
		return r1

static func roll_with_detail(sides: int = 20, count: int = 1) -> Array:
	# 返回每一次掷骰结果组成的数组（用于显示或日志）
	var rolls = []
	for i in count:
		rolls.append(randi() % sides + 1)
	return rolls

static func roll_dice_string(sides: int, count: int) -> String:
	var rolls = roll_with_detail(sides, count)
	var total = 0
	for r in rolls:
		total += r
	return "%dd%d=%d (%s)" % [count, sides, total, ", ".join(rolls.map(str))]
