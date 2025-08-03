extends Button
class_name LevelSelectButton

var level_path : String

func _on_button_down():
	SceneManager.goto_scene(level_path)
