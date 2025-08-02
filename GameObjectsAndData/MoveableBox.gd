extends BaseGameObject
class_name MoveableBox

@export var object_data : MoveableObjectData

func register():
	object_data = object_data.duplicate()
	object_data.ref_to_node = self
	var world_pos = global_position
	GridManager.place_object_world(world_pos, object_data)
