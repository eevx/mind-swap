extends Node
# TurnManager

signal turn_ended

var _turn_character_index := 0
var _turn_characters : Array[CharacterObjectData] = []
var _move_index := 0
var recorded_moves : Array[Array] = [] #array of simultaneous moves
var turn_active = false

func start_new_turn():
	if turn_active:
		return
	_turn_character_index = 0
	_turn_characters = GridManager.get_sorted_characters()
	_move_index = 0
	turn_active = true
	recorded_moves.clear()

func advance_turn():
	if not turn_active:
		return
	
	if _turn_character_index >= _turn_characters.size():
		end_turn()
		return

	var character : CharacterObjectData = _turn_characters[_turn_character_index]

	if _move_index >= character.command_array.size() or not GridManager.get_object_grid_pos(character):
		_turn_character_index += 1
		_move_index = 0
		advance_turn()
		return
	
	ActionHistory.start_new_log()
	
	var command = character.command_array[_move_index]
	var new_action : Action = character.run_command(command)
	if new_action:
		execute_action(new_action)
		#print(new_action.debug_action())

	_move_index += 1

func execute_action(action: Action):
	if action.execute():
		ActionHistory.record_action(action)
		return true
	else:
		return false

func end_turn():
	turn_ended.emit()
	turn_active = false
