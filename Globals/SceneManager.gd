extends Node

var _transition_active := false
var current_scene : Node = null
var transition_scene = preload("res://UI/scene_transition.tscn")

signal scene_changed

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
	scene_changed.emit()
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

func goto_next_level():
	var current_level = current_scene.scene_file_path
	if LevelArray.levels.has(current_level):
		goto_scene("res://Levels/level_complete.tscn", true)
		SfxManager.play_sfx("level_win")
		await scene_changed
		await get_tree().create_timer(1.).timeout
		var id : int= LevelArray.levels.find(current_level)
		var new_level_id = id + 1
		if LevelArray.levels.size() > new_level_id:
			if not LevelArray.levels[new_level_id].is_empty():
				goto_scene(LevelArray.levels[new_level_id])
				return
		goto_scene("res://Levels/level_select.tscn")
		return
	push_warning("failed to go to next level")
	return
