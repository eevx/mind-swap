extends Node2D
class_name CommandRowVisualizer

var ref_to_data : CharacterObjectData
@export var clickable_module : PackedScene
var module_array : Array[ClickableModule]

func _ready():
	if not ref_to_data:
		queue_free()
		return
	ref_to_data.command_array_changed.connect(update_visuals)
	var num = ref_to_data.command_array.size()
	var total_length = (GlobalVariables.GRID_CELL_SIZE.x + 2) * (num)
	var start_pos = -float(total_length)/2.
	for i in range(num):
		var new_pos := Vector2(start_pos + (GlobalVariables.GRID_CELL_SIZE.x + 2) * i + GlobalVariables.GRID_CELL_SIZE.x / 2., 0)
		var new_clickable : ClickableModule = clickable_module.instantiate()
		new_clickable.index_in_array = i
		new_clickable.position = new_pos
		new_clickable.owner_data = ref_to_data
		module_array.push_back(new_clickable)
		add_child(new_clickable)
	update_visuals()

func update_visuals():
	var i := 0
	for clickable in module_array:
		clickable.update_visual(ref_to_data.command_array[i])
		i += 1
