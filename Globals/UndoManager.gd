extends Node

# Stack to keep history of actions (only undo, no redo)
var undo_stack: Array = []

# Record and push an action (typically the one returned by run_command)
func push_action(action: Action) -> void:
	if action:
		undo_stack.append(action)

# Undo the most recent action
func undo():
	if undo_stack.is_empty():
		return  # nothing to undo
	var action: Action = undo_stack.pop_back()  # pop last
	action.undo()  # perform its undo logic
