extends Node

@export var chunk_size: Vector2i = Vector2i(16, 16)
@export var cell_world_size: Vector2 = Vector2(64, 64)  # for view snapping

# chunk key -> (cell key -> CellData)
var chunks: Dictionary = {}

# Signals
signal object_placed(grid_pos: Vector2i, object_data: GameObjectData)
signal object_removed(grid_pos: Vector2i, object_data: GameObjectData)

# Helpers
func _chunk_coord(grid_pos: Vector2i) -> Vector2i:
	return Vector2i(floor(grid_pos.x / chunk_size.x), floor(grid_pos.y / chunk_size.y))

func _chunk_key(chunk_coord: Vector2i) -> String:
	return str(chunk_coord.x) + "," + str(chunk_coord.y)

func _cell_key(grid_pos: Vector2i) -> String:
	return str(grid_pos.x) + "," + str(grid_pos.y)

func _ensure_chunk(chunk_coord: Vector2i) -> Dictionary:
	var ck = _chunk_key(chunk_coord)
	if not chunks.has(ck):
		chunks[ck] = {}
	return chunks[ck]

# Access cell, optional creation
func get_cell_data(grid_pos: Vector2i, create_if_missing: bool = true) -> CellData:
	var chunk_coord = _chunk_coord(grid_pos)
	var chunk = _ensure_chunk(chunk_coord)
	var cellk = _cell_key(grid_pos)
	if not chunk.has(cellk):
		if create_if_missing:
			var cd = CellData.new()
			chunk[cellk] = cd
		else:
			return null
	return chunk[cellk]

func place_object(grid_pos: Vector2i, obj_data: GameObjectData) -> void:
	var cell = get_cell_data(grid_pos)
	cell.add_occupant(obj_data)
	emit_signal("object_placed", grid_pos, obj_data)

func remove_object(grid_pos: Vector2i, filter_func: Callable) -> void:
	var cell = get_cell_data(grid_pos, false)
	if not cell:
		return
	var removed := []
	for occ in cell.find_occupants(filter_func):
		removed.append(occ)
	for occ in removed:
		cell.remove_occupant(func(o): return o == occ)
		emit_signal("object_removed", grid_pos, occ)

# Querying a rect region
func iterate_region(min_pos: Vector2i, max_pos: Vector2i) -> Array:
	var results := []
	for x in range(int(min_pos.x) , int(max_pos.x) + 1):
		for y in range(int(min_pos.y) , int(max_pos.y) + 1):
			var cell = get_cell_data(Vector2i(x, y), false)
			if cell and cell.occupants.size() > 0:
				results.append({"pos": Vector2i(x, y), "cell": cell})
	return results

# Coordinate conversion for visuals
func grid_to_world(grid_pos: Vector2i, center: bool = true) -> Vector2:
	var world = Vector2(grid_pos.x * cell_world_size.x, grid_pos.y * cell_world_size.y)
	if center:
		world += cell_world_size * 0.5
	return world

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(floor(world_pos.x / cell_world_size.x), floor(world_pos.y / cell_world_size.y))
