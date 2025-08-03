extends Resource
class_name CellData

enum cell_type {WALK, WALL, DANGER}

var type : cell_type = cell_type.DANGER
var occupant : GameObjectData = null

func set_type(t: cell_type):
	type = t

func get_type():
	return type

func get_occupant() -> GameObjectData:
	return occupant

func add_occupant(obj: GameObjectData) -> void:
	if not obj:
		return
	#if occupant:
		#push_warning("cell occupant: ", occupant.ref_to_node, " removed by new occupant: ", obj.ref_to_node)
	occupant = obj

func remove_occupant() -> void:
	if occupant:
		occupant = null
