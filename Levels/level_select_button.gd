extends Button
class_name LevelSelectButton

var level_path : String
var label_text : String
@export var left_texture : Texture2D
@export var done_texture : Texture2D
@export var label : Label

func _ready():
	await get_parent().ready
	icon = left_texture
	label.text = label_text

func _on_button_down():
	if not level_path.is_empty():
		SceneManager.goto_scene(level_path)
