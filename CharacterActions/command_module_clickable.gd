extends Area2D
class_name ClickableModule

var owner_data : CharacterObjectData
var index_in_array : int
var _clicked := false
var _mouse_offset := Vector2()
var _init_pos : Vector2

func _ready():
	_init_pos = position

func update_visual(type : int):
	pass

func _process(_delta):
	if _clicked:
		global_position = get_global_mouse_position() - _mouse_offset

func _unhandled_input(event):
	if event.is_action_released("left_click") and _clicked:
		_clicked = false
		var swap_attempt = get_overlapping_clickable()
		if swap_attempt:
			if swap_attempt.owner_data == owner_data:
				pass
			else:
				var temp_command_type = owner_data.command_array[index_in_array]
				owner_data.swap_command(swap_attempt.owner_data.command_array[swap_attempt.index_in_array], index_in_array)
				swap_attempt.owner_data.swap_command(temp_command_type, swap_attempt.index_in_array)
	reset()

func reset():
	position = _init_pos

func get_overlapping_clickable() -> ClickableModule:
	var space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.collide_with_areas = true
	point_query.collide_with_bodies = false
	point_query.position = get_global_mouse_position()
	var result = space_state.intersect_point(point_query)
	for r in result:
		if r.collider is ClickableModule and r.collider != self:
			return r.collider
	return null

func _on_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed("left_click"):
		_clicked = true
		_mouse_offset = get_global_mouse_position() - global_position
