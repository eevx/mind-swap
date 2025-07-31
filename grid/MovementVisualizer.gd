extends Node2D

@export var highlight_tile_id: int = 1  # assign in TileSet
@export var selected_unit: Node2D = null  # visual node with GameObjectData
@onready var grid_tm: TileMap = $GridTileMap
@onready var highlight_tm: TileMap = $HighlightMap

func _ready():
	highlight_tm.clear()
	# optionally connect selection signals

func update_reachable():
	highlight_tm.clear()
	if not selected_unit:
		return
	# Assume unit has data_resource and knows its grid_pos
	var data: GameObjectData = selected_unit.data_resource
	var current_grid = selected_unit.grid_pos
	# Determine movement type and budget from its custom properties or type
	var movement_type = MoveActionTypes.MovementType.WALK
	var budget = 3
	if data.custom.has("movement_type"):
		movement_type = data.custom["movement_type"]
	if data.custom.has("movement_budget"):
		budget = data.custom["movement_budget"]

	var reachable = MoveActionTypes.get_reachable_tiles(current_grid, movement_type, budget)
	for tile in reachable:
		highlight_tm.set_cellv(tile, highlight_tile_id)

func _process(_delta):
	# for demo: update every frame; in a real game you’d call when selection or state changes
	update_reachable()
