extends Node

var undo_stack : Array[Array] = []

func start_new_log():
	undo_stack.push_back([])

func record_action(action: Action):
	print(action.debug_action())
	undo_stack[-1].push_back(action)

func undo_last_action():
	if undo_stack.size() == 0:
		return
	var last_action_array : Array = undo_stack.pop_back()
	for action in last_action_array:
		action.undo()
