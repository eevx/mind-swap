extends Action
class_name PushAction

var object_data : MoveableObjectData
var from_pos : Vector2i
var to_pos : Vector2i

## initialize as object_data, from (vector2i), to (vector2i)
func _init(data: MoveableObjectData, from: Vector2i, to: Vector2i):
	self.object_data = data
	self.from_pos = from
	self.to_pos = to

func debug_action():
	return ["push", object_data.ref_to_node, from_pos, to_pos]

func try_push():
	var dir : Vector2i = to_pos - from_pos
	var cell_data : CellData = GridManager.get_cell_data(to_pos)
	if cell_data.get_occupant() is CharacterObjectData or cell_data.get_type() == cell_data.cell_type.WALL:
		return false
	elif cell_data.get_occupant() is MoveableObjectData:
		var action : Action = PushAction.new(cell_data.get_occupant(), to_pos, to_pos + dir)
		var action_success = TurnManager.execute_action(action)
		return action_success
	else:
		return true

func execute():
	if not try_push():
		return false
	GridManager.remove_object(from_pos)
	GridManager.place_object(to_pos, object_data)
	
	update_visual(from_pos, to_pos)
	apply_cell_effect(to_pos)
	return true

func apply_cell_effect(pos):
	var cell_data : CellData = GridManager.get_cell_data(pos)
	var action : Action
	if cell_data:
		if cell_data.get_type() == cell_data.cell_type.DANGER:
			action = DropAction.new(object_data, pos)
	if action:
		TurnManager.execute_action(action)

func update_visual(from: Vector2i, to: Vector2i):
	if object_data.ref_to_node:
		if object_data.ref_to_node.has_method("queue_animation"):
			object_data.ref_to_node.queue_animation("push", [from, to])
			SfxManager.play_sfx("death", -20.)

func undo():
	GridManager.remove_object(to_pos, object_data)
	GridManager.place_object(from_pos, object_data)
	update_visual(to_pos, from_pos)
