extends MoveableBox
class_name MoveableBoxLaser

enum laser_type {VERTICAL, HORIZONTAL}

@export var laser_direction : laser_type

@export var vertical_sprite : Sprite2D
@export var horizontal_sprite : Sprite2D

func _ready():
	super()
	TurnManager.turn_ended.connect(_laser_effect)
	if laser_direction == laser_type.VERTICAL:
		horizontal_sprite.hide()
	else:
		vertical_sprite.hide()

func _laser_effect():
	if not object_data:
		return
	
	var pos = GridManager.get_object_grid_pos(object_data)
	if not pos:
		return
	var max_extent := 40
	var directions := []
	match laser_direction:
		laser_type.VERTICAL: directions = [Vector2i.UP, Vector2i.DOWN]
		laser_type.HORIZONTAL: directions = [Vector2i.LEFT, Vector2i.RIGHT]
		_: directions = []

	for dir in directions:
		for i in range(1, max_extent + 1):
			var cell_pos = pos + dir * i
			var cell_data : CellData = GridManager.get_cell_data(cell_pos)
			if cell_data == null:
				break
			var occupant = cell_data.get_occupant()
			
			if occupant is CharacterObjectData:
				var destroy_action = DestroyAction.new(occupant, cell_pos)
				TurnManager.execute_action(destroy_action)
			elif occupant is MoveableObjectData or cell_data.get_type() == cell_data.cell_type.WALL:
				break
