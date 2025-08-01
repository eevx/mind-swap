extends BaseGameObject
class_name MoveableBox

@export var object_data : MoveableObjectData

func register():
	object_data.ref_to_node = self
	var world_pos = global_position
	GridManager.place_object_world(world_pos, object_data)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		print(GridManager.get_object_grid_pos(object_data))
