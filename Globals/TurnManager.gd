extends Node
# TurnManager

signal turn_ended
signal all_turns_ended
signal swap_action

var _turn_character_index := 0
var _turn_characters : Array[CharacterObjectData] = []
var _move_index := 0
var turn_active = false

var swaps_performed := 0:
	set(value):
		swaps_performed = value
		swap_action.emit()
	
var swaps_allowed := 2

func is_turn_active() -> bool:
	return turn_active

func start_new_turn():
	if turn_active:
		push_warning("turn already active")
		return
	_turn_character_index = 0
	_turn_characters = GridManager.get_sorted_characters()
	_move_index = 0
	turn_active = true

func skip_to(data: Dictionary):
	turn_active = true
	_turn_character_index = 0
	_turn_characters = GridManager.get_sorted_characters()
	_move_index = 0
	turn_active = true
	while(_turn_character_index < _turn_characters.size()):
		if _move_index == data.move_index and _turn_characters[_turn_character_index] == data.character:
			break
		if _move_index >= _turn_characters[_turn_character_index].command_array.size():
			_turn_character_index += 1
			_move_index = 0
		else:
			_move_index += 1

func advance_turn() -> bool:
	if not turn_active:
		push_warning("cannot advance turn as turn not formally started")
		return false
	
	if _turn_character_index >= _turn_characters.size():
		end_turn()
		return false

	var character : CharacterObjectData = _turn_characters[_turn_character_index]
	if _move_index >= character.command_array.size() or GridManager.get_object_grid_pos(character) == null:
		_turn_character_index += 1
		_move_index = 0
		if _turn_character_index >= _turn_characters.size():
			end_turn()
		return false

	ActionHistory.start_new_log(character)
	
	var turn_success : bool
	var command = character.command_array[_move_index]
	_move_index += 1
	var new_action : Action = character.run_command(command)
	if new_action:
		turn_success = execute_action(new_action)
		if turn_success:
			turn_ended.emit()
		return turn_success
	return false

func execute_action(action: Action):
	var action_success = action.execute()
	if action_success:
		ActionHistory.record_action(action)
	return action_success

func end_turn():
	all_turns_ended.emit()
	_move_index = 0
	_turn_character_index = 0
	turn_active = false

func reset():
	end_turn()
	swaps_performed = 0
