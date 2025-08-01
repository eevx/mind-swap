extends Node
# TurnManager

signal all_turns_ended

var _turn_character_index := 0
var _turn_characters : Array[CharacterObjectData] = []
var _move_index := 0
var turn_active = false

func start_new_turn():
	if turn_active:
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

func advance_turn():
	if not turn_active:
		return
	
	if _turn_character_index >= _turn_characters.size():
		end_turn()
		return

	var character : CharacterObjectData = _turn_characters[_turn_character_index]
	if _move_index >= character.command_array.size() or GridManager.get_object_grid_pos(character) == null:
		_turn_character_index += 1
		_move_index = 0
		advance_turn()
		return

	ActionHistory.start_new_log(character)
	
	var command = character.command_array[_move_index]
	var new_action : Action = character.run_command(command)
	if new_action:
		execute_action(new_action)
		#print(new_action.debug_action())

	_move_index += 1

func execute_action(action: Action):
	var action_success = action.execute()
	if action_success:
		ActionHistory.record_action(action)
	return action_success

func end_turn():
	all_turns_ended.emit()
	turn_active = false
