extends Resource
class_name GameObjectData

@export var id: String = ""
@export var type: String = ""
@export var owner: String = ""
@export var hp: int = 100
@export var custom: Dictionary = {}  # arbitrary extra data

# runtime-only reference to a visual instance (not serialized if you clear before save)
var instance: Node = null

signal data_changed  # for views / systems to react

# Mutators must emit signal so observers update
func apply_damage(amount: int) -> void:
	hp = max(0, hp - amount)
	emit_signal("data_changed", self)

func set_custom(key: String, value) -> void:
	custom[key] = value
	emit_signal("data_changed", self)

func set_owner(new_owner: String) -> void:
	owner = new_owner
	emit_signal("data_changed", self)
