extends Area2D
class_name ClickableModule

var owner_data : CharacterObjectData
var index_in_array : int
var _clicked := false
var _mouse_offset := Vector2()
var _init_pos : Vector2
var current_type : int = 0

@export var command_sprite : Sprite2D
@export var indicator_sprite : Sprite2D
var _currently_indicated := false
var _prev_mouse_pos := Vector2.ZERO
var _tilt_amount : float = 0.

func _ready():
	_init_pos = position
	TurnManager.turn_ended.connect(_on_turn_ended)
	if indicator_sprite:
		indicator_sprite.hide()

func update_visual(type : int):
	command_sprite.frame = type
	current_type = type
	#$Label.text = CharacterObjectData.command_type.find_key(type)
	#$Label.text = $Label.text.replace("_", " ").capitalize()
	pass

func _process(delta):
	if _clicked:
		global_position = get_global_mouse_position() - _mouse_offset
		var mouse_vel = (get_global_mouse_position() - _prev_mouse_pos) / delta
		_tilt_amount = clamp(lerp(_tilt_amount, mouse_vel.x * 0.001, 0.1), -PI/6., PI/6.)
		rotation = 0 + _tilt_amount
	else:
		set_indicator()
	_prev_mouse_pos = get_global_mouse_position()

func _on_turn_ended():
	if _currently_indicated:
		var flash_tween = create_tween()
		flash_tween.tween_property(self, "modulate", Color(2, 2, 2), 0.1)
		flash_tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)

func set_indicator():
	if not indicator_sprite:
		return
	if TurnManager._turn_characters.size() > 0 and TurnManager._turn_character_index < TurnManager._turn_characters.size():
		if TurnManager._turn_characters[TurnManager._turn_character_index] == owner_data and TurnManager._move_index == index_in_array:
			indicator_sprite.show()
			_currently_indicated = true
		else:
			indicator_sprite.hide()
			_currently_indicated = false

func _unhandled_input(event):
	if event.is_action_released("left_click") and _clicked:
		_clicked = false
		var swap_attempt = get_overlapping_clickable()
		if swap_attempt:
			#var temp_command_type = owner_data.command_array[index_in_array]
			#owner_data.swap_command(swap_attempt.owner_data.command_array[swap_attempt.index_in_array], index_in_array)
			#swap_attempt.owner_data.swap_command(temp_command_type, swap_attempt.index_in_array)
			var swap_action : Action = SwapAction.new(\
			owner_data, swap_attempt.owner_data.command_array[swap_attempt.index_in_array], index_in_array,\
			swap_attempt.owner_data, owner_data.command_array[index_in_array], swap_attempt.index_in_array
			)
			#var swap_action_2 : Action = SwapAction.new(swap_attempt.owner_data, temp_command_type, swap_attempt.index_in_array)
			#TurnManager.execute_action(swap_action_1)
			TurnManager.execute_action(swap_action)
			bounce()
			swap_attempt.bounce()
		reset()

func reset():
	position = _init_pos
	z_index = 2
	rotation = 0

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
		if TurnManager.swaps_performed >= TurnManager.swaps_allowed:
			SfxManager.play_sfx("error", -5.)
			LevelCamera.camera_shake(0.2)
			return
		SfxManager.play_sfx("hover", -7.)
		_clicked = true
		_mouse_offset = get_global_mouse_position() - global_position
		get_viewport().set_input_as_handled()
		z_index = 5

func _on_mouse_entered():
	command_sprite.frame = current_type + 5
	scale = Vector2.ONE * 1.1
	SfxManager.play_sfx("hover", -10., randf_range(0.9, 1.1))


func _on_mouse_exited():
	update_visual(current_type)
	scale = Vector2.ONE

func bounce():
	scale = Vector2.ONE * 0.5
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
