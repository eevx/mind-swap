extends Action
class_name ShootAction

var character_data: CharacterObjectData
var pos : Vector2i
var final_pos : Vector2i

## initialize as character_data, from (vector2i), to (vector2i)
func _init(data: CharacterObjectData, p: Vector2i):
	self.character_data = data
	self.pos = p

func debug_action():
	return ["shoot", character_data.ref_to_node, pos]

func execute():
	var extent := 30
	for i in range(extent):
		var cell_pos : Vector2i = pos + character_data.current_dir * (1 + i)
		var cell_data : CellData = GridManager.get_cell_data(cell_pos)
		final_pos = cell_pos
		if cell_data.get_type() == cell_data.cell_type.WALL:
			break
		elif cell_data.get_occupant() is MoveableObjectData:
			break
		elif cell_data.get_occupant() is CharacterObjectData:
			var c = cell_data.get_occupant()
			var action : Action = DestroyAction.new(c, cell_pos)
			TurnManager.execute_action(action)
			break
	update_visual(pos, final_pos)
	return true

func update_visual(from: Vector2i, to : Vector2i):
	if character_data.ref_to_node:
		if character_data.ref_to_node.has_method("queue_animation"):
			character_data.ref_to_node.queue_animation("shoot", [from, to])
	pass

func undo():
	update_visual(pos, final_pos)
