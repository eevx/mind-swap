extends Node

var data : GameObjectData
var pos : Vector2i

func _init(data: GameObjectData, pos: Vector2i):
	self.data = data
	self.pos = pos

func execute(): 
	GridManager.remove_object(pos)
	update_visual(false)
	return true

func update_visual(show_value: bool):
	if data.ref_to_node:
		data.ref_to_node.visible = show_value

func debug_action():
	return ["destroy_action", data.ref_to_node, pos]

func undo():
	GridManager.place_object(pos, data)
	update_visual(true)
