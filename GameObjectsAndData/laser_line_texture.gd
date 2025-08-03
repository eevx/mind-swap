extends Line2D
class_name LaserLine

@export var particles : CPUParticles2D
var hitting := true

func _process(_delta):
	particles.visible = hitting
	particles.direction = get_point_position(1).direction_to(get_point_position(0))
	particles.position = get_point_position(1)
