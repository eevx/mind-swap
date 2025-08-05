extends Camera2D

@export var offset_amount := 10.

var _init_transform : Transform2D
var shake_tween : Tween

func _ready() -> void:
	_init_transform = transform

func camera_shake(time := 0.5, strength := 0.5):
	strength = clamp(strength, 0 , 1.)
	if shake_tween:
		shake_tween.kill()
	
	var shake = func(s: float):
		set_offset(Vector2(randf_range(-1, 1), randf_range(-1, 1,)).normalized() * s * offset_amount)
	
	shake_tween = create_tween()
	shake_tween.tween_method(shake, strength, 0., time).set_ease(Tween.EASE_OUT)
