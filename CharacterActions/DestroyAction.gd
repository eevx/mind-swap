extends Action
class_name DestroyAction

var object_data : GameObjectData
var pos : Vector2i

func _init(data: GameObjectData, p: Vector2i):
	self.object_data = data
	self.pos = p

func execute(): 
	GridManager.remove_object(pos)
	update_visual(false)
	return true

func update_visual(show_value: bool):
	if object_data.ref_to_node:
		object_data.ref_to_node.visible = show_value

func debug_action():
	#TODO
	return ["destroy_action", object_data.ref_to_node, pos]

func undo():
	GridManager.place_object(pos, object_data)
	update_visual(true)
