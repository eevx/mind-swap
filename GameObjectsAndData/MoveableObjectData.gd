extends GameObjectData
class_name MoveableObjectData

func _init() -> void:
	TurnManager.turn_ended.connect(_on_turn_ended)

func _on_turn_ended():
	apply_cell_effect()

func apply_cell_effect():
	var pos = GridManager.get_object_grid_pos(self)
	if pos == null:
		return
	var cell_data : CellData = GridManager.get_cell_data(pos)
	var action : Action
	if cell_data:
		if cell_data.get_type() == cell_data.cell_type.DANGER:
			action = DropAction.new(self, pos)
	if action:
		TurnManager.execute_action(action)
