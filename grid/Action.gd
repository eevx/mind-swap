class_name MoveAction

var actor_data: GameObjectData
var from_pos: Vector2i
var to_pos: Vector2i

func _init(actor, from, to):
	actor_data = actor
	from_pos = from
	to_pos = to

func validate() -> bool:
	# e.g., check if destination is empty or allowed
	return true

func execute() -> void:
	# remove from old cell
	GridManager.remove_object(from_pos, func(o): return o == actor_data)
	# place in new
	GridManager.place_object(to_pos, actor_data)
	# optionally update visual
	if actor_data.instance:
		actor_data.instance.position = GridManager.grid_to_world(to_pos)
