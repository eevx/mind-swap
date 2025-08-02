extends CanvasLayer
class_name LevelManager

@export var timer : Timer
@export var command_visualizer_scene : PackedScene
@export var level_select_scene_path : String
var visualizers : Array[CommandRowVisualizer]

enum level_state {PLAY, PAUSE}
var current_state : level_state 

func _ready():
	timer.wait_time = GlobalVariables.TIME_STEP
	timer.timeout.connect(_next_turn)
	
	await get_tree().process_frame
	setup_command_visualizers()
	state_transition_to(level_state.PLAY)

func _process(_delta):
	state_process()

func state_process():
	match current_state: #state process
		level_state.PLAY:
			pass
		level_state.PAUSE:
			pass

func state_transition_to(new_state : level_state):
	if current_state == new_state:
		push_warning("changed to same state")
	match current_state: #state exit
		level_state.PLAY:
			pass
		level_state.PAUSE:
			pass
	
	match new_state: #state enter
		level_state.PLAY:
			timer.start()
			hide_command_visualizers()
			pass
		level_state.PAUSE:
			timer.stop()
			show_command_visualizers()
			pass
	current_state = new_state

func setup_command_visualizers():
	var char_array = GridManager.get_sorted_characters()
	if not command_visualizer_scene.can_instantiate():
		return
	for c in char_array:
		var new_visualizer : CommandRowVisualizer = command_visualizer_scene.instantiate()
		new_visualizer.ref_to_data = c
		new_visualizer.global_position = GridManager.grid_to_world(GridManager.get_object_grid_pos(c)) + Vector2.UP * 20
		c.ref_to_node.add_child(new_visualizer)
		visualizers.push_back(new_visualizer)
	hide_command_visualizers()

func show_command_visualizers():
	for v in visualizers:
		v.show()

func hide_command_visualizers():
	for v in visualizers:
		v.hide()

func _on_scrub_left_button_down():
	if current_state != level_state.PAUSE:
		state_transition_to(level_state.PAUSE)
	for v in visualizers:
		v.show()
	ActionHistory.undo_last_action()

func _on_play_pause_button_down():
	match current_state: 
		level_state.PLAY:
			state_transition_to(level_state.PAUSE)
		level_state.PAUSE:
			state_transition_to(level_state.PLAY)

func _on_scrub_right_button_down():
	if current_state != level_state.PAUSE:
		state_transition_to(level_state.PAUSE)
	show_command_visualizers()
	if not TurnManager.is_turn_active():
		TurnManager.start_new_turn()
	TurnManager.advance_turn()

func _next_turn(continue_if_failed := true):
	if not current_state == level_state.PLAY:
		return
	
	if not TurnManager.is_turn_active():
		TurnManager.start_new_turn()
	
	var turn_success := TurnManager.advance_turn()
	if not turn_success and continue_if_failed:
		await get_tree().create_timer(GlobalVariables.TIME_STEP/2.).timeout
		_next_turn()
	else:
		timer.start()


func _on_back_button_down():
	if not level_select_scene_path.is_empty():
		SceneManager.goto_scene(level_select_scene_path)


func _on_reload_button_down():
	SceneManager.reload_scene()
