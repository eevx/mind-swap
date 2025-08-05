extends BaseGameObject
class_name BaseEnemy

@export var EnemyData : CharacterObjectData
@export var player_sprite : Sprite2D
@export var player_animated_sprite : AnimatedSprite2D
@export var shoot_scene : PackedScene
@export var indicator : Node2D

var animation_tween : Tween

func _process(_delta: float) -> void:
	set_indicator()

func set_indicator():
	if not indicator:
		return
	if TurnManager._turn_characters.size() > 0 and TurnManager._turn_character_index < TurnManager._turn_characters.size():
		if TurnManager._turn_characters[TurnManager._turn_character_index].ref_to_node == self:
			indicator.show()
		else:
			indicator.hide()

func register():
	EnemyData = EnemyData.duplicate()
	EnemyData.ref_to_node = self
	var world_pos = global_position
	GridManager.place_object_world(world_pos, EnemyData)

func register_animations():
	_animation_library = {
		"turn": func(args): _turn_animation(args[0], args[1]),
		"move": func(args): _move_animation(args[0], args[1]),
		"death": func(args): _death_animation(args[0]),
		"shoot": func(args): _shoot_animation(args[0], args[1])
	}
	queue_animation("turn", [Vector2i(1, 0), EnemyData.current_dir])

func _turn_animation(from_dir : Vector2i, to_dir : Vector2i):
	player_sprite.show()
	player_animated_sprite.hide()
	if animation_tween:
		animation_tween.kill()
	
	var get_custom_angle = func(vec: Vector2) -> float:
		if vec == Vector2.ZERO:
			return 0.0
		var angle = vec.angle()  # CCW from RIGHT (0 rad)
		angle = fmod(-angle + PI/2 + TAU, TAU)  # Flip to CW and shift so DOWN is 0
		return angle


	
	var from_angle = (get_custom_angle.call(Vector2(from_dir)))
	var to_angle = (get_custom_angle.call(Vector2(to_dir)))
	
	var from_frame = int(round(12 * from_angle / (2*PI))) % 12
	var to_frame = int(round(12 * to_angle / (2*PI))) % 12
	
	player_sprite.frame = from_frame
	animation_tween = create_tween()
	animation_tween.tween_property(player_sprite, "frame", to_frame, GlobalVariables.ANIMATION_TIME_STEP)
	animation_tween.tween_callback(func(): animation_done())

func _move_animation(from_pos : Vector2i, to_pos : Vector2i):
	player_sprite.show()
	player_animated_sprite.hide()
	if animation_tween:
		animation_tween.kill()

	
	var from = GridManager.grid_to_world(from_pos)
	var to = GridManager.grid_to_world(to_pos)
	
	global_position = from
	animation_tween = create_tween()
	animation_tween.tween_property(self, "global_position", to, GlobalVariables.ANIMATION_TIME_STEP).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	animation_tween.set_parallel(false).tween_callback(func(): animation_done())

func _death_animation(is_show: bool):
	player_animated_sprite.show()
	player_sprite.hide()
	if animation_tween:
		animation_tween.kill()
	
	var custom_speed = max(0.5 / GlobalVariables.ANIMATION_TIME_STEP, 1.0)
	match EnemyData.current_dir:
		Vector2i.UP:
			player_animated_sprite.play("death_up", custom_speed)
			await player_animated_sprite.animation_finished
			if is_show: player_animated_sprite.frame = 0
		Vector2i.DOWN:
			player_animated_sprite.play("death_down", custom_speed)
			await player_animated_sprite.animation_finished
			if is_show: player_animated_sprite.frame = 0
		Vector2i.LEFT:
			player_animated_sprite.play("death_left", custom_speed)
			await player_animated_sprite.animation_finished
			if is_show: player_animated_sprite.frame = 0
		Vector2i.RIGHT:
			player_animated_sprite.play("death_right", custom_speed)
			await player_animated_sprite.animation_finished
			if is_show: player_animated_sprite.frame = 0
	visible = is_show
	animation_done()
	
func _shoot_animation(from_pos : Vector2i, to_pos : Vector2i):
	player_animated_sprite.show()
	player_sprite.hide()
	if animation_tween:
		animation_tween.kill()
	
	if shoot_scene.can_instantiate():
		var new_shoot_scene : ShootBurst = shoot_scene.instantiate()
		var start = GridManager.grid_to_world(from_pos)
		var end = GridManager.grid_to_world(to_pos)
		new_shoot_scene.start_pos = start + EnemyData.current_dir * GlobalVariables.GRID_CELL_SIZE/2.
		new_shoot_scene.end_pos = end + Vector2i.UP * GlobalVariables.GRID_CELL_SIZE/2.
		new_shoot_scene.time = GlobalVariables.ANIMATION_TIME_STEP
		add_child(new_shoot_scene)
		
	var custom_speed = max(0.5 / GlobalVariables.ANIMATION_TIME_STEP, 1.0)
	match EnemyData.current_dir:
		Vector2i.UP:
			player_animated_sprite.play("shoot_up", custom_speed)
			await player_animated_sprite.animation_finished
		Vector2i.DOWN:
			player_animated_sprite.play("shoot_down", custom_speed)
			await player_animated_sprite.animation_finished
		Vector2i.LEFT:
			player_animated_sprite.play("shoot_left", custom_speed)
			await player_animated_sprite.animation_finished
		Vector2i.RIGHT:
			player_animated_sprite.play("shoot_right", custom_speed)
			await player_animated_sprite.animation_finished
		_:
			pass
	animation_done()
