extends Node

var _transition_active := false
var current_scene : Node = null
var transition_scene = preload("res://UI/scene_transition.tscn")

func _ready():
	current_scene = get_tree().current_scene

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		reload_scene(false)

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
	
	GridManager.clear_chunks()
	TurnManager.end_turn()
	ActionHistory.reset_stack()
	
	if is_transition:
		var transition := add_transition(1)
		await transition.transition_finished
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

#var current_scene = null
#var next_room : String
#var saved_room_path : String

#func _ready():
	#
	#powerups.resize(num_of_powerups)
	#saved_powerup_state.resize(num_of_powerups)
	#powerups.fill(false)
	#
	#var root = get_tree().root
	#current_scene = root.get_child(get_child_count() - 1)
	#saved_room_path = current_scene.scene_file_path
#
#func _process(_delta):
	#if Input.is_action_just_pressed("reload"):
		#goto_scene(saved_room_path, "checkpoint")
#
#func goto_scene(path, room_from_to : String = ""):
	#next_room = room_from_to 
	#print("loading " + path)
	#call_deferred("deferred_goto_scene", path)
#
#func reload_save():
	#player_max_hp = saved_max_hp
	#current_gun_state = saved_gun_state
	#current_double_jump_state = saved_double_jump_state
	#current_slide_state = saved_slide_state
	#current_wall_jump_state = saved_wall_jump_state
	#powerups = saved_powerup_state.duplicate()
	#
	#player_hp = int(player_max_hp / 1.5)
	#player_velocity = Vector2()
	#player_direction = 0
	#
	#goto_scene(saved_room_path, "checkpoint")
#
#func deferred_goto_scene(path):
	#var s = ResourceLoader.load(path)
	#if s == null:
		#goto_scene(current_scene.scene_file_path)
		#return
	#if current_scene != null:
		#current_scene.free()
	#current_scene = s.instantiate()
	#get_tree().root.add_child(current_scene)
	#get_tree().current_scene = current_scene
	#var player = current_scene.get_node_or_null("Player")
	#if player != null:
		#set_variables(player)
		#var entry_point = current_scene.get_node_or_null(next_room)
		#if not entry_point == null:
			#player.global_position = current_scene.get_node(next_room).global_position
		#current_scene.get_node("Camera").global_position = player.global_position
	#var checkpoint = current_scene.get_node_or_null("checkpoint")
	#if checkpoint is CheckPoint and saved_room_path == current_scene.scene_file_path:
		#checkpoint.get_node("AnimationPlayer").play("active")
#
#func set_variables(player : Player):
	#player.hp = player_hp
	#player.max_hp = player_max_hp
	#player.velocity = player_velocity
	#player.get_node("AnimatedSprite2D").flip_h = false if player_direction == 0 else true
	#
	#player.has_gun = current_gun_state
	#player.has_double_jump = current_double_jump_state
	#player.has_slide = current_slide_state
	#player.has_wall_jump = current_wall_jump_state
	#
