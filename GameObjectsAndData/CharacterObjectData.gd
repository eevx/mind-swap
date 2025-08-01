extends GameObjectData
class_name CharacterObjectData

enum command_type {MOVE_FORWARD, TURN_LEFT_90, TURN_RIGHT_90, TURN_180, SHOOT}

@export var command_array : Array[command_type]
@export var current_dir := Vector2i(1, 0)
@export var hp := 1
@export var turn_order := 0

signal command_array_changed

#func swap_command(type : command_type, index: int):
	#if index >= command_array.size():
		#return
	#command_array[index] = type
	#command_array_changed.emit()
	#print("command swapped for ", ref_to_node, " at index ", index)

func run_command(command: command_type) -> Action:
	var grid_pos = GridManager.get_object_grid_pos(self) 
	var action : Action = null
	match command:
		command_type.MOVE_FORWARD:
			action = MoveAction.new(self, grid_pos, grid_pos + current_dir)
		command_type.TURN_LEFT_90:
			action = TurnAction.new(self, current_dir, Vector2i(current_dir.y, -current_dir.x))
		command_type.TURN_RIGHT_90:
			action = TurnAction.new(self, current_dir, Vector2i(-current_dir.y, current_dir.x))
		command_type.TURN_180:
			action = TurnAction.new(self, current_dir, -current_dir)
		command_type.SHOOT:
			action = ShootAction.new(self, grid_pos)
		_:
			pass

	return action
