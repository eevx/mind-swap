extends AudioStreamPlayer
class_name AudioPlayerOneshot

func _on_finished() -> void:
	queue_free()
