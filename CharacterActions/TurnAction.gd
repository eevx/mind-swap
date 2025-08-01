extends Action
class_name TurnAction

var character_data: CharacterObjectData
var from_pos: Vector2i
var to_pos: Vector2i

## initialize as character_data, from (vector2i), to (vector2i)
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
	character_data.current_dir = to_pos
	# optionally update visual
	update_visual(to_pos)

func update_visual(pos):
	if character_data.ref_to_node:
		pass

func undo():
	pass
