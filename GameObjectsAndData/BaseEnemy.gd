extends BaseGameObject
class_name BaseEnemy

@export var EnemyData : CharacterObjectData

func register():
	EnemyData = EnemyData.duplicate()
	EnemyData.ref_to_node = self
	var world_pos = global_position
	GridManager.place_object_world(world_pos, EnemyData)
	#TODO
	z_index = 1
	rotation = Vector2(EnemyData.current_dir).angle() + PI/2
