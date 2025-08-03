extends GridContainer

func _ready():
	var i := 0
	for child in get_children():
		if child is LevelSelectButton:
			child.label_text = str(i+1)
			if i < LevelArray.levels.size():
				child.level_path = LevelArray.levels[i]
			else:
				child.disabled = true
		i += 1
