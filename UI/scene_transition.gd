extends Node2D
class_name SceneTransition

signal transition_finished
@export var canvas_layer : CanvasItem
@export var fade_time := 0.5
var fade_tween : Tween

func fade_out():
	set_shader_parameter(0)
	canvas_layer.material.set_shader_parameter("reverse", 0)
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_method(set_shader_parameter, 0., 1., fade_time).set_ease(Tween.EASE_IN)
	fade_tween.tween_callback(func():
		transition_finished.emit())
	pass

func fade_in():
	set_shader_parameter(1)
	canvas_layer.material.set_shader_parameter("reverse", 1)
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_method(set_shader_parameter, 1., 0., fade_time).set_ease(Tween.EASE_OUT)
	fade_tween.tween_callback(func():
		transition_finished.emit()
		queue_free())

func set_shader_parameter(value : float):
	if not canvas_layer:
		return
	canvas_layer.material.set_shader_parameter("progress", value)
