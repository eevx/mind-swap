extends Button

@export var level_scene_path : String

func _ready():
	if name.is_valid_int():
		text = "LVL " + name

func _on_button_down():
	if not level_scene_path.is_empty():
		SceneManager.goto_scene(level_scene_path)
