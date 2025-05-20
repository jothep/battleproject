class_name ActionOrderResolver

static func determine_order(p1: Character, p2: Character) -> String:
	# 10% 概率触发相打
	if randf() < 0.1:
		return "simultaneous"

	var agi1 = p1.attributes.get_agility()
	var agi2 = p2.attributes.get_agility()
	var total = agi1 + agi2

	# 避免除0
	if total == 0:
		if randf() < 0.5:
			return "p1_first"
		else:
			return "p2_first"

	# 权重随机
	var roll = randi() % total
	return "p1_first" if roll < agi1 else "p2_first"
