extends Node

var chunk_size: Vector2i = Vector2i(2, 2)
var cell_world_size: Vector2

# chunk key -> (cell key -> CellData)
var chunks: Dictionary = {}
var object_positions: Dictionary = {} # GameObjectData -> Vector2i

# Signals
signal object_placed(grid_pos: Vector2i, object_data: GameObjectData)
signal object_removed(grid_pos: Vector2i, object_data: GameObjectData)

func _ready():
	cell_world_size = GlobalVariables.GRID_CELL_SIZE
	await get_tree().process_frame
	for character_data in get_sorted_characters():
		print(character_data.turn_order)

func _process(_delta):
	if Input.is_action_just_pressed("left_click"):
		var pos = world_to_grid(get_tree().current_scene.get_global_mouse_position())
		print(get_cell_data(pos).cell_type.find_key(get_cell_data(pos).get_type()))
		if get_cell_data(pos).get_occupant():
			print(get_cell_data(pos).get_occupant().ref_to_node)
	if Input.is_action_just_pressed("ui_right"):
		TurnManager.start_new_turn()
		TurnManager.advance_turn()
	if Input.is_action_just_pressed("ui_left"):
		ActionHistory.undo_last_action()
	if Input.is_action_just_pressed("ui_down"):
		for c in get_sorted_characters():
			var visualizer_scene = preload("res://CharacterActions/command_visualizer.tscn").instantiate()
			visualizer_scene.ref_to_data = c
			get_tree().root.add_child(visualizer_scene)
			visualizer_scene.global_position = grid_to_world(get_object_grid_pos(c)) + Vector2.UP * 10

# Helpers
func debug_print_all_cells() -> void:
	for chunk_key in chunks.keys():
		var chunk = chunks[chunk_key]
		for cell_key in chunk.keys():
			var cell_data: CellData = chunk[cell_key]
			var parts = cell_key.split(",")
			var grid_pos = Vector2i(parts[0].to_int(), parts[1].to_int())
			if cell_data:
				print("Grid Pos:", grid_pos, "| Data:", cell_data.get_type(), " ", type_string(typeof(cell_data.get_occupant())))

func get_sorted_characters() -> Array[CharacterObjectData]:
	var characters: Array[CharacterObjectData] = []

	# Gather all CharacterObjectData occupants from all cells
	for chunk_key in chunks.keys():
		var chunk = chunks[chunk_key]
		for cell_key in chunk.keys():
			var cell_data: CellData = chunk[cell_key]
			if cell_data and cell_data.get_occupant() is CharacterObjectData:
				characters.append(cell_data.get_occupant())

	# Sort by turn_order
	characters.sort_custom(func(a: CharacterObjectData, b: CharacterObjectData) -> bool:
		return a.turn_order < b.turn_order
	)

	# Check for duplicate turn_order values
	var seen = {}
	for i in range(characters.size()):
		var character = characters[i]
		if seen.has(character.turn_order):
			push_error("Duplicate turn_order value detected: ", character.turn_order)
			return []
		seen[character.turn_order] = true

	return characters


func clear_chunks() -> void:
	chunks.clear()

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

func get_cell_data_world(world_pos: Vector2, create_if_missing: bool = true) -> CellData:
	var grid_pos = world_to_grid(world_pos)
	return get_cell_data(grid_pos, create_if_missing)

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

func place_object_world(world_pos: Vector2, obj_data: GameObjectData) -> void:
	var grid_pos = world_to_grid(world_pos)
	place_object(grid_pos, obj_data)

func place_object(grid_pos: Vector2i, obj_data: GameObjectData) -> void:
	var cell = get_cell_data(grid_pos)
	cell.add_occupant(obj_data)
	object_positions[obj_data] = grid_pos
	object_placed.emit(grid_pos, obj_data)

func remove_object_world(world_pos: Vector2) -> void:
	var grid_pos = world_to_grid(world_pos)
	remove_object(grid_pos)

func remove_object(grid_pos: Vector2i, expected_obj: GameObjectData = null) -> void:
	var cell = get_cell_data(grid_pos, false)
	if not cell:
		return
	var obj = cell.get_occupant()
	if not obj:
		return
	
	if expected_obj and obj != expected_obj:
		# Do not remove the wrong object
		return

	cell.remove_occupant()
	object_positions.erase(obj)
	object_removed.emit(grid_pos, obj)


func get_object_grid_pos(object_data : GameObjectData):
	if object_positions.has(object_data):
		return object_positions[object_data]
	else:
		return null

# Returns a list of dictionaries: {pos: Vector2i, cell: CellData}
func iterate_region(min_pos: Vector2i, max_pos: Vector2i) -> Array: 
	var results := []
	for x in range(int(min_pos.x), int(max_pos.x) + 1):
		for y in range(int(min_pos.y), int(max_pos.y) + 1):
			var cell = get_cell_data(Vector2i(x, y), false)
			if cell and cell.get_occupant():
				results.append({"pos": Vector2i(x, y), "cell": cell})
	return results

# Coordinate conversion
func grid_to_world(grid_pos: Vector2i, center: bool = true) -> Vector2:
	var world = Vector2(grid_pos.x * cell_world_size.x, grid_pos.y * cell_world_size.y)
	if center:
		world += cell_world_size * 0.5
	return world

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(floor(world_pos.x / cell_world_size.x), floor(world_pos.y / cell_world_size.y))
