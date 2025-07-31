extends Resource
class_name CellData

@export var metadata: Dictionary = {}  # e.g., terrain type, cover, etc.
@export var occupants: Array = []  # GameObjectData instances

func add_occupant(obj: GameObjectData) -> void:
	if not obj:
		return
	occupants.append(obj)

func remove_occupant(filter_func: Callable) -> void:
	for i in range(occupants.size() - 1, -1, -1):
		if filter_func.call(occupants[i]):
			occupants.remove_at(i)

func find_occupants(filter_func: Callable) -> Array:
	var result := []
	for occ in occupants:
		if filter_func.call(occ):
			result.append(occ)
	return result
