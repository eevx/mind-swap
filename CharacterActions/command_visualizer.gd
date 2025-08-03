extends Node2D
class_name CommandRowVisualizer

var ref_to_data : CharacterObjectData
@export var clickable_module : PackedScene
@export var line : Line2D
var module_array : Array[ClickableModule]

func _ready():
	if not ref_to_data:
		queue_free()
		return
	ref_to_data.command_array_changed.connect(update_visuals)
	var num = ref_to_data.command_array.size()
	var total_length = (GlobalVariables.GRID_CELL_SIZE.x + 4) * (num)
	var start_pos = -float(total_length)/2.
	for i in range(num):
		var new_pos := Vector2(start_pos + (GlobalVariables.GRID_CELL_SIZE.x + 4) * i + GlobalVariables.GRID_CELL_SIZE.x / 2., 0)
		var new_clickable : ClickableModule = clickable_module.instantiate()
		new_clickable.index_in_array = i
		new_clickable.position = new_pos
		new_clickable.owner_data = ref_to_data
		module_array.push_back(new_clickable)
		add_child(new_clickable)
	update_visuals()

func _process(_delta):
	if not ref_to_data or not line:
		return
	
	if ref_to_data.command_array.size() == 0:
		hide()

	#var clock_position = (Vector2.UP * get_window().get_visible_rect().size.y / 3.).rotated((ref_to_data.turn_order + 1) * PI/2.)
	#global_position = clock_position
	#line.set_point_position(0, line.to_local(ref_to_data.ref_to_node.global_position))
	#line.set_point_position(1, line.to_local(clock_position))
	
	var ordered_position = Vector2.RIGHT * get_window().get_visible_rect().size.x / 3. + Vector2.UP * (get_window().get_visible_rect().size.y * (0.5 - (ref_to_data.turn_order + 1) * 0.2))
	global_position = ordered_position
	line.set_point_position(0, line.to_local(ref_to_data.ref_to_node.global_position))
	line.set_point_position(1, line.to_local(ordered_position))
	
func update_visuals():
	var i := 0
	for clickable in module_array:
		clickable.update_visual(ref_to_data.command_array[i])
		i += 1
