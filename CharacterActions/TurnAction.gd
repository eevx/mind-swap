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

	update_visual(from_dir, to_dir)
	return true

func update_visual(from: Vector2i, to : Vector2i):
	if character_data.ref_to_node:
		if character_data.ref_to_node.has_method("queue_animation"):
			character_data.ref_to_node.queue_animation("turn", [from, to])
			SfxManager.play_sfx("click", 2.)
	#if character_data.ref_to_node:
		#character_data.ref_to_node.rotation = Vector2(to).angle() + PI/2
		#pass

func undo():
	character_data.current_dir = from_dir
	update_visual(to_dir, from_dir)
