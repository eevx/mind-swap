extends Node2D
class_name BaseGameObject

var _animation_queue: Array = []
var _is_playing := false

# Name → Callable function taking (Array args)
var _animation_library := {}

func _ready():
	z_index = 1
	register()
	register_animations()

## register this object to GridManager
func register():
	pass

func register_animations():
	_animation_library = {}

func queue_animation(animation_name: String, args: Array = [], override_current := false):
	var anim_data = { "name": animation_name, "args": args }
	if override_current:
		_animation_queue.clear()
		if _is_playing:
			_animation_queue.push_front(anim_data)
			return  # current will continue and be overridden next
		_play_animation(anim_data)
	else:
		_animation_queue.append(anim_data)
		if not _is_playing:
			_play_next()

func _play_next():
	if _animation_queue.is_empty():
		_is_playing = false
		return
	var next = _animation_queue.pop_front()
	_play_animation(next)

func _play_animation(anim_data: Dictionary):
	var name = anim_data.name
	var args = anim_data.args
	var callable = _animation_library.get(name)
	if callable:
		_is_playing = true
		callable.call(args)
	else:
		push_warning("Unknown animation: %s" % name)
		_play_next()

func animation_done():
	_is_playing = false
	_play_next()
