extends TileMapLayer

func _ready():
	register_tiles()

func register_tiles():
	for tile_pos in get_used_cells():
		var tile_data : TileData = get_cell_tile_data(tile_pos)
		if tile_data:
			var custom_data = tile_data.get_custom_data("CellType")
			var cell_type : CellData.cell_type #cell_type can be 0, 1, 2, ...
			match custom_data:
				0:
					cell_type = CellData.cell_type.WALK
				1: 
					cell_type = CellData.cell_type.WALL
				2:
					cell_type = CellData.cell_type.DANGER
				_:
					continue
			var world_pos = to_global(map_to_local(tile_pos))
			var cell = GridManager.get_cell_data_world(world_pos)
			cell.set_type(cell_type)
