extends Node2D
class_name ShootBurst

var start_pos := Vector2.ZERO
var end_pos := Vector2.ZERO
var time := 0.2

@export var line_texture : Line2D
@export var particles : CPUParticles2D

func _ready():
	line_texture.set_point_position(0, to_local(start_pos))
	line_texture.set_point_position(1, to_local(end_pos))
	particles.direction = line_texture.get_point_position(1).direction_to(line_texture.get_point_position(0))
	particles.global_position = end_pos
	particles.emitting = true	
	line_texture.width = 10

	var tween = create_tween()
	tween.tween_property(line_texture, "width", 75, time/2.).set_ease(Tween.EASE_OUT)
	tween.tween_property(line_texture, "width", 0, time/2.).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		await get_tree().create_timer(1.).timeout
		queue_free())
