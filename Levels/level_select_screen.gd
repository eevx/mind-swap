extends GridContainer

func _ready():
	var i := 0
	for child in get_children():
		if child is LevelSelectButton:
			child.text = "LVL " + str(i+1)
			if i < LevelArray.levels.size():
				child.level_path = LevelArray.levels[i]
		i += 1
