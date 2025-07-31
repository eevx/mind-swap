extends Node
class_name TurnManager

enum Phase { START, ACTION, RESOLVE, END }

var turn_order: Array = []  # list of owner identifiers or actor IDs
var current_index: int = 0
var phase: int = Phase.START

signal turn_started(current_player)
signal action_executed(action)
signal turn_ended(current_player)

func start_turns(order: Array) -> void:
	turn_order = order.duplicate()
	current_index = 0
	_begin_current_turn()

func _begin_current_turn() -> void:
	var current_player = turn_order[current_index]
	phase = Phase.START
	emit_signal("turn_started", current_player)
	phase = Phase.ACTION

func execute_action(action) -> void:
	if phase != Phase.ACTION:
		return
	if action.validate():
		action.execute()
		emit_signal("action_executed", action)
		phase = Phase.RESOLVE
		# resolve effects...
		phase = Phase.END
		_end_current_turn()
	else:
		push_warning("Invalid action attempted: %s" % action)

func _end_current_turn() -> void:
	var finished_player = turn_order[current_index]
	emit_signal("turn_ended", finished_player)
	current_index = (current_index + 1) % turn_order.size()
	_begin_current_turn()
