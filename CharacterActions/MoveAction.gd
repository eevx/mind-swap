extends Action
class_name MoveAction

var character_data: CharacterObjectData
var from_pos: Vector2i
var to_pos: Vector2i

## initialize as character_data, from (in grid_pos), to (in grid_pos)
func _init(data: CharacterObjectData, from: Vector2i, to: Vector2i):
	self.character_data = data
	self.from_pos = from
	self.to_pos = to

func debug_action():
	return ["move_forward", character_data.ref_to_node, from_pos, to_pos]

func validate():
	var cell_data = GridManager.get_cell_data(to_pos, false)
	if cell_data:
		if cell_data.get_type() == CellData.cell_type.WALL:
			return false
		elif cell_data.get_occupant() is CharacterObjectData:
			return false
		elif cell_data.get_occupant() is MoveableObjectData:
			var action : Action = PushAction.new(cell_data.get_occupant(), to_pos, to_pos + (to_pos - from_pos))
			var action_success = TurnManager.execute_action(action)
			return action_success
	return true

func execute():
	if not validate():
		return false
	GridManager.remove_object(from_pos)
	GridManager.place_object(to_pos, character_data)
	
	update_visual(to_pos)
	apply_cell_effect(to_pos)
	return true

func apply_cell_effect(pos):
	var cell_data : CellData = GridManager.get_cell_data(pos)
	var action : Action
	if cell_data:
		if cell_data.get_type() == cell_data.cell_type.DANGER:
			action = DestroyAction.new(character_data, pos)
	if action:
		TurnManager.execute_action(action)

func update_visual(pos:Vector2i):
	#TODO
	if character_data.ref_to_node:
		character_data.ref_to_node.global_position = GridManager.grid_to_world(pos)

func undo():
	GridManager.remove_object(to_pos, character_data)
	GridManager.place_object(from_pos, character_data)
	update_visual(from_pos)
