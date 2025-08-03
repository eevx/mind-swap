extends BaseGameObject
class_name MoveableBox

@export var object_data : MoveableObjectData
var animation_tween : Tween

func register():
	object_data = object_data.duplicate()
	object_data.ref_to_node = self
	var world_pos = global_position
	GridManager.place_object_world(world_pos, object_data)

func register_animations():
	_animation_library = {
		"push": func(args): _push_animation(args[0], args[1]),
		"death": func(args): _death_animation(args[0])
	}

func _push_animation(from: Vector2i, to: Vector2i):
	if animation_tween:
		animation_tween.kill()
	
	var from_pos = GridManager.grid_to_world(from)
	var to_pos = GridManager.grid_to_world(to)
	
	global_position = from_pos
	animation_tween = create_tween()
	animation_tween.tween_property(self, "global_position", to_pos, GlobalVariables.ANIMATION_TIME_STEP)
	animation_tween.tween_callback(func(): animation_done())

func _death_animation(is_show: bool):
	if animation_tween:
		animation_tween.kill()
	
	visible = is_show
	animation_done()
