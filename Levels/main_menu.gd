extends Node2D

@export var level_select_scene : String

func _on_button_button_down():
	SceneManager.goto_scene(level_select_scene)
