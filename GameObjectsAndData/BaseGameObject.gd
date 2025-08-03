extends Node2D
class_name BaseGameObject

var _animation_queue: Array = []
var _is_playing := false

# Name → Callable function taking (Array args)
var _animation_library := {}

func _ready():
	register()

## register this object to GridManager
func register():
	pass

func register_animations():
	_animation_library = {}
