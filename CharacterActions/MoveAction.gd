extends Action
class_name MoveAction

var character_data: CharacterObjectData
var from_pos: Vector2i
var to_pos: Vector2i

## initialize as character_data, from (in grid_pos), to (in grid_pos)
func _init(data, from, to):
	character_data = data
	from_pos = from
	to_pos = to

func validate() -> bool:
	# e.g., check if destination is empty or allowed
	return true

func execute() -> void:
	# remove from old cell
	if not validate():
		return
	GridManager.remove_object(from_pos)
	# place in new
	GridManager.place_object(to_pos, character_data)
	# optionally update visual
	update_visual(to_pos)

func update_visual(pos):
	if character_data.ref_to_node:
		character_data.ref_to_node.global_position = GridManager.grid_to_world(pos)

func undo():
	# Remove from the destination cell (where it was moved to)
	GridManager.remove_object(to_pos)
	# Place back into the original cell
	GridManager.place_object(from_pos, character_data)
	# Update visuals to reflect the rollback
	update_visual(from_pos)
