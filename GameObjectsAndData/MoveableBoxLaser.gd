extends MoveableBox
class_name MoveableBoxLaser

enum laser_type {VERTICAL, HORIZONTAL}

@export var laser_direction : laser_type

@export var vertical_sprite : Sprite2D
@export var horizontal_sprite : Sprite2D

@export var laser_1 : LaserLine
@export var laser_2 : LaserLine

var dropped := false

func _ready():
	super()
	TurnManager.turn_ended.connect(_laser_effect)
	if laser_direction == laser_type.VERTICAL:
		horizontal_sprite.hide()
	else:
		vertical_sprite.hide()

func _process(_delta):
	_show_laser()

func _show_laser():
	if not object_data:
		return
	
	if dropped:
		laser_1.hide()
		laser_2.hide()
		return
	else:
		laser_1.show()
		laser_2.show()
	
	var pos = GridManager.world_to_grid(global_position)
	
	#var pos = GridManager.get_object_grid_pos(object_data)
	#var further_check := true
	#if GridManager.get_cell_data_world(global_position).get_occupant():
		#further_check = GridManager.get_cell_data_world(global_position).get_occupant().ref_to_node == self
	#if not pos and not further_check:
		#laser_1.hide()
		#laser_2.hide()
		#return
	#else:
		#laser_1.show()
		#laser_2.show()

	var max_extent := 40
	var directions := []
	match laser_direction:
		laser_type.VERTICAL: directions = [Vector2i.UP, Vector2i.DOWN]
		laser_type.HORIZONTAL: directions = [Vector2i.LEFT, Vector2i.RIGHT]
		_: directions = []
	
	var ends : Array[int] = []

	for dir in directions:
		for i in range(1, max_extent + 1):
			if i == max_extent:
				ends.push_back(i)
				break
			var cell_pos = pos + dir * i
			var cell_data : CellData = GridManager.get_cell_data(cell_pos)
			var occupant = cell_data.get_occupant()
			if occupant is MoveableObjectData or cell_data.get_type() == cell_data.cell_type.WALL:
				ends.push_back(i)
				break
				
	if ends.size() == 2:
		laser_1.set_point_position(1, GridManager.grid_to_world(pos + directions[0] * ends[0]))
		laser_2.set_point_position(1, GridManager.grid_to_world(pos + directions[1] * ends[1]))
	
	if laser_direction == laser_type.VERTICAL:
		laser_1.set_point_position(1, Vector2(laser_1.get_point_position(0).x, laser_1.get_point_position(1).y) - directions[0] * GlobalVariables.GRID_CELL_SIZE.y * 1.)
		laser_2.set_point_position(1, Vector2(laser_2.get_point_position(0).x, laser_2.get_point_position(1).y))
	else:
		laser_1.set_point_position(1, Vector2(laser_1.get_point_position(1).x, laser_1.get_point_position(0).y))
		laser_2.set_point_position(1, Vector2(laser_2.get_point_position(1).x, laser_2.get_point_position(0).y) - directions[1] * GlobalVariables.GRID_CELL_SIZE.x * 1.)

func _laser_effect():
	if not object_data:
		return
	
	if dropped:
		return
	
	var pos = GridManager.world_to_grid(global_position)
	
	#var pos = GridManager.get_object_grid_pos(object_data)
	#var further_check := true
	#if GridManager.get_cell_data_world(global_position).get_occupant():
		#further_check = GridManager.get_cell_data_world(global_position).get_occupant().ref_to_node == self
	#if not pos and not further_check:
		#return

	var max_extent := 40
	var directions := []
	match laser_direction:
		laser_type.VERTICAL: directions = [Vector2i.UP, Vector2i.DOWN]
		laser_type.HORIZONTAL: directions = [Vector2i.LEFT, Vector2i.RIGHT]
		_: directions = []
	
	var ends : Array[int] = []

	for dir in directions:
		for i in range(1, max_extent + 1):
			if i == max_extent:
				ends.push_back(i)
				break
			var cell_pos = pos + dir * i
			var cell_data : CellData = GridManager.get_cell_data(cell_pos)
			var occupant = cell_data.get_occupant()
			
			if occupant is CharacterObjectData:
				var destroy_action = DestroyAction.new(occupant, cell_pos)
				TurnManager.execute_action(destroy_action)
			elif occupant is MoveableObjectData or cell_data.get_type() == cell_data.cell_type.WALL:
				ends.push_back(i)
				break

func _drop_animation(is_drop: bool):
	super(is_drop)
	dropped = is_drop
