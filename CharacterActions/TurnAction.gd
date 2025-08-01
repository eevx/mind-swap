extends Action
class_name TurnAction

var character_data: CharacterObjectData
var from_dir: Vector2i
var to_dir: Vector2i

## initialize as character_data, from (vector2i), to (vector2i)
func _init(data: CharacterObjectData, from: Vector2i, to: Vector2i):
	character_data = data
	from_dir = from
	to_dir = to

func debug_action():
	return ["turn", character_data.ref_to_node, from_dir, to_dir]

func execute():
	character_data.current_dir = to_dir

	update_visual(to_dir)
	return true

func update_visual(dir : Vector2i):
	SfxManager.play_sfx("push")
	if character_data.ref_to_node:
		#TODO
		character_data.ref_to_node.rotation = Vector2(dir).angle() + PI/2
		pass

func undo():
	character_data.current_dir = from_dir
	update_visual(from_dir)
