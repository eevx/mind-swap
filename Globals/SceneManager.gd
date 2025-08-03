extends Node

var _transition_active := false
var current_scene : Node = null
var transition_scene = preload("res://UI/scene_transition.tscn")

func _ready():
	current_scene = get_tree().current_scene

func goto_scene(file_path : String, is_transition := true):
	call_deferred("deferred_goto_scene", file_path, is_transition)

func deferred_goto_scene(file_path : String, is_transition := true):
	if _transition_active:
		push_warning("attempted to interrupt transition")
		return
	
	var s := ResourceLoader.load(file_path)
	if s == null:
		push_warning(file_path, " file path does not exist")
		return
	
	_transition_active = true
	
	if is_transition:
		var transition := add_transition(1)
		await transition.transition_finished
		
	GridManager.clear_chunks()
	TurnManager.reset()
	ActionHistory.reset_stack()
	
	if current_scene != null:
		current_scene.free()
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	
	if is_transition:
		var transition := add_transition(0)
		await transition.transition_finished
	
	_transition_active = false
	get_tree().current_scene = current_scene

func reload_scene(is_transition := true):
	goto_scene(current_scene.scene_file_path, is_transition)

##mode 0: fade in, mode 1: fade out
func add_transition(mode: int) -> SceneTransition:
	if transition_scene.can_instantiate():
		var new_transition_scene : SceneTransition = transition_scene.instantiate()
		match mode:
			0:
				new_transition_scene.fade_in()
			1:
				new_transition_scene.fade_out()
		get_tree().root.add_child(new_transition_scene)
		return new_transition_scene
	return null
