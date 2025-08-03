extends Action
class_name DropAction

var object_data : GameObjectData
var pos : Vector2i

func _init(data: MoveableObjectData, p: Vector2i):
	self.object_data = data
	self.pos = p

func execute(): 
	GridManager.remove_object(pos)
	GridManager.get_cell_data(pos).set_type(CellData.cell_type.WALK)
	update_visual(true)
	return true

func update_visual(show_value: bool):
	if object_data.ref_to_node:
		if object_data.ref_to_node.has_method("queue_animation"):
			object_data.ref_to_node.queue_animation("drop", [show_value])

	#if object_data.ref_to_node:
		#object_data.ref_to_node.visible = show_value

func debug_action():
	return ["drop_action", object_data.ref_to_node, pos]

func undo():
	GridManager.place_object(pos, object_data)
	update_visual(false)
