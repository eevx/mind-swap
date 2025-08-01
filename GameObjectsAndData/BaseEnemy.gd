extends BaseGameObject
class_name BaseEnemy

@export var EnemyData : CharacterObjectData

func _ready():
	register()

func register():
	EnemyData.ref_to_node = self
	var world_pos = global_position
	GridManager.place_object_world(world_pos, EnemyData)
