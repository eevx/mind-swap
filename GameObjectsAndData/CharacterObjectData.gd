extends GameObjectData
class_name CharacterObjectData

enum command_type {MOVE_FORWARD, TURN_LEFT_90, TURN_RIGHT_90, TURN_180}

@export var command_array : Array[command_type]
@export var current_dir := Vector2i(1, 0)
@export var hp := 1
@export var turn_order := 0

func run_command(command: command_type) -> Action:
	var grid_pos = GridManager.get_object_grid_pos(self) 
	var action : Action
	match command:
		command_type.MOVE_FORWARD:
			action = MoveAction.new(self, grid_pos, grid_pos + current_dir)
		command_type.TURN_LEFT_90:
			action = TurnAction.new(self, current_dir, Vector2i(current_dir.y, -current_dir.x))
		command_type.TURN_RIGHT_90:
			action = TurnAction.new(self, current_dir, Vector2i(-current_dir.y, current_dir.x))
		command_type.TURN_180:
			action = TurnAction.new(self, current_dir, -current_dir)
		_:
			pass
	if action:
		action.execute()
		UndoManager.push_action(action)
	return action
