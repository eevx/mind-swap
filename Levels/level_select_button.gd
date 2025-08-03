extends Button
class_name LevelSelectButton

var level_path : String

func _on_button_down():
	if not level_path.is_empty():
		SceneManager.goto_scene(level_path)
