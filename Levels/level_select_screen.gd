extends GridContainer

func _ready():
	var i := 0
	for child in get_children():
		if child is LevelSelectButton:
			child.text = "LVL " + str(i+1)
			child.pat
