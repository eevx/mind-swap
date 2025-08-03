extends BaseGameObject
class_name BaseEnemy

@export var EnemyData : CharacterObjectData
@export var player_sprite : Sprite2D
@export var player_animated_sprite : AnimatedSprite2D

func register():
	EnemyData = EnemyData.duplicate()
	EnemyData.ref_to_node = self
	var world_pos = global_position
	GridManager.place_object_world(world_pos, EnemyData)
	#TODO
	rotation = Vector2(EnemyData.current_dir).angle() + PI/2
