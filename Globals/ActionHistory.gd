extends Node

var undo_stack : Array[Array] = []

func reset_stack():
	undo_stack.clear()

func start_new_log(character : CharacterObjectData = null):
	undo_stack.push_back([])
	if character:
		undo_stack[-1].push_back({"character": character, "move_index": TurnManager._move_index})

func record_action(action: Action):
	print(action.debug_action())
	if undo_stack.size() == 0 or action is SwapAction:
		start_new_log()
	undo_stack[-1].push_back(action)

func undo_last_action():
	if undo_stack.size() == 0:
		return
	var last_action_array : Array = undo_stack.pop_back()
	
	var skip_pos : Dictionary = {}
	for data in last_action_array:
		if data is Action:
			prints("UNDO", data.debug_action())
			data.undo()
		if data is Dictionary:
			skip_pos = data
	
	if not skip_pos.is_empty():
		TurnManager.skip_to(skip_pos)
