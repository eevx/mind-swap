extends TileMapLayer

var _beat_pos : bool = false
var _flash_cells: Dictionary = {} # set in register_tiles
var _enemy_world_positions: Array = [] # updated each frame
var beat_strength: float = 0.0

# tuning
const MIN_DIST := 0.5        # tiles (closest clamp)
const MAX_DIST := 4.0        # tiles (farthest clamp)
const MAX_INCREASE := 0.6    # max brightness increase (e.g. 0.6 => up to 1.6x)
const BEAT_DECAY := 2.0      # how quickly beat_strength decays (higher => faster)
const NOTIFY_EPS := 0.005    # small epsilon to avoid excessive notify calls

func _ready():
	register_tiles()
	MusicManager.beat.connect(flash_tiles_on_beat)
	set_process(true)

func _process(delta: float) -> void:
	if beat_strength > 0.0:
		beat_strength = max(0.0, beat_strength - BEAT_DECAY * delta)
		if beat_strength > NOTIFY_EPS:
			notify_runtime_tile_data_update()

func _update_enemy_positions() -> void:
	_enemy_world_positions.clear()
	for enemy in GridManager.get_sorted_characters():
		var grid_pos = GridManager.get_object_grid_pos(enemy)
		if grid_pos == null:
			continue
		_enemy_world_positions.append(GridManager.grid_to_world(grid_pos))

func register_tiles():
	for tile_pos in get_used_cells():
		var tile_data : TileData = get_cell_tile_data(tile_pos)
		if tile_data:
			var custom_data = tile_data.get_custom_data("CellType")
			var cell_type : CellData.cell_type
			match custom_data:
				0:
					cell_type = CellData.cell_type.WALK
					_flash_cells[tile_pos] = true
				1:
					cell_type = CellData.cell_type.WALL
				2:
					cell_type = CellData.cell_type.DANGER
				_:
					continue
			var world_pos = to_global(map_to_local(tile_pos))
			var cell = GridManager.get_cell_data_world(world_pos)
			cell.set_type(cell_type)

# Godot 4.x / 4.5: engine callbacks include layer param
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return _flash_cells.has(coords)

# smoother per-tile calculation using precomputed enemy positions & beat_strength
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:

	#var base_checker := ((coords.x + coords.y) % 2) == 0

	#var checker_effect := base_checker if _beat_pos else (not base_checker)
	
	var checker_effect = _beat_pos #no checker effect 

	var tile_world_pos = to_global(map_to_local(coords))
	var dist_tiles: float = INF
	#for e_world in _enemy_world_positions:
		#var d = e_world.distance_to(tile_world_pos) / float(GlobalVariables.GRID_CELL_SIZE.x)
		#if d < dist_tiles:
			#dist_tiles = d
#
	#if dist_tiles == INF:
		#dist_tiles = MAX_DIST
	
	dist_tiles = tile_world_pos.distance_to(Vector2.ONE * float(GlobalVariables.GRID_CELL_SIZE.x) * 0.5) / float(GlobalVariables.GRID_CELL_SIZE.x)
	dist_tiles = clamp(dist_tiles, MIN_DIST, MAX_DIST)
	var proximity :float = clamp((MAX_DIST - dist_tiles) / (MAX_DIST - MIN_DIST), 0.0, 1.0)

	var combined := proximity * beat_strength

	#var checker_multiplier = 1.0 if checker_effect else 0.6
	
	#var brightness : float = 0.8 + MAX_INCREASE * combined * checker_multiplier
	var brightness : float = 0.8 + MAX_INCREASE * combined #correlate with current volume only
	brightness = max(0.0, brightness)
	
	tile_data.modulate = Color(brightness, brightness, brightness, 1.0)
	tile_data.texture_origin = Vector2.ZERO + Vector2.UP * (beat_strength * 2.)

func flash_tiles_on_beat():
	_update_enemy_positions()
	_beat_pos = !_beat_pos
	var volume : float = MusicManager.get_current_loudness()
	beat_strength = 0.5 + 30. * volume
	notify_runtime_tile_data_update()
