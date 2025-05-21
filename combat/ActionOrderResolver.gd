class_name ActionOrderResolver



static func determine_order(p1: Character, p2: Character) -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	# 10% 概率触发相打
	if rng.randf() < 0.1:
		return "simultaneous"

	var agi1 = p1.attributes.get_agility()
	var agi2 = p2.attributes.get_agility()
	var total = agi1 + agi2

	# 避免除0
	if total == 0:
		return "p1_first" if rng.randf() < 0.5 else "p2_first"

	# 敏捷比例决定先后手
	var roll = rng.randi_range(0, total - 1)
	return "p1_first" if roll < agi1 else "p2_first"
