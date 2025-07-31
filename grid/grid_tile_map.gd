extends Node2D

func _ready() -> void:
	var enemy_template: GameObjectData = preload("res://Resource/enemy.tres")
	var enemy_data: GameObjectData = enemy_template.duplicate(true)  # deep copy for a fresh instance
	enemy_data.id = "enemy_1_variant"  # optionally override
